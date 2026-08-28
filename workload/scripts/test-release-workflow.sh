#!/bin/bash
#
# Copyright (c) Samsung Electronics. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#
# Semantic checks for .github/workflows/release-workload.yml.
#
# The release workflow cannot be executed here, so these assertions pin the ordering and
# guard conditions that make a release safe and RETRYABLE:
#
#   * the version bump is persisted only AFTER the build and artifact verification, so a
#     failed release does not leave the branch bumped and therefore unretryable
#     (the retry would compute OLD == NEW);
#   * OLD == NEW resumes rather than aborts;
#   * a reference-only run mutates nothing;
#   * the release tag targets the commit that carries the released Versions.props;
#   * pushes use the verified staging directory, not a glob over the workspace;
#   * re-creating an existing tag is a no-op.
#
# Usage:
#   bash workload/scripts/test-release-workflow.sh
#   make -C workload test-release-workflow
#

set -uo pipefail

WORKLOAD_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WF="$WORKLOAD_DIR/../.github/workflows/release-workload.yml"

c_reset=$'\033[0m'; c_red=$'\033[31m'; c_green=$'\033[32m'
[[ -t 1 ]] || { c_reset=""; c_red=""; c_green=""; }

pass=0; fail=0

if [[ ! -f "$WF" ]]; then
    echo "ERROR: $WF not found."
    exit 2
fi

assert() {
    local label="$1" cond="$2"
    if [[ "$cond" == "1" ]]; then
        printf "  %sPASS%s  %s\n" "$c_green" "$c_reset" "$label"
        pass=$((pass + 1))
    else
        printf "  %sFAIL%s  %s\n" "$c_red" "$c_reset" "$label"
        fail=$((fail + 1))
    fi
}

# Resolve a step's line number. A missing anchor is a hard error: silently returning an
# empty value would turn every ordering assertion that uses it into a confusing failure.
line_of() {
    local ln
    ln="$(grep -n -F -- "$1" "$WF" | head -1 | cut -d: -f1)"
    if [[ -z "$ln" ]]; then
        printf "  %sFAIL%s  workflow step not found: %s\n" "$c_red" "$c_reset" "$1"
        fail=$((fail + 1))
        echo 0
        return
    fi
    echo "$ln"
}

BUILD_LN=$(line_of "    - name: Build")
STAGE_LN=$(line_of "    - name: Stage and verify packages")
RESERVE_LN=$(line_of "    - name: Resolve and reserve release version")
CHECKOUT_LN=$(line_of "    - name: Check out the reserved release commit")
PUSH_LN=$(line_of "    - name: Push SDK/Runtime/Templates packs")
REL_LN=$(line_of "    - name: Create GitHub Release")

# --- ordering ---------------------------------------------------------------

assert "build runs before staging" \
    "$([[ -n "$BUILD_LN" && -n "$STAGE_LN" && "$BUILD_LN" -lt "$STAGE_LN" ]] && echo 1 || echo 0)"

# The release commit is now created FIRST so every package embeds the same SHA as the tag.
# Retryability comes from the reservation ref + resume detection, not from deferring it.
assert "version is reserved before the build" \
    "$([[ -n "$RESERVE_LN" && -n "$BUILD_LN" && "$RESERVE_LN" -lt "$BUILD_LN" ]] && echo 1 || echo 0)"

assert "reserved commit is checked out before the build" \
    "$([[ -n "$CHECKOUT_LN" && -n "$BUILD_LN" && "$CHECKOUT_LN" -lt "$BUILD_LN" ]] && echo 1 || echo 0)"

assert "ownership is claimed via an atomic reservation ref" \
    "$(grep -q 'refs/tizen-release/v' "$WF" && echo 1 || echo 0)"

assert "a foreign reservation aborts the run" \
    "$(grep -q 'already reserved by a release with different inputs' "$WF" && echo 1 || echo 0)"

