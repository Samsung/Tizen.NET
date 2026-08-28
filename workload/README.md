# Workload for Tizen .NET

This is a build of Tizen workload for Tizen in .NET 10, and for the .NET 11 preview SDK band.

See [docs/net11.md](docs/net11.md) for the .NET 11 target framework / API-level mapping,
how to build that band, and the external artifacts it is still blocked on.

## Local checks

```sh
make check         # metadata consistency + version-band tests + install-script drift
make test          # single-TFM smoke test (needs a bootstrapped SDK)
make test-matrix   # full TFM matrix
```

## Using IDEs
Refer [here](https://github.com/dotnet/net6-mobile-samples#using-ides) to see the supporting status of an each IDE and how to manually enable workload.
