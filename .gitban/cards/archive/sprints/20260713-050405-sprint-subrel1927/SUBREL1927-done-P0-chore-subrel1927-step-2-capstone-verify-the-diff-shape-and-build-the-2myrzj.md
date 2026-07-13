
# SUBREL1927 step 2 capstone: verify the diff shape and build the PR evidence pack

> **Sprint**: SUBREL1927 | **Type**: chore | **Step**: 2 | **Priority**: P0 | **Depends on**: step 1 (`6lu6av`)
>
> The sprint's capstone. Runs DD-002 **rev 4**'s **12 mechanical checks** against the branch, runs the
> one behavioral no-harm regression we actually have, and assembles the evidence the PR will cite.
>
> **The deliverable under test is FIVE insertions across three files — 13 added lines (RCR +1, DPA +1,
> SDD +11), 0 deleted, 0 modified.** The design was overturned three times and an earlier revision of
> this card checked for four insertions with a stale gate string. The gates below are rev 4's.
>
> **Gate on lines, never on words.** The "~120 added words" figure that appeared in earlier cards (and
> was headed for the PR body) is **false** — the five specified strings total ~165 words. A word count
> is also unfalsifiable-by-tool; the additions triple is not. `git diff --numstat` is the tightest
> single gate this sprint has: it catches a re-flowed Edit 3a, a dropped Edit 3b, and a "helpfully
> expanded" bullet, all in one line of output. Do not let a word count reach the PR body — a
> maintainer falsifies it in ten seconds, at a repo whose whole credibility strategy is making no
> easily-checked false claims.
>
> **This card does NOT open the upstream PR.** That is handled separately by the `gitban-pr` skill plus
> the `contributing` playbook (clean code-only branch off `upstream/dev`, fork showcase branch,
> authoring-environment disclosure). This card prepares and verifies; it does not push, does not open,
> does not comment upstream.

## Task Overview

* **Task Description:** Verify that the branch produced by step 1 is *exactly* the diff DD-002 rev 4 specifies — **five** pure insertions, three files, zero deletions, zero modifications, zero new headings, zero new numbered steps, harness-neutral, status-blind, with SDD's rule at **both** of its fire points — then capture the outputs as the PR's evidence pack.
* **Motivation:** Four of these checks exist specifically to stop a well-meaning executor from "improving" the change into rejection at a repo with a ~94% PR rejection rate. Check 6 (`further input` = **3**/1/1) catches SDD silently losing an agent kind's fire-point instance — the exact defect that overturned the design twice. Check 10 (status-blind) catches the single most tempting wrong edit. Check 11 catches prose landing in text the maintainer is deleting. Check 12, run naively, gives a **false pass** on this fork and a **false alarm** at the baseline. All were hit in practice while writing the design.
* **Scope:** Read-only verification against the branch + `git worktree` at `$BASE` + one shell test. **No source edits** — if a check fails, the fix belongs back in step 1's files, not here.
* **Related Work:** DD-002 §Verification (checks 1–12) and §"Definition of done (binary)"; upstream obra/superpowers issue #1927, PRs #1926 and #1934.
* **Estimated Effort:** ~30 min (plus ~10 min if the optional SDD integration test is run).

**Required Checks:**
- [x] **Task description** clearly states what needs to be done.
- [x] **Motivation** explains why this work is necessary.
- [x] **Scope** defines what will be changed.

### Required Reading

| What | Where |
| :--- | :--- |
| The 12 checks, verbatim, with both check-12 traps spelled out | `docs/designs/DD-002-subagent-release-in-workflow-bodies.md` §Verification |
| The binary DoD this card discharges | same doc, §"Definition of done (binary)" |
| Why the wording must stay status-blind | same doc, KDD-3 |
| Why SDD's rule is at the task boundary **and** needs a second instance for the final reviewer — and why both earlier sitings were wrong | same doc, KDD-2b and KDD-5 |
| The five exact strings the diff must contain | same doc, §"Interface Design — the exact prose" |

## Work Log

`$BASE` = the commit step 1 branched from (`096e15aa736d2e920fb7f1e2c954604f02ebbdb0` unless step 1 recorded drift on `upstream/dev` — use the value step 1 recorded, and say which).

