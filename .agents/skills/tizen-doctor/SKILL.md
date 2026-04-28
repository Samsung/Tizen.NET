---
name: tizen-doctor
description: Diagnose a Tizen .NET development environment and guide the user to a working build. Use when `dotnet build` fails on a Tizen TFM such as `net6.0-tizen8.0`, `net6.0-tizen9.0`, `net8.0-tizen10.0`, or `net8.0-tizen11.0` (NETSDK1139, NETSDK1147, missing Tizen.NET.Sdk), when setting up a fresh machine for TizenFX / Tizen .NET development, when the Tizen Workload appears installed but target framework resolution still fails, when `sdb` / emulator / certificate tooling is missing, or whenever the user asks "why won't this Tizen project build?". Covers Linux (incl. WSL2), Windows, and macOS. Targets Tizen API Level 11 – 14 (platform 8.0 / 9.0 / 10.0 / 11.0) on .NET 6 and .NET 8 SDK bands.
license: MIT
---

# tizen-doctor

Diagnose and repair a Tizen .NET development environment.

This skill is the entry point for **"my Tizen build is broken, help me figure out why."** It collects a structured snapshot of the environment, compares it to the known-good configuration matrix, and returns a prioritized list of fixes.

## When to use this skill

Trigger this skill when any of the following is true:

- `dotnet build` against a project with a Tizen TFM — `net6.0-tizen8.0`, `net6.0-tizen9.0`, `net8.0-tizen10.0`, `net8.0-tizen11.0`, or the unversioned `net6.0-tizen` / `net8.0-tizen` fallbacks — fails with:
  - `NETSDK1139` — target platform not recognized
  - `NETSDK1147` — workload missing
  - `The SDK 'Tizen.NET.Sdk' specified could not be found`
  - `Package Tizen.NET.API* is not compatible`
- The user is setting up a fresh development machine for TizenFX, a Tizen .NET application, or a Tizen library.
- `dotnet workload list` shows `tizen` as installed but builds still fail.
- Tooling problems around `sdb`, emulator launch, or certificate profile creation.
- The user explicitly asks "what do I need to install to build a Tizen app / TizenFX?"

## When NOT to use this skill

- Runtime issues on an already-built app (use Tizen runtime / log skills instead).
- NUI layout or rendering bugs (use a NUI-specific skill if available).
- API Level compatibility questions unrelated to build failure (use `tizen-api` when available).
- Pure C# / .NET language questions with no Tizen component.

## Inputs

The skill needs, at minimum:

1. **Host OS**: Linux (distro + version, or WSL2), Windows, or macOS.
2. **Error signature**: exact message or MSBuild error code if the user has one.
3. **Project kind**: TizenFX itself (uses `build.sh`), a Tizen application, or a library that targets a `net*-tizen` TFM.

If any of these are missing, ask the user for them before running diagnostics — the script picks different checks based on OS.

## Workflow

### Step 1 — Collect environment

Run the collector script for the host OS. It prints a single YAML-ish report covering .NET SDK, installed workloads, Tizen Studio / `sdb`, Java runtime, certificate profiles, and environment variables.

```bash
# Linux / macOS / WSL2
bash scripts/collect-env.sh

# Windows — built-in PowerShell 5.1
powershell.exe -ExecutionPolicy Bypass -File scripts/collect-env.ps1

# Windows — PowerShell 7+ (if installed)
pwsh -File scripts/collect-env.ps1
```

If `bash` / `pwsh` is not available, fall back to the manual checklist in `references/manual-env-checklist.md` (add only if the scripts cannot run).

### Step 2 — Diagnose

Compare the collected report against `references/tfm-workload-matrix.md`. Classify each finding into one of:

| Severity | Meaning |
|---|---|
| 🔴 **Blocker** | Build will fail until fixed. Examples: missing .NET SDK, missing Tizen Workload, wrong SDK version for the requested TFM. |
| 🟡 **Likely** | Fix is probably needed for the user's goal but build may still partially succeed. Examples: missing `sdb`, no signing certificate, outdated Workload. |
| 🟢 **Optional** | Nice-to-have. Examples: emulator images, IDE extensions. |

