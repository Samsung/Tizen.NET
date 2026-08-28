# DOTNET_VERSION
#
# Resolved immediately from the caller or, when unset, from Versions.props.
#
# This used to be cached in $(TMPDIR)/dotnet-version.config with Versions.props as its only
# prerequisite. Because the cache file was then newer than Versions.props, make never
# regenerated it, so a DIFFERENT DOTNET_VERSION passed into an existing tree was ignored and
# the previous band's value was reused - silently building/testing the wrong band.
ifeq ($(strip $(DOTNET_VERSION)),)
DOTNET_VERSION := $(shell grep -oE '<MicrosoftDotnetSdkInternalPackageVersion>[^<]+' $(TOP)/build/Versions.props | sed 's/.*>//')
endif

# TizenFX API versions per API level — auto-extracted from Versions.props (SSOT)
-include $(TMPDIR)/tizen-fx-api-versions.config
$(TMPDIR)/tizen-fx-api-versions.config: $(TOP)/build/Versions.props
	@mkdir -p $(TMPDIR)
	@grep -oE '<TizenFXAPI[0-9]+Version>[^<]+' build/Versions.props \
	  | sed -E 's/<TizenFXAPI([0-9]+)Version>/TizenFXAPI\1Version=/' > $@

$(info DOTNET_VERSION is.. $(DOTNET_VERSION))

# NOTE: do not add a parse-time guard for an empty DOTNET_VERSION here. The value arrives
# via `-include $(TMPDIR)/dotnet-version.config`, and on make's first parse pass (before it
# regenerates that file and restarts) DOTNET_VERSION is legitimately empty.
# Pass DOTNET_VERSION through the environment or omit it entirely; an explicit empty
# command-line override (make DOTNET_VERSION=) wins over the generated file and yields an
# empty band.

DOTNET_VERSION_BAND = $(firstword $(subst -, ,$(DOTNET_VERSION)))

IS_PRERELEASE=$(findstring -,$(DOTNET_VERSION))
IS_RTM=$(findstring -rtm,$(DOTNET_VERSION))
VERSIONS=$(shell echo $(DOTNET_VERSION) | tr "." "\n")
ifneq ($(IS_PRERELEASE),)
	VERSIONS := $(shell echo $(VERSIONS) | tr "-" "\n")
endif

MAJOR = $(word 1,$(VERSIONS))
MINOR = $(word 2,$(VERSIONS))
MICRO = $(word 3,$(VERSIONS))
# Feature band: the patch component rounded down to the nearest hundred (404 -> 400).
BAND = $(shell echo "$(MICRO)" | cut -c1)00

PRERELEASE = $(word 4,$(VERSIONS))
PRERELEASE_VERSION = $(word 5,$(VERSIONS))

# DOTNET_DESTDIR
ifeq ($(DESTDIR),)
	# Keyed by the FULL SDK version, not the feature band. Band-keying meant 10.0.100 and
	# 10.0.101 (or two different previews of one band) shared a bootstrap directory, so the
	# second request silently reused the first SDK and tested the wrong build. Manifest
	# paths stay band-based below, which is what the SDK itself expects.
	DOTNET_DESTDIR = $(OUTDIR)/dotnet-$(DOTNET_VERSION)
else
	DOTNET_DESTDIR = $(abspath $(DESTDIR))
endif

ifeq ($(MAJOR),6)
	DOTNET_VERSION_BAND := $(MAJOR).$(MINOR).$(BAND)
	DOTNET6_MANIFESTS_DESTDIR := $(MAJOR).$(MINOR).$(BAND)
	DOTNET_MANIFESTS_DESTDIR = $(DOTNET_DESTDIR)/sdk-manifests/$(DOTNET6_MANIFESTS_DESTDIR)/samsung.net.sdk.tizen
else
	ifneq ($(IS_PRERELEASE),)
		ifneq ($(IS_RTM),)
			DOTNET_VERSION_BAND := $(MAJOR).$(MINOR).$(BAND)-$(PRERELEASE)
		else
			DOTNET_VERSION_BAND := $(MAJOR).$(MINOR).$(BAND)-$(PRERELEASE).$(PRERELEASE_VERSION)
		endif
	else
		DOTNET_VERSION_BAND := $(MAJOR).$(MINOR).$(BAND)
	endif
	DOTNET_MANIFESTS_DESTDIR = $(DOTNET_DESTDIR)/sdk-manifests/$(DOTNET_VERSION_BAND)/samsung.net.sdk.tizen
endif


# TIZEN_WORKLOAD_VERSION
-include $(TMPDIR)/workload-version.config
$(TMPDIR)/workload-version.config: $(TOP)/build/Versions.props
	@mkdir -p $(TMPDIR)
	@grep "<TizenWorkloadVersion>" build/Versions.props | sed -e 's/<\/*TizenWorkloadVersion>//g' -e 's/[ \t]*/TIZEN_WORKLOAD_VERSION=/' > $@

TIZEN_VERSION_BLAME_COMMIT := $(shell git blame $(TOP)/build/Versions.props HEAD | grep "<TizenWorkloadVersion>" | sed 's/ .*//')
TIZEN_COMMIT_DISTANCE := $(shell git log $(TIZEN_VERSION_BLAME_COMMIT)..HEAD --oneline | wc -l)

CURRENT_HASH := $(shell git log -1 --pretty=%h)

# BRANCH_NAME
ifeq ($(BRANCH_NAME),)
	CURRENT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
else
	CURRENT_BRANCH := $(BRANCH_NAME)
endif

# PRERELEASE_TAG, PULLREQUEST_ID
ifneq ($(PRERELEASE_TAG),)
	PRERELEASE_VERSION := $(PRERELEASE_TAG)
else
	ifneq ($(PULLREQUEST_ID),)
		PRERELEASE_VERSION := ci.pr.gh$(PULLREQUEST_ID)
	else
		PRERELEASE_VERSION := ci.$(CURRENT_BRANCH)
	endif
endif

TIZEN_WORKLOAD_VERSION_FULL := $(TIZEN_WORKLOAD_VERSION)
