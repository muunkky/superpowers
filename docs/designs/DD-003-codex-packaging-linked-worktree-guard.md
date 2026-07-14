# DD-003: Codex packaging works from a linked git worktree

> **PRD**: none (contained bug fix — problem and "solved" stated below) | **Date**: 2026-07-14 | **Author**: muunkky
>
> **Upstream contribution.** This is a fix for `obra/superpowers`. This design doc, like every gitban
> artifact, stays on the fork for traceability and is never pushed or linked upstream. The upstream PR
> carries only the code diff; this doc's *conclusions* become the PR body's "Alternatives considered".

## Overview

**Problem.** The Codex packaging and sync scripts decide "is this path a git checkout?" with
`[[ -d "$X/.git" ]]`. In a *linked git worktree*, `.git` is a **file** (containing `gitdir: <path>`),
not a directory — so the guard rejects a perfectly valid checkout. Anyone whose superpowers checkout is
a linked worktree (a common setup, and the one superpowers' own `using-git-worktrees` skill encourages)
cannot package or sync the Codex plugin at all.

**"Solved."** The Codex packaging/sync scripts run to completion from a linked worktree exactly as they
do from a primary clone, while still rejecting a path that is genuinely not a git checkout. A regression
test fails on today's `dev` and passes with the fix.

**Approach.** Replace the directory test with `git -C "$X" rev-parse --is-inside-work-tree`, which is
already the idiom used elsewhere in the repo (`scripts/lint-shell.sh:43`) and is the exact replacement
the maintainer named when he closed the prior attempt (PR #1910). The deliberation below is almost
entirely about **scope** — one site or all three — not mechanism.

## Requirements

The implementation is complete when:

1. `scripts/package-codex-plugin.sh` runs to completion when invoked from a linked worktree (reaches the
   same downstream state a primary clone reaches).
2. The guard still `die`s when pointed at a path that is genuinely not a git checkout.
3. `tests/codex/test-package-codex-plugin.sh` gains a linked-worktree regression test that is RED on
   unmodified `dev` and GREEN with the fix.
4. The diff touches exactly two files (the one script + its test) and adds no dependency.
5. The same defect at the two `sync-to-codex-plugin.sh` sites is documented in the PR body as reproduced
   and offered as a follow-up — not silently left, not silently fixed.

## Current State

Three guards share the identical defect (all verified failing on `dev` @ `92164e2` by running the
scripts from a linked worktree):

| File | Line | Guard | Role |
|---|---|---|---|
| `scripts/package-codex-plugin.sh` | 143 | `[[ -d "$REPO_ROOT/.git" ]]` | the repo being packaged |
| `scripts/sync-to-codex-plugin.sh` | 176 | `[[ -d "$UPSTREAM/.git" ]]` | the superpowers checkout to sync from |
| `scripts/sync-to-codex-plugin.sh` | 220 | `[[ -d "$DEST_REPO/.git" ]]` | a user-supplied `--local` destination |

Reproduction (all three, by execution):

- **package:143** — from a linked worktree the script dies `ERROR: repo root is not a git checkout`; a
  plain clone at the same commit (control) clears the guard and proceeds to an unrelated
  `--metadata-source` error; with the guard swapped, the worktree run reaches that same later point.
- **sync:176** — from a linked worktree, dies `ERROR: upstream '...' is not a git checkout` before any
  network call; a plain clone on `main` clears it.
- **sync:220** — with `--local` pointed at a linked worktree, dies `ERROR: --local path '...' is not a
  git checkout`; a normal clone as `--local` clears it.

`tests/codex/test-package-codex-plugin.sh` covers the packaging script but has **no** linked-worktree
case — its three `worktree` mentions all test a *dirty* tree, an unrelated concept.

## Target State

`package-codex-plugin.sh:143` uses `git rev-parse --is-inside-work-tree`; the packaging test suite gains
a linked-worktree case. The two `sync-to-codex-plugin.sh` sites are unchanged in this PR and named in the
PR body as a follow-up. After a maintainer's go-ahead (or on his invitation), a second PR fixes them with
their own regression tests in `tests/codex-plugin-sync/test-sync-to-codex-plugin.sh` (which exists).

## Design

### Architecture

No architecture. Two mechanical edits: one guard line in one script, one test block appended to the
existing suite, mirroring the suite's own dirty-worktree idiom.

### Key Design Decisions

**Decision 1 — Scope: fix one site now, flag the other two (chosen), vs. fix all three in one PR.**

Both are defensible. All three are the same defect with the same one-line fix, and obra's rule is
"one problem per PR" — a wrong idiom for "is this a checkout" is arguably *one* problem, which favours
fixing all three.

Chosen: **fix only `package-codex-plugin.sh:143` + its regression test, and name the two sync sites in
the PR body as reproduced-but-unfixed, offered as a follow-up.** Reasons, in order of weight:

1. **It is the exact scope the maintainer already blessed.** He closed the prior attempt (#1910) with:
   *"The worktree fix is worth keeping: please reopen it as a single, standalone PR from the account that
   will own it … and we'll evaluate it on its own merits."* "The worktree fix" referred to the packaging
   site. Matching that scope removes the largest source of a "no" — scope disagreement — before it starts.
2. **The median merged external PR here is 6 lines / 1 file, against an 84% closure rate.** A diff across
   two scripts and two test suites is materially more surface for a hostile triage to catch on, for a fix
   whose narrow form is already invited.
3. **Flagging beats bundling for demonstrating thoroughness.** Naming the two sibling sites — with their
   line numbers and their reproduced error strings — shows the whole defect class was swept, and hands the
   maintainer the decision on the wider fix rather than presuming it. It costs nothing if he declines, and
   turns into a clean, pre-socialized follow-up PR if he accepts.

The follow-up path is real, not a fig leaf: the sync sites are reproduced (so the follow-up will make no
unexecuted claim) and a test harness for them already exists.

**Decision 2 — Mechanism: `git rev-parse --is-inside-work-tree` (chosen) vs. `[[ -e "$X/.git" ]]`.**

`[[ -e "$X/.git" ]]` (accept a file *or* a directory) is one character from the original and would fix
the symptom. Rejected: it accepts any path containing a `.git` entry without confirming it is actually a
working tree, which is *weaker* than the guard being replaced. `git -C "$X" rev-parse
--is-inside-work-tree >/dev/null 2>&1` actually asks git the question the guard is trying to answer,
handles primary clones, linked worktrees, and subdirectories uniformly, and correctly rejects a non-repo
(exit 128). It is already the repo's own idiom (`scripts/lint-shell.sh:43`, the identical exit-code form)
and the maintainer named it specifically. The `-C "$X"` is load-bearing — it tests the target path, not
the current directory.

**Bare-repo strictness delta (verified, and deliberately accepted).** A *bare* repo prints `false` but
exits 0, so the exit-code form `... || die` *accepts* a bare repo, whereas the old `[[ -d "$REPO_ROOT/.git"
]]` rejected it (a bare repo has no `.git` subdir). This is the one direction the new guard is *less*
strict. It is harmless: you cannot package a Codex plugin from a bare repo (no working tree to stage), and
the downstream steps fail anyway — just later and messier. We accept it rather than add output-string
matching, because diverging from the repo's own idiom and the maintainer-named form to defend a nonsensical
input would read as over-thought. The PR body notes this delta so a re-run finds nothing undisclosed.

**Why replace, not delete.** Line 144 (immediately below the guard) already runs `git -C "$REPO_ROOT"
rev-parse --verify "$REF^{commit}"`, which itself fails on a non-repo — so deleting line 143 would also fix
the worktree case and still reject a non-repo, just with a vaguer message. We keep an explicit guard purely
for its precise diagnostic ("repo root is not a git checkout"); the backstop below confirms the change is
low-risk.

### Interface Design

```sh
# scripts/package-codex-plugin.sh, replacing line 143
git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
  die "repo root is not a git checkout: $REPO_ROOT"
```

The `die` message is unchanged, so any downstream expectation on the error text is preserved.

## Implementation Phases

### Phase 1: Fix the packaging guard + regression test

**Goal.** `package-codex-plugin.sh` runs from a linked worktree; a test proves it.

**Test strategy (written first).** Add a linked-worktree case to
`tests/codex/test-package-codex-plugin.sh`, mirroring the existing dirty-worktree test: clone the repo
`--no-local`, `git -C <clone> worktree add --detach <checkout> HEAD`, run the packaging script from the
checkout with the suite's existing `$metadata_source` fixture and an `--output` target, assert exit 0.
Wrap the script call in `set +e`/`set -e` like the dirty-worktree test.

**Placement is load-bearing — insert BEFORE the tar.gz block (before line 198), NOT appended at the end.**
The suite has 3 pre-existing tar.gz failures on GNU tar that abort the run under `set -e` at line 198,
before anything after it executes. Appending the test (after the dirty-worktree test at ~line 285) would
put it in that dead zone, where it never runs in a normal `bash tests/...` invocation on an affected box —
possibly including the maintainer's. The `$metadata_source` fixture is ready by line 141 and the zip test
finishes by line 197, so inserting the worktree case at ~line 197 (after the zip test, before the tar.gz
block) lets it run in the normal invocation. This also avoids the maintainer seeing the suite abort
*before* the new test and misreading the abort as the PR breaking the suite.

**Deliverables.** The one-line guard change; the test block.

**Infrastructure / Documentation.** None. No user-facing behaviour doc changes (the fix restores intended
behaviour); the PR body carries the explanation.

**Dependencies.** None.

**Definition of done.**
- [ ] From a linked worktree, `package-codex-plugin.sh` reaches the same state a primary clone reaches.
- [ ] The guard still `die`s on a genuine non-repo directory.
- [ ] The new test is RED on unmodified `dev` and GREEN with the fix (proven in isolation — see Risks).
- [ ] `git diff --stat upstream/dev` shows exactly two files: the script and its test.

## Migration & Rollback

N/A — pure bug fix, no state or interface change. Rollback is a one-line revert.

## Risks

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| The suite can't demonstrate RED/GREEN on this box | Med | **Certain** | On Linux/GNU tar 1.34 the suite has 3 pre-existing tar.gz failures (present on pristine `dev`, unrelated to this change) and `set -e` aborts the run before the worktree tests. Prove RED/GREEN for the new test in isolation using the suite's own `write_metadata_fixture` helper. Do **not** touch the tar bug — separate problem, separate PR. State this limitation plainly in the PR body rather than claiming "all tests pass". |
| Reads as scope creep | Med | Low (given narrow scope) | Decision 1 holds the diff to one script + one test; sibling sites are flagged, not bundled. |
| Someone re-runs the claims | High | **Certain** (this maintainer does) | Every claim in the PR body is executed and quoted with its command; the sibling-site claim is "reproduced", which it now is. |

## Roadmap Connection

`m1/s1/codex-integration` — project scope is explicitly "Native Codex plugin: hooks, skill discovery,
marketplace **packaging**, subagent lifecycle." This is a new bug leaf under it, tracked like its siblings
(`codex-sessionstart-stability`, `codex-windows-sandbox`) by PR/issue reference, no PRD.

## Open Questions

- **Will the maintainer want the two sync sites in the same PR after all?** Possibly. The follow-up is
  pre-reproduced and ready either way; if he asks for them inline, the second script + its test are a
  known, small addition.

---
## Revision History
| Date | Author | Notes |
|---|---|---|
| 2026-07-14 | muunkky | Initial — scope decision (fix package site, flag sync siblings) after reproducing all three sites on `dev` @ 92164e2. |
| 2026-07-14 | muunkky | Design review (Approve): test must go BEFORE the tar.gz abort (~line 197), not appended; documented the bare-repo strictness delta and the line-144 gitness backstop. |
