TOP := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

BINDIR := $(TOP)/bin
TMPDIR := $(TOP)/.tmp

include $(TOP)/Versions.mk
include $(TOP)/Config.mk

create-pack = \
		@dotnet pack --nologo $(TOP)/build/$(1).proj \
			-p:Configuration=Release \
			-p:IncludeSymbols=False \
			-p:TizenPackVersion=$(2) \
			-p:TizenVersionHash=$(CURRENT_HASH)

install-packs = \
		@dotnet msbuild --nologo -t:ExtractWorkloadPacks \
			$(TOP)/build/Samsung.NET.Workload.Tizen.proj \
			-p:DotNetTargetPath=$(1) \
			-p:DotNetTargetVersion=$(2)

uninstall-packs = \
		@dotnet msbuild --nologo -t:DeleteExtractedWorkloadPacks \
			$(TOP)/build/Samsung.NET.Workload.Tizen.proj \
			-p:DotNetTargetPath=$(1) \
			-p:DotNetTargetVersion=$(2)

all: create-nupkgs

$(BINDIR)/.stamp-create-nupkgs:
	$(call create-pack,Samsung.NET.Workload.Tizen,$(TIZEN_PACK_VERSION_FULL))
	$(call create-pack,Samsung.Tizen.Sdk,$(TIZEN_PACK_VERSION_FULL))
	$(call create-pack,Samsung.Tizen.Ref,$(TIZEN_PACK_VERSION_FULL))
	$(call create-pack,Samsung.Tizen.Templates,$(TIZEN_PACK_VERSION_FULL))
	@touch $@

create-nupkgs: $(BINDIR)/.stamp-create-nupkgs

install: create-nupkgs
	$(call install-packs,$(abspath $(DESTDIR)),$(DESTVER))

uninstall:
	$(call uninstall-packs,$(abspath $(DESTDIR)),$(DESTVER))


$(BINDIR)/.stamp-prepare-installer: $(BINDIR)/.stamp-create-nupkgs
	@rm -fr $(TMPDIR)
	$(call install-packs,$(abspath $(TMPDIR)),$(DESTVER))
	@touch $@

MSI_BIN_DIR := $(BINDIR)/windows

define CreateMsi
$(MSI_BIN_DIR)/Samsung.NET.Workload.Tizen.$1.wix: $(BINDIR)/.stamp-prepare-installer
	@dotnet msbuild --nologo $(TOP)/build/GenerateWixFile.proj \
									-t:Generate \
									-p:MSIVersion=$(TIZEN_PACK_VERSION_FULL) \
									-p:SourceDirectory=$(TMPDIR) \
									-p:DestinationFile="$$@"

$(MSI_BIN_DIR)/Samsung.NET.Workload.Tizen.$1.msi: $(MSI_BIN_DIR)/Samsung.NET.Workload.Tizen.$1.wix
	@wixl -o "$$@" "$$<" -a x64

MSI_TARGET := $(MSI_BIN_DIR)/Samsung.NET.Workload.Tizen.$1.msi
endef

$(eval $(call CreateMsi,$(TIZEN_PACK_VERSION_FULL)))

msi: $(MSI_TARGET)
	@rm -fr $(TMPDIR)

clean:
	@rm -fr $(BINDIR)
	@rm -fr $(TMPDIR)
	@rm -fr $(TOP)/build/obj/
