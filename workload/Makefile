TOP := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

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
$(eval $(call CreateNuGetPkgs,Samsung.NETCore.App.Runtime,$(TIZEN_PACK_VERSION_FULL),.tizen))

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

# Create MSI windows installer
define CreateMsi
$(WORKLOAD_MSI_OUTDIR)/Samsung.NET.Workload.Tizen.$(1).wix: | $(TMPDIR)/msi
	@$(DOTNET6) msbuild --nologo $(TOP)/build/GenerateWixFile.proj \
									-t:Generate \
									-p:MSIVersion=$(TIZEN_PACK_VERSION_FULL) \
									-p:SourceDirectory=$(TMPDIR)/msi \
									-p:DestinationFile="$$@"

$(WORKLOAD_MSI_OUTDIR)/Samsung.NET.Workload.Tizen.$(1).msi: $(WORKLOAD_MSI_OUTDIR)/Samsung.NET.Workload.Tizen.$(1).wix
	@wixl -o "$$@" "$$<" -a x64

MSI_TARGET := $(WORKLOAD_MSI_OUTDIR)/Samsung.NET.Workload.Tizen.$(1).msi
endef

$(TMPDIR)/msi: install
	@mkdir -p $@/sdk-manifests/$(DOTNET6_VERSION_BAND)
	@cp -fr $(DOTNET6_MANIFESTS_DESTDIR) $@/sdk-manifests/$(DOTNET6_VERSION_BAND)
	@mkdir -p $@/packs
	@cp -fr $(DOTNET6_DESTDIR)/packs/Samsung.Tizen.Sdk $@/packs
	@cp -fr $(DOTNET6_DESTDIR)/packs/Samsung.Tizen.Ref $@/packs
	@cp -fr $(DOTNET6_DESTDIR)/packs/Samsung.NETCore.App.Runtime.* $@/packs
	@mkdir -p $@/template-packs
	@cp -f $(DOTNET6_DESTDIR)/template-packs/samsung.tizen.templates.*.nupkg $@/template-packs

$(eval $(call CreateMsi,$(TIZEN_PACK_VERSION_FULL)))

msi: $(MSI_TARGET)
	@rm -fr $(TMPDIR)

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
