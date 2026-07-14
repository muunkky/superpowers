#!/usr/bin/env bash
# Pre-flight check against the anti-patterns. RUN THIS BEFORE POSTING, not after.
#
# Everything it checks is something we actually shipped and had to retract on
# 2026-07-13. It exists because "be careful" is not a control.
#
#   ./preflight.sh                # audit every open PR + our live comments
#   ./preflight.sh --pr 1982      # one PR
#   ./preflight.sh --text file.md # a draft COMMENT before you post it
#   ./preflight.sh --body file.md # a draft PR BODY (skips the comment-only length/heading rules)
set -uo pipefail
# Derived, never hardcoded — see the note in check-upstream.sh. An audit that
# silently checks the wrong account still prints "clean".
UP="$(git remote get-url upstream 2>/dev/null | sed -E 's#.*github\.com[:/]##; s#\.git$##')"
ME="$(git remote get-url origin   2>/dev/null | sed -E 's#.*github\.com[:/]##; s#/.*##')"
[ -n "$UP" ] && [ -n "$ME" ] || { echo "🔴 need 'origin' and 'upstream' remotes — run .claude/skills/contributing/fork-setup.sh" >&2; exit 2; }
fail=0
flag() { echo "  🔴 $1"; fail=1; }
ok()   { echo "  ✅ $1"; }

check_text() {  # $1=label $2=text $3=is_comment
  local L="$1" T="$2" C="${3:-0}" n
  echo "── $L"

  # AP3 — fabricated attestation. The sole-sufficient kill.
  grep -qiE "human (partner )?who reviewed|reviewed the complete diff" <<<"$T" && \
    grep -qE "^\s*-\s*\[x\]" <<<"$T" && \
    ok "has a ticked human-review box — CONFIRM the named account exists on GitHub"
  grep -qiE "I (can'?t|cannot) run (the )?evals?" <<<"$T" && \
    flag "AP3/AP1: claims we can't run evals. FALSE — the writing-skills pressure test runs locally."
  grep -qiE "no (existing|prior) PRs? (were )?found|none found" <<<"$T" && \
    flag "AP3: 'no existing PRs found' — they search, INCLUDING your own. Verify."
  grep -qiE "tested adversarially" <<<"$T" && ! grep -qiE "adversarial|turn-back|sent back|reused" <<<"$T" && \
    flag "AP3: claims adversarial testing but shows none. Show the run or untick."

  # AP3 — the disclosure must match the machine. obra's bar is "ALL installed
  # plugins"; hiding the authoring environment is a stated closing reason. On
  # 2026-07-13 all four of our PRs named only gitban while three more were
  # enabled, and #1984 asserted "No others." — a checkable false statement.
  # Scope to the disclosure line itself — "and nothing else" about a PR's scope
  # is not a claim about plugins, and "gitban plugin (...)" must still trigger.
  local DISC sf=~/.claude/settings.json p
  DISC=$(grep -iE "plugins installed|^Disclosure:|Plugins:|plugin \(" <<<"$T" || true)
  if [ -n "$DISC" ]; then
    if [ -f "$sf" ]; then
      for p in $(python3 -c "import json;print(' '.join(k.split('@')[0] for k in json.load(open('$sf')).get('enabledPlugins',{})))" 2>/dev/null); do
        grep -qi -- "$p" <<<"$DISC" || flag "AP3: disclosure omits enabled plugin '$p'. obra's bar is ALL installed plugins."
      done
    fi
    grep -qiE "no others|only plugin|nothing else" <<<"$DISC" && \
      flag "AP3: 'no others' is a checkable claim. Enumerate from settings.json instead."
  fi
  # A hardcoded harness version goes stale the moment the CLI updates. Only
  # meaningful for a DRAFT you are about to post, where "now" is when the work
  # happened. On an already-posted PR the older version is usually the honest
  # one — it is when the diff and the evals actually ran — so flagging it there
  # would paint every PR red forever and teach us to wave the gate through.
  if [ "${DRAFT:-0}" = "1" ] && command -v claude >/dev/null 2>&1; then
    local live; live=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [ -n "$live" ] && grep -qE "Claude Code [0-9]+\.[0-9]+\.[0-9]+" <<<"$T" && ! grep -q "$live" <<<"$T"; then
      flag "AP3: claims a Claude Code version that isn't the live one ($live). If the work genuinely predates the update, keep it; otherwise read it off the machine."
    fi
  fi

  # AP1 — assertion in place of execution
  grep -qiE "by inspection|this could (cause|lead)|my review agent|should (in theory|probably)" <<<"$T" && \
    flag "AP1: assertion, not execution. Run it and quote the output."

  # Unverifiable numbers — their triage re-runs every one.
  n=$(grep -oiE "~[0-9]+|approximately [0-9]+|roughly [0-9]+|[0-9]+ (added )?words" <<<"$T" | wc -l)
  [ "$n" -gt 0 ] && flag "AP1: $n unverifiable/approximate count(s) (incl. word counts). Use git diff --numstat — they re-run it."

  # AP7 — sounding like a bot
  local len=${#T} bold; bold=$(( $(grep -o '\*\*' <<<"$T" | wc -l) / 2 ))
  if [ "$C" = "1" ]; then
    [ "$len" -gt 2000 ] && flag "AP7: $len chars. A comment over ~2000 is showing off." || ok "length ${len}"
    [ "$bold" -gt 4 ] && flag "AP7: $bold bolds. Plain prose." || ok "$bold bolds"
    # Fence-aware: `# pass 6` from node --test / TAP output is not a heading.
    # A gate that cries wolf is a gate you learn to ignore.
    awk '/^```/{f=!f;next} !f' <<<"$T" | grep -qE "^#{1,3} " && \
      flag "AP7: headings in a comment. It's a message, not a document."
  fi
  grep -qiE "adversarial review round|review round|our (harness|lifecycle)|PRD|design doc|sprint" <<<"$T" && \
    flag "AP7: narrating OUR process. He cares about HIS code."
  grep -qiE "autonomous dev harness.*driving|roadmap → PRD|adversarial reviewer at each gate" <<<"$T" && \
    flag "AP7: gitban PITCH. Name it + link it (that IS the disclosure). Never describe what it does."
  grep -qiE "invents nothing|reuses? (your|the) (exact )?(construction|idiom)" <<<"$T" && \
    grep -qi "invents nothing" <<<"$T" && flag "AP7: 'invents nothing' is overstated. They'll grep it."

  # AP8 — noise
  if [ "$C" = "1" ]; then
    grep -qiE "^(closing|reopening|amended|correction to|correcting something)" <<<"$T" && \
      flag "AP8: NOISE — you're narrating your own decision. Delete it. Edit the original instead."
  fi
}

case "${1:-}" in
  --text) DRAFT=1; check_text "draft: $2" "$(cat "$2")" 1; echo; [ $fail -eq 0 ] && echo "✅ safe to post" || echo "🔴 FIX BEFORE POSTING"; exit $fail ;;
  # A PR body is NOT a comment: obra's template mandates headings and sections,
  # so the length/heading rules would fire every time. A gate that always cries
  # wolf is one you learn to wave through — that is how a control rots.
  --body) DRAFT=1; check_text "body draft: $2" "$(cat "$2")" 0; echo; [ $fail -eq 0 ] && echo "✅ safe to post" || echo "🔴 FIX BEFORE POSTING"; exit $fail ;;
  --pr)   PRS="$2" ;;
  *)      PRS=$(gh pr list -R "$UP" --author "$ME" --state open --json number --jq '.[].number') ;;
