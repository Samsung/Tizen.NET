# DOTNET_VERSION
-include $(TMPDIR)/dotnet-version.config
$(TMPDIR)/dotnet-version.config: $(TOP)/build/Versions.props
	@mkdir -p $(TMPDIR)
	@grep "<MicrosoftDotnetSdkInternalPackageVersion>" build/Versions.props | sed -e 's/<\/*MicrosoftDotnetSdkInternalPackageVersion>//g' -e 's/[ \t]*/DOTNET_VERSION=/' > $@
DOTNET_VERSION_BAND = $(firstword $(subst -, ,$(DOTNET_VERSION)))

IS_PRERELEASE=$(findstring -,$(DOTNET_VERSION))
VERSIONS=$(shell echo $(DOTNET_VERSION) | tr "." "\n")
ifneq ($(IS_PRERELEASE),)
	VERSIONS := $(shell echo $(VERSIONS) | tr "-" "\n")
endif

MAJOR = $(word 1,$(VERSIONS))
MINOR = $(word 2,$(VERSIONS))
MICRO = $(word 3,$(VERSIONS))
BAND := $(shell echo "${MICRO}" |  cut -c1)00

PRERELEASE = $(word 4,$(VERSIONS))
PRERELEASE_VERSION = $(word 5,$(VERSIONS))

# DOTNET_DESTDIR
ifeq ($(DESTDIR),)
	DOTNET_DESTDIR = $(OUTDIR)/dotnet
else
	DOTNET_DESTDIR = $(abspath $(DESTDIR))
endif

ifeq ($(MAJOR),6)
	DOTNET6_MANIFESTS_DESTDIR := $(MAJOR).$(MINOR).$(BAND)
	DOTNET_MANIFESTS_DESTDIR := $(DOTNET_DESTDIR)/sdk-manifests/$(DOTNET6_MANIFESTS_DESTDIR)/samsung.net.sdk.tizen
else
	DOTNET7_MANIFESTS_DESTDIR := $(MAJOR).$(MINOR).$(MICRO)-$(PRERELEASE).$(PRERELEASE_VERSION)
	DOTNET_MANIFESTS_DESTDIR = $(DOTNET_DESTDIR)/sdk-manifests/$(DOTNET7_MANIFESTS_DESTDIR)/samsung.net.sdk.tizen
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

ifeq ($(IS_STABLE_RELEASE_TAG), true)
	TIZEN_WORKLOAD_VERSION_FULL := $(TIZEN_WORKLOAD_VERSION)
else
	TIZEN_WORKLOAD_VERSION_FULL := $(TIZEN_WORKLOAD_VERSION)-$(PRERELEASE_VERSION).$(TIZEN_COMMIT_DISTANCE)
endif
