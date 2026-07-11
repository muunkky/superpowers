# Requirements Reconciliation Spike: BSCH1957 — brainstorm launcher shell-free fix

**When to use this template:** Final gate before decomposition. This card also serves as the sprint planning card (step 1): it captures every requirement from PRD-001 / DD-001 / ADR-001 and records the card inventory + sequencing the sprint uses to honor them. End state: requirements reconciled and all BSCH1957 cards in `todo`.

**Who fills this out:** The sprint architect, before the substantive cards are worked.

---

## Reconciliation Overview

* **Sprint / Initiative:** BSCH1957 — retire the brainstorm companion operator-launcher shell-injection shape (upstream obra/superpowers issue #1957).
* **Reconciliation Question:** Does the planned BSCH1957 sprint honor every requirement in PRD-001, DD-001, and ADR-001 — and where it cannot (deliberately dropped shell features), is that explicit?
* **Primary Source PRD:** `docs/prds/PRD-001-brainstorm-companion-launcher-injection-shape.md` (gitignored; local planning doc).
* **Roadmap Node:** `m1/s3/brainstorming/companion-security-hardening`.
* **Architect:** cameron (muunkky fork).

**Required Checks:**
- [x] **Reconciliation question** is stated and scoped to this sprint.
- [x] **Primary source PRD** is identified (PRD-001).
- [x] This spike is completed **before** the substantive cards are worked.

---

## Time Box

**Maximum Duration:** 1 hour. The three source docs are converged and accepted; reconciliation is transcription + mapping, not investigation.

---

## Context

**What this sprint is meant to deliver:** A ~24-line change to `skills/brainstorming/scripts/server.cjs` (a new `parseLauncherCommand` tokenizer + a rewritten `BRAINSTORM_OPEN_CMD` call site that uses `cp.execFile` with no shell), plus tokenizer unit tests, a required end-to-end no-execution test, and operator documentation — landing as a real PR to obra/superpowers off `upstream/dev`.

**Why reconcile now:** Decomposition is about to begin. The change is small and mechanical from DD-001's Interface Design, but the security property is subtle (the sink, not just the tokenizer, must be shell-free) and easy to lose at the seam between cards. An explicit requirement-to-card mapping keeps any invariant from silently dropping.

**Cost of not reconciling:** A dropped invariant ships a fix that clears unit tests but reopens injection (e.g. a call site that reverts to `cp.exec(argv.join(' '))`), or narrows the override so a real launcher form regresses — trading one problem for another on a repo with a ~94% PR rejection rate.

---

## Source Documents to Review

- [x] Listed every applicable PRD, ADR, and design doc in the Source Documents table below.
- [x] Marked each listed document reviewed and recorded the requirements and constraints it imposes.
- [x] Searched `docs/adr/` and `docs/designs/` for any superseding ADR or newer design-doc revision.

| Document | Type | Location / Link | Reviewed? [y/n] | Requirements / Constraints Extracted |
| :--- | :--- | :--- | :---: | :--- |
| Brainstorm launcher injection shape | PRD | docs/prds/PRD-001-brainstorm-companion-launcher-injection-shape.md | y | Audit no longer flags the override path High/blocking; override still launches realistic commands (binary + flags + quoted/spaced path); four guards unchanged; built-in path unchanged; existing suite green; no new dependency; document `BRAINSTORM_OPEN_CMD`. |
| Retire launcher shell shape via quote-aware argv tokenizer | design doc | docs/designs/DD-001-brainstorm-launcher-shell-free-argv.md | y | Candidate (a): `parseLauncherCommand` + `cp.execFile(argv[0], [...argv.slice(1), url])`; guard `if (argv.length && argv[0])`, else fall through; tokenizer contract (whitespace + single/double quotes, quote-stripped, never throws, empty/whitespace/quoted-empty behavior); unit tests in browser-launcher.test.js; REQUIRED e2e no-execution test in lifecycle.test.js; doc block in visual-companion.md incl. tilde + backslash in the no-shell list. |
| Retire launcher shell shape (in-tree tokenizer + execFile) | ADR | docs/adr/ADR-001-brainstorm-launcher-shell-free-argv.md | y | Accepted decision locking candidate (a); the dropped shell layer IS the security property; validation is the required e2e no-execution spawn test; only `server.cjs` export + one-branch call-site edit; single-commit rollback. |
| No superseding ADR / newer design revision | ADR / design doc | docs/adr/, docs/designs/ | y | ADR-001 is the first and only ADR; DD-001 rev 2 (2026-07-11) is the latest. None applicable beyond the three above. |

---

## Requirement Reconciliation

| Req ID | Requirement (restated in your own words) | Source | How the sprint honors it | Honored by [card / sequencing / capstone / deferred] | Classification [law / advisory] |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **R1** | The override branch launches with no shell — `cp.execFile(argv[0], [...argv.slice(1), url])`, URL as a discrete argv element, matching the built-in branch two lines below; `cp.exec` no longer appears in `maybeOpenBrowser`. | DD-001 req 1; ADR-001 Decision | step 3 rewrites the call site; step 4 capstone greps `maybeOpenBrowser` for `cp.exec`. | card (step 3) + capstone (step 4) | law |
| **R2** | A shell metacharacter in the override value OR the URL is an inert literal argv token, never interpreted. | DD-001 req 2 | step 2A unit tests assert metacharacters (`; $() backtick && \|`) survive as literal tokens; step 3 e2e test proves the sink is shell-free. | card (step 2A) + capstone (step 3 e2e) | law |
| **R3** | The existing lifecycle override contract holds unchanged: `node "<abs>" "<abs>"` launches once, the launched process receives the reachable key-carrying URL; existing assertions are NOT weakened. | DD-001 req 3; PRD success #1 | step 2A unit test proves the quote-stripped argv; step 3 keeps both existing lifecycle tests green with no assertion edited; step 4 capstone re-runs them. | card (step 2A/3) + capstone (step 4) | law |
| **R4** | A quoted path containing a space reaches the launched process as a single argument, not split. | DD-001 req 4; PRD success #2 | step 2A unit test: `parseLauncherCommand('bin "/A/My Browser.app/x"')` → `['bin', '/A/My Browser.app/x']`. | card (step 2A) | law |
| **R5** | The four pre-launch guards (opt-in, loopback-only, skip-if-connected, once-only) AND the built-in platform-launcher branch are behaviorally unchanged. | DD-001 req 5; PRD success #3,#4 | step 3 touches only the override branch; existing "does NOT auto-open unless approved" + once-only assertions stay green; step 4 capstone runs the full suite. | card (step 3) + capstone (step 4) | law |
| **R6** | No new runtime dependency; the tokenizer is hand-rolled standard-library JavaScript. | DD-001 req 6; PRD success #5 | step 2A implements the tokenizer in stdlib JS; step 4 capstone asserts no new entry in package.json / package-lock.json and diff adds no dependency. | card (step 2A) + capstone (step 4) | law |
| **R7** | `BRAINSTORM_OPEN_CMD` is documented for operators: accepted shape, opt-in/loopback trust posture, and an explicit "no shell" note naming the dropped features including tilde (`~`) and backslash-escaping. | DD-001 req 7; PRD success #7 | step 2B adds a compact block to visual-companion.md after "Starting a Session". | card (step 2B) | law |
| **R8** | An equivalent security audit / skeptical reviewer no longer classifies the override path as High-severity / blocking. | PRD Features (audit finding); PRD success #6; ADR-001 Validation | Structural outcome of R1+R2 (the `cp.exec(string)` sink is gone) plus R7 documentation; verified by the step 3 e2e no-execution test as objective evidence, and flagged for human review because the ultimate call rests on an external auditor's judgment (see Subjective Requirements). | capstone (step 3 e2e) + human review | advisory |

---

## Law vs Advisory Split

- [x] Every requirement in the Requirement Reconciliation table is assigned exactly one classification.

| Req ID | Requirement (short) | Classification [law / advisory] | Rationale for the classification | Enforcement (laws) / Signal (advisories) |
| :---: | :--- | :--- | :--- | :--- |
| **R1** | Override uses execFile, no shell | law | The whole point; a `cp.exec` sink fails the sprint. | step 4 capstone greps `maybeOpenBrowser` for `cp.exec` (must be absent). |
| **R2** | Metacharacters inert | law | The security property itself. | step 2A unit assertions + step 3 e2e no-execution test. |
| **R3** | Existing lifecycle tests green, unchanged | law | The only executable spec of the path; weakening it is a regression. | step 4 capstone runs both existing lifecycle tests unmodified. |
| **R4** | Quoted spaced path stays one arg | law | Named acceptance in PRD/DD; realistic-use bound. | step 2A unit assertion. |
| **R5** | Guards + built-in branch unchanged | law | Out-of-scope surfaces must not move. | step 3 diff scoped to override branch; step 4 runs full suite. |
| **R6** | No new dependency | law | Hard zero-dependency repo constraint. | step 4 capstone checks package.json / lockfile diff. |
| **R7** | Operator docs for BRAINSTORM_OPEN_CMD | law | Explicit PRD goal + DD-001 req 7. | step 2B doc block; step 4 capstone confirms it exists with the no-shell note. |
| **R8** | Audit no longer flags High/blocking | advisory | Rests on an external auditor's judgment; not a pass/fail gate we can run here. | step 3 e2e non-execution is the objective proxy; final call routed to human (below). |

> **Discipline:** R8 is deliberately advisory because its verdict is owned by an external party. The objective, mechanically-verifiable proxy (the shell sink is gone, injection does not execute) is a law via R1/R2.

---

## Subjective Requirements for Human Review

- [x] Reviewed every requirement for subjectivity and recorded each subjective one in the table below.

| Req ID | Subjective Requirement | Why it is subjective | Architect's proposed interpretation | Needs human ruling? [y/n] | Status [flagged-routed / resolved-by-human] | Resolver / Decision (optional) |
| :---: | :--- | :--- | :--- | :---: | :--- | :--- |
| **R8** | "A security reviewer / re-run audit no longer warrants a High/blocking finding on the launcher path" (PRD success #6). | No threshold we can execute; depends on the org's auditor and any undisclosed findings (PRD assumption: #1957 is the whole problem). | Removing the `cp.exec(string)` sink eliminates the structural shell-shape match; the required e2e no-execution test is the objective evidence a reviewer inspects. Treat R8 as satisfied when R1+R2+R7 hold, subject to human confirmation at PR review. | y | flagged-routed | Routed to the Phase-3 human-eyes gate / PR reviewer; no human ruling recorded yet. |

---

## Success Criteria

- [x] All applicable PRDs, ADRs, and design docs are listed and marked reviewed.
- [x] Every product requirement from the source documents is restated and mapped to how the sprint honors it.
- [x] Each requirement is classified as law or advisory, with each law's enforcement named.
- [x] Every subjective requirement is flagged for human review (R8 recorded; no others found).
- [x] Every subjective requirement is recorded in the Subjective Requirements table and routed to the Phase-3 human-eyes gate (status `flagged-routed`).
- [x] No requirement is left without an honoring mechanism (R1–R8 all mapped; no gaps).

---

## Reconciliation Gaps & Escalations (optional)

| Gap / Conflict | Requirement(s) involved | Why it could not be reconciled | Resolution path [resolved / deferred / blocked-pending-human] | Owner (optional) |
| :--- | :--- | :--- | :--- | :--- |
| None — all eight requirements map to a card, sequencing, or capstone with no unresolved conflict. | R1–R8 | N/A | resolved | cameron |

---

## Reconciliation Findings & Recommendation

| Item | Detail / Link |
| :--- | :--- |
| **Requirements reconciled** | 8 of 8 mapped to cards / capstone (no deferrals). |
| **Laws vs advisories** | 7 law, 1 advisory (R8, audit outcome). |
| **Subjective requirements flagged** | 1 flagged-routed (R8); 0 self-ruled. |
| **Decomposition input** | Sprint BSCH1957: step 1 (this spike) → step 2A tokenizer+unit tests / step 2B docs (parallel) → step 3 call-site rewrite + e2e no-execution test → step 4 capstone verification → step 5 closeout. |

### Summary & Recommendation

All eight requirements map to planned cards. Six code/behavior laws (R1–R6) are enforced by step 2A/step 3 and re-verified by the step 4 capstone; the documentation law (R7) is owned by step 2B; the audit-outcome advisory (R8) is flagged for human review with the shell-free sink + e2e non-execution test as its objective proxy. The `cp.exec`-absence grep, the two-tier test strategy (tokenizer units + required e2e no-execution spawn), and the diff-scope check are the load-bearing enforcements. **Recommendation: proceed to decomposition — all BSCH1957 cards may be created and moved to `todo`.**

### Follow-up & Lessons Learned

| Topic | Status / Action Required |
| :--- | :--- |
| **Decomposition unblocked?** | Yes — proceed; all cards created and moved to todo. |
| **Source docs need an update?** | No — PRD/DD/ADR are converged and internally consistent. |
| **Human rulings outstanding?** | 1 — R8 (audit acceptance) routed to PR review; not blocking decomposition. |
| **Lessons learned (optional)** | Restating requirements surfaced that the load-bearing regression lock is the e2e *sink* test, not the tokenizer units — captured as its own capstone in step 3. |

### Completion Checklist

- [x] Reconciliation question was answered for the whole sprint.
- [x] Every source document was reviewed and logged.
- [x] Every requirement was restated and mapped to an honoring mechanism.
- [x] Law-vs-advisory split is complete and each law's enforcement is named.
- [x] Every subjective requirement is recorded and routed (R8, `flagged-routed`).
- [x] Time box was respected.
- [x] A clear go / no-go recommendation for decomposition is recorded (GO).
- [x] Any source-document defects found were captured as follow-up (none).


## Executor Close-out (cycle 2)

**Verdict:** Reconciliation content verified sound; card completed. GO for decomposition (already done — all 5 downstream cards in `todo`).

**Environment fix vs cycle 1:** Cycle 1 halted with `WRONG BASE` (worktree mis-forked from `main` d884ae0 instead of `sprint/BSCH1957`). This cycle runs directly on `sprint/BSCH1957` in the main working tree (HEAD `096e15a`, `upstream/dev` is an ancestor — base check PASS), so the tag/merge-back corruption risk that blocked cycle 1 no longer applies.

**Grounding re-verified against the live tree (not just the doc):**
- Shell sink present: `skills/brainstorming/scripts/server.cjs:540` — `cp.exec(process.env.BRAINSTORM_OPEN_CMD + ' ' + JSON.stringify(url), ...)`. This is the R1/R2 target the sprint retires.
- Built-in launcher already shell-free: `server.cjs:547` — `cp.execFile(launcher.bin, launcher.args, ...)`, the two-lines-below shape R1 says the override must match.
- `maybeOpenBrowser()` at `server.cjs:530`; override guard at `:539`.
- Target test files exist: `tests/brainstorm-server/browser-launcher.test.js` (R4/R2 unit assertions land here) and `tests/brainstorm-server/lifecycle.test.js` (R3 existing override contract + R2 required e2e no-execution test).
- Operator doc target exists: `skills/brainstorming/visual-companion.md` (R7).
- No superseding ADR/design: `docs/adr/` + `docs/designs/` are gitignored local planning docs; ADR-001 is the only ADR, DD-001 rev 2 (2026-07-11) the latest design — consistent with the reconciliation table.
- Downstream cards all `todo`: 1lq5e4 (2A tokenizer+units, P0), 5c4jtc (2B docs, P1), 6vbxlc (3 call-site+e2e, P0), 8iew0h (4 capstone, P0), vxq64m (closeout, P1).

**What this card's "tests" proved:** This is a reconciliation spike — its deliverable is the R1–R8 requirement-to-card mapping (card body), not code. No test suite was run (correct for a spike). Verification was structural: every requirement in the table traces to a real source-doc requirement and a real file/line in the tree, and every honoring card exists in `todo`. The mapping is faithful and gap-free (8/8 mapped, 7 law / 1 advisory, R8 flagged-routed to the PR human-eyes gate).

**Deferred:** Nothing. All reconciliation work is complete; the code/test/doc laws (R1–R7) are owned by downstream cards 2A/2B/3/4 and were intentionally out of this spike's scope.