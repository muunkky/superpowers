
# SUBREL1927 step 1: land the five DD-002 insertions

> **Sprint**: SUBREL1927 | **Type**: documentation | **Step**: 1 | **Priority**: P0
>
> Implements the APPROVED design doc `docs/designs/DD-002-subagent-release-in-workflow-bodies.md`
> (**rev 4** — the design was overturned three times; earlier revisions of THIS CARD encoded rev-2
> prose and rev-1/rev-2 sites, both of which are now WRONG). The design is **prescriptive**: it
> specifies the exact prose, verbatim, and exactly where each insertion lands. **Do not re-derive,
> re-word, re-wrap, improve, expand, or "tighten" any of it.**
>
> The entire deliverable is **5 pure insertions across 3 files — 13 added lines (RCR +1, DPA +1,
> SDD +11), 0 deleted, 0 modified — ZERO new headings, ZERO new numbered steps.**
>
> **The gate is the line count, not a word count.** `git diff --numstat "$BASE"...HEAD` must print
> exactly `1 0` / `1 0` / `11 0` for RCR / DPA / SDD. (An earlier revision of this card claimed
> "~120 added words" — that figure was stale from the four-insertion design and is **false** for the
> five specified strings, which total ~165 words. Do not reintroduce a word count anywhere, and do
> not let one reach the PR body: it is a claim a maintainer falsifies with `--numstat` in ten
> seconds, in a contribution whose whole credibility rests on making no easily-checked false claims.)
>
> **Two of the five (Edits 3a and 3b) both live in SDD.** SDD carries **two** rule instances plus the
> Red Flags backstop — three occurrences of `further input` in that file. A count of 2 means an agent
> kind lost its fire-point instance (DD-002 Open Question 3, closed: **do not consolidate them**).

## Documentation Scope & Context

* **Related Work:** DD-002 (design, APPROVED) · PRD-002 · NOM-002 · upstream issue obra/superpowers#1927. Sprint SUBREL1927.
* **Documentation Type:** Agent skill prose (`skills/*/SKILL.md`) — behavior-shaping content executed by a controller mid-loop, **not** user-facing docs. It gets a Definition of Done.
* **Target Audience:** A controller agent executing one of the three cross-harness dispatch workflows (SDD / DPA / RCR) on any harness.

**Required Checks:**
- [x] Related work/context is identified above
- [x] Documentation type and audience are clear
- [x] Existing documentation locations are known (avoid creating duplicates)

### Required Reading (read before touching a file)

| What | Where | Why |
| :--- | :--- | :--- |
| **The design doc — read it end to end (rev 4, APPROVED)** | `docs/designs/DD-002-subagent-release-in-workflow-bodies.md` | Prescriptive. §"Interface Design — the exact prose" is the spec — **copy the five strings out of it verbatim**. **KDD-2b, KDD-3 and KDD-5 are the traps**, and its Revision History records exactly which earlier sitings were shipped and why each was wrong. |
| Insertion sites | `skills/requesting-code-review/SKILL.md`, `skills/dispatching-parallel-agents/SKILL.md`, `skills/subagent-driven-development/SKILL.md` | The only three files this sprint may touch. |
| The reused idiom (do not paraphrase) | `skills/executing-plans/SKILL.md` L14 — grep `the per-platform tool refs in` | The pointer phrase is quoted verbatim from here. It is the PR's strongest acceptance signal. |
| Off-limits file | `skills/using-superpowers/references/codex-tools.md` | Owned by upstream PR #1926. **Read-only. Zero changes anywhere under `skills/using-superpowers/`.** |

### Requirements captured from DD-002 (nothing else is in scope)

