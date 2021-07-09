-include $(TMPDIR)/dotnet.config
$(TMPDIR)/dotnet.config: $(TOP)/build/Versions.props
	@mkdir -p $(TMPDIR)
	@grep "<MicrosoftDotnetSdkInternalPackageVersion>" build/Versions.props | sed -e 's/<\/*MicrosoftDotnetSdkInternalPackageVersion>//g' -e 's/[ \t]*/DOTNET6_VERSION=/' > $@
DOTNET6_VERSION_BAND = $(firstword $(subst -, ,$(DOTNET6_VERSION)))

ifeq ($(DESTDIR),)
DOTNET6_DESTDIR = $(OUTDIR)/dotnet
else
DOTNET6_DESTDIR = $(DESTDIR)
endif

DOTNET6_MANIFESTS_DESTDIR=$(DOTNET6_DESTDIR)/sdk-manifests/$(DOTNET6_VERSION_BAND)/samsung.net.sdk.tizen

TIZEN_VERSION_BLAME_COMMIT := $(shell git blame $(TOP)/Versions.mk HEAD | grep TIZEN_PACK_VERSION | sed 's/ .*//')
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

TIZEN_PACK_VERSION_FULL := $(TIZEN_PACK_VERSION)-$(PRERELEASE_VERSION).$(TIZEN_COMMIT_DISTANCE)
