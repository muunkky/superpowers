#!/usr/bin/env bash
# Regression suite for the contributing playbook itself.
#
#   .claude/skills/contributing/selftest.sh
#
# Every check here is a mistake we actually shipped. The playbook tells you to
# never assert what you have not executed; this is the playbook holding itself
# to that. Run it after editing the skill, and on a fresh clone.
#
# It tests the CONTROLS, not the prose: that the guardrail exists, that the
# gates catch what they claim to catch, and that no attestation is pre-filled.
set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 2
D=.claude/skills/contributing
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

pass=0; fail=0
ok()   { echo "  ✅ $1"; pass=$((pass+1)); }
bad()  { echo "  🔴 $1"; fail=$((fail+1)); }
grp()  { echo; echo "── $1"; }

# ─────────────────────────────────────────────────────────────────────────────
grp "the tooling exists and runs"
for s in preflight check-upstream fork-setup selftest; do
  [ -x "$D/$s.sh" ] && ok "$s.sh present + executable" || bad "$s.sh MISSING or not executable"
done
if command -v shellcheck >/dev/null 2>&1; then
  for s in preflight check-upstream fork-setup selftest; do
    shellcheck -S error "$D/$s.sh" >/dev/null 2>&1 && ok "$s.sh shellcheck clean" || bad "$s.sh has shellcheck ERRORS"
  done
else
  echo "  ⚠️  shellcheck not installed — skipping lint"
fi

# Documented ≠ shipped. fork-setup.sh was prose in a code block for months and
# nobody noticed the guardrail did not exist on disk.
grp "every path the skill points at actually exists"
while read -r p; do
  [ -z "$p" ] && continue
  [ -e "$p" ] && ok "referenced path exists: $p" || bad "DEAD REFERENCE in SKILL.md: $p"
done < <(grep -oE '`\.claude/skills/contributing/[a-zA-Z0-9._/-]+`|`docs/reports/[a-zA-Z0-9._/-]+`' "$D/SKILL.md" \
         | tr -d '`' | sort -u)

# ─────────────────────────────────────────────────────────────────────────────
grp "the guardrail: artifacts must be invisible to git"
# Probe by pattern, not by a file that happens not to exist.
probe=".gitban/__selftest_probe"; mkdir -p .gitban 2>/dev/null; : > "$probe"
git check-ignore -q "$probe" && ok ".gitban/ is invisible to git" \
  || bad ".gitban/ IS VISIBLE — artifacts can be committed into an upstream PR"
rm -f "$probe"
for d in docs/prds docs/adr docs/designs docs/decks docs/reports; do
  probe="$d/__selftest_probe"; mkdir -p "$d" 2>/dev/null; : > "$probe"
  git check-ignore -q "$probe" || bad "$d/ IS VISIBLE to git — lifecycle artifacts can leak upstream"
  rm -f "$probe"
done
git check-ignore -q "docs/prds/__x" && ok "lifecycle doc dirs are invisible to git"

grp "the guardrail: upstream is fetch-only"
[ "$(git remote get-url --push upstream 2>/dev/null)" = "DISABLED" ] \
  && ok "upstream push URL is DISABLED" \
  || bad "upstream push URL is NOT disabled — 'git push upstream' can hit the canonical repo"

# The tracked .gitignore must NOT carry the artifact entries: putting them there
# would itself be an upstream diff — the exact leak the guardrail prevents.
grep -qE '^\.gitban/|^docs/prds/' .gitignore 2>/dev/null \
  && bad "artifact ignores leaked into the TRACKED .gitignore (that becomes an upstream diff)" \
  || ok "tracked .gitignore is clean of our artifact entries"

# ─────────────────────────────────────────────────────────────────────────────
grp "no attestation is pre-filled (the #1906 kill)"
# A template that ships its own answers gets recited, not read. Ours shipped a
# named human reviewer; any team using it would attest a human who never looked.
PRT=.claude/skills/gitban-pr/SKILL.local.md
if [ -f "$PRT" ]; then
  grep -qiE '\| *Human partner who reviewed this diff *\| *[A-Z][a-z]+ [A-Z]' "$PRT" \
    && bad "PR template PRE-FILLS a human reviewer name — it will be recited, not read" \
    || ok "PR template does not pre-fill a human reviewer"
  # Must catch an ASSERTION, not the rule that FORBIDS one — and the rule itself
  # lives inside a table cell ("Never write 'no others'"), so position can't tell
  # them apart. Negation can: a line that says never/don't/avoid is the rule.
  grep -iE 'no others|only plugin' "$PRT" | grep -viE "never|don'?t|do not|avoid" | grep -q . \
    && bad "PR template ASSERTS 'no others' — checkable and false" \
    || ok "PR template forbids, and never makes, a 'no others' claim"
  grep -qE 'claude --version' "$PRT" && ok "PR template tells you to READ the harness version" \
    || bad "PR template does not say to read the harness version off the machine"
  grep -qE 'enabledPlugins|settings\.json' "$PRT" && ok "PR template tells you to READ the plugin list" \
    || bad "PR template does not say to enumerate plugins from settings.json"
