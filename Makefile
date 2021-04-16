mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
topdir := $(dir $(mkfile_path))
DOTNET_TARGET_PATH := $(abspath $(DESTDIR))

all: create-nupkgs

create-nupkgs:
	@dotnet msbuild -t:CreateAllPacks $(topdir)/packs/Tizen.NET.Sdk.Workload.proj

install: create-nupkgs
	@dotnet msbuild -t:ExtractWorkloadPacks $(topdir)/packs/Tizen.NET.Sdk.Workload.proj \
		-p:DotNetTargetPath=$(DOTNET_TARGET_PATH) \

uninstall:
	@dotnet msbuild -t:DeleteExtractedWorkloadPacks $(topdir)/packs/Tizen.NET.Sdk.Workload.proj \
		-p:DotNetTargetPath=$(DOTNET_TARGET_PATH) \

clean:
	@rm -fr $(topdir)/bin/
	@rm -fr $(topdir)/packs/obj/