assert "releases are serialized by a concurrency group" \
    "$(grep -q 'group: tizen-workload-release' "$WF" && echo 1 || echo 0)"

assert "in-flight releases are never cancelled" \
    "$(grep -q 'cancel-in-progress: false' "$WF" && echo 1 || echo 0)"

assert "the build runs from the reserved SHA, not the event SHA" \
    "$(grep -q 'git checkout --detach "\$SHA"' "$WF" && echo 1 || echo 0)"

assert "source drift against the reserved version is rejected" \
    "$(grep -q 'Source drift' "$WF" && echo 1 || echo 0)"

assert "the applied version is pinned explicitly (--set-version)" \
    "$(grep -q 'next-workload-version.py --apply --set-version' "$WF" && echo 1 || echo 0)"

assert "every package is verified to carry the reserved commit" \
    "$(grep -q 'do not all originate from the reserved release commit' "$WF" && echo 1 || echo 0)"

assert "release tag is created last" \
    "$([[ -n "$PUSH_LN" && -n "$REL_LN" && "$PUSH_LN" -lt "$REL_LN" ]] && echo 1 || echo 0)"

# --- retryability / non-mutation --------------------------------------------

assert "OLD == NEW reserves the current commit instead of failing" \
    "$(grep -q 'is already \$NEW; reserving the current commit' "$WF" && ! grep -q 'ERROR: computed next == current' "$WF" && echo 1 || echo 0)"

assert "reference-only run is non-mutating" \
    "$(grep -q 'Reference-only run: leaving TizenWorkloadVersion' "$WF" && echo 1 || echo 0)"

assert "a resumed run rebuilds from the reservation's commit" \
    "$(grep -q 'print-field sha' "$WF" && grep -q 'release_sha=\$RESUME_SHA' "$WF" && echo 1 || echo 0)"

assert "build is not continue-on-error" \
    "$(awk -v s="$BUILD_LN" -v e="$STAGE_LN" 'NR>s && NR<e && /continue-on-error/ {found=1} END{exit !found}' "$WF" && echo 0 || echo 1)"

# --- correctness of what gets published -------------------------------------

assert "tag targets the reserved release commit" \
    "$(grep -q 'SHA="\${{ steps.bump.outputs.release_sha }}"' "$WF" && grep -q -- '--target "\$SHA"' "$WF" && echo 1 || echo 0)"

assert "release notes use the staged manifest id" \
    "$(grep -q 'steps.stage.outputs.manifest_id' "$WF" && echo 1 || echo 0)"

assert "release notes do not recompute the band with \${SDK%%-*}" \
    "$(grep -q 'BAND="\${SDK%%-\*}"' "$WF" && echo 0 || echo 1)"

assert "pushes come from the verified staging directory" \
    "$(grep -q 'steps.stage.outputs.staging }}/Samsung.NET.Sdk.Tizen.Manifest-' "$WF" && echo 1 || echo 0)"

assert "no push globs the raw workspace output directory" \
    "$(grep -q 'dotnet nuget push ./workload/out/' "$WF" && echo 0 || echo 1)"

assert "existing release tag is a no-op (resumable)" \
    "$(grep -q 'already exists at the reserved commit' "$WF" && echo 1 || echo 0)"

# --- partial-publication resume ---------------------------------------------

MANIFEST_PUSH_LN=$(line_of "    - name: Push Manifest pack")
COMPANION_PUSH_LN=$(line_of "    - name: Push SDK/Runtime/Templates packs")
VERIFY_LN=$(line_of "    - name: Verify publication is complete")

assert "publication state is inspected before advancing the version" \
    "$(grep -q 'release-state.py --version "\$V"' "$WF" && echo 1 || echo 0)"

assert "a partially published version is resumed, never advanced" \
    "$(grep -q 'is unfinished (state=\$STATE' "$WF" && grep -q 'NEW=\$(python3 scripts/next-workload-version.py)' "$WF" && echo 1 || echo 0)"

