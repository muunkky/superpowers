#!/usr/bin/env bash
# Re-establish the two things that DO NOT travel through git. Run once per clone.
#
#   .claude/skills/contributing/fork-setup.sh
#
# Without this, a fresh clone is silently unsafe:
#
#   1. No .git/info/exclude  → gitban's artifacts (PRDs, ADRs, cards, roadmap) become
#      visible to git, so they can be committed onto a contribution branch and shipped
#      upstream. The whole "the upstream PR is a clean slice of code only" guarantee is
#      not discipline — it is this file. git cannot commit what it cannot see.
#
#   2. No 'upstream' remote with its push URL DISABLED → `git push upstream` reaches the
#      canonical repo. Fetch-only is the point.
#
# Idempotent. Safe to re-run.
set -uo pipefail

UPSTREAM_URL="${UPSTREAM_URL:-https://github.com/obra/superpowers.git}"
PARENT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not a git repo" >&2; exit 2; }
cd "$PARENT"

# --- 1. upstream remote, fetch-only -----------------------------------------
if git remote get-url upstream >/dev/null 2>&1; then
  echo "✅ upstream remote exists: $(git remote get-url upstream)"
else
  git remote add upstream "$UPSTREAM_URL"
  echo "✅ added upstream → $UPSTREAM_URL"
fi
git remote set-url --push upstream DISABLED
echo "✅ upstream push URL: DISABLED (a stray 'git push upstream' now fails)"

# --- 2. the local ignore that keeps artifacts invisible to git ---------------
# Deliberately .git/info/exclude and NOT the tracked .gitignore: editing the
# tracked .gitignore would itself become an upstream diff — the exact leak the
# guardrail exists to prevent.
EX=.git/info/exclude
mkdir -p "$(dirname "$EX")"; touch "$EX"
added=0
# 'tmp/' is load-bearing: the posting gate tells you to draft every comment and
# PR body into tmp/ first. If git can see those drafts, they can be committed
# onto a contribution branch and shipped upstream — the exact leak this prevents.
for e in '.gitban/' 'docs/prds/' 'docs/adr/' 'docs/designs/' 'docs/decks/' 'docs/reports/' 'CONTRIBUTING-gitban.md' 'tmp/'; do
  grep -qxF "$e" "$EX" || { echo "$e" >> "$EX"; added=$((added+1)); }
done
echo "✅ .git/info/exclude: $added entr$([ "$added" = 1 ] && echo y || echo ies) added, $(grep -cvE '^\s*(#|$)' "$EX") total"

# --- verify, don't assert ----------------------------------------------------
echo
echo "── verifying"
fail=0
[ "$(git remote get-url --push upstream 2>/dev/null)" = "DISABLED" ] \
  && echo "  ✅ push to upstream is blocked" \
  || { echo "  🔴 upstream push URL is NOT disabled"; fail=1; }

# The real test: can git still see an artifact path? Use a path that is ignored
# by pattern, not one that happens not to exist.
probe=".gitban/__forksetup_probe"
mkdir -p .gitban 2>/dev/null && : > "$probe"
if git check-ignore -q "$probe"; then
  echo "  ✅ .gitban/ is invisible to git (artifacts cannot be committed by accident)"
else
  echo "  🔴 .gitban/ is STILL VISIBLE to git — artifacts can leak into an upstream PR"; fail=1
fi
rm -f "$probe"

echo
[ "$fail" -eq 0 ] && echo "✅ clone is set up" || { echo "🔴 setup incomplete — fix before contributing"; exit 1; }
