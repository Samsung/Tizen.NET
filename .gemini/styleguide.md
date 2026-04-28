# Tizen.NET Code Review Style Guide

This guide instructs Gemini Code Assist on how to review pull requests in the
`Samsung/Tizen.NET` repository. The repo provides the **Tizen workload for the
.NET SDK**, so reviews must consider workload manifests, install scripts, and
multi-branch (per-SDK-band) layout — not just C# code style.

## 1. Project Context

- This repo ships the **Tizen workload for the .NET SDK**.
- Active branches map to .NET SDK bands (e.g., `main`, `net10.0`, `net9.0`, `net8.0`, `net7.0`, `net6.0`). The same file may have legitimately different content across branches — don't reflexively suggest "syncing" content across branches.
- `workload/scripts/workload-install.sh` and `workload-install.ps1` are end-user-facing install scripts. Behavior changes there have user-visible blast radius.

## 2. Tone / What NOT to comment on

- Do **not** nitpick `.md`, `assets/`, or generated files (already in `ignore_patterns`, but reinforced here).
- Do **not** suggest churning existing code style just because newer C# syntax exists.
- Do **not** propose architectural rewrites in a small PR. Keep suggestions scoped to the diff.
- Do **not** reflexively suggest adding tests for trivial constant changes or version bumps.
- Reviews should be terse and technical. No emoji, no congratulatory language.