assert "a published-but-untagged version is resumed to finish the tag" \
    "$(grep -q 'STATE" = "published" ] && \[ "\$RELEASED" = "true" \]' "$WF" && echo 1 || echo 0)"

assert "companion packs are pushed BEFORE the manifest" \
    "$([[ -n "$COMPANION_PUSH_LN" && -n "$MANIFEST_PUSH_LN" && "$COMPANION_PUSH_LN" -lt "$MANIFEST_PUSH_LN" ]] && echo 1 || echo 0)"

assert "publication completeness is verified before tagging" \
    "$([[ -n "$VERIFY_LN" && -n "$REL_LN" && "$VERIFY_LN" -lt "$REL_LN" ]] && echo 1 || echo 0)"

assert "every push is idempotent (--skip-duplicate)" \
    "$([[ "$(grep -c 'skip-duplicate' "$WF")" -ge 3 ]] && echo 1 || echo 0)"

# --- resume set must match what the workflow actually publishes --------------
#
# release-state.py decides whether a version is fully published. If a pack is added to the
# push steps but not to that list, a version missing it would be reported "published", get
# tagged, and never be completed - the exact failure this machinery exists to prevent.

assert "band is computed in exactly one place" \
    "$([[ "$(grep -c 'compute_target_version_band' "$WF")" -eq 1 ]] && echo 1 || echo 0)"

STATE_PKGS="$(python3 - "$WORKLOAD_DIR/scripts/release-state.py" <<'PYEOF'
import re, sys
src = open(sys.argv[1], encoding="utf-8").read()
block = re.search(r"VERSIONED_PACKAGE_SUFFIXES = \[(.*?)\]", src, re.S).group(1)
print("\n".join(sorted(re.findall(r'"([^"]+)"', block))))
PYEOF
)"

# Package globs the workflow pushes under the workload version (excludes the Ref packs,
# which are versioned by TizenFX and gated by release_reference).
PUSHED="$(grep -oE '\$pattern|for pattern in [^;]*' "$WF" | sed -n 's/^for pattern in //p' | tr ' ' '\n' | sed '/^$/d' | sort -u)"

norm() { sed 's/^Samsung\.NETCore\.App\.Runtime$/Samsung.NETCore.App.Runtime.tizen/' ; }

# The reservation payload records the authoritative package set for a release, so it is a
# THIRD place the list lives. All three must agree.
RESERVED_PKGS="$(grep -oE 'PACKAGES="[^"]*"' "$WF" | head -1 | sed 's/PACKAGES="//;s/"$//' \
    | tr ',' '\n' | sed 's/\$MANIFEST_ID//' | sed '/^$/d' | sort -u)"

missing_from_state=""
while read -r pkg; do
    [[ -z "$pkg" ]] && continue
    canonical="$(echo "$pkg" | norm)"
    grep -Fqx "$canonical" <<< "$STATE_PKGS" || missing_from_state="$missing_from_state $canonical"
done <<< "$PUSHED"

assert "every pushed pack is tracked by release-state.py" \
    "$([[ -z "$missing_from_state" ]] && echo 1 || echo 0)"
[[ -n "$missing_from_state" ]] && echo "        untracked:$missing_from_state"

# The reverse direction matters just as much and was missing. A package listed in
# release-state.py that the workflow never pushes can never become present, so
# "Verify publication is complete" would retry until it gave up and the release would
# never be tagged - an unpublishable version, on every single run.
missing_from_push=""
NORM_PUSHED="$(echo "$PUSHED" | norm | sort -u)"
while read -r pkg; do
    [[ -z "$pkg" ]] && continue
    grep -Fqx "$pkg" <<< "$NORM_PUSHED" || missing_from_push="$missing_from_push $pkg"
done <<< "$STATE_PKGS"

assert "every pack release-state.py waits for is actually pushed" \
    "$([[ -z "$missing_from_push" ]] && echo 1 || echo 0)"