Only flag items the user's stated goal actually needs. Installing the emulator is irrelevant if they only want to run unit tests.

### Step 3 — Produce the fix list

Return a **prioritized, copy-pasteable** fix list, grouped by severity. Each fix must include:

1. The exact command to run.
2. A one-line explanation of why it is needed.
3. A verification command so the user can confirm the fix worked.

Template:

```markdown
## 🔴 Blockers

1. **Install the Tizen Workload**
   - Why: `net8.0-tizen11.0` (and sibling Tizen TFMs) require `Tizen.NET.Sdk`, which ships via the Tizen Workload. **The Tizen Workload is not on the public dotnet workload feed — installing it via `dotnet workload install tizen` will not work.** It is bootstrapped from a script in the Samsung/Tizen.NET repo.
   - Command (Linux / macOS / WSL):
     ```bash
     curl -sSL https://raw.githubusercontent.com/Samsung/Tizen.NET/main/workload/scripts/workload-install.sh | sudo bash
     ```
   - Command (Windows PowerShell):
     ```powershell
     Invoke-WebRequest 'https://raw.githubusercontent.com/Samsung/Tizen.NET/main/workload/scripts/workload-install.ps1' -OutFile 'workload-install.ps1'
     ./workload-install.ps1
     ```
   - Verify: `dotnet workload list` shows `tizen` with a version matching the active SDK band.
   - Updating: re-run the same script — `dotnet workload update` does **not** update the Tizen workload.

2. ...

## 🟡 Likely

...

## 🟢 Optional

...
```

End the response with a single next-command suggestion — the one thing the user should run *right now* to move forward.

## Common pitfalls

| Symptom | Root cause | Fix |
|---|---|---|
| `NETSDK1139` on `net8.0-tizen11.0` (or any `net*-tizen*` TFM) | Tizen Workload not installed for the current .NET SDK | Run Samsung's `workload-install.{sh,ps1}` from `Samsung/Tizen.NET/workload/scripts/`. **Note: `dotnet workload install tizen` does NOT work — Tizen workload is not on the public feed.** |
| Workload installed, TFM still unresolved | Mixed .NET SDKs on PATH; `dotnet` resolves to a version without the workload | Check `dotnet --info` and `dotnet --list-sdks`; install workload for the active SDK |
| `build.sh` fails on Windows | TizenFX `build.sh` assumes a POSIX shell | Use WSL2 or Git Bash; native Windows `dotnet build` works for app projects but not for the TizenFX repo itself |
| `Tizen.NET.API*` package restore fails | Project TFM's platform suffix does not match the API package version (e.g., `net6.0-tizen9.0` ↔ API12, `net8.0-tizen11.0` ↔ API14) | Pin the correct TFM or re-run Samsung's `workload-install.{sh,ps1}` to refresh to the latest workload (the standard `dotnet workload update` does not update the Tizen workload) |
| Workload is listed but a specific TFM still fails (observed: .NET 10 SDK + `tizen 10.0.123` + `net8.0-tizen11.0`) | Installed workload's `WorkloadManifest.json` is missing the `Samsung.Tizen.Ref.API<N>` pack for that TFM | Inspect the manifest (see `references/tfm-workload-matrix.md`); install the SDK band whose manifest includes the needed Ref pack |
| `sdb: command not found` | Tizen Studio not installed, or `tools/` not on PATH | Install Tizen Studio; prepend `$TIZEN_STUDIO/tools` to `PATH` |
| Cert signing fails silently | No active certificate profile | Create via Tizen Certificate Manager or `tizen security-profiles add` |

## Out-of-scope (redirect)

- "How do I write XAML for NUI?" → not this skill.
- "Which Tizen API Level introduced X?" → use `tizen-api` once available.
- "My app crashes on the device" → use `tizen-runtime` / log skills.

## Notes for maintainers

- Keep `references/tfm-workload-matrix.md` current — Tizen Workload versions ship alongside .NET SDK band updates.
- When adding a new error signature, add one row to the **Common pitfalls** table above and one matching entry in `references/error-signatures.md` (create that file if needed).
- Scripts must degrade gracefully: if a command is missing, print `not-found` rather than failing the whole collector.