else
  bad "gitban-pr/SKILL.local.md missing — the PR body has no fork overlay"
fi

# The overlay is appended verbatim into the package-managed SKILL.md (ADR-046).
# If those drift, you edit one and ship the other.
PRM=.claude/skills/gitban-pr/SKILL.md
if [ -f "$PRM" ] && [ -f "$PRT" ]; then
  M=$(grep -n 'SKILL.local.md overlay appended below' "$PRM" | cut -d: -f1)
  if [ -n "$M" ]; then
    diff -q <(tail -n +"$((M+2))" "$PRM") "$PRT" >/dev/null \
      && ok "gitban-pr overlay is in sync with its appended copy" \
      || bad "gitban-pr SKILL.local.md has DRIFTED from the copy appended into SKILL.md"
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
grp "identity is derived, never hardcoded"
# A hardcoded account is a silent wrong-answer bug: run by anyone else the sweep
# audits the wrong threads and still prints "clean".
grep -qE '^(ME|UP|UPSTREAM)="[a-z]' "$D/preflight.sh" "$D/check-upstream.sh" \
  && bad "an audit script HARDCODES an account/repo — it will silently audit the wrong one" \
  || ok "preflight + check-upstream derive identity from git remotes"

# ─────────────────────────────────────────────────────────────────────────────
grp "the gates actually catch what they claim to (RED)"
cat > "$TMP/bad.md" <<'EOF'
By inspection this should probably fix it. No existing PRs found.
I cannot run the evals. Roughly 40 lines changed.

Disclosure: agent-assisted — Claude Opus 4.8, Claude Code 1.0.0, gitban plugin (x.io). No others.
EOF
out=$("$D/preflight.sh" --text "$TMP/bad.md" 2>&1)
for want in "assertion, not execution" "no existing PRs" "can't run evals" "approximate count" "no others"; do
  grep -qi -- "$want" <<<"$out" && ok "preflight catches: $want" || bad "preflight MISSED: $want"
done
grep -q "FIX BEFORE POSTING" <<<"$out" && ok "preflight fails a bad draft" || bad "preflight PASSED a bad draft"

grp "the gates do not cry wolf (GREEN)"
# A gate that is always red is a gate you learn to wave through. TAP output
# (`# pass 6`) is not a markdown heading; obra's template mandates headings in a
# PR BODY, so those rules must not fire there.
cat > "$TMP/good.md" <<'EOF'
Their antigravity test holds up. The pi one does not:

```
$ node --test tests/pi/test-pi-extension.mjs
# pass 6
# fail 0
```

It passes on a file with no mapping table, which is the regression it exists to catch.
EOF
out=$("$D/preflight.sh" --text "$TMP/good.md" 2>&1)
grep -q "safe to post" <<<"$out" && ok "preflight passes a good comment (no false alarm)" \
  || bad "preflight FALSE-POSITIVES on a clean comment: $(grep '🔴' <<<"$out" | head -1)"
grep -qi "headings in a comment" <<<"$out" \
  && bad "preflight reads TAP output (# pass) as a markdown heading" \
  || ok "preflight's heading check is code-fence aware"

printf '## H\n\nbody with headings, as obras template REQUIRES.\n' > "$TMP/body.md"
out=$("$D/preflight.sh" --body "$TMP/body.md" 2>&1)
grep -qi "headings in a comment" <<<"$out" \
  && bad "--body mode flags headings that obra's PR template mandates" \
  || ok "--body mode does not flag template-mandated headings"

# ─────────────────────────────────────────────────────────────────────────────
echo
echo "════════════════════════════════════"
echo "  $pass passed, $fail failed"
[ "$fail" -eq 0 ] && { echo "  ✅ playbook is sound"; exit 0; }
echo "  🔴 playbook has $fail broken invariant(s)"; exit 1