[[ -n "$missing_from_push" ]] && echo "        never pushed:$missing_from_push"

missing_from_reservation=""
while read -r pkg; do
    [[ -z "$pkg" ]] && continue
    grep -Fqx "$pkg" <<< "$RESERVED_PKGS" || missing_from_reservation="$missing_from_reservation $pkg"
done <<< "$STATE_PKGS"

assert "the reservation payload records the same package set" \
    "$([[ -z "$missing_from_reservation" ]] && echo 1 || echo 0)"
[[ -n "$missing_from_reservation" ]] && echo "        not reserved:$missing_from_reservation"

# --- durable resume, reservation binding and tag provenance ------------------
assert "resume is driven by enumerating reservation refs, not by \$OLD" \
    "$(grep -q "for-each-ref --format='%(refname)' 'refs/tizen-release/v\*'" "$WF" && echo 1 || echo 0)"

assert "a candidate reservation must match this run's inputs before being resumed" \
    "$(grep -q 'release-reservation.py verify' "$WF" && grep -q -- '--expect-band' "$WF" && echo 1 || echo 0)"

assert "the reservation binds sdk, band, branch, manifest id and package set" \
    "$(for f in --expect-sdk --expect-band --expect-branch --expect-manifest-id --expect-packages; do
           grep -q -- "$f" "$WF" || { echo 0; exit; }; done; echo 1)"

assert "the reservation is created as a compare-and-swap that requires absence" \
    "$(grep -q -- '--force-with-lease="refs/tizen-release/v\$NEW:"' "$WF" && echo 1 || echo 0)"

assert "two unfinished reservations for the same inputs abort rather than guess" \
    "$(grep -q 'More than one unfinished reservation' "$WF" && echo 1 || echo 0)"

assert "an existing tag is only reused when it targets the reserved commit" \
    "$(grep -q 'is tagged at \$TAG_SHA but this version was reserved' "$WF" && echo 1 || echo 0)"

assert "a release whose tag cannot be resolved to a commit is rejected" \
    "$(grep -q 'its tag could not be resolved to a commit' "$WF" && echo 1 || echo 0)"

# --- functional: reservation payload binding ---------------------------------
#
# Grep assertions above prove the workflow WIRES the reservation up. These run the real
# script and prove it actually rejects the mismatches it is supposed to.
RES="$WORKLOAD_DIR/scripts/release-reservation.py"
RESDIR="$(mktemp -d)"
PKGS="Samsung.NET.Sdk.Tizen.Manifest-11.0.100-preview.7,Samsung.NETCore.App.Runtime.tizen,Samsung.Tizen.Sdk,Samsung.Tizen.Templates"
GOOD_SHA="1111111111111111111111111111111111111111"
python3 "$RES" encode --version 10.0.128 --sha "$GOOD_SHA" \
    --sdk 11.0.100-preview.7.26381.103 --band 11.0.100-preview.7 \
    --manifest-id Samsung.NET.Sdk.Tizen.Manifest-11.0.100-preview.7 \
    --packages "$PKGS" --branch net10.0 > "$RESDIR/p.json"

assert "a reservation payload round-trips against its own inputs" \
    "$(python3 "$RES" verify --payload-file "$RESDIR/p.json" --expect-version 10.0.128 \
        --expect-sdk 11.0.100-preview.7.26381.103 --expect-band 11.0.100-preview.7 \
        --expect-branch net10.0 --expect-packages "$PKGS" >/dev/null 2>&1 && echo 1 || echo 0)"

assert "the reserved release SHA is recoverable from the payload" \
    "$([[ "$(python3 "$RES" verify --payload-file "$RESDIR/p.json" --print-field sha)" == "$GOOD_SHA" ]] && echo 1 || echo 0)"

