#!/usr/bin/env bash
# Sweep every upstream thread we've touched for activity we haven't seen.
#
# The thread list is DERIVED from GitHub, never hand-maintained — a manifest we
# had to remember to update would go stale silently, and the sweep would then
# report "nothing new" while skipping a thread. GitHub already knows every issue
# and PR we've commented on or authored; that IS the manifest.
#
# The only state is a last-checked timestamp (WATCH.state, gitignored).
#
# Usage:
#   ./check-upstream.sh              # activity since last run
#   ./check-upstream.sh --since 24h  # activity in a window (doesn't move the mark)
#   ./check-upstream.sh --all        # every thread + its state, ignore timestamps
set -uo pipefail

# Identity is DERIVED, never hardcoded. A hardcoded account is a silent
# wrong-answer bug: run by anyone else, the sweep enumerates someone else's
# threads, finds none of yours, and prints its success banner — and you trust it.
# The remotes already know who you are; ask them.
UPSTREAM="$(git remote get-url upstream 2>/dev/null | sed -E 's#.*github\.com[:/]##; s#\.git$##')"
ME="$(git remote get-url origin 2>/dev/null | sed -E 's#.*github\.com[:/]##; s#/.*##')"
[ -n "$UPSTREAM" ] || { echo "no 'upstream' remote — run scripts/fork-setup.sh" >&2; exit 2; }
[ -n "$ME" ]       || { echo "no 'origin' remote — cannot tell whose threads to sweep" >&2; exit 2; }
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE="$DIR/WATCH.state"

MODE="since-last"
case "${1:-}" in
  --all)   MODE="all" ;;
  --since) MODE="window"; WINDOW="${2:?--since needs a value like 24h or 7d}" ;;
esac

if [ "$MODE" = "window" ]; then
  SINCE=$(date -u -d "-${WINDOW/h/ hours}" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null \
       || date -u -d "-${WINDOW/d/ days}"  +%Y-%m-%dT%H:%M:%SZ)
elif [ -f "$STATE" ] && [ "$MODE" = "since-last" ]; then
  SINCE=$(cat "$STATE")
else
  SINCE="1970-01-01T00:00:00Z"
fi
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "═══ upstream sweep — $UPSTREAM"
[ "$MODE" = "all" ] && echo "    every thread we've touched" || echo "    activity since $SINCE"
echo

# --- derive the thread list: anything we authored or commented on -------------
# NOTE: `gh search issues` does NOT return pull requests. Both queries are
# required, or the sweep silently skips every PR — including our own. (Found by
# running it: the first version reported 4 threads and missed all four of our PRs.)
threads=$( { gh search issues --repo "$UPSTREAM" --author "$ME"    --limit 100 --json number --jq '.[].number'
             gh search issues --repo "$UPSTREAM" --commenter "$ME" --limit 100 --json number --jq '.[].number'
             gh search prs    --repo "$UPSTREAM" --author "$ME"    --limit 100 --json number --jq '.[].number'
             gh search prs    --repo "$UPSTREAM" --commenter "$ME" --limit 100 --json number --jq '.[].number'
           } 2>/dev/null | sort -un )

[ -z "$threads" ] && { echo "  (no threads found — is gh authenticated?)"; exit 0; }

needs_reply=0; total=0
for n in $threads; do
  total=$((total+1))
  # No external jq dependency — gh has --jq built in.
  read -r state ispr title <<<"$(gh api "repos/$UPSTREAM/issues/$n" \
      --jq '"\(.state) \(.pull_request != null) \(.title)"' 2>/dev/null)" || continue
  [ -z "$state" ] && continue
  kind=$([ "$ispr" = true ] && echo PR || echo issue)

  # new comments from anyone who is not us
  new=$(gh api "repos/$UPSTREAM/issues/$n/comments?since=$SINCE" --paginate \
          --jq ".[] | select(.user.login != \"$ME\") | \"\(.user.login)|\(.created_at)|\(.body[0:220] | gsub(\"[\\n\\r]\"; \" \"))\"" 2>/dev/null)

  # PR reviews (a review is not an issue comment — easy to miss)
  reviews=""
  if [ "$ispr" = true ]; then
    reviews=$(gh api "repos/$UPSTREAM/pulls/$n/reviews" \
                --jq ".[] | select(.user.login != \"$ME\") | select(.submitted_at > \"$SINCE\") | \"\(.user.login)|\(.state)|\(.body[0:220] | gsub(\"[\\n\\r]\"; \" \"))\"" 2>/dev/null)
  fi

  if [ "$MODE" = "all" ]; then
    printf '  %-5s #%-5s [%s] %s\n' "$kind" "$n" "$state" "${title:0:60}"
    continue
  fi

  [ -z "$new" ] && [ -z "$reviews" ] && continue

  needs_reply=$((needs_reply+1))
  echo "──────────────────────────────────────────────────────────────"
  echo "  $kind #$n [$state] — $title"
  echo "  https://github.com/$UPSTREAM/issues/$n"
  [ -n "$reviews" ] && while IFS='|' read -r who st body; do
      echo "    ★ REVIEW by @$who ($st)"; echo "      ${body}"
    done <<<"$reviews"
  [ -n "$new" ] && while IFS='|' read -r who when body; do
      flag=""; [ "$who" = "obra" ] && flag="  ⚑ MAINTAINER"
      echo "    → @$who$flag  $when"; echo "      ${body}"
    done <<<"$new"
  echo
done

echo "══════════════════════════════════════════════════════════════"
if [ "$MODE" = "all" ]; then
  echo "  $total threads touched."
else
  echo "  $needs_reply of $total threads have new activity."
  if [ "$needs_reply" -eq 0 ]; then
    echo "  Nothing to answer. (Silence here is normal — ~76% of decided PRs are"
    echo "   closed unmerged and closures come in waves. Quiet is not a verdict.)"
  else
    echo
    echo "  For each: decide reply / record / ignore."
    echo "  Anything where SOMEONE ELSE ACTED because of us — a citation, our code"
    echo "  taken, a close with a reason — goes in CREDIBILITY.md. Routine chatter"
    echo "  does not; that ledger is signals, not a log."
  fi
fi

# Only advance the mark on a real sweep — never on a --since window or --all.
if [ "$MODE" = "since-last" ]; then echo "$NOW" > "$STATE"; fi
exit 0
