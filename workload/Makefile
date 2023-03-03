TOP := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

TMPDIR := $(TOP)/.tmp
OUTDIR := $(TOP)/out
WORKLOAD_PACKS_OUTDIR := $(OUTDIR)/nuget-unsigned
WORKLOAD_MSI_OUTDIR := $(OUTDIR)/windows

.DEFAULT_GOAL := packs

include $(TOP)/Config.mk

DIRECTORIES += \
	$(OUTDIR) \
	$(TMPDIR) \
	$(DOTNET_MANIFESTS_DESTDIR)

$(DIRECTORIES):
	@mkdir -p $@

# Install dotnet sdk for internal use
DOTNET := $(DOTNET_DESTDIR)/dotnet

$(DOTNET): | $(TMPDIR)/dotnet-install.sh
	@bash $(TMPDIR)/dotnet-install.sh -v $(DOTNET_VERSION) -i $(DOTNET_DESTDIR)

$(TMPDIR)/dotnet-install.sh: | $(OUTDIR)
	@curl -o $@ \
		https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh


# Create nuget packages for manifest and packs
define CreateNuGetPkgs
$(WORKLOAD_PACKS_OUTDIR)/$(1)$(3).$(2).nupkg: $(DOTNET)
		@$(DOTNET) pack --nologo $(TOP)/build/$(1).proj \
			-p:Configuration=Release \
			-p:IncludeSymbols=False \
			-p:TizenPackVersion=$(2) \
			-p:TizenVersionHash=$(CURRENT_HASH) \
			-p:DotNetPreviewVersionBand=$(4)

NUPKG_TARGETS += $(WORKLOAD_PACKS_OUTDIR)/$(1)$(3).$(2).nupkg
endef

$(eval $(call CreateNuGetPkgs,Samsung.NET.Sdk.Tizen,$(TIZEN_WORKLOAD_VERSION_FULL),.Manifest-$(DOTNET_VERSION_BAND),$(DOTNET_VERSION_BAND)))
$(eval $(call CreateNuGetPkgs,Samsung.Tizen.Sdk,$(TIZEN_WORKLOAD_VERSION_FULL)))
$(eval $(call CreateNuGetPkgs,Samsung.Tizen.Ref,$(TIZEN_WORKLOAD_VERSION_FULL)))
$(eval $(call CreateNuGetPkgs,Samsung.Tizen.Templates,$(TIZEN_WORKLOAD_VERSION_FULL)))
$(eval $(call CreateNuGetPkgs,Samsung.NETCore.App.Runtime,$(TIZEN_WORKLOAD_VERSION_FULL),.tizen))

.PHONY: packs
packs: $(NUPKG_TARGETS)

# Install workload to the dotnet sdk
$(TMPDIR)/.stamp-install-workload: | $(DOTNET_MANIFESTS_DESTDIR)
	@cp -f \
		$(TOP)/LICENSE \
		$(TOP)/src/Samsung.NET.Sdk.Tizen/WorkloadManifest.targets \
		$(WORKLOAD_PACKS_OUTDIR)/workload-manifest/WorkloadManifest.json \
		$(DOTNET_MANIFESTS_DESTDIR)
	@$(DOTNET) workload install tizen --skip-manifest-update \
		--source $(WORKLOAD_PACKS_OUTDIR) --temp-dir=$(TMPDIR)
	@touch $@

.PHONY: install
install: packs $(TMPDIR)/.stamp-install-workload


# Uninstall workload from the dotnet sdk
.PHONY: uninstall
uninstall:
	@$(DOTNET) workload uninstall tizen
	@rm -f $(TMPDIR)/.stamp-install-workload

# Create MSI windows installer
define CreateMsi
$(WORKLOAD_MSI_OUTDIR)/Samsung.NET.Workload.Tizen.$(1).wix: | $(TMPDIR)/msi
	@$(DOTNET) msbuild --nologo $(TOP)/build/GenerateWixFile.proj \
									-t:Generate \
									-p:MSIVersion=$(TIZEN_WORKLOAD_VERSION_FULL) \
									-p:SourceDirectory=$(TMPDIR)/msi \
									-p:DestinationFile="$$@"

$(WORKLOAD_MSI_OUTDIR)/Samsung.NET.Workload.Tizen.$(1).msi: $(WORKLOAD_MSI_OUTDIR)/Samsung.NET.Workload.Tizen.$(1).wix
	@wixl -o "$$@" "$$<" -a x64 -v

MSI_TARGET := $(WORKLOAD_MSI_OUTDIR)/Samsung.NET.Workload.Tizen.$(1).msi
endef

$(TMPDIR)/msi: install
	@mkdir -p $@/sdk-manifests/$(DOTNET_VERSION_BAND)
	@cp -fr $(DOTNET_MANIFESTS_DESTDIR) $@/sdk-manifests/$(DOTNET_VERSION_BAND)
	@mkdir -p $@/packs
	@cp -fr $(DOTNET_DESTDIR)/packs/Samsung.Tizen.Sdk $@/packs
	@cp -fr $(DOTNET_DESTDIR)/packs/Samsung.Tizen.Ref $@/packs
	@cp -fr $(DOTNET_DESTDIR)/packs/Samsung.NETCore.App.Runtime.* $@/packs
	@mkdir -p $@/template-packs
	@cp -f $(DOTNET_DESTDIR)/template-packs/samsung.tizen.templates.*.nupkg $@/template-packs

$(eval $(call CreateMsi,$(TIZEN_WORKLOAD_VERSION_FULL)))

msi: $(MSI_TARGET)
	@rm -fr $(TMPDIR)

# Test 'tizen' workload
.PHONY: test
test: install
	@rm -fr $(TMPDIR)/test
	@mkdir -p $(TMPDIR)/test
	@$(DOTNET) new tizen --output $(TMPDIR)/test
	@$(DOTNET) build $(TMPDIR)/test


# Remove artifacts and temporary files
clean:
	@rm -fr $(OUTDIR)
	@rm -fr $(TMPDIR)
	@rm -fr $(TOP)/build/obj/