# Each of these is a redispatch that must NOT be allowed to adopt the reservation.
for bad in "--expect-band 10.0.100" "--expect-sdk 10.0.100" "--expect-branch main" \
           "--expect-version 10.0.129" "--expect-manifest-id Samsung.NET.Sdk.Tizen.Manifest-10.0.100"; do
    flag="${bad%% *}"
    python3 "$RES" verify --payload-file "$RESDIR/p.json" $bad >/dev/null 2>&1
    assert "a reservation is not adopted when $flag differs" \
        "$([[ $? -eq 3 ]] && echo 1 || echo 0)"
done

python3 "$RES" verify --payload-file "$RESDIR/p.json" \
    --expect-packages "Samsung.Tizen.Sdk,Samsung.Tizen.Templates" >/dev/null 2>&1
assert "a reservation with a different package set is rejected" \
    "$([[ $? -eq 3 ]] && echo 1 || echo 0)"

# A bare pre-payload reservation carries no inputs, so it cannot be validated - and
# therefore must not be resumed rather than being trusted by default.
echo '{"version":"10.0.128","sha":"'"$GOOD_SHA"'"}' > "$RESDIR/legacy.json"
python3 "$RES" verify --payload-file "$RESDIR/legacy.json" --expect-version 10.0.128 >/dev/null 2>&1
assert "a reservation missing its input fields is refused, not trusted" \
    "$([[ $? -eq 3 ]] && echo 1 || echo 0)"

python3 "$RES" encode --version 10.0.128 --sha "deadbeef" --sdk x --band y \
    --manifest-id z --packages a --branch b >/dev/null 2>&1
assert "an abbreviated SHA is refused when reserving" \
    "$([[ $? -eq 2 ]] && echo 1 || echo 0)"
rm -rf "$RESDIR"

# --- functional: OLD == NEW must be a no-op, not a failure -------------------
#
# The workflow calls `--apply --set-version` OUTSIDE a condition under `set -e`, so a
# non-zero exit killed the step and made the documented "reserve the current commit"
# recovery below it unreachable. This proves the exit code, which is what set -e sees.
NWDIR="$(mktemp -d)"
cat > "$NWDIR/Versions.props" <<'PROPS'
<Project>
  <PropertyGroup>
    <TizenWorkloadVersion>10.0.128</TizenWorkloadVersion>
  </PropertyGroup>
</Project>
PROPS
python3 "$WORKLOAD_DIR/scripts/next-workload-version.py" --apply --set-version 10.0.128 \
    --versions-props "$NWDIR/Versions.props" >/dev/null 2>&1
assert "--set-version equal to the current value exits 0 (OLD == NEW is resumable)" \
    "$([[ $? -eq 0 ]] && echo 1 || echo 0)"

assert "the no-op leaves Versions.props byte-identical" \
    "$(grep -q '<TizenWorkloadVersion>10.0.128</TizenWorkloadVersion>' "$NWDIR/Versions.props" && echo 1 || echo 0)"

# Going BACKWARDS is still a hard error: only the equal case is a resume.
python3 "$WORKLOAD_DIR/scripts/next-workload-version.py" --apply --set-version 10.0.127 \
    --versions-props "$NWDIR/Versions.props" >/dev/null 2>&1
assert "--set-version below the current value is still refused" \
    "$([[ $? -ne 0 ]] && echo 1 || echo 0)"
rm -rf "$NWDIR"

# --- functional: a 200 that cannot be parsed is not "never published" --------
FEED="$(mktemp -d)"
mkdir -p "$FEED/samsung.tizen.sdk"
# `{}` used to yield [] via .get("versions", []), making a published package look missing.
echo '{}' > "$FEED/samsung.tizen.sdk/index.json"
python3 "$WORKLOAD_DIR/scripts/release-state.py" --version 10.0.128 \
    --band 11.0.100-preview.7 --feed-base "file://$FEED" >/dev/null 2>&1
assert "an index with no 'versions' key is an error, not absence" \
    "$([[ $? -eq 2 ]] && echo 1 || echo 0)"