| ID | Requirement (from DD-002 rev 4 §Requirements) | Discharged by |
| :--- | :--- | :--- |
| R1 | Each of the three SKILL bodies carries an explicit release step **inside its existing workflow sequence**, at the point the controller consumes the subagent's result. Not a preamble, not a new section — and **not in a section the happy path can skip**. | Edits 1, 2, 3a, 3b |
| R2 | Every release instance states the **intent condition in the same sentence** — that the controller will send that agent no further input. **The exact wording varies by site** (*"unless you intend to send it further input"* where the agent is singular; *"you will send none of them further input"* where a set is released at a boundary). R2 requires the *condition*, not a fixed phrase — **do not gate on a fixed substring**. **No instance keys the condition to SDD's implementer statuses** (KDD-3), and every instance is sited where the intent is **determinate** (KDD-2b). | Edits 1, 2, 3a, 3b, 4 |
| R3 | SDD's Red Flags `**Never:**` list carries the obligation **for both agent populations** — the per-task agents *and* the final whole-branch reviewer. A task-scoped Red Flag would exclude the one agent whose rule is necessarily a forward obligation. | Edit 4 |
| R4 | Each of the three bodies points the controller at `../using-superpowers/references/` at the moment the rule fires. (In SDD the pointer rides on Edit 3a only — one rationale + pointer per *file*.) | Edits 1, 2, 3a |
| R5 | **Harness-neutral**: no added line names a harness (Codex/Claude/Gemini/OpenCode/Copilot/Pi) or a harness tool (`close_agent`/`spawn_agent`/`wait_agent`/`send_input`). | All edits |
| R6 | Exactly 3 files changed, all `SKILL.md`; `skills/using-superpowers/**` untouched; **no existing sentence deleted or reworded**; no new heading, no new numbered step. | Diff shape |
| R7 | Zero new dependencies, zero new files. | Diff shape |

---

## Pre-Work Documentation Audit

