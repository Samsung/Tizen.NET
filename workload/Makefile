TOP := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

BINDIR := $(TOP)/bin
TMPDIR := $(TOP)/.tmp
NUPKG_BIN_DIR := $(BINDIR)/nuget-unsigned
MSI_BIN_DIR := $(BINDIR)/windows

.DEFAULT_GOAL := packs

include $(TOP)/Versions.mk
include $(TOP)/Config.mk

# Create nuget packages for manifest and packs
define CreateNuGetPkgs
$(NUPKG_BIN_DIR)/$(1)$(3).$(2).nupkg:
		@dotnet pack --nologo $(TOP)/build/$(1).proj \
			-p:Configuration=Release \
			-p:IncludeSymbols=False \
			-p:TizenPackVersion=$(2) \
			-p:TizenVersionHash=$(CURRENT_HASH) \
			-p:TargetDotnetVersion=$(4)

NUPKG_TARGETS += $(NUPKG_BIN_DIR)/$(1)$(3).$(2).nupkg
endef

$(eval $(call CreateNuGetPkgs,Samsung.NET.Sdk.Tizen,$(TIZEN_PACK_VERSION_FULL),.Manifest-$(TARGET_DOTNET_VERSION_BAND),$(DESTVER)))
$(eval $(call CreateNuGetPkgs,Samsung.Tizen.Sdk,$(TIZEN_PACK_VERSION_FULL)))
$(eval $(call CreateNuGetPkgs,Samsung.Tizen.Ref,$(TIZEN_PACK_VERSION_FULL)))
$(eval $(call CreateNuGetPkgs,Samsung.Tizen.Templates,$(TIZEN_PACK_VERSION_FULL)))

packs: $(NUPKG_TARGETS)


# Install workload to DESTDIR
define InstallWorkload
		@dotnet msbuild --nologo -t:InstallWorkloadPacks \
			$(TOP)/build/Samsung.NET.Sdk.Tizen.proj \
			-p:TargetDotnetPath=$(1) \
			-p:TargetDotnetVersion=$(2)
endef

install: packs
	$(call InstallWorkload,$(abspath $(DESTDIR)),$(DESTVER))


# Uninstall workload from the dotnet sdk
define UninstallWorkload
		@dotnet msbuild --nologo -t:UninstallWorkloadPacks \
			$(TOP)/build/Samsung.NET.Sdk.Tizen.proj \
			-p:TargetDotnetPath=$(1) \
			-p:TargetDotnetVersion=$(2)
endef
uninstall:
	$(call UninstallWorkload,$(abspath $(DESTDIR)),$(DESTVER))


# Create MSI windows bundle
define CreateMsi
$(MSI_BIN_DIR)/Samsung.NET.Workload.Tizen.$(1).wix: prepare-create-installer
	@dotnet msbuild --nologo $(TOP)/build/GenerateWixFile.proj \
									-t:Generate \
									-p:MSIVersion=$(TIZEN_PACK_VERSION_FULL) \
									-p:SourceDirectory=$(TMPDIR)/msi \
									-p:DestinationFile="$$@"

$(MSI_BIN_DIR)/Samsung.NET.Workload.Tizen.$(1).msi: $(MSI_BIN_DIR)/Samsung.NET.Workload.Tizen.$(1).wix
	@wixl -o "$$@" "$$<" -a x64

MSI_TARGET := $(MSI_BIN_DIR)/Samsung.NET.Workload.Tizen.$(1).msi
endef

prepare-create-installer: packs
	@rm -fr $(TMPDIR)
	$(call InstallWorkload,$(abspath $(TMPDIR)/msi),$(DESTVER))

$(eval $(call CreateMsi,$(TIZEN_PACK_VERSION_FULL)))

msi: $(MSI_TARGET)
	@rm -fr $(TMPDIR)


# Remove artifacts and temporary files
clean:
	@rm -fr $(BINDIR)
	@rm -fr $(TMPDIR)
	@rm -fr $(TOP)/build/obj/
