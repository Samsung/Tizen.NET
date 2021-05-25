-include $(TMPDIR)/dotnet.config
$(TMPDIR)/dotnet.config: $(TOP)/build/Versions.props
	@mkdir -p $(TMPDIR)
	@grep "<_DefaultTargetDotnetVersion>" build/Versions.props | sed -e 's/<\/*_DefaultTargetDotnetVersion>//g' -e 's/[ \t]*/TARGET_DOTNET_VERSION=/' > $@

ifeq ($(DESTVER),)
TARGET_DOTNET_VERSION_BAND=$(firstword $(subst -, ,$(TARGET_DOTNET_VERSION)))
else
TARGET_DOTNET_VERSION_BAND=$(firstword $(subst -, ,$(DESTVER)))
endif


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
