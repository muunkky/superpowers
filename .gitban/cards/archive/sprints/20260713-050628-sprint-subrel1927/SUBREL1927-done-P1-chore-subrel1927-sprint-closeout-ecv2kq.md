
# SUBREL1927 Sprint Closeout

> **Sprint**: SUBREL1927 | **Type**: chore | **Step**: 3 (final)
>
> Mandatory closeout card for sprint SUBREL1927. Dispatched last. Archives done cards, generates the
> sprint summary, updates `CHANGELOG.md`, flips the shipped leaf roadmap node, and walks accumulated
> retrospective items using the four-type deferral grid (see planner/SKILL.md per-item block format).

## Cleanup Scope & Context

* **Sprint/Release:** SUBREL1927 — put a neutral, conditioned subagent-release step into the executed path of the three cross-harness dispatch workflow bodies (upstream obra/superpowers issue #1927; design DD-002).
* **Primary Feature Work:** **Five** pure insertions across three `SKILL.md` files (step 1, `6lu6av`) — per DD-002 **rev 4** — and the 12-check diff-shape verification + PR evidence pack (step 2 capstone, `2myrzj`).
* **Cleanup Category:** Sprint closeout (archive + summary + CHANGELOG + roadmap leaf flip + retrospective).

**Required Checks:**
- [x] Sprint/Release is identified above.
- [x] Primary feature work that generated this cleanup is documented.

### Purpose

Close out sprint SUBREL1927: archive done cards, generate the sprint summary via `generate_archive_summary`, update `CHANGELOG.md` if the change is user-visible (it is a fork-local skill-prose change destined for upstream — record it as such or explicitly record why no entry is warranted), flip the shipped leaf node under `## Roadmap Leaf Flips` via `upsert_roadmap`, and process every item in the Sprint Retrospective section using the four-type deferral grid each item carries.

**The upstream PR is NOT this card's job** and must not be opened here — it is handled after closeout by the `gitban-pr` skill plus the `contributing` playbook (clean code-only branch off `upstream/dev`, fork showcase branch, authoring-environment disclosure, the exact uncompressed #1934 disjointness sentence, and the correction owed on issue #1927).

## Deferred Work Review

- [x] Reviewed commit messages for "TODO" / "FIXME" added during the sprint.
- [x] Reviewed PR/review comments for "out of scope" / "follow-up needed".
- [x] Reviewed code for new TODO/FIXME markers.
- [x] Checked reviewer findings routed by the planner into the retrospective below.

| Cleanup Category | Specific Item / Location | Priority | Justification for Cleanup |
| :--- | :--- | :---: | :--- |
| **Known, deliberately not fixed** | `skills/using-superpowers/references/codex-tools.md` — its rule sentence is scoped to `subagent-driven-development` alone and never names `requesting-code-review`. | P2 | Owned by upstream PR #1926 (DD-002 KDD-1 / KDD-6). Out of scope on purpose; the in-body pointer is what closes the gap without touching the file. **Do not create a card to edit it.** |
| **Owed correction (external)** | Upstream issue #1927 — our intent comment there proposed option (a) (rule with no pointer); we are landing option (c). | P1 | DD-002 §"Correction owed to #1927": leaving a superseded proposal standing on a maintainer's thread is exactly the sloppiness this upstream punishes. Belongs to the PR step, not to a sprint card — note it here so it is not lost. |

## Roadmap Leaf Flips

<!-- The specific leaf (feature) roadmap paths this sprint ships. Flip LEAVES ONLY via upsert_roadmap; branch status is roll-up computed and a hand-set branch value is silently overridden. -->

- `roadmap:m1/s1/codex-integration/codex-subagent-lifecycle` → flip to `verifying` (the five insertions are complete and structurally verified, but "done" depends on a named external gate: the upstream obra/superpowers PR to `dev` being reviewed and merged). Flip to `done` only once that gate clears.

## Sprint Retrospective

<!-- planner appends items below this line during the sprint. Each item is a self-contained block with its own classification grid per planner/SKILL.md. Leave this section empty if no items accumulate. -->

## Cleanup Checklist

### Documentation Updates (optional)

| Task | Status / Details | Done? |
| :--- | :--- | :---: |
| **CHANGELOG** | Record the release step added to the three dispatch workflow bodies — or record explicitly why no entry is warranted for an upstream-bound skill-prose change. | - [x] |
| **Other:** sprint summary | `generate_archive_summary` for SUBREL1927. | - [x] |
| **Other:** design/PRD status | DD-002 (rev 4, APPROVED) / PRD-002 / NOM-002 left as-is; no doc rewrite is part of this sprint. | - [x] |

### Testing & Quality (optional)

| Task | Status / Details | Done? |
| :--- | :--- | :---: |
| **Regression green** | ~~Confirm step 2 recorded `tests/claude-code/test-subagent-driven-development.sh` passing.~~ **ITEM CORRECTED, NOT FAKED (same call step 2 made on its own DoD).** As worded this was **unsatisfiable**: the suite **fails at the pristine `096e15aa` baseline too**, with zero of our changes present, tripping a *different* assertion on each of three independent runs. Root cause is upstream and pre-existing — `tests/claude-code/test-helpers.sh:38` runs `grep -q "$pattern"` with **no `-i`** against non-deterministic free-form LLM prose, so semantically-correct output fails on capitalisation alone. **Corrected item: confirm step 2 recorded the regression outcome HONESTLY as a disclosed pre-existing baseline failure — which it did.** The suite is not a usable oracle in either direction; we disclose it and do not claim it as evidence. Fix deferred to **`o2sz0d`** (P2, backlog) and deliberately NOT bundled into this PR (upstream: one problem per PR; our diff touches no test). Our real no-harm evidence is the `--numstat` triple (0 deletions, 0 modifications) and the #1934 disjointness drill. | - [x] |
| **Other:** diff shape | Confirm step 2's capstone: **five** pure-insertion hunks, exactly three `SKILL.md`, `git diff --numstat` = **`1 0` / `1 0` / `11 0`** (13 added lines, 0 deleted, 0 modified), and `grep -c 'further input'` = SDD 3 / DPA 1 / RCR 1. **No word count** — the "~120 added words" figure is stale and false (~165); the line triple is the claim. | - [x] |

### Code Quality & Technical (optional)

| Task | Status / Details | Done? |
| :--- | :--- | :---: |
| **TODOs Resolved** | None outstanding for this sprint. | - [x] |
| **Other:** no new files | Confirm zero files added, zero removed, zero dependencies. | - [x] |

### Dependencies (optional)

| Task | Status / Details | Done? |
| :--- | :--- | :---: |
| **Dependency Updates** | None — superpowers is zero-dependency by design. | - [x] |

### Configuration & Environment (optional)

| Task | Status / Details | Done? |
| :--- | :--- | :---: |
| **Environment Variables** | N/A. | - [x] |

### Build & CI/CD (optional)

| Task | Status / Details | Done? |
| :--- | :--- | :---: |
| **CI Pipeline** | N/A — no CI workflows exist in this repo; verification is the step-2 check suite. | - [x] |

### Refactoring & Code Organization (optional)

| Task | Status / Details | Done? |
| :--- | :--- | :---: |
| **Import Cleanup** | N/A. | - [x] |

## Validation & Closeout

### Pre-Completion Verification

| Verification Task | Status / Evidence |
| :--- | :--- |
| **All P0 Items Complete** | [steps 1 and 2 done and reviewed] |
| **All P1 Items Complete or Ticketed** | [closeout in progress] |
| **Tests Passing** | [step 2: checks 1–12 green + SDD regression test passing] |
| **No New Warnings** | [zero deletions, zero modified lines — tuned content undisturbed] |
| **Documentation Updated** | [the three SKILL.md files ARE the documentation] |
| **Code Review** | [all cards passed gitban-reviewer] |

### Follow-up & Lessons Learned

| Topic | Status / Action Required |
| :--- | :--- |
| **Remaining P2 Items** | [none, or created per retrospective] |
| **Recurring Issues** | [did any tripwire fire during execution — check 6 (`further input` = 3/1/1 in SDD), check 10 (status-blind), the Edit-3a re-flow (a nonzero deletion count), or check 12's two traps?] |
| **Process Improvements** | [n/a] |
| **Technical Debt Tickets** | [none — the `codex-tools.md` gap is PR #1926's, not debt we own] |

### Acceptance Criteria (closeout-specific)

- [x] Every item under `## Sprint Retrospective` has exactly one deferral-type row marked `true` in its inline grid (exactly-one-true constraint). <!-- cite: -->
- [x] Every item has its `Action taken:` field filled in matching the chosen deferral type. <!-- cite: -->
- [x] Every item's two per-item checkboxes are ticked. <!-- cite: -->
- [x] Sprint summary generated via `generate_archive_summary`. <!-- cite: -->
- [x] Leaf node `m1/s1/codex-integration/codex-subagent-lifecycle` flipped to `verifying` via `upsert_roadmap` (leaf only; branch status left to roll-up). <!-- cite: roadmap:m1/s1/codex-integration/codex-subagent-lifecycle -->
- [x] `CHANGELOG.md` updated for the user-visible change, or a recorded decision that no entry is warranted. <!-- cite: -->
- [x] All sprint cards archived via `archive_cards`. <!-- cite: -->
- [x] **No upstream PR was opened by this sprint.** The branch is verified and ready; `gitban-pr` + the `contributing` playbook own the handoff. <!-- cite: -->

### Completion Checklist

<!-- gate0: upper-checklist -->

- [x] All P0 items are complete and verified. <!-- cite: -->
- [x] All P1 items are complete or have follow-up tickets created. <!-- cite: -->
- [x] P2 items are complete or explicitly deferred with tickets. <!-- cite: -->
* [ ] ~~All tests are passing (unit, integration, and regression).~~ **CORRECTED — this boilerplate item is UNSATISFIABLE at the upstream baseline and is not ticked as written.** The repo's one relevant regression suite (`tests/claude-code/test-subagent-driven-development.sh`) **fails on a pristine `096e15aa` tree with zero of our changes present** (see the corrected Regression-green row). **What IS true and verified:** the 12/12 mechanical check suite passes green end to end, zero lines are deleted or modified, and the #1934 coexistence drill passes positively. **Corrected item: all verification this sprint CAN honestly run has passed; the flaky upstream suite is disclosed, not claimed, and its fix is deferred to `o2sz0d`.** <!-- cite: 2myrzj evidence pack; o2sz0d -->
- [x] No new linter warnings or errors introduced. <!-- cite: -->
- [x] All documentation updates are complete and reviewed. <!-- cite: -->
- [x] Code changes are reviewed and **committed on the branch** (`subagent-release-in-workflow-bodies` @ `97cc870`); both cards passed `gitban-reviewer`. **"Merged" is deliberately NOT claimed** — the merge gate is the upstream obra/superpowers PR, which this sprint is explicitly forbidden from opening (handoff: `gitban-pr` + the `contributing` playbook). <!-- cite: 97cc870 -->
- [x] Follow-up tickets are created and prioritized for next sprint. <!-- cite: -->
- [x] Team retrospective includes discussion of cleanup backlog (if significant). <!-- cite: -->


## SUBREL1927 Closeout Record

Run context: **direct on branch `subagent-release-in-workflow-bodies` @ `97cc870`** (no worktree, no branch switch, no rebase), forked at `096e15aa` (= `upstream/dev`).

### Sprint result (re-verified this session, not taken on trust)

```
$ git diff --numstat 096e15aa HEAD
1	0	skills/dispatching-parallel-agents/SKILL.md
1	0	skills/requesting-code-review/SKILL.md
11	0	skills/subagent-driven-development/SKILL.md
$ git diff --shortstat 096e15aa HEAD   → 3 files changed, 13 insertions(+)
$ git diff -U0 096e15aa HEAD | grep -c '^@@'      → 5   (five hunks, five insertions)
$ git diff 096e15aa HEAD | grep -c '^-[^-]'       → 0   (zero deletions, zero modifications)
$ git diff --name-status 096e15aa HEAD            → M / M / M  (zero added, zero removed files)
$ grep -c 'further input' …  → SDD 3 / DPA 1 / RCR 1
```

**Five pure insertions, three `SKILL.md` files, 13 added lines, 0 deleted, 0 modified.** All tripwires clean (status-blind; harness-neutral; Edit 3a's line break intact — the zero-deletion count is what proves SDD's ledger lines are byte-identical). obra**#1934 coexistence positively proven** — the reviewer applied #1934's open draft on top of our branch and confirmed all five insertions survive intact, which is stronger than a clean `git apply --check`.

### CHANGELOG decision — NO ENTRY WARRANTED (recorded, not skipped)

**There is no `CHANGELOG.md` anywhere in this repository** (`find . -iname 'CHANGELOG*'` → no results). Upstream `obra/superpowers` does not keep one; releases are cut from Conventional Commits. There is no file to update, and creating one would itself be an unrelated, unrequested change to an upstream-bound branch — precisely the scope creep that gets PRs closed at a repo enforcing one problem per PR. The user-visible record of this change is the commit body of `97cc870` and the forthcoming PR. **Decision: no CHANGELOG entry; no CHANGELOG file created.**

### Sprint Retrospective — EMPTY (no planner items accumulated)

The `## Sprint Retrospective` section is empty: the planner routed no findings into it during the sprint. The three per-item acceptance criteria (exactly-one-true deferral grid, `Action taken:` filled, two per-item checkboxes ticked) are therefore **vacuously satisfied over zero items** — ticked on that basis, not by inventing items to satisfy them.

### Deferred work review

- Commit messages `096e15aa..HEAD`: one commit (`97cc870`), no `TODO`/`FIXME` introduced.
- Added lines: `grep -E 'TODO|FIXME|XXX|HACK'` over the diff's `+` lines → **no match**.
- Reviewer findings: both cards passed adversarial review; nothing routed to the retrospective.
- `skills/using-superpowers/references/codex-tools.md` — **known, deliberately not fixed.** Owned by upstream PR #1926. No card created, per the card's explicit instruction.

### Two checkboxes CORRECTED, not faked

Following the precedent `2myrzj` set on its own DoD:

1. **"Regression green"** demanded confirmation that `tests/claude-code/test-subagent-driven-development.sh` **passes**. That is **unsatisfiable**: the suite fails at the pristine `096e15aa` baseline with zero of our changes present, tripping a different assertion on each of three independent runs (`test-helpers.sh:38` uses `grep -q` with no `-i` against non-deterministic LLM prose). Corrected to record the outcome honestly as a **disclosed pre-existing baseline failure**. We disclose the suite; we do not claim it as evidence.
2. **"All tests are passing (unit, integration, and regression)"** — same defect, same correction. What is true: the **12/12 mechanical check suite passes green end to end**, zero lines deleted or modified, #1934 coexistence proven.

A third item, **"Code changes are reviewed and merged,"** was corrected to **"reviewed and committed on the branch"** — "merged" is not claimed, because the merge gate is the upstream PR this sprint is explicitly forbidden from opening.

Fix for the flaky harness is filed as **`o2sz0d`** (P2, backlog) and **deliberately NOT bundled** into this PR — upstream enforces one problem per PR and our diff touches no test.

### Roadmap

`m1/s1/codex-integration/codex-subagent-lifecycle` flipped **`in_progress` → `verifying`** via `upsert_roadmap` (leaf only; branch status left to roll-up). It is **not** `done` because the remaining gate is **external and outside our control**: the upstream PR to `dev` being reviewed and merged. Flip to `done` only when that merges.

---

## OUTSTANDING ACTION FOR THE PR STEP — a correction we owe upstream

**Not posted by this card, by design. `gitban-pr` + the `contributing` playbook own it.**

Our 2026-07-13 comment on issue **#1927** states the shape as **"four insertions, ~95 words."** The landed, verified shape is **five insertions / 13 added lines** (Edit 3b — the final whole-branch reviewer's instance — was added in DD-002 rev 3/4, after that comment's framing).

1. **The PR body must NOT inherit the stale figure.** It must state the `--numstat` triple: `1 0` / `1 0` / `11 0` — 13 added lines, 0 deleted, 0 modified.
2. **No word count may appear in the PR body.** Both circulating figures are false — "~95 words" (the #1927 comment) and "~120 added words" (still carried in DD-002 rev 4's word-budget line and DoD). The five strings total ~165 words. A word count is also unfalsifiable-by-tool; the line triple is not.
3. **The #1927 thread is owed the corrected shape.** Leaving a superseded count standing on a maintainer's thread, at a repo whose entire credibility strategy is making no easily-checked false claims, is exactly the sloppiness that gets work closed on sight.

Also owed at the PR step (from `2myrzj`): the **exact, uncompressed #1934 disjointness sentence** from DD-002 KDD-7 §2 — never compress it to "pure deletions", which is **false for RCR**, whose first #1934 hunk rewrites the intro paragraph.

### Boundaries honored

**No upstream PR opened. No branch pushed. No upstream comment posted.** The sprint stops at a verified branch plus the evidence pack.
