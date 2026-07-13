#!/usr/bin/env bash
# Pre-flight check against the anti-patterns. RUN THIS BEFORE POSTING, not after.
#
# Everything it checks is something we actually shipped and had to retract on
# 2026-07-13. It exists because "be careful" is not a control.
#
#   ./preflight.sh                # audit every open PR + our live comments
#   ./preflight.sh --pr 1982      # one PR
#   ./preflight.sh --text file.md # a draft comment/body BEFORE you post it
set -uo pipefail
UP="obra/superpowers"; ME="muunkky"
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

  # AP1 — assertion in place of execution
  grep -qiE "by inspection|this could (cause|lead)|my review agent|should (in theory|probably)" <<<"$T" && \
    flag "AP1: assertion, not execution. Run it and quote the output."

  # Unverifiable numbers — their triage re-runs every one.
  n=$(grep -oE "~[0-9]+|approximately [0-9]+|roughly [0-9]+|[0-9]+ (added )?words" <<<"$T" | wc -l)
  [ "$n" -gt 0 ] && flag "AP1: $n unverifiable/approximate count(s) (incl. word counts). Use git diff --numstat — they re-run it."

  # AP7 — sounding like a bot
  local len=${#T} bold; bold=$(( $(grep -o '\*\*' <<<"$T" | wc -l) / 2 ))
  if [ "$C" = "1" ]; then
    [ "$len" -gt 2000 ] && flag "AP7: $len chars. A comment over ~2000 is showing off." || ok "length ${len}"
    [ "$bold" -gt 4 ] && flag "AP7: $bold bolds. Plain prose." || ok "$bold bolds"
    grep -qE "^#{1,3} " <<<"$T" && flag "AP7: headings in a comment. It's a message, not a document."
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
  --text) check_text "draft: $2" "$(cat "$2")" 1; echo; [ $fail -eq 0 ] && echo "✅ safe to post" || echo "🔴 FIX BEFORE POSTING"; exit $fail ;;
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
    grep -qE "#$c[^0-9].{0,40}(merged|MERGED)" <<<"$body" && said="MERGED"
    grep -qE "#$c[^0-9].{0,40}(open|OPEN|draft)" <<<"$body" && said="OPEN"
    grep -qE "#$c[^0-9].{0,40}(closed|CLOSED)" <<<"$body" && said="CLOSED"
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
