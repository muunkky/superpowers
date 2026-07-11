# Feature: BSCH1957 sprint capstone — integration verification

## Feature Overview & Context

* **Associated Ticket/Epic:** upstream obra/superpowers issue #1957; PRD-001 Success Criteria; ADR-001 Validation.
* **Feature Area/Component:** brainstorm companion server + its test suite + operator docs (the whole BSCH1957 change surface).
* **Target Release/Milestone:** BSCH1957 sprint — the gate before the PR is opened.

**Required Checks:**
- [x] **Associated Ticket/Epic** link is included above.
- [x] **Feature Area/Component** is identified.
- [x] **Target Release/Milestone** is confirmed.

**Depends on:** step 3 `6vbxlc` (code + e2e test) AND step 2B `5c4jtc` (docs). This is the sprint capstone: it proves the assembled change (all four tracked files together) satisfies every PRD acceptance criterion, that the FULL `tests/brainstorm-server` suite is actually run and green on Linux, and that the tracked diff is scoped correctly for an upstream PR.

### Required Reading

| Path / Location | Why |
| :--- | :--- |
| `docs/prds/PRD-001-...md` "Success Criteria" (7 items) | The acceptance yardstick this capstone verifies end-to-end. |
| `docs/adr/ADR-001-...md` "Validation" | The required-evidence list (e2e no-execution, unit assertions, existing tests unchanged, no new dep). |
| `tests/brainstorm-server/package.json` `scripts.test` | The full suite runner (`ws-protocol → helper → browser-launcher → auth → branding → server → lifecycle → start/stop`); this capstone runs the WHOLE thing, not a subset. |
| Repo `.gitignore` (and `git check-ignore docs/ .gitban`) | Confirms `docs/prds`, `docs/adr`, `docs/designs`, and `.gitban` are gitignored and MUST NOT appear in the PR diff. |

## Documentation & Prior Art Review

- [x] `README.md` reviewed (zero-dependency constraint, contribution rules, PR targets `dev`).
- [x] Existing architecture documentation or ADRs reviewed (ADR-001 Validation).
- [x] Related feature implementations reviewed (steps 2A/2B/3 outputs).
- [x] API documentation or interface specs reviewed [if applicable].

| Document Type | Link / Location | Key Findings / Action Required |
| :--- | :--- | :--- |
| **README.md** | repo root + CLAUDE.md | PR targets `upstream/dev`; zero-dependency; disclose authoring environment; docs/.gitban are gitignored and excluded from the code diff. |
| **PRD Success Criteria** | PRD-001 | 7 criteria — suite green with no weakened assertions; override launches for quoted-path + spaced-path; guards intact; built-in branch unchanged; no new dep; reviewer no-longer-High (advisory, human); `BRAINSTORM_OPEN_CMD` documented. |
| **ADR Validation** | ADR-001 | Required e2e no-execution test; unit assertions; existing tests unchanged; full suite green on Linux; no dependency. |

## Design & Planning

### Initial Design Thoughts & Requirements

* This card runs and OBSERVES; it changes no product code. Its value is the assembled, cross-cutting proof no single implementation card can give alone.
* "Green on Linux" must be observed (paste the run output), not asserted.
* Diff scope is a hard gate: exactly `server.cjs`, `visual-companion.md`, `browser-launcher.test.js`, `lifecycle.test.js` are tracked-changed; no `docs/**`, no `.gitban/**`, no `package.json`/`package-lock.json` deltas.

### Acceptance Criteria

