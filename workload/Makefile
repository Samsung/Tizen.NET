TOP := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

TMPDIR := $(TOP)/.tmp
OUTDIR := $(TOP)/bin
WORKLOAD_PACKS_OUTDIR := $(OUTDIR)/nuget-unsigned
WORKLOAD_MSI_OUTDIR := $(OUTDIR)/windows

.DEFAULT_GOAL := packs

include $(TOP)/Versions.mk
include $(TOP)/Config.mk

DIRECTORIES += \
	$(OUTDIR) \
	$(TMPDIR)

$(DIRECTORIES):
	@mkdir -p $@


# Install dotnet 6.0 sdk for internal use
DOTNET6 := $(DOTNET6_DESTDIR)/dotnet

$(DOTNET6): | $(TMPDIR)/dotnet-install.sh
	@bash $(TMPDIR)/dotnet-install.sh -v $(DOTNET6_VERSION) -i $(DOTNET6_DESTDIR)

$(TMPDIR)/dotnet-install.sh: | $(OUTDIR)
	@curl -o $@ \
		https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh


# Create nuget packages for manifest and packs
define CreateNuGetPkgs
$(WORKLOAD_PACKS_OUTDIR)/$(1)$(3).$(2).nupkg: $(DOTNET6)
		@$(DOTNET6) pack --nologo $(TOP)/build/$(1).proj \
			-p:Configuration=Release \
			-p:IncludeSymbols=False \
			-p:TizenPackVersion=$(2) \
			-p:TizenVersionHash=$(CURRENT_HASH) \
			-p:DotNetPreviewVersionBand=$(4)

NUPKG_TARGETS += $(WORKLOAD_PACKS_OUTDIR)/$(1)$(3).$(2).nupkg
endef

$(eval $(call CreateNuGetPkgs,Samsung.NET.Sdk.Tizen,$(TIZEN_PACK_VERSION_FULL),.Manifest-$(DOTNET6_VERSION_BAND),$(DOTNET6_VERSION_BAND)))
$(eval $(call CreateNuGetPkgs,Samsung.Tizen.Sdk,$(TIZEN_PACK_VERSION_FULL)))
$(eval $(call CreateNuGetPkgs,Samsung.Tizen.Ref,$(TIZEN_PACK_VERSION_FULL)))
$(eval $(call CreateNuGetPkgs,Samsung.Tizen.Templates,$(TIZEN_PACK_VERSION_FULL)))

packs: $(NUPKG_TARGETS)


# Install workload to DESTDIR
define InstallWorkload
		@$(DOTNET6) msbuild --nologo -t:InstallWorkloadPacks \
			$(TOP)/build/Samsung.NET.Sdk.Tizen.proj \
			-p:TargetDotnetPath=$(1)
endef

install: packs
	$(call InstallWorkload,$(abspath $(DOTNET6_DESTDIR)))


# Uninstall workload from the dotnet sdk
define UninstallWorkload
		@$(DOTNET6) msbuild --nologo -t:UninstallWorkloadPacks \
			$(TOP)/build/Samsung.NET.Sdk.Tizen.proj \
			-p:TargetDotnetPath=$(1)
endef
uninstall: $(DOTNET6)
	$(call UninstallWorkload,$(abspath $(DOTNET6_DESTDIR)))


# Create MSI windows bundle
define CreateMsi
$(WORKLOAD_MSI_OUTDIR)/Samsung.NET.Workload.Tizen.$(1).wix: prepare-create-installer
	@$(DOTNET6) msbuild --nologo $(TOP)/build/GenerateWixFile.proj \
									-t:Generate \
									-p:MSIVersion=$(TIZEN_PACK_VERSION_FULL) \
									-p:SourceDirectory=$(TMPDIR)/msi \
									-p:DestinationFile="$$@"

$(WORKLOAD_MSI_OUTDIR)/Samsung.NET.Workload.Tizen.$(1).msi: $(WORKLOAD_MSI_OUTDIR)/Samsung.NET.Workload.Tizen.$(1).wix
	@wixl -o "$$@" "$$<" -a x64

MSI_TARGET := $(WORKLOAD_MSI_OUTDIR)/Samsung.NET.Workload.Tizen.$(1).msi
endef

prepare-create-installer: packs
	@rm -fr $(TMPDIR)
	$(call InstallWorkload,$(abspath $(TMPDIR)/msi)))

$(eval $(call CreateMsi,$(TIZEN_PACK_VERSION_FULL)))

msi: $(MSI_TARGET)
	@rm -fr $(TMPDIR)


# Remove artifacts and temporary files
clean:
	@rm -fr $(OUTDIR)
	@rm -fr $(TMPDIR)
	@rm -fr $(TOP)/build/obj/
