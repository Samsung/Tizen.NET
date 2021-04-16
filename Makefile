mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
topdir := $(dir $(mkfile_path))


all: create-nupkgs

create-nupkgs:
	@dotnet msbuild -t:CreateAllPacks $(topdir)/packs/Tizen.NET.Sdk.Workload.proj



install: create-nupkgs
	@dotnet msbuild -t:ExtractWorkloadPacks $(topdir)/packs/Tizen.NET.Sdk.Workload.proj

clean:
	@rm -fr $(topdir)/bin/
	@rm -fr $(topdir)/packs/obj/