- [x] The FULL `tests/brainstorm-server` suite is run on Linux and is green — observed output captured on the card (not merely asserted). (`npm test` in `tests/brainstorm-server`, or equivalent node/bash invocation of every file in `scripts.test`.)
- [x] Both existing `lifecycle.test.js` override tests pass with NO assertion weakened (diff of that file adds tests only; it does not edit an existing assertion).
- [x] `parseLauncherCommand` unit assertions (step 2A) and the required e2e no-execution test (step 3) are present and pass.
- [x] `grep -n "cp.exec\b" server.cjs` shows no `cp.exec(` inside `maybeOpenBrowser` (only `cp.execFile` on both launch branches).
- [x] The working branch's merge-base is `upstream/dev` (`git merge-base --is-ancestor upstream/dev HEAD` succeeds, or `git merge-base HEAD upstream/dev` resolves to the `upstream/dev` tip) — so the diff-scope and no-dependency checks below are measured against the correct upstream base, not `origin/main`.
- [x] Tracked diff (against the `upstream/dev` merge-base) = ONLY `skills/brainstorming/scripts/server.cjs`, `skills/brainstorming/visual-companion.md`, `tests/brainstorm-server/browser-launcher.test.js`, `tests/brainstorm-server/lifecycle.test.js`. No `docs/**`, no `.gitban/**` in the code diff.
- [x] No new dependency: `package.json` and `package-lock.json` (repo root and `tests/brainstorm-server`) are unchanged.
- [x] `BRAINSTORM_OPEN_CMD` operator docs (step 2B) exist in `visual-companion.md` with the no-shell note.
- [x] The advisory audit-outcome (PRD success #6 / R8) is confirmed routed to human/PR review with the e2e non-execution test as its objective proxy.

## Feature Work Phases

| Phase / Task | Status / Link to Artifact or Card | Universal Check |
| :--- | :--- | :---: |
| **Design & Architecture** | N/A — verification card, no new design | - [x] Design Complete |
| **Test Plan Creation** | Run plan = full suite + grep + diff-scope + dep check | - [x] Test Plan Approved |
| **TDD Implementation** | N/A — no product code changes here | - [x] Implementation Complete |
| **Integration Testing** | Full `tests/brainstorm-server` suite on Linux | - [x] Integration Tests Pass |
| **Documentation** | Confirm step 2B doc block is present | - [x] Documentation Complete |
| **Code Review** | gitban-reviewer (dispatch) | - [x] Code Review Approved |
| **Deployment Plan** | N/A — plugin source; feeds the PR phase | - [x] Deployment Plan Ready |

## TDD Implementation Workflow

| Step | Status/Details | Universal Check |
| :---: | :--- | :---: |
| **1. Write Failing Tests** | N/A — no new tests authored here; this card runs the assembled suite from steps 2A/3. | - [x] Failing tests are committed and documented |
| **2. Implement Feature Code** | N/A — verification only. | - [x] Feature implementation is complete |
| **3. Run Passing Tests** | Run full `tests/brainstorm-server` suite on Linux; capture green output. | - [x] Originally failing tests now pass |
| **4. Refactor** | N/A. | - [x] Code is refactored for clarity and maintainability |
| **5. Full Regression Suite** | Whole suite green (unit + spawn + shell scripts as the runner allows on Linux). | - [x] All tests pass (unit, integration, e2e) |
| **6. Performance Testing** | N/A. | - [x] Performance requirements are met |

### Implementation Notes

**Test Strategy:** Observation, not assertion. Run `npm test` (or node/bash each file) in `tests/brainstorm-server`; paste the pass/fail summary. Then `git diff --stat` to prove the four-file scope, `git status` to prove no gitignored planning docs leaked, and confirm `package.json`/`package-lock.json` are untouched. Windows-only shell scripts (`windows-lifecycle.test.sh`) are not expected to run on Linux — note their platform-skip explicitly rather than reporting a false failure.

**Key Implementation Decisions:** The capstone is unfakeable because it re-runs the real spawn test from step 3 as part of the full suite and inspects the actual tracked diff, so a scope leak or a silent dependency addition is caught here even if an individual card missed it.

## Validation & Closeout

| Task | Detail/Link |
| :--- | :--- |
| **Code Review** | gitban-reviewer via dispatch |
| **QA Verification** | Full `tests/brainstorm-server` suite green on Linux (output captured) |
| **Staging Deployment** | N/A — plugin source |
| **Production Deployment** | N/A — the PR (`gitban-pr`, targeting `dev`) is the delivery |
| **Monitoring Setup** | N/A |

### Follow-up & Lessons Learned

| Topic | Status / Action Required |
| :--- | :--- |
| **Postmortem Required?** | No |
| **Further Investigation?** | R8 audit acceptance confirmed at human/PR review. |
| **Technical Debt Created?** | No. |
| **Future Enhancements** | Shell escape hatch gated on evidence of real use. |

## Definition of Done

### Intent

This card is the sprint's single end-to-end proof that the shell-free launcher change is complete, correct, and safe to ship as an upstream PR. It matters because the fix touches security-sensitive code on a repo with a ~94% PR rejection rate: a reviewer must be able to see, in one place, that every one of the PRD's acceptance criteria holds against the assembled change, that the entire brainstorm-server test suite genuinely passes on Linux (not just the files an individual card touched), and that the diff is exactly the four files it should be — with no gitignored planning doc and no new dependency riding along. If this capstone were skipped, a scope leak (a `docs/` file in the diff) or a silent dependency addition could reach the PR and get it closed on sight.

### Observable outcomes

- [x] **Capstone:** the FULL `tests/brainstorm-server` suite is executed on Linux and reported green, with the run output captured on the card — including the step-3 e2e no-execution spawn test and both unchanged existing override tests.
- [x] `grep` confirms `cp.exec(` is absent from `maybeOpenBrowser` (both launch branches use `cp.execFile`).
- [x] The branch's merge-base is `upstream/dev`, and `git diff --stat upstream/dev...HEAD` shows exactly four tracked files changed — `server.cjs`, `visual-companion.md`, `browser-launcher.test.js`, `lifecycle.test.js` — with no `docs/**` or `.gitban/**` in the code diff.
- [x] `package.json` and `package-lock.json` (root and `tests/brainstorm-server`) are unchanged — no new dependency.
- [x] All seven PRD-001 success criteria are checked off against the assembled change; the advisory audit-outcome (R8) is recorded as routed to human/PR review with the e2e non-execution test as its objective proxy.

### Completion Checklist

- [x] All acceptance criteria are met and verified.
- [x] All tests are passing (full `tests/brainstorm-server` suite on Linux).
- [x] Code review is approved.
- [x] Documentation is updated (step 2B doc block confirmed present).
- [x] Feature is included in the sprint branch.
- [x] Monitoring and alerting are configured. <!-- N/A: plugin source, no runtime service -->
- [x] Stakeholders are notified of completion.
- [x] Follow-up actions are documented and tickets created (none needed).
- [x] Associated ticket/epic is referenced (#1957).


## CAPSTONE VERIFICATION — OBSERVED EVIDENCE (BSCH1957)

Run against branch `sprint/BSCH1957` (tip `33e3c08`), base `upstream/dev` (`096e15a`). Read-only verification from the parent working tree checked out on `sprint/BSCH1957`; no code modified, nothing pushed.

### Check 1 — Merge-base = upstream/dev — PASS
- `git merge-base --is-ancestor upstream/dev sprint/BSCH1957` → exit 0 (upstream/dev IS ancestor).
- `git merge-base upstream/dev sprint/BSCH1957` = `096e15aa736d2e920fb7f1e2c954604f02ebbdb0` == `upstream/dev` tip. Diff base is confirmed upstream/dev.
- `git diff --stat upstream/dev...sprint/BSCH1957`: 4 files changed, 177 insertions(+), 4 deletions(-).

### Check 2 — Diff scope = EXACTLY 4 files — PASS
`git diff --name-only upstream/dev...sprint/BSCH1957`:
```
skills/brainstorming/scripts/server.cjs
skills/brainstorming/visual-companion.md
tests/brainstorm-server/browser-launcher.test.js
tests/brainstorm-server/lifecycle.test.js
```
No `docs/**`, `docs/prds`, `docs/adr`, `docs/designs`, `docs/decks`, `.gitban/**`, or `node_modules/**` paths. `git check-ignore` confirms docs/prds, docs/adr, docs/designs, .gitban are gitignored. `git status --short` clean.

### Check 3 — Shell sink removed — PASS
`grep -n 'cp\.exec\b' skills/brainstorming/scripts/server.cjs` → empty (exit 1). Only `cp.execFile` remains, on BOTH launch branches inside `maybeOpenBrowser`: line 573 (operator `BRAINSTORM_OPEN_CMD` override, via `parseLauncherCommand` argv) and line 582 (platform launcher). Removed deletion lines confirm the old sink was `cp.exec(process.env.BRAINSTORM_OPEN_CMD + ' ' + JSON.stringify(url), ...)` — now gone.

### Check 4 — FULL suite green on Linux — PASS
`npm test` in `tests/brainstorm-server` on node v22.22.2, Linux. Exit code 0. Observed per-file tallies (144 tests total, 0 failed):
| File | Passed | Failed |
| :--- | ---: | ---: |
| ws-protocol.test.js | 32 | 0 |
| helper.test.js | 15 | 0 |
| browser-launcher.test.js | 12 | 0 |
| auth.test.js | 20 | 0 |
| branding.test.js | 7 | 0 |
| server.test.js | 33 | 0 (0 skipped) |
| lifecycle.test.js | 14 | 0 |
| start-server.test.sh | 4 | 0 |
| stop-server.test.sh | 7 | 0 |
| **TOTAL** | **144** | **0** |

Required tests explicitly confirmed present & passing:
- `operator BRAINSTORM_OPEN_CMD is spawned without a shell (no injection)` (lifecycle.test.js:493 — real spawn; asserts injected `; touch <pwned>` file was NOT created) — PASS.
- `auto-opens the browser once, on the first screen` (existing quoted-path override test) — PASS.
- `metacharacters survive as inert literal tokens (no shell)` + `quoted spaced path stays one argument` + `lifecycle shape strips double quotes` (browser-launcher.test.js parseLauncherCommand unit assertions) — PASS.

`windows-lifecycle.test.sh` is NOT in `scripts.test` — Windows-only, correctly platform-skipped on Linux (not a false failure).

### Check 4b — No new dependency — PASS
`git diff upstream/dev...sprint/BSCH1957 -- package.json '**/package.json' '**/package-lock.json'` → empty. The `ws` dep in `tests/brainstorm-server/package.json` is pre-existing (unchanged). numstat shows package files absent from the diff entirely.

### No weakened assertions — PASS
numstat: lifecycle.test.js `30/0` (additions only, zero deletions — adds tests, edits no existing assertion). browser-launcher.test.js `78/1` — the single deletion is the export-destructure line `browserLauncherForPlatform` (widened to also export `parseLauncherCommand`), NOT an assertion. server.cjs `39/3` — the 3 deletions are exactly the removed `cp.exec` shell sink + its comment + `return`.

### Check 5 — All 7 PRD-001 Success Criteria satisfied
Read directly from `docs/prds/PRD-001-brainstorm-companion-launcher-injection-shape.md` §Success Criteria:
1. Existing suite passes, no assertion-weakening edits (adds allowed) → PASS — 144/0 green; lifecycle 30/0 additive; only benign export/sink deletions.
2. Override launches for binary-plus-quoted-path (lifecycle shape) AND spaced launcher path → PASS — `auto-opens the browser once` + `quoted spaced path stays one argument` + `lifecycle shape strips double quotes` green.
3. Opt-in / loopback-only / skip-if-connected / once-only guards intact via green guard tests → PASS — `does NOT auto-open unless approved (BRAINSTORM_OPEN unset)`, `auto-opens the browser once` green; auth/gate suite 20/0.
4. Built-in platform-launcher branch behavior unchanged → PASS — browser-launcher Windows/WSL/Linux tests green; platform branch still `cp.execFile(launcher.bin, launcher.args, ...)` (server.cjs:582).
5. No new runtime dependency in diff → PASS — package.json/lock unchanged.
6. Security reviewer would no longer rate the operator path High/blocking → routed to human/PR review (advisory, R8); OBJECTIVE PROXY = the e2e no-execution spawn test, which passes (metachars never execute).
7. `BRAINSTORM_OPEN_CMD` documented with trust posture + command shape → PASS — visual-companion.md §"Operator configuration: `BRAINSTORM_OPEN_CMD`" (line 105+) incl. explicit **"No shell."** note enumerating non-honored shell features.

### R8 advisory audit-outcome
Confirmed routed to human/PR review with the e2e non-execution spawn test (`operator BRAINSTORM_OPEN_CMD is spawned without a shell (no injection)`) as the objective proxy. No automated gate claims a subjective reviewer verdict.

**VERDICT: All capstone acceptance criteria PASS. Diff scope = 4 files. Suite = 144 passed / 0 failed on Linux (exit 0).**
