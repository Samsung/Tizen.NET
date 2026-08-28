TOP := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

TMPDIR := $(TOP)/.tmp
OUTDIR := $(TOP)/out
WORKLOAD_PACKS_OUTDIR := $(OUTDIR)/nuget-unsigned
WORKLOAD_MSI_OUTDIR := $(OUTDIR)/windows
NUGET_ORG := https://api.nuget.org/v3/index.json

.DEFAULT_GOAL := packs

export DOTNET_VERSION

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
		-L https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh


# Create nuget packages for manifest and packs
define CreateNuGetPkgs
$(WORKLOAD_PACKS_OUTDIR)/$(1)$(3).$(2).nupkg: $(DOTNET)
		@$(DOTNET) pack --nologo $(TOP)/build/$(1).proj \
			-p:Configuration=Release \
			-p:IncludeSymbols=False \
			-p:TizenPackVersion=$(2) \
			-p:TizenVersionHash=$(CURRENT_HASH) \
			-p:DotNetPreviewVersionBand=$(4) \
			-p:MicrosoftDotnetSdkInternalPackageVersion=$(DOTNET_VERSION)

NUPKG_TARGETS += $(WORKLOAD_PACKS_OUTDIR)/$(1)$(3).$(2).nupkg
endef

$(eval $(call CreateNuGetPkgs,Samsung.NET.Sdk.Tizen,$(TIZEN_WORKLOAD_VERSION_FULL),.Manifest-$(DOTNET_VERSION_BAND),$(DOTNET_VERSION_BAND)))
$(eval $(call CreateNuGetPkgs,Samsung.Tizen.Sdk,$(TIZEN_WORKLOAD_VERSION_FULL)))
$(eval $(call CreateNuGetPkgs,Samsung.Tizen.Ref.API11,$(TizenFXAPI11Version)))
$(eval $(call CreateNuGetPkgs,Samsung.Tizen.Ref.API12,$(TizenFXAPI12Version)))
$(eval $(call CreateNuGetPkgs,Samsung.Tizen.Ref.API13,$(TizenFXAPI13Version)))
$(eval $(call CreateNuGetPkgs,Samsung.Tizen.Ref.API14,$(TizenFXAPI14Version)))
$(eval $(call CreateNuGetPkgs,Samsung.Tizen.Ref.API15,$(TizenFXAPI15Version)))
$(eval $(call CreateNuGetPkgs,Samsung.Tizen.Templates,$(TIZEN_WORKLOAD_VERSION_FULL)))
$(eval $(call CreateNuGetPkgs,Samsung.NETCore.App.Runtime,$(TIZEN_WORKLOAD_VERSION_FULL),.tizen))

.PHONY: packs
packs: $(NUPKG_TARGETS)

# Install workload to the dotnet sdk
INSTALL_STAMP = $(TMPDIR)/.stamp-install-workload-$(DOTNET_VERSION)

$(INSTALL_STAMP): | $(DOTNET_MANIFESTS_DESTDIR)
	@cp -f \
		$(TOP)/LICENSE \
		$(TOP)/src/Samsung.NET.Sdk.Tizen/WorkloadManifest.targets \
		$(WORKLOAD_PACKS_OUTDIR)/workload-manifest/WorkloadManifest.json \
		$(DOTNET_MANIFESTS_DESTDIR)
	@$(DOTNET) workload install tizen --skip-manifest-update \
		--source $(WORKLOAD_PACKS_OUTDIR) --source $(NUGET_ORG) --temp-dir=$(TMPDIR)
	@touch $@

.PHONY: install
install: packs $(INSTALL_STAMP)


# Uninstall workload from the dotnet sdk
.PHONY: uninstall
uninstall:
	@$(DOTNET) workload uninstall tizen
	@rm -f $(INSTALL_STAMP)

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
	@cp -fr $(DOTNET_DESTDIR)/packs/Samsung.Tizen.Ref.API* $@/packs
	@cp -fr $(DOTNET_DESTDIR)/packs/Samsung.NETCore.App.Runtime.* $@/packs
	@mkdir -p $@/template-packs
	@cp -f $(DOTNET_DESTDIR)/template-packs/samsung.tizen.templates.*.nupkg $@/template-packs

