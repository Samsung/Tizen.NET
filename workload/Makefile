TOP := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

TMPDIR := $(TOP)/.tmp
OUTDIR := $(TOP)/out
WORKLOAD_PACKS_OUTDIR := $(OUTDIR)/nuget-unsigned
WORKLOAD_MSI_OUTDIR := $(OUTDIR)/windows

.DEFAULT_GOAL := packs

include $(TOP)/Versions.mk
include $(TOP)/Config.mk

DIRECTORIES += \
	$(OUTDIR) \
	$(TMPDIR) \
	$(DOTNET6_MANIFESTS_DESTDIR)

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
define CreateNuGetPack
$(WORKLOAD_PACKS_OUTDIR)/$(1)$(2).$(TIZEN_PACK_VERSION_FULL).nupkg: $(DOTNET6)
		@$(DOTNET6) pack --nologo $(TOP)/build/$(1).proj \
			-p:Configuration=Release \
			-p:IncludeSymbols=False \
			-p:TizenPackVersion=$(TIZEN_PACK_VERSION_FULL) \
			-p:TizenVersionHash=$(CURRENT_HASH) \
			-p:DotNetPreviewVersionBand=$(3)

NUPKG_TARGETS += $(WORKLOAD_PACKS_OUTDIR)/$(1)$(2).$(TIZEN_PACK_VERSION_FULL).nupkg
endef

$(eval $(call CreateNuGetPack,Samsung.NET.Sdk.Tizen,.Manifest-$(DOTNET6_VERSION_BAND),$(DOTNET6_VERSION_BAND)))
$(eval $(call CreateNuGetPack,Samsung.Tizen.Sdk))
$(eval $(call CreateNuGetPack,Samsung.Tizen.Ref))
$(eval $(call CreateNuGetPack,Samsung.Tizen.Templates))
$(eval $(call CreateNuGetPack,Samsung.NETCore.App.Runtime,.tizen))

.PHONY: packs
packs: $(NUPKG_TARGETS)


# Install workload to the dotnet sdk
$(TMPDIR)/.stamp-install-workload: | $(DOTNET6_MANIFESTS_DESTDIR)
	@cp -f \
		$(TOP)/LICENSE \
		$(TOP)/src/Samsung.NET.Sdk.Tizen/WorkloadManifest.targets \
		$(WORKLOAD_PACKS_OUTDIR)/workload-manifest/WorkloadManifest.json \
		$(DOTNET6_MANIFESTS_DESTDIR)
	@$(DOTNET6) workload install tizen --skip-manifest-update \
		--source $(WORKLOAD_PACKS_OUTDIR) --temp-dir=$(TMPDIR)
	@touch $@

.PHONY: install
install: packs $(TMPDIR)/.stamp-install-workload


# Uninstall workload from the dotnet sdk
.PHONY: uninstall
uninstall:
	@$(DOTNET6) workload uninstall tizen
	@rm -f $(TMPDIR)/.stamp-install-workload

# Create MSI windows bundles
define CreateMsiNuGetPack
$(WORKLOAD_PACKS_OUTDIR)/$(1)$(2).$(TIZEN_PACK_VERSION_FULL).Msi.x64.nupkg: | install
		@$(DOTNET6) pack --nologo $(TOP)/build/$(1).proj \
			-p:Configuration=Release \
			-p:IncludeSymbols=False \
			-p:CreateMsiNuGet=True \
			-p:ProductVersion=$(TIZEN_PACK_VERSION) \
			-p:TizenPackVersion=$(TIZEN_PACK_VERSION_FULL) \
			-p:TizenVersionHash=$(CURRENT_HASH) \
			-p:TargetDotnetDirectory=$(DOTNET6_DESTDIR) \
			-p:DotNetPreviewVersionBand=$(3)

MSI_NUGET_TARGETS += $(WORKLOAD_PACKS_OUTDIR)/$(1)$(2).$(TIZEN_PACK_VERSION_FULL).Msi.x64.nupkg
endef

$(eval $(call CreateMsiNuGetPack,Samsung.NET.Sdk.Tizen,.Manifest-$(DOTNET6_VERSION_BAND),$(DOTNET6_VERSION_BAND)))
$(eval $(call CreateMsiNuGetPack,Samsung.Tizen.Sdk))
$(eval $(call CreateMsiNuGetPack,Samsung.Tizen.Ref))
$(eval $(call CreateMsiNuGetPack,Samsung.Tizen.Templates))
$(eval $(call CreateMsiNuGetPack,Samsung.NETCore.App.Runtime,.tizen))

msi: $(MSI_NUGET_TARGETS)


# Test 'tizen' workload
.PHONY: test
test: install
	@rm -fr $(TMPDIR)/test
	@mkdir -p $(TMPDIR)/test
	@$(DOTNET6) new tizen --output $(TMPDIR)/test
	@$(DOTNET6) build $(TMPDIR)/test


# Remove artifacts and temporary files
clean:
	@rm -fr $(OUTDIR)
	@rm -fr $(TMPDIR)
	@rm -fr $(TOP)/build/obj/
