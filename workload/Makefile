MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
TOP := $(notdir $(patsubst %/,%,$(dir $(MAKEFILE_PATH))))

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
			$(TOP)/build/Microsoft.NET.Workload.Tizen.proj \
			-p:DotNetTargetPath=$(1) \
			-p:DotNetTargetVersion=$(2)

uninstall-packs = \
		@dotnet msbuild --nologo -t:DeleteExtractedWorkloadPacks \
			$(TOP)/build/Microsoft.NET.Workload.Tizen.proj \
			-p:DotNetTargetPath=$(1) \
			-p:DotNetTargetVersion=$(2)

all: create-nupkgs

create-nupkgs:
	$(call create-pack,Microsoft.NET.Workload.Tizen,$(TIZEN_PACK_VERSION_FULL))
	$(call create-pack,Tizen.NET.Sdk.Workload,$(TIZEN_PACK_VERSION_FULL))
	$(call create-pack,Tizen.NET.Ref,$(TIZEN_PACK_VERSION_FULL))

install:
	$(call install-packs,$(abspath $(DESTDIR)),$(DESTVER))

uninstall:
	$(call uninstall-packs,$(abspath $(DESTDIR)),$(DESTVER))

clean:
	@rm -fr $(TOP)/bin/
	@rm -fr $(TOP)/packs/obj/