$(eval $(call CreateMsi,$(TIZEN_WORKLOAD_VERSION_FULL)))

msi: $(MSI_TARGET)
	@rm -fr $(TMPDIR)

# Compute the next TizenWorkloadVersion by inspecting every Samsung.NET.Sdk.Tizen.Manifest
# package published to NuGet. Globally sequential — same answer regardless of branch.
#   make next-workload-version     # print only
#   make bump-workload-version     # update Versions.props in place
.PHONY: next-workload-version
next-workload-version:
	@python3 $(TOP)/scripts/next-workload-version.py

.PHONY: bump-workload-version
bump-workload-version:
	@python3 $(TOP)/scripts/next-workload-version.py --apply --verbose


# Test 'tizen' workload (single-TFM smoke test using the template defaults)
.PHONY: test
test: install
	@rm -fr $(TMPDIR)/test
	@mkdir -p $(TMPDIR)/test
	@$(DOTNET) new tizen --output $(TMPDIR)/test
	@$(DOTNET) build $(TMPDIR)/test


# Test 'tizen' workload across all officially supported TFM/api-version combinations.
# Matrix is defined in scripts/test-matrix.sh.
.PHONY: test-matrix
test-matrix: install
	@DOTNET=$(DOTNET) TEST_MATRIX_TMP=$(TMPDIR)/matrix \
		bash $(TOP)/scripts/test-matrix.sh


# Static checks that need no dotnet install: cross-file metadata consistency and
# the SDK feature-band detection shared by both install scripts.
.PHONY: validate-metadata
validate-metadata:
	@python3 $(TOP)/scripts/validate-workload-metadata.py

.PHONY: test-version-band
test-version-band:
	@bash $(TOP)/scripts/test-version-band.sh

.PHONY: test-matrix-self-test
test-matrix-self-test:
	@bash $(TOP)/scripts/test-matrix.sh --self-test

.PHONY: test-template-conditions
test-template-conditions:
	@bash $(TOP)/scripts/test-template-conditions.sh

.PHONY: test-package-fallback
test-package-fallback:
	@bash $(TOP)/scripts/test-package-fallback.sh

.PHONY: test-release-workflow
test-release-workflow:
	@bash $(TOP)/scripts/test-release-workflow.sh

.PHONY: test-install-failure
test-install-failure:
	@bash $(TOP)/scripts/test-install-failure.sh

.PHONY: check
check: validate-metadata test-matrix-self-test test-version-band test-template-conditions test-package-fallback test-release-workflow test-install-failure
	@if command -v pwsh >/dev/null 2>&1; then \
		pwsh $(TOP)/scripts/Generate-InstallScripts.ps1 -Check; \
	else \
		echo "ERROR: pwsh not found. It is required to verify version-map drift and"; \
		echo "       install-script integrity. Install PowerShell 7+ (https://aka.ms/powershell)"; \
		echo "       or run: make check SKIP_PWSH_CHECKS=1 (leaves those checks unverified)."; \
		[ -n "$(SKIP_PWSH_CHECKS)" ]; \
	fi

# Print the feature band Config.mk derives for DOTNET_VERSION. Used by
# scripts/test-version-band.sh to prove the producer agrees with the installers.
.PHONY: print-version-band
print-version-band:
	@echo $(DOTNET_VERSION_BAND)

.PHONY: print-dotnet-destdir
print-dotnet-destdir:
	@echo $(DOTNET_DESTDIR)

.PHONY: print-install-stamp
print-install-stamp:
	@echo $(INSTALL_STAMP)


# Remove artifacts and temporary files
clean:
	@rm -fr $(OUTDIR)
	@rm -fr $(TMPDIR)
	@rm -fr $(TOP)/build/obj/