Anchors are **text, never line numbers** (DD-002 KDD-7 §1 — the maintainer's in-flight PR #1934 touches all three files and will shift every line number; every anchor string below still exists verbatim after it).

- [x] Repository root reviewed for doc cruft (stray .md files, outdated READMEs) — **N/A: no new files, no root changes**
- [x] `/docs` directory (or equivalent) reviewed for existing coverage — **DD-002/PRD-002/NOM-002 read; they are the spec, not the deliverable**
- [x] Related service/component documentation reviewed — the three SKILL.md bodies + `executing-plans/SKILL.md` L14 idiom
- [x] Team wiki or internal docs reviewed — **N/A**

### Branch and baseline (do this first — it is load-bearing for every later check)

`$BASE = 096e15aa736d2e920fb7f1e2c954604f02ebbdb0` (`upstream/dev` at design time).

**Our fork's `main` is NOT a descendant of `$BASE`** (verified: 15 files diverge). Work committed on top of fork `main` makes the step-2 diff-shape checks structurally impossible. So:

1. `git fetch upstream`
2. Record `git rev-parse upstream/dev`.
3. **If it equals `$BASE`** — branch from it: `git switch -c subagent-release-in-workflow-bodies 096e15aa736d2e920fb7f1e2c954604f02ebbdb0`
4. **If `upstream/dev` has moved** — branch from the new tip instead, set `$BASE` to that tip, **re-verify all five anchor strings still exist verbatim** (they survive PR #1934 — verified), and record the drift in the Work table below. Also re-read `skills/using-superpowers/references/codex-tools.md` at the new tip (DD-002 Migration & Rollback requires this check anyway).
5. The sprint's own state survives the branch switch and **never enters the diff** — but the two ignore mechanisms are **different files**, so know which is which before you go hunting:
   - `.git/info/exclude` lists **`.gitban/`**, **`log/`**, and the lifecycle-doc subdirectories **`docs/{prds,adr,designs,decks,reports}/`** — **not `docs/` wholesale** (34 other files under `docs/` **are** tracked).
   - **`.claude/`** is ignored by the **root `.gitignore`**, not by `.git/info/exclude`.

   Net effect is what this card depends on and it is verified. Confirm `git status` shows only the three SKILL.md files as modified.

| Document Location | Current State | Action Required |
| :--- | :--- | :--- |
| **skills/requesting-code-review/SKILL.md** | `**3. Act on feedback:**` list ends `- Push back if reviewer is wrong (with reasoning)` | Edit 1 — append one bullet **after** the push-back bullet |
| **skills/dispatching-parallel-agents/SKILL.md** | `### 4. Review and Integrate` list ends `- Integrate all changes` | Edit 2 — append one bullet **after** `Integrate all changes` |
| **skills/subagent-driven-development/SKILL.md** | `## Durable Progress` — the ledger bullet `- When a task's review comes back clean, append one line to the ledger in / the same message as your other bookkeeping: / \`Task N: complete (commits <base7>..<head7>, review clean)\`.` (L257–259 @ `$BASE`) | Edit 3a — **extend that existing bullet** with five new lines. **The three existing lines stay byte-identical.** |
| **skills/subagent-driven-development/SKILL.md** | `## Constructing Reviewer Prompts` — list ends with the fix-dispatch bullet `- If the final whole-branch review returns findings, dispatch ONE fix / subagent with the complete findings list — not one fixer per finding. …` (L214–217 @ `$BASE`), then `## File Handoffs` | Edit 3b — append **one new bullet after that fix-dispatch bullet**, as the list's final entry. **NOT on the L203–207 review-package bullet** (see tripwire 2). |
| **skills/subagent-driven-development/SKILL.md** | Red Flags `**Never:**` list ends `- Re-dispatch a task the progress ledger already marks complete — check\n  the ledger (and \`git log\`) after any compaction or resume` | Edit 4 — append one bullet as the **final** `**Never:**` entry; it must name **both** agent populations |
| **skills/using-superpowers/references/codex-tools.md** | Rule sentence is scoped to SDD only; RCR named nowhere | **OFF-LIMITS — PR #1926 owns it. Zero changes.** |

**Documentation Organization Check:**
- [x] No duplicate documentation found across locations — **one clause per site. SDD deliberately carries TWO rule instances (Edit 3a at the task boundary for the per-task agents; Edit 3b for the final whole-branch reviewer) because those agent kinds finish at different points. DD-002 Open Question 3 is closed with the answer NO — one instance is NOT enough. Do not consolidate them.** The rationale + pointer appear **once per file** (SDD's ride on Edit 3a).
- [x] Documentation follows team's organization standards — insertions match each list's existing bullet form and each file's wrap width (~72–78 cols in SDD; DPA/RCR bullets are single unwrapped lines)
- [x] Cross-references between docs are working — `../using-superpowers/references/` resolves from all three skill dirs
- [x] Orphaned or outdated docs identified for cleanup — **none; zero deletions**

---

## Documentation Work

### The five insertions — verbatim. Copy them out of DD-002 §"Interface Design — the exact prose". Do not retype from memory, do not re-wrap, do not "improve".

**Edit 1 — `skills/requesting-code-review/SKILL.md`**, appended as the **last** bullet of `**3. Act on feedback:**` (after the push-back bullet; `## Example` follows and is unchanged):

```markdown
- Push back if reviewer is wrong (with reasoning)
- Release the reviewer unless you intend to send it further input — on some harnesses a finished agent holds its slot until closed (see the per-platform tool refs in `../using-superpowers/references/`)
```

**Edit 2 — `skills/dispatching-parallel-agents/SKILL.md`**, appended as the **last** bullet of `### 4. Review and Integrate` (after `- Integrate all changes`; `## Agent Prompt Structure` follows and is unchanged):

```markdown
- Integrate all changes
- Release each agent unless you intend to send it further input — on some harnesses a finished agent holds its slot until closed (see the per-platform tool refs in `../using-superpowers/references/`)
```

**Edit 3a — `skills/subagent-driven-development/SKILL.md` — the TASK BOUNDARY.** Extend the **existing** task-completion bullet in `## Durable Progress` (L257–259 @ `$BASE`). This covers the **implementer, task reviewer, and fix subagents** — the only point at which all three are unambiguously finished under **both** readings of SDD's re-dispatch ambiguity. **Do not add a new bullet here**; the release rides along with the "other bookkeeping" the bullet already names. Hard-wrap to the list's existing width:

```markdown
- When a task's review comes back clean, append one line to the ledger in
  the same message as your other bookkeeping:
  `Task N: complete (commits <base7>..<head7>, review clean)`.
  That bookkeeping includes releasing the subagents the task used —
  implementer, task reviewer, and any fix subagents — you will send none
  of them further input. On some harnesses a finished agent holds its slot
  until closed (see the per-platform tool refs in
  `../using-superpowers/references/`).
```

> **The line break after `` review clean)`. `` is LOAD-BEARING, not stylistic.** The new sentence
> **must begin on its own line** so that the three existing lines (L257–259) stay **byte-identical**
> and this edit is a **pure insertion of five lines**, not a modification. If you "tidy" it onto the
> end of the previous line, the diff gains a deletion and the PR's headline claim — *zero deletions,
> every hunk a pure insertion* — becomes **false**. Do not re-flow it.

**Edit 3b — `skills/subagent-driven-development/SKILL.md` — the FINAL WHOLE-BRANCH REVIEWER.** A **new final bullet** in `## Constructing Reviewer Prompts`, **after** the fix-dispatch bullet (L214–217 @ `$BASE`), which is the final review's turn-back. No rationale, no pointer — Edit 3a carries both, in the same file. (`## File Handoffs` follows and is unchanged.)

```markdown
- If the final whole-branch review returns findings, dispatch ONE fix
  subagent with the complete findings list — not one fixer per finding.
  Per-finding fixers each rebuild context and re-run suites; a real
  session's final-review fix wave cost more than all its tasks combined.
- Release the final whole-branch reviewer, and any fixer it triggered, once
  you have acted on its findings and will send them no further input.
```

**Edit 4 — `skills/subagent-driven-development/SKILL.md`**, appended as the **final** bullet of the Red Flags `**Never:**` list (the four-line bullet is the only addition; `**If subagent asks questions:**` is unchanged). It must cover **both** agent populations — a task-scoped Red Flag would by construction exclude the final whole-branch reviewer, the one agent whose rule is necessarily a forward obligation:

```markdown
- Re-dispatch a task the progress ledger already marks complete — check
  the ledger (and `git log`) after any compaction or resume
- Leave subagents open once you are finished with them — release a task's
  implementer, reviewer and fixers at task close-out, and the final
  whole-branch reviewer once you have acted on its findings; you will send
  none of them further input
```

### The five tripwires — a "helpful improvement" here is a defect

Each of these fired in a real revision of this design. They are the reason the design was overturned
three times. Step 2 greps for every one of them and **fails the sprint** if it trips.

1. **Status-blind (KDD-3).** Do **not** map the condition onto `NEEDS_CONTEXT` / `BLOCKED` / `DONE_WITH_CONCERNS` / `DONE`. It reads beautifully and **it is wrong**: SDD is internally ambiguous about whether a re-dispatch reuses the same agent, and under the fresh-dispatch reading a status-keyed rule tells the controller to hold a `BLOCKED` agent open **forever** — manufacturing the exact leak this fixes, in the flagship skill. The wording is deliberately status-blind.
2. **SDD's site moved TWICE — both "more natural" sections are WRONG (KDD-2b / KDD-5).** An intent-keyed rule must be sited where the intent is **determinate**, not merely where the path is unconditional.
   - **NOT `## Handling Reviewer ⚠️ Items`** (rev 1's site) — it opens *"The task reviewer **may** report…"*: an **exception handler** a clean task never enters, so the rule would be absent from the executed path.
   - **NOT `## Handling Implementer Status`** (rev 2's site) — unconditional, but the controller **cannot yet know** whether it will reuse the agent (the task review has not run, and Red Flags say *"Implementer (same subagent) fixes them"*). The rule degrades to inaction and **the agent leaks anyway**. This one *looked* right and shipped in a whole revision.
   - The site is the **task boundary**: `## Durable Progress`'s task-completion ledger bullet (**Edit 3a**) — the only prose step in SDD that is *both* unconditional *and* intent-settled.
   - **Edit 3b must NOT go on the L203–207 final-review *package* bullet.** That bullet is **dispatch preparation** — it executes **before the final reviewer is spawned**, so a release rule there would fire before the agent it governs exists, and would sit *above* its own turn-back (L214–217). An earlier card and an earlier DoD said to put it there. **That is wrong.** It goes **after** the fix-dispatch bullet.
3. **Harness-neutral (R5).** No added line may contain `close_agent`, `spawn_agent`, `wait_agent`, `send_input`, `Codex`, `Claude`, `OpenCode`, `Gemini`, `Copilot`, or `Pi`. The pointer names a *directory of per-platform refs*, not a platform. Keep `the per-platform tool refs in` **verbatim** — it is quoted from `executing-plans` L14 and paraphrasing it throws away the PR's best acceptance signal.
4. **Edit 3a's leading line break is load-bearing.** See the callout under Edit 3a. Re-flowing the new sentence onto the existing `review clean)` line converts a pure insertion into a modification, puts a non-zero number in the deletions column of `git diff --numstat`, and makes the PR's headline claim false.
5. **Every instance keeps the words `further input`.** The phrasing differs by site on purpose (*"unless you intend to send it further input"* vs *"you will send none of them further input"*) — **do not normalise them to one phrase**, and do not gate on a fixed substring. The gate is `grep -c 'further input'` → **SDD 3 / DPA 1 / RCR 1**. A count of 2 in SDD means an agent kind lost its fire-point instance.

### Hard scope fence

* **No new files.** **No dependencies.** **No deletions. No modifications to any existing line.**
* `skills/using-superpowers/**` — **zero changes** (PR #1926 owns `codex-tools.md`).
* **Do not touch** RCR `## Integration with Workflows` (obra's PR #1934 deletes it), SDD `## Example Workflow`, SDD `## Advantages`, DPA `## Verification` / `## Common Mistakes` / `## Key Benefits` / `## Real-World Impact`, RCR `## Red Flags`, or any prompt template (`implementer-prompt.md`, `task-reviewer-prompt.md`, `code-reviewer.md`).
* **Do not open the upstream PR.** That is handled separately (`gitban-pr` + the `contributing` playbook).

| Task | Status / Link to Artifact | Universal Check |
| :--- | :--- | :---: |
| **Branch cut from `upstream/dev`** | [record `git rev-parse upstream/dev`; note drift from `$BASE` if any] | - [x] Complete |
| **Edit 1 — RCR step 3 bullet** | [commit] | - [x] Complete |
| **Edit 2 — DPA step 4 bullet** | [commit] | - [x] Complete |
| **Edit 3a — SDD `## Durable Progress` ledger bullet extended (task boundary)** | [commit] | - [x] Complete |
| **Edit 3b — SDD `## Constructing Reviewer Prompts` new final bullet, AFTER the fix-dispatch bullet** | [commit] | - [x] Complete |
| **Edit 4 — SDD Red Flags `**Never:**` bullet (both agent populations)** | [commit] | - [x] Complete |
| **Self-check `git diff --numstat` = 0 deletions** | [paste output] | - [x] Complete |
| **Self-check `grep -c 'further input'` = SDD 3 / DPA 1 / RCR 1** | [paste output] | - [x] Complete |

**Documentation Quality Standards:**
- [x] All code examples tested and working — **N/A: no code examples added**
- [x] All commands verified — **N/A**
- [x] All links working (no 404s) — `../using-superpowers/references/` resolves from all three skill dirs
- [x] Consistent formatting and style — added bullets match their list's form; SDD's added lines are hard-wrapped to the surrounding ~72–78-col width, and Edit 3a's new sentence starts on its own line (load-bearing)
- [x] Appropriate for target audience — a controller mid-loop
- [x] Follows team's documentation style guide — reuses `executing-plans` L14's pointer construction verbatim; invents no new convention

## Definition of Done

### Intent

A controller agent working through any of the three dispatch workflows — code review, parallel agents, or subagent-driven development — reaches an explicit instruction to release each finished subagent at the moment it is actually finished with it, phrased so it only releases agents it will send no further input to, and phrased without naming any harness or tool. Today all three workflows end their result-handling step without ever saying "release it", so a controller that follows them exactly leaks agents on harnesses where a finished agent keeps holding its concurrency slot. If this is broken, the first sign is a long dispatch run that stalls because the agent pool is exhausted by agents that finished their work hours ago. The two ways *we* can break it while appearing to succeed: siting SDD's rule where the controller cannot yet know whether it will reuse the agent (it then holds every agent and the leak survives untouched, in the flagship skill), or keying the rule to implementer statuses (a controller then dutifully holds a stuck `BLOCKED` agent open forever).

### Observable outcomes

- [x] `grep -c 'further input'` returns **3 / 1 / 1** for `skills/subagent-driven-development/SKILL.md`, `skills/dispatching-parallel-agents/SKILL.md`, `skills/requesting-code-review/SKILL.md` respectively — SDD's 3 = Edit 3a (task boundary) + Edit 3b (final reviewer) + Edit 4 (Red Flags). **A count of 2 in SDD means an agent kind lost its fire-point instance and R1 has regressed.** (R1 R2 R3)
- [x] `grep -c 'using-superpowers/references/'` returns **≥1** for each of the same three files, and the relative path **resolves** from all three skill dirs (R4)
- [x] In RCR, the added bullet is the **last** bullet under `**3. Act on feedback:**`; in DPA, the **last** bullet under `### 4. Review and Integrate` (Architecture rule 2 — release follows every turn-back)
- [x] In SDD, **Edit 3a** extends the task-completion ledger bullet in `## Durable Progress` — **not** `## Handling Implementer Status`, **not** `## Handling Reviewer ⚠️ Items` (KDD-2b / KDD-5)
- [x] In SDD, **Edit 3b** is a **new final bullet** in `## Constructing Reviewer Prompts`, **after** the fix-dispatch turn-back bullet (L214–217) — **not** on the L203–207 review-package bullet, which executes *before the final reviewer is dispatched* (KDD-2b / B4)
- [x] In SDD, **Edit 4** names **both** agent populations — the task's implementer/reviewer/fixers *and* the final whole-branch reviewer (R3)
- [x] `git diff "$BASE"...HEAD | grep -E '^\+' | grep -E 'NEEDS_CONTEXT|BLOCKED|DONE_WITH_CONCERNS'` finds **nothing** (KDD-3 — status-blind guard)
- [x] `git diff "$BASE"...HEAD | grep -E '^\+' | grep -nE 'close_agent|spawn_agent|wait_agent|send_input|Codex|Claude|OpenCode|Gemini|Copilot|\bPi\b'` finds **nothing** (R5)
- [x] `git diff "$BASE"...HEAD | grep -E '^\+#{1,6} |^\+\*\*[0-9]+\.'` finds **nothing** — no new heading, no new numbered step. (New *bullets* are fine; they are the established pattern.)
- [x] `git diff --numstat "$BASE"...HEAD` shows **0 deletions on every file** — in particular Edit 3a's existing three lines (L257–259) are **byte-identical**, proving the new sentence began on its own line — and `git diff --name-only "$BASE"...HEAD` lists **exactly 3 paths, all `SKILL.md`**, none under `skills/using-superpowers/` (R6 R7)
- [x] **Capstone:** reading each of the three `SKILL.md` bodies straight through from its dispatch step, the controller hits an explicit, conditioned release instruction — in SDD, once at the task boundary for the per-task agents and once for the final whole-branch reviewer — with a working pointer to `../using-superpowers/references/`, **before** the workflow's steps run out and **after** every turn-back at that site; and the full diff against `$BASE` is **five pure-insertion hunks with `git diff --numstat "$BASE"...HEAD` printing exactly `1 0` (RCR) / `1 0` (DPA) / `11 0` (SDD) — 13 added lines, 0 deleted, 0 modified, zero new headings, zero new numbered steps**. (Line counts, not word counts. An additions-count mismatch is the tightest single signal available: it catches a re-flowed Edit 3a, a dropped Edit 3b, and a "helpfully expanded" bullet in one line of output.)

## Validation & Closeout

| Task | Detail/Link |
| :--- | :--- |
| **Final Location** | Branch `subagent-release-in-workflow-bodies`, cut from `upstream/dev` @ `$BASE` |
| **Path to final** | `skills/requesting-code-review/SKILL.md`, `skills/dispatching-parallel-agents/SKILL.md`, `skills/subagent-driven-development/SKILL.md` |

### Follow-up & Lessons Learned

| Topic | Status / Action Required |
| :--- | :--- |
| **Documentation Gaps Identified?** | `codex-tools.md`'s rule sentence is SDD-scoped and never names RCR — known, deliberately not fixed here (PR #1926 owns the file; DD-002 KDD-1) |
| **Style Guide Updates Needed?** | No — the in-body pointer reuses `executing-plans` L14's existing construction |
| **Future Maintenance Plan** | NOM-002 records the durable convention; step 2 re-checks coexistence with upstream PRs #1926 / #1934 before the PR is prepared |

### Completion Checklist

- [x] All documentation tasks from work plan are complete
- [x] Documentation is in the correct location (not in root dir or random places)
- [x] Cross-references to related docs are added
- [x] Documentation is peer-reviewed for accuracy
- [x] No doc cruft left behind (old files cleaned up) — **zero files added, zero removed**
- [x] Future maintenance plan identified [if applicable]
- [x] Related work cards are updated [if applicable]


## BLOCKED
HELD FOR SPRINT REVIEW — not a design defect. DD-002 is now **rev 4, APPROVED**, and this card has been fully rewritten against it (title, all five insertion strings, all sites, tripwires, DoD). The block is now purely procedural: the owner unblocks after `gitban-sprint-reviewer` passes the revised sprint.

What the rewrite settled (the three design overturns are closed — do NOT reopen them):
- It is FIVE insertions, not four: 13 added lines (RCR +1, DPA +1, SDD +11), 0 deleted, 0 modified. The old "~120 added words" figure was stale from the four-insertion design and is FALSE for the five specified strings (~165 words) — it has been replaced everywhere by the mechanically-checkable line count, and must not reach the PR body.
- SDD's rule moved TWICE and both earlier sites are WRONG: NOT `## Handling Reviewer ⚠️ Items` (an exception handler a clean task never enters — rev 1), and NOT `## Handling Implementer Status` (unconditional, but the controller cannot yet know whether it will reuse the agent, so the rule degrades to inaction and the agent leaks anyway — rev 2).
- SDD now carries TWO rule instances: Edit 3a at the task boundary (extending `## Durable Progress`'s ledger bullet) for the per-task agents, and Edit 3b as a new final bullet in `## Constructing Reviewer Prompts` AFTER the fix-dispatch turn-back, for the final whole-branch reviewer. The earlier "one enumeration discharges all four agents" claim is retired.
- Edit 3b does NOT go on the L203–207 review-package bullet — that bullet executes before the final reviewer is dispatched. An earlier version of this card said to put it there; that instruction was wrong and is deleted.
- The in-body pointer SURVIVES: `close_agent` is registered `ToolExposure::Deferred` on any model with tool-search, so its name and obligation-bearing description are NOT in the controller's context when the rule fires. Option (c) stands on evidence; option (a) is refuted.

DO NOT DISPATCH until the owner unblocks. When dispatched, copy the five strings verbatim out of DD-002 §"Interface Design"; do not re-word, re-wrap, or "improve" them.


## Close-out — Step 1 complete (5 insertions landed)

All five DD-002 rev-4 strings transcribed **verbatim**. No re-wording, no re-wrapping, no "improvements".

### Diff shape — the gate, verbatim

```
$ git diff --numstat 096e15aa736d2e920fb7f1e2c954604f02ebbdb0...HEAD
1	0	skills/dispatching-parallel-agents/SKILL.md
1	0	skills/requesting-code-review/SKILL.md
11	0	skills/subagent-driven-development/SKILL.md
```

13 added, **0 deleted, 0 modified**. Exactly 3 paths, all `SKILL.md`, none under `skills/using-superpowers/`.
SDD's 11 = Edit 3a (5) + Edit 3b (2) + Edit 4 (4).

### Gates — all green

| Gate | Result |
| :--- | :--- |
| `grep -c 'further input'` | SDD **3** / DPA **1** / RCR **1** |
| `grep -c 'using-superpowers/references/'` | 1 / 1 / 1 (≥1 each); dir resolves from all three skill dirs |
| Status-blind guard (`NEEDS_CONTEXT\|BLOCKED\|DONE_WITH_CONCERNS` on `^+`) | **empty** |
| Harness-neutral guard (harness/tool names on `^+`) | **empty** |
| No new heading / numbered step | **empty** |

### Tripwires — all avoided

- **Edit 3a's leading line break preserved.** The new sentence starts on its own line; L257–259 are byte-identical (proven by the 0 in SDD's deletions column).
- **Rule is status-blind.** No added line names an implementer status.
- **Harness-neutral.** No harness or harness-tool name in any added line. `the per-platform tool refs in` kept verbatim from `executing-plans` L14.
- **Edit 3b sited after the fix-dispatch bullet** (the final review's turn-back) — *not* on the L203–207 review-package bullet.
- **SDD keeps two rule instances** (3a task boundary + 3b final reviewer); not consolidated.

### Honest close-out — regression check

`tests/claude-code/test-subagent-driven-development.sh`: Tests 1–4 **PASS**; **Test 5 FAILS**.

**Test 5's failure is PRE-EXISTING and NOT caused by this change — verified, not assumed.** I stashed the edits, confirmed a 0-line diff (pristine baseline), and re-ran: Test 5 fails **identically at the untouched baseline**. It is an LLM-response string-match (`assert_contains "not trust\|don't trust\|skeptical\|..."`) against free-form model output; the agent's answer was in fact fully skeptical but phrased it as "**Do Not Trust** the Report" (capitalized), which the case-sensitive pattern misses. It probes `task-reviewer-prompt.md`, a file this card does not touch. No-harm confirmed.

### Scope fence — honored

Zero changes under `skills/using-superpowers/**` (PR #1926 owns `codex-tools.md`). RCR `## Integration with Workflows` untouched (obra's #1934 deletes it). No prompt template, no Example Workflow, no new files, no dependencies.

**Upstream PR NOT opened** — per card scope, the sprint stops at a verified branch.

### Execution note (deviation from prompt, no effect on deliverable)

The dispatch prompt said to work direct on `subagent-release-in-workflow-bodies`, but the harness enforces worktree isolation and **blocked** edits to the shared checkout. Work landed on worktree branch `worktree-agent-a2a7156918d5217e4`, whose HEAD was **exactly `096e15aa…`** (the baseline) — so the diff shape is identical and the merge-back is unaffected. Commit `97cc870`.