| Step | Status/Details | Universal Check |
| :---: | :--- | :---: |
| **1. Review Current State** | [confirm branch, confirm `$BASE`, confirm `git status` is clean apart from the three SKILL.md] | - [x] Current state is understood and documented. |
| **2. Plan Changes** | [none — this card changes no source; it verifies] | - [x] Change plan is documented. |
| **3. Make Changes** | [N/A — read-only. Any failure routes back to step 1's files.] | - [x] Changes are implemented. |
| **4. Test/Verify** | [paste the output of checks 1–12 + the regression test] | - [x] Changes are tested/verified. |
| **5. Update Documentation** | [N/A — the three SKILL.md files are the documentation] | - [x] Documentation is updated [if applicable]. |
| **6. Review/Merge** | [evidence pack recorded on this card; PR is a separate, later step — **do not open it**] | - [x] Changes are reviewed and merged. |

#### Work Notes

**Commands/Scripts Used:**

```bash
BASE=096e15aa736d2e920fb7f1e2c954604f02ebbdb0   # or the tip step 1 branched from, if it drifted

# 1. Diff shape: exactly three files, all SKILL.md  [R6]
git diff --stat "$BASE"...HEAD
git diff --name-only "$BASE"...HEAD | grep -cv 'SKILL\.md$'          # must print 0
git diff --name-only "$BASE"...HEAD | wc -l                          # must print 3

# 2. The no-touch constraint on PR #1926's file  [R6]
git diff --name-only "$BASE"...HEAD -- skills/using-superpowers/     # must print nothing

# 3. Pure addition, AND the exact additions triple  [R6] — the tightest gate in this sprint
git diff --numstat "$BASE"...HEAD
#   Must be EXACTLY (order aside):
#      1   0   skills/requesting-code-review/SKILL.md
#      1   0   skills/dispatching-parallel-agents/SKILL.md
#     11   0   skills/subagent-driven-development/SKILL.md
#
#   Deletions column 0/0/0: all five edits are pure insertions. Edit 3a adds whole lines INSIDE an
#     existing bullet (SDD L257-259 stay byte-identical); 1, 2, 3b and 4 are new bullets. A nonzero
#     deletion count means someone re-flowed an existing line — fix the wrap in step 1, do not accept
#     it. This is the PR's headline claim.
#   Additions column 1/1/11: this single line catches a re-flowed Edit 3a (SDD drops to 10 + a
#     deletion), a dropped or consolidated Edit 3b (SDD 9), and any "helpfully expanded" bullet
#     (anything over). SDD's 11 = Edit 3a (5) + Edit 3b (2) + Edit 4 (4).
#   DO NOT substitute a word count for this. There isn't one that's true — the earlier "~120 added
#     words" was stale and false (the five strings are ~165 words) — and a word count is not
#     mechanically checkable anyway. Lines are.

# 4. Harness neutrality — no tool or platform name on any ADDED line  [R5]
git diff "$BASE"...HEAD | grep -E '^\+' \
  | grep -nE 'close_agent|spawn_agent|wait_agent|send_input|Codex|Claude|OpenCode|Gemini|Copilot|\bPi\b'
                                                                     # must find nothing

# 5. No new sections, no new numbered steps  [R6]
git diff "$BASE"...HEAD | grep -E '^\+#{1,6} |^\+\*\*[0-9]+\.'       # must find nothing

# 6. The rule, with its condition, at every fire point  [R1 R2 R3]
grep -c 'further input' \
  skills/subagent-driven-development/SKILL.md \
  skills/dispatching-parallel-agents/SKILL.md \
  skills/requesting-code-review/SKILL.md       # must be 3 / 1 / 1
#   SDD's 3 = Edit 3a (task boundary) + Edit 3b (final reviewer) + Edit 4 (Red Flags).
#   A count of 2 in SDD means an agent kind lost its fire-point instance — R1 has regressed.
#   Do NOT gate on a fixed phrase: three of the five instances legitimately say
#   "send none of them further input" / "send them no further input", not "send it further input".

# 7. The pointer, in all three bodies  [R4]
grep -c 'using-superpowers/references/' \
  skills/subagent-driven-development/SKILL.md \
  skills/dispatching-parallel-agents/SKILL.md \
  skills/requesting-code-review/SKILL.md       # must be >=1 each

# 8. The pointer actually resolves from each skill dir  [R4]
for s in subagent-driven-development dispatching-parallel-agents requesting-code-review; do
  (cd "skills/$s" && test -d ../using-superpowers/references) \
    && echo "OK  $s" || echo "BROKEN  $s"
done

# 9. The release step follows every turn-back at its site  [Architecture rule 2]
awk '/^\*\*3\. Act on feedback/,/^## Example/' skills/requesting-code-review/SKILL.md
awk '/^### 4\. Review and Integrate/,/^## Agent Prompt/' skills/dispatching-parallel-agents/SKILL.md
#   read both: the release bullet must be LAST.
#
#   SDD, by eye (KDD-2b / KDD-5) — the two sitings that were WRONG in earlier revisions:
awk '/^## Durable Progress/,/^## Red Flags/'            skills/subagent-driven-development/SKILL.md
awk '/^## Constructing Reviewer Prompts/,/^## File Handoffs/' skills/subagent-driven-development/SKILL.md
#   Edit 3a must EXTEND the task-completion ledger bullet in `## Durable Progress` — NOT sit in
#     `## Handling Implementer Status` (rev 2's site: the controller cannot yet know whether it will
#     reuse the agent) and NOT in `## Handling Reviewer ⚠️ Items` (rev 1's site: an exception handler
#     a clean task never enters). Confirm both of those sections are UNCHANGED in the diff.
#   Edit 3b must be the LAST bullet of `## Constructing Reviewer Prompts`, AFTER the fix-dispatch
#     turn-back bullet — NOT appended to the review-package bullet above it, which executes BEFORE the
#     final reviewer is dispatched.
#   Edit 4 must name BOTH agent populations (task agents AND the final whole-branch reviewer).

# 10. KDD-3 guard — the SDD rule must be status-blind
git diff "$BASE"...HEAD | grep -E '^\+' | grep -E 'NEEDS_CONTEXT|BLOCKED|DONE_WITH_CONCERNS'
                                                                     # must find nothing

# 11. KDD-7 guard — nothing we add may live in, or reference, a section PR #1934 deletes
git diff "$BASE"...HEAD | grep -E '^\+' \
  | grep -E 'Advantages|Key Benefits|Real-World Impact|Integration with Workflows|Time saved'
                                                                     # must find nothing

# 12. KDD-7 rebase drill — #1934 must still apply over OUR three files, at the pinned baseline.
#     TWO TRAPS, both hit in practice:
#     (a) `git apply --check` validates against the WORKING TREE, not $BASE. On this fork (whose main
#         is NOT a descendant of $BASE) it can silently PASS against the wrong text. Run it in a
#         worktree pinned at $BASE.
#     (b) The FULL #1934 diff does NOT apply at $BASE — it fails on skills/executing-plans/SKILL.md,
#         a file we never touch (#1934 is stale against `dev`). That is NOT a conflict with us.
#         SCOPE THE CHECK TO OUR THREE FILES.
#     (c) THIS REPO'S ADR-051 cwd-pin hook blocks unpinned git write-class invocations. The design doc
#         predates the hook. `git -C <dir> apply --check` is already pinned and passes; bare
#         `git worktree add …` is NOT and WILL BE BLOCKED. Use the pinned form below. (A one-off
#         `mcp__gitban__allow_hook_bypass_once` is the fallback, not the default.)
#     (d) Use the SESSION SCRATCHPAD, not /tmp.
SCRATCH="$SCRATCHPAD"                 # the session scratchpad dir; do not use /tmp
PARENT="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"

gh pr diff 1934 --repo obra/superpowers > "$SCRATCH/1934.diff"
git -C "$PARENT" worktree add "$SCRATCH/base" "$BASE"               # pinned — survives the ADR-051 hook
git -C "$SCRATCH/base" apply --check \
  --include='skills/subagent-driven-development/*' \
  --include='skills/dispatching-parallel-agents/*' \
  --include='skills/requesting-code-review/*' "$SCRATCH/1934.diff"  # must be CLEAN
git -C "$PARENT" worktree remove "$SCRATCH/base"

# Regression (behavioral no-harm, on the one harness we have; requires the `claude` CLI)
tests/claude-code/test-subagent-driven-development.sh
# Stronger no-harm check, run once before the PR (~10 min + API spend):
tests/claude-code/test-subagent-driven-development-integration.sh
```

**Decisions Made:**
* [Record the `$BASE` actually used and whether `upstream/dev` had drifted.]
* [Record the state of `skills/using-superpowers/references/codex-tools.md` at `dev` tip (DD-002 requires a re-read immediately before the PR) and whether PR #1934 has been updated since 2026-07-05.]

**Issues Encountered:**
* [If any check fails: **do not patch it here.** Route the fix back into step 1's three files and re-run checks 1–12 from the top.]

## Definition of Done

### Intent

Before this change is put in front of a maintainer who closes slop on sight, we can *demonstrate* — not assert — that the branch is exactly the minimal, contained change the design promised: five insertions, three files, nothing deleted, nothing reworded, no harness named, no status enumerated, the rule present at every point where an agent actually finishes, and nothing landing in text the maintainer is himself deleting. If this verification is broken or skipped, the way we find out is the PR being closed with a comment about the thing we did not check — the status-keyed "improvement", a re-flowed line that quietly turns our "zero deletions" headline into a lie, an SDD agent kind whose release instruction went missing, the accidental touch of `codex-tools.md`, or the confident-but-false claim that our patch coexists with PR #1934.

### Observable outcomes

- [x] Checks **1, 2, 3** pass: exactly 3 changed paths, all `SKILL.md`, none under `skills/using-superpowers/`, and **`git diff --numstat "$BASE"...HEAD` prints exactly `1 0` (RCR) / `1 0` (DPA) / `11 0` (SDD)** — 13 added lines, 0 deleted, 0 modified. The **additions** half of that triple is a hard gate, not decoration: SDD ≠ 11 means a re-flowed Edit 3a (10 + a deletion), a dropped/consolidated Edit 3b (9), or an expanded bullet (>11). The **deletions** half proves SDD's L257–259 ledger lines are byte-identical, i.e. Edit 3a's new sentence began on its own line
- [x] Check **4** passes: **no added line** matches `close_agent|spawn_agent|wait_agent|send_input|Codex|Claude|OpenCode|Gemini|Copilot|\bPi\b` (harness-neutrality guard)
- [x] Check **5** passes: no added line is a heading (`^\+#`) or a new numbered step (`^\+\*\*[0-9]+\.`). **New bullets are expected and fine** — they are the established pattern in these lists
- [x] Checks **6, 7, 8** pass: **`grep -c 'further input'` returns 3 / 1 / 1** across SDD / DPA / RCR — SDD's 3 = Edit 3a + Edit 3b + Edit 4; **a count of 2 in SDD is a FAIL: an agent kind lost its fire-point instance.** `using-superpowers/references/` appears ≥1 in each; the relative path **resolves** from all three skill dirs
- [x] Check **9** passes by reading: the release bullet is the **last** bullet at both RCR's and DPA's site; **Edit 3a extends the task-completion ledger bullet in `## Durable Progress`** (not `## Handling Implementer Status`, not `## Handling Reviewer ⚠️ Items` — both are earlier, WRONG sites and must be untouched in the diff); **Edit 3b is the last bullet of `## Constructing Reviewer Prompts`, after the fix-dispatch turn-back** (not on the review-package bullet above it, which runs before the final reviewer exists); **Edit 4 names both agent populations** (KDD-2b / KDD-5 / R3)
- [x] Check **10** passes: **no added line** contains `NEEDS_CONTEXT`, `BLOCKED`, or `DONE_WITH_CONCERNS` — **the status-blind guard. If this fails, the rule is WRONG** (it would tell a controller to hold a `BLOCKED` agent open forever) and the sprint does not ship until step 1 is corrected
- [x] Check **11** passes: no added line sits in, or references, `Advantages` / `Key Benefits` / `Real-World Impact` / `Integration with Workflows` / `Time saved`
- [x] Check **12** passes **in the correct form**: run in a `git worktree` pinned at `$BASE` **and** `--include`-scoped to our three skill dirs. An unscoped run is invalid evidence — it gives a false pass against this fork's working tree and a false alarm on `executing-plans` (a file we never touch)
- [x] `tests/claude-code/test-subagent-driven-development.sh` — **no-harm confirmed against the baseline** (deferred to o2sz0d). The original wording of this box ("**passes**") was UNSATISFIABLE and has been corrected rather than faked: the suite **fails at the pristine `096e15aa` baseline too**, with ZERO of our changes present. Reproduced independently THREE times (executor, reviewer, capstone), each tripping a *different* assertion — which is itself the proof. Root cause is upstream: `tests/claude-code/test-helpers.sh:38` runs `grep -q "$pattern"` with **no `-i`**, case-sensitively matching non-deterministic free-form LLM prose, so semantically-correct output fails on capitalisation ("**Do Not Trust** the Report" vs `not trust`; "**Read the plan** once" vs `read.*plan`). It probes `task-reviewer-prompt.md`, a file this card never touches. **The honest claim — and the ONLY one the PR may make:** this suite **fails at the pristine baseline and is therefore not a usable oracle in EITHER direction**. We disclose it; we do not claim it as evidence.

**Do NOT argue "no-harm by construction" (i.e. "our diff deletes nothing, so no existing assertion can break").** That reasoning is OVERCLAIMED and self-defeating: these assertions are not over file text, they are over **non-deterministic LLM prose generated from the file**, and the model demonstrably reads the working-tree `SKILL.md` — so adding 11 lines DOES change its input and CAN flip a case-sensitive match. Worse, it contradicts this PR's own thesis: **we are arguing that adding prose to a SKILL.md changes what a controller does.** We cannot argue that and simultaneously argue that adding prose to a SKILL.md cannot change what a model says about that skill. @obra maintains an eval harness *because* he believes skill prose shapes behaviour — he is precisely the reader who would catch that contradiction.

Our actual no-harm evidence was never this suite: it is the **`--numstat` triple** (`1 0`, `1 0`, `11 0` — zero deletions, zero modifications) and the **#1934 disjointness drill**. Fixing the flaky harness is a SEPARATE upstream problem (one problem per PR), filed as `o2sz0d`; it must NOT be bundled into this PR. (Note for `o2sz0d`: `-i` fixes both observed failures but does not make the suite *sound* — do not let it be closed by a one-character patch.)
- [x] The evidence pack is recorded on this card: raw output of checks 1–12, the regression result, the `$BASE` actually used, the re-read state of `codex-tools.md` at `dev` tip, and the current state of PR #1934
- [x] **No PR was opened, no branch pushed upstream, no upstream comment posted** by this card
- [x] **Capstone:** on a clean checkout of the branch, one pass of checks 1–12 runs green end to end and `git diff "$BASE"...HEAD` prints **five hunks and only five hunks — all pure insertions (`+` lines only), across exactly three `SKILL.md` files, with `--numstat` reading exactly `1 0` / `1 0` / `11 0` (13 added lines, 0 deleted, 0 modified), zero new headings, zero new numbered steps** — which is, verbatim, the diff shape DD-002 rev 4 promises and **the only quantitative claim the PR body may make about the size of this change.**

## Completion & Follow-up

| Task | Detail/Link |
| :--- | :--- |
| **Changes Made** | [none — verification only; the diff is step 1's] |
| **Files Modified** | [0 by this card; the branch's 3 SKILL.md are verified] |
| **Pull Request** | **N/A — deliberately not opened by this card.** Handoff: `gitban-pr` + `contributing` playbook. |
| **Testing Performed** | [checks 1–12 + `tests/claude-code/test-subagent-driven-development.sh` (+ the integration test, if run)] |

### Follow-up & Lessons Learned

| Topic | Status / Action Required |
| :--- | :--- |
| **Related Chores Identified?** | [e.g. `codex-tools.md` widening — belongs to PR #1926, not us] |
| **Documentation Updates Needed?** | [PR body must carry the exact, uncompressed #1934 disjointness sentence from DD-002 KDD-7 §2 — **never** compress it to "pure deletions", which is false for RCR. **And the PR body's size claim must be the `--numstat` triple (13 added lines: 1/1/11, 0 deleted), NEVER a word count** — the "~120 added words" figure is stale and false (~165), and DD-002 rev 4 still carries it in its Word budget line and DoD; that doc line is wrong and the PR must not inherit it.] |
| **Follow-up Work Required?** | [Correction owed on upstream issue #1927: our intent comment there proposed option (a); we are landing (c). Post it with/before the PR — handled by the PR step, flagged here.] |
| **Process Improvements?** | [record whether check 12's two traps recurred] |
| **Automation Opportunities?** | [checks 1–12 are a candidate for a reusable verification script if we do this again] |

### Completion Checklist

- [x] All planned changes are implemented. — **N/A: verification card, no source changes**
- [x] Changes are tested/verified (tests pass, configs work, etc.).
- [x] Documentation is updated (CHANGELOG, README, etc.) if applicable. — **N/A**
- [x] Changes are reviewed (self-review or peer review as appropriate).
- [x] Pull request is merged or changes are committed. — **N/A: PR is out of scope for this card by design**
- [x] Follow-up tickets created for related work identified during execution.


## PR Evidence Pack — SUBREL1927 capstone (checks 1–12 + regression)

**Run context.** Executed **direct on branch `subagent-release-in-workflow-bodies` @ `97cc870ac687cda5fece30a9eb4ec6ef0cb2447e`** in `/home/cameron/projects/superpowers`. No source file was changed by this card; `git status --short` is empty.

**`$BASE` used: `096e15aa736d2e920fb7f1e2c954604f02ebbdb0`.** Re-fetched `upstream/dev` this session — its tip is still `096e15aa…`. **No drift.** `git merge-base --is-ancestor $BASE HEAD` → yes.

---

### Checks 1–12 — verbatim results

**CHECK 1 — diff shape (3 files, all SKILL.md). PASS**
```
$ git diff --stat 096e15aa...HEAD
 skills/dispatching-parallel-agents/SKILL.md |  1 +
 skills/requesting-code-review/SKILL.md      |  1 +
 skills/subagent-driven-development/SKILL.md | 11 +++++++++++
 3 files changed, 13 insertions(+)
$ git diff --name-only 096e15aa...HEAD | grep -cv 'SKILL\.md$'   → 0
$ git diff --name-only 096e15aa...HEAD | wc -l                    → 3
```

**CHECK 2 — no-touch on PR #1926's file. PASS**
```
$ git diff --name-only 096e15aa...HEAD -- skills/using-superpowers/
(no output)
```

**CHECK 3 — the additions triple (THE gate). PASS**
```
$ git diff --numstat 096e15aa...HEAD
1	0	skills/dispatching-parallel-agents/SKILL.md
1	0	skills/requesting-code-review/SKILL.md
11	0	skills/subagent-driven-development/SKILL.md
```
**13 added lines, 0 deleted, 0 modified.** RCR `1 0` / DPA `1 0` / SDD `11 0`, exactly as DD-002 rev 4 specifies. SDD's 11 = Edit 3a (5) + Edit 3b (2) + Edit 4 (4). Independently confirmed by `grep -c '^-'` over the SDD diff body → **0 deleted lines**, so SDD's ledger lines are byte-identical (Edit 3a began on its own line, no re-flow).

**CHECK 4 — harness neutrality. PASS** — grep for `close_agent|spawn_agent|wait_agent|send_input|Codex|Claude|OpenCode|Gemini|Copilot|\bPi\b` over added lines: **no match** (grep exit 1).

**CHECK 5 — no new headings, no new numbered steps. PASS** — grep `^\+#{1,6} |^\+\*\*[0-9]+\.` over the diff: **no match** (grep exit 1). Five new bullets only.

**CHECK 6 — `grep -c 'further input'`. PASS (3 / 1 / 1)**
```
skills/subagent-driven-development/SKILL.md:3
skills/dispatching-parallel-agents/SKILL.md:1
skills/requesting-code-review/SKILL.md:1
```
SDD's 3 = Edit 3a + Edit 3b + Edit 4. No agent kind lost its fire-point instance.

**CHECK 7 — `grep -c 'using-superpowers/references/'`. PASS (≥1 each: SDD 1 / DPA 1 / RCR 1).**

**CHECK 8 — relative pointer resolves from each skill dir. PASS**
```
OK  subagent-driven-development
OK  dispatching-parallel-agents
OK  requesting-code-review
```

**CHECK 9 — siting, by reading. PASS**
- **RCR** — release bullet is the **last** bullet under `**3. Act on feedback:**`, after "Push back if reviewer is wrong".
- **DPA** — release bullet is the **last** bullet under `### 4. Review and Integrate`, after "Integrate all changes".
- **SDD Edit 3a** — extends the **task-completion ledger bullet in `## Durable Progress`** (the `Task N: complete (...)` bullet). Confirmed by section map: SDD hunks land at old lines **215, 257, 387**; the two earlier WRONG sites — `## Handling Implementer Status` (L132–149) and `## Handling Reviewer ⚠️ Items` (L150–158) — are **outside every hunk and are untouched**.
- **SDD Edit 3b** — the **last** bullet of `## Constructing Reviewer Prompts`, immediately after the "dispatch ONE fix subagent with the complete findings list" (fix-dispatch turn-back) bullet, and immediately before `## File Handoffs`. Not on the review-package bullet.
- **SDD Edit 4** — Red Flags `**Never:**` bullet names **both populations**: "a task's implementer, reviewer and fixers at task close-out, **and** the final whole-branch reviewer once you have acted on its findings".

**CHECK 10 — KDD-3 status-blind guard. PASS** — no added line contains `NEEDS_CONTEXT`, `BLOCKED`, or `DONE_WITH_CONCERNS` (grep exit 1).

**CHECK 11 — nothing lands in / references text #1934 deletes. PASS** — no added line matches `Advantages|Key Benefits|Real-World Impact|Integration with Workflows|Time saved` (grep exit 1).

**CHECK 12 — #1934 coexistence drill. PASS, run in the correct form.**
Both traps avoided: run in `git worktree`s (ADR-051-pinned `git -C "$PARENT" worktree add --detach`, in the **session scratchpad**, not `/tmp`), and `--include`-scoped to our three skill dirs.

- **12a (control) — #1934 scoped to our 3 files, applied in a worktree pinned at `$BASE`:** `git apply --check` → **CLEAN (exit 0)**. All 3 patches checked, 9 others skipped by `--include`.
- **12b (the real coexistence test) — #1934 scoped to our 3 files, applied in a worktree pinned at OUR branch `97cc870`:** **CLEAN (exit 0)**, with only benign line offsets, which is the positive proof of disjointness:
```
Checking patch skills/dispatching-parallel-agents/SKILL.md...
Hunk #1 succeeded at 159 (offset 1 line).
Hunk #2 succeeded at 166 (offset 1 line).
Checking patch skills/requesting-code-review/SKILL.md...
Hunk #2 succeeded at 73 (offset 1 line).
Checking patch skills/subagent-driven-development/SKILL.md...
Hunk #1 succeeded at 339 (offset 7 lines).
```
- **12c (negative control) — UNSCOPED #1934 at `$BASE`:** fails, exactly as DD-002 documents — `error: patch failed: skills/executing-plans/SKILL.md:11` — a file we never touch. #1934 is stale against `dev`. **This is a false alarm, not a conflict with us.**

**PR #1934 current state (re-read this session):** `#1934` — *"refactor: strip social proof, self-selling, and recap detritus from 12 skills (eval-gated)"* — **OPEN, draft**, base `dev`, head `skill-detritus-cleanup`, **12 files, +12 / −223**, `updatedAt` **2026-07-05T19:31:23Z** (unchanged since the design was written).

---

### Regression test — DISCLOSED PRE-EXISTING FAILURE (not caused by this change)

`tests/claude-code/test-subagent-driven-development.sh`

| Tree | Result |
| :--- | :--- |
| **Our branch `97cc870`** | **FAIL** — `[FAIL] Reviewer is skeptical` (Test 5) |
| **Pristine baseline `096e15aa` (clean `git worktree`, zero changes)** | **FAIL** — `[FAIL] Mentions loading plan` (Test 1) |

**The suite fails at the untouched upstream baseline too, and it fails on a *different* assertion each run.** Root cause is upstream and pre-existing: `tests/claude-code/test-helpers.sh:38` is
```bash
if echo "$output" | grep -q "$pattern"; then
```
— `grep -q` with **no `-i`**, case-sensitively string-matching free-form, non-deterministic LLM prose. Both observed failures are pure case mismatches on text that *does* satisfy the assertion semantically:
- branch run, Test 5: pattern `not trust\|don't trust\|skeptical\|…`; the model answered *"**Do Not Trust** the Report … treat … as **unverified claims**"*.
- baseline run, Test 1: pattern `Load Plan\|read.*plan\|extract.*tasks`; the model answered *"**Read the plan** once"*.

This test probes files this card never touches, our change deletes nothing, and fixing the helper is **out of scope** (one problem per PR). **Recorded as a disclosed pre-existing failure — we do NOT claim the suite passes.**

`tests/claude-code/test-subagent-driven-development-integration.sh` was **not run** (~10 min + API spend); it is optional in the card and its result would be subject to the same non-deterministic string-matching defect.

---

### Facts the PR body must carry

**1. Size claim — the ONLY quantitative claim permitted about the size of this change:**
> Five insertions across three `SKILL.md` files: `git diff --numstat` reads `1 0` (requesting-code-review), `1 0` (dispatching-parallel-agents), `11 0` (subagent-driven-development) — **13 added lines, 0 deleted, 0 modified.**

**No word count.** The "~120 added words" figure that survives in DD-002 rev 4's Word-budget line and DoD is **false** (the five strings total ~165 words) and is unfalsifiable-by-tool. Do not let it into the PR body.

**2. The #1934 disjointness statement — VERBATIM from DD-002 KDD-7 §2. Do NOT compress it to "#1934 only deletes" / "pure deletions" — that is FALSE for RCR, whose first hunk is a *rewrite* of the intro paragraph:**
> *#1934 touches all three files: in RCR it rewrites the intro paragraph and removes `## Integration with Workflows`; in DPA it removes `Time saved` / `Key Benefits` / `Real-World Impact`; in SDD it removes `## Advantages`. All are disjoint from our five insertions, which land in the workflow steps it preserves — this applies cleanly in either merge order.*

**3. `codex-rs` citations — re-verified this session against the pinned tag `rust-v0.142.5` (fetched from `raw.githubusercontent.com`, not from memory):**

- [`codex-rs/core/src/tools/handlers/multi_agents_spec.rs#L296`](https://github.com/openai/codex/blob/rust-v0.142.5/codex-rs/core/src/tools/handlers/multi_agents_spec.rs#L296) — the `close_agent` tool description, verbatim at L296:
  > *"Close an agent and any open descendants when they are no longer needed, and return the target agent's previous status before shutdown was requested. **Completed agents remain open and count toward the concurrency limit until closed.** Don't keep agents open for too long if they are not needed anymore."*
- [`codex-rs/core/src/tools/spec_plan.rs`](https://github.com/openai/codex/blob/rust-v0.142.5/codex-rs/core/src/tools/spec_plan.rs#L820-L842) @ `rust-v0.142.5`, `add_collaboration_tools`:
  - **multi-agent v1 branch (L820–842):** `let exposure = if search_tool_enabled(turn_context) { ToolExposure::Deferred } else { ToolExposure::Direct };` … `planned_tools.add_with_exposure(CloseAgentHandler, exposure);` (**L841**). ⇒ On any model with tool-search, `close_agent` — **and its obligation-bearing description** — is **`ToolExposure::Deferred`**, i.e. **not in the controller's context when the rule fires.** This is what makes the pointer load-bearing rather than redundant.
  - **multi-agent v2 branch (L771–819):** registers `SpawnAgentHandlerV2`, `SendMessageHandlerV2`, `FollowupTaskHandlerV2`, `WaitAgentHandlerV2`, **`InterruptAgentHandler`**, `ListAgentsHandlerV2` — **no `CloseAgentHandler` at all.** ⇒ The release *verb* is not stable across versions, which independently vindicates harness-neutrality.

**4. The honest limit — VERBATIM, and it must not be softened:**
> **We have not observed slot exhaustion in a live Codex session; no one on the issue has.** The mechanism is **cited, not observed**. The change is verified **structurally, not behaviorally** — we prove the release step exists, sits in the executed path, is reuse-safe by construction, names no harness tool, and resolves to a real reference directory. **We cannot drive a Codex multi-agent session, so we do not prove a Codex controller then calls `close_agent`.**

**5. `codex-tools.md` re-read at `dev` tip (`096e15aa`), blob `1897cc3b`:** unchanged, and **untouched by our branch** (check 2). It already carries the rule — *"you should always close implementer and reviewer subagents when they have finished all their work"* — but scoped to `subagent-driven-development` only, in a platform-reference footer, never in the workflow steps a controller executes. That is exactly the gap this change closes. **PR #1926** (*"docs(codex): document deferred tool mapping"*, **OPEN**, base `dev`, +12/−0, sole file `skills/using-superpowers/references/codex-tools.md`) still owns that file — the no-touch constraint holds.

---

### Discrepancy owed a correction (flag for the PR step — NOT fixed here)

Our second comment on issue **#1927** (posted 2026-07-13T09:41:45Z) states the shape as **"four insertions, ~95 words"**. The landed, verified shape is **five insertions / 13 added lines** (Edit 3b — the final whole-branch reviewer's instance — was added in DD-002 rev 3/4, after that comment's framing). The PR body must state the `--numstat` triple and must **not** inherit "four insertions" or any word count. The already-acknowledged option-(a)→(c) correction was posted in that same comment; this count correction is still owed.

### Boundaries honored

**No PR was opened. No branch was pushed. No upstream comment was posted by this card.** The sprint stops at a verified branch + this evidence pack. Handoff: `gitban-pr` + the `contributing` playbook.

### Verdict

**Checks 1–12: 12/12 PASS.** Regression suite: **pre-existing upstream failure, disclosed above, reproduced at the pristine baseline.** The branch is exactly the diff DD-002 rev 4 promises.


## Follow-up card + the test-suite adjudication (RESOLVED)

**Follow-up ticket created:** **`o2sz0d`** — *"Fix case-sensitive assertion matching in claude-code test-helpers"* (bug, P2, backlog). Captures the pre-existing upstream defect at `tests/claude-code/test-helpers.sh:38` (`grep -q` with no `-i`, matched against non-deterministic LLM prose) that makes `tests/claude-code/test-subagent-driven-development.sh` fail on a *different* assertion each run — **including on a pristine `096e15aa` tree with zero of our changes present**. **Deliberately out of scope for the SUBREL1927 PR** (upstream enforces one problem per PR; our change touches no test). Note for `o2sz0d`: `-i` fixes both observed failures but does NOT make the suite *sound* — do not let it be closed by a one-character patch.

**The DoD box was WRONG, and was corrected rather than faked.** Its original wording demanded the suite **"passes"** — **unsatisfiable at the upstream baseline**, so no correct diff could ever have satisfied it. The executor rightly refused to tick it; the reviewer adjudicated; the box now records what is actually true and verifiable.

**Reproduced independently THREE times** (executor, reviewer, capstone) on pristine `096e15aa`, each tripping a *different* assertion — which is itself the proof of nondeterminism (the script is `set -euo pipefail` fail-fast, so it stops at whichever assertion trips first). Root cause: semantically-correct model output failing on **capitalisation alone** (*"**Read** the plan once"* vs pattern `read.*plan`). The reviewer also found the superpowers plugin is not installed in this environment at all — the suite is an even weaker oracle than first thought.

**What the PR may claim, and what it must NOT:**

- ✅ **The suite fails at the pristine baseline and is not a usable oracle in EITHER direction. We disclose it; we do not claim it as evidence.**
- ❌ **NEVER argue "no-harm by construction"** ("our diff deletes nothing, so no existing assertion can break"). It is overclaimed AND self-defeating: the assertions run over **non-deterministic LLM prose generated from the file**, and the model reads the working-tree `SKILL.md` — so adding 11 lines *does* change its input. Worse, **it contradicts this PR's own thesis**: we are arguing that adding prose to a SKILL.md changes what a controller does. We cannot argue that and simultaneously argue that adding prose to a SKILL.md cannot change what a model says about that skill. @obra maintains an eval harness *because* he believes skill prose shapes behaviour — he is exactly the reader who catches that.

**Our real no-harm evidence was never this suite.** It is the **`--numstat` triple** (`1 0`, `1 0`, `11 0` — zero deletions, zero modifications) and the **#1934 disjointness drill** (which the reviewer strengthened: it did not stop at `git apply --check`, it *actually applied* #1934 on top of our branch and confirmed all five insertions survive intact — positive proof of coexistence, not merely absence of a reported conflict).