esac

for p in $PRS; do
  echo "═══ PR #$p"
  body=$(gh pr view "$p" -R "$UP" --json body --jq '.body')
  read -r add del files base <<<"$(gh pr view "$p" -R "$UP" --json additions,deletions,changedFiles,baseRefName --jq '"\(.additions) \(.deletions) \(.changedFiles) \(.baseRefName)"')"

  # every count claim must match the real diff
  for c in $(grep -oE "[0-9]+ added lines|[0-9]+ insertions|[0-9]+ files" <<<"$body" | grep -oE "^[0-9]+"); do :; done
  grep -qE "$add added lines|$add insertions" <<<"$body" || \
    grep -qE "[0-9]+ (added lines|insertions)" <<<"$body" && \
    { grep -qE "\b$add\b" <<<"$body" || flag "count claim doesn't match real diff (+$add/-$del in ${files}f)"; }
  [ "$base" = "dev" ] || flag "targets $base, not dev"

  # Cited PR/issue states go STALE — the queue moves under you. #1932 and #1933
  # flipped open→merged while our PRs sat there. Re-check every one.
  for c in $(grep -oE "#(1[0-9]{3}|[0-9]{3})" <<<"$body" | tr -d '#' | sort -un); do
    [ "$c" = "$p" ] && continue
    real=$(gh pr view "$c" -R "$UP" --json state,mergedAt --jq 'if .mergedAt then "MERGED" else .state end' 2>/dev/null)
    [ -z "$real" ] && real=$(gh issue view "$c" -R "$UP" --json state --jq '.state' 2>/dev/null)
    [ -z "$real" ] && continue
    said=""
    grep -qE "#${c}[^0-9].{0,40}(merged|MERGED)" <<<"$body" && said="MERGED"
    grep -qE "#${c}[^0-9].{0,40}(open|OPEN|draft)" <<<"$body" && said="OPEN"
    grep -qE "#${c}[^0-9].{0,40}(closed|CLOSED)" <<<"$body" && said="CLOSED"
    [ -n "$said" ] && [ "$said" != "$real" ] && flag "says #$c is $said — it is $real (state drifted)"
  done

  check_text "body" "$body" 0

  # our comments on the thread
  gh api "repos/$UP/issues/$p/comments" --jq ".[] | select(.user.login==\"$ME\") | .body" 2>/dev/null | \
  while IFS= read -r -d '' cm 2>/dev/null || [ -n "${cm:-}" ]; do :; done
  cn=$(gh api "repos/$UP/issues/$p/comments" --jq "[.[] | select(.user.login==\"$ME\")] | length")
  [ "$cn" -gt 0 ] && echo "  ⚠️  $cn comment(s) from us on this thread — each must serve HIM (AP8)"
  echo
done

echo "══════════════════"
[ $fail -eq 0 ] && echo "✅ clean" || echo "🔴 $fail issue(s) — FIX BEFORE HE SEES IT"
exit $fail