echo '{"versions": "10.0.128"}' > "$FEED/samsung.tizen.sdk/index.json"
python3 "$WORKLOAD_DIR/scripts/release-state.py" --version 10.0.128 \
    --band 11.0.100-preview.7 --feed-base "file://$FEED" >/dev/null 2>&1
assert "an index whose 'versions' is not a list is an error" \
    "$([[ $? -eq 2 ]] && echo 1 || echo 0)"
rm -rf "$FEED"

# --- functional: the search index is paginated and validated -----------------
#
# The search endpoint caps results per request, so a single query returned only the first
# page. The stub feed puts the highest build counter on the LAST page: an unpaginated
# reader answers 10.0.102 (a version already published) instead of 10.0.106.
STUB="$WORKLOAD_DIR/scripts/stub-nuget-search.py"
assert "the search index is paginated to completion" \
    "$([[ "$(python3 "$STUB" ok)" == "rc=0 out=10.0.106" ]] && echo 1 || echo 0)"

for mode in truncated nototal badtotal; do
    assert "a $mode search response aborts instead of lowering the version" \
        "$([[ "$(python3 "$STUB" "$mode")" == "rc=1 out=" ]] && echo 1 || echo 0)"
done


# --- failure injection against the real state script # --- failure injection against the real state script -------------------------
#
# Simulates a release interrupted at each step, using a local file:// feed, and asserts the
# resume decision the workflow would make.

STATE_PY="$WORKLOAD_DIR/scripts/release-state.py"
FEED="$(mktemp -d)"
trap 'rm -rf "$FEED"' EXIT

seed() {  # seed <package-id> <version>
    mkdir -p "$FEED/$1"
    printf '{"versions":["%s"]}' "$2" > "$FEED/$1/index.json"
}
state_of() {
    python3 "$STATE_PY" --version "$1" --band 11.0.100-preview.7 \
        --feed-base "file://$FEED" 2>/dev/null | sed -n 's/^state=//p'
}

V=10.0.130
MANIFEST_ID=samsung.net.sdk.tizen.manifest-11.0.100-preview.7

echo ""
echo "-- failure injection --"

rm -rf "$FEED"; mkdir -p "$FEED"
assert "nothing published -> unpublished" "$([[ "$(state_of $V)" == "unpublished" ]] && echo 1 || echo 0)"

# Interrupted immediately after the manifest push (the exact case that stranded V).
seed "$MANIFEST_ID" "$V"
assert "interrupted after manifest push -> partial" "$([[ "$(state_of $V)" == "partial" ]] && echo 1 || echo 0)"

# Interrupted midway through the companion packs.
seed samsung.tizen.sdk "$V"
assert "interrupted after one companion pack -> partial" "$([[ "$(state_of $V)" == "partial" ]] && echo 1 || echo 0)"

seed samsung.netcore.app.runtime.tizen "$V"
assert "interrupted before the last pack -> partial" "$([[ "$(state_of $V)" == "partial" ]] && echo 1 || echo 0)"

seed samsung.tizen.templates "$V"
assert "all packs present -> published" "$([[ "$(state_of $V)" == "published" ]] && echo 1 || echo 0)"

# A different version must be unaffected by V's artifacts.
assert "an unrelated version is still unpublished" "$([[ "$(state_of 10.0.131)" == "unpublished" ]] && echo 1 || echo 0)"

# A feed that cannot be reached must NOT read as "unpublished" - that would advance the
# version and strand the partial release.
python3 "$STATE_PY" --version "$V" --band 11.0.100-preview.7 \
    --feed-base "http://127.0.0.1:9/unreachable" >/dev/null 2>&1
assert "unreachable feed exits non-zero (never 'unpublished')" \
    "$([[ $? -ne 0 ]] && echo 1 || echo 0)"

echo ""
echo "=========== release-workflow summary ==========="
echo "  passed: $pass"
echo "  failed: $fail"

[[ $fail -eq 0 ]] || exit 1
exit 0
