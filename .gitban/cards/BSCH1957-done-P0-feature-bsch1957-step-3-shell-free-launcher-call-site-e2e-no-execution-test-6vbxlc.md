# Feature: shell-free `BRAINSTORM_OPEN_CMD` call site + required e2e no-execution test

## Feature Overview & Context

* **Associated Ticket/Epic:** upstream obra/superpowers issue #1957; DD-001 Target State; ADR-001 Decision + Validation.
* **Feature Area/Component:** brainstorm companion server — `maybeOpenBrowser()` in `skills/brainstorming/scripts/server.cjs`.
* **Target Release/Milestone:** BSCH1957 sprint (PR to obra/superpowers `dev`).

**Required Checks:**
- [x] **Associated Ticket/Epic** link is included above.
- [x] **Feature Area/Component** is identified.
- [x] **Target Release/Milestone** is confirmed.

**Depends on:** step 2A `1lq5e4` (consumes `parseLauncherCommand`; also shares `server.cjs`, so it lands after 2A). **Blocked by nothing else.** **Blocks:** step 4 capstone. This card is the security-critical one — it removes the flagged `cp.exec(string)` sink and regression-locks the property with a spawn test.

### Required Reading

| Path / Location | Why |
| :--- | :--- |
| `skills/brainstorming/scripts/server.cjs` lines 526–548 | `maybeOpenBrowser()`. Replace ONLY the override branch (lines 539–542, `cp.exec(...)`); the four guards (531–535) and the built-in `execFile` branch (543–547) stay byte-for-byte behaviorally unchanged. |
| `skills/brainstorming/scripts/server.cjs` line 716+ | `parseLauncherCommand` is exported here after step 2A; call it from the override branch. |
| `tests/brainstorm-server/lifecycle.test.js` lines 60–66 | `openCaptureCommand(dir, marker)` — the existing spawn harness that writes a capture script and returns `node "<script>" "<marker>"`. REUSE it for the new no-execution test; do not duplicate it into `browser-launcher.test.js`. |
| `tests/brainstorm-server/lifecycle.test.js` lines 447–491 | The two existing override tests ("auto-opens … once", "does NOT auto-open unless approved"). Their assertions must stay GREEN and UNCHANGED. |
| `docs/designs/DD-001-brainstorm-launcher-shell-free-argv.md` "Target State" + "Test strategy" | The exact call-site replacement and the required e2e no-execution test design. |

## Documentation & Prior Art Review

- [x] `README.md` or project documentation reviewed.
- [x] Existing architecture documentation or ADRs reviewed (ADR-001, DD-001).
- [x] Related feature implementations or similar code reviewed (built-in `execFile` branch two lines below — the reference pattern this card matches).
- [x] API documentation or interface specs reviewed [if applicable].

| Document Type | Link / Location | Key Findings / Action Required |
| :--- | :--- | :--- |
| **Architecture Docs** | DD-001 Target State | Replace `cp.exec(cmd + url)` with `parseLauncherCommand` → `cp.execFile(argv[0], [...argv.slice(1), url])`; guard `if (argv.length && argv[0])`, `return` inside the guard, else fall through to the built-in launcher. |
| **ADR** | ADR-001 | The dropped shell layer IS the security property; validation is the required e2e no-execution spawn test — that test (not the unit tests) catches a revert to `cp.exec`. |
| **Similar Features** | `server.cjs` 543–547 | Built-in branch already does `cp.execFile(bin, args)` with URL as discrete argv; the override branch becomes structurally identical. |
| **Tests** | lifecycle.test.js | `openCaptureCommand` harness + `waitForFile` are present to reuse. For the injection test, assert non-execution (`<pwned>` absent) + fired-once (marker non-empty); the `http.get` reachability check is used by the clean "auto-opens once" test, not by this injection test (its argv[3] is `';'`, not the URL). |

## Design & Planning

### Initial Design Thoughts & Requirements

* R1: no shell — `cp.exec` must not appear in `maybeOpenBrowser` after this card.
* Guard is `if (argv.length && argv[0])` so a quoted-empty (`['']`) or whitespace-only override falls through to the built-in platform launcher rather than reaching `execFile('', …)`.
* In-code comment updated to: "no shell — argv via execFile, matching the platform-launcher branch below."
* R5: the four guards and the built-in branch are untouched in behavior; the `browserOpened=true` once-guard at the top is independent of which branch runs.
* The e2e no-execution test is the load-bearing regression lock: it is what fails if a future edit reverts the sink to `cp.exec(argv.join(' '))` while every unit test stays green.

### Acceptance Criteria

- [x] The override branch calls `cp.execFile(argv[0], [...argv.slice(1), url])` with no shell; `cp.exec` no longer appears anywhere in `maybeOpenBrowser`.
- [x] The guard is `if (argv.length && argv[0])`; a whitespace-only (`"   "`) and a quoted-empty (`'""'`) `BRAINSTORM_OPEN_CMD` fall through to the built-in platform launcher.
- [x] The in-code comment on the override branch states the no-shell/execFile rationale.
- [x] The four pre-launch guards and the built-in `execFile` branch are unchanged in behavior.
- [x] REQUIRED e2e no-execution test added to `lifecycle.test.js` reusing `openCaptureCommand`: with `BRAINSTORM_OPEN=1` and `BRAINSTORM_OPEN_CMD` = `node "<capture>" "<marker>" ; touch "<pwned>"`, the test asserts EXACTLY two things — (a) `<pwned>` is NEVER created on disk (the `;`/`touch`/`<pwned>` tokens are passed as inert literal argv, not shell-executed), and (b) the override still FIRED exactly once (the capture script ran and wrote the marker → marker file exists and is non-empty). **Do NOT assert the marker's contents equal the reachable/key-carrying URL for this injection test.** With the injected tokens the tokenized argv is `[node, <capture>, <marker>, ';', 'touch', '<pwned>', url]`, so the capture script's `process.argv[3]` is `';'`, not the URL — the URL is pushed past argv[3] and the "records the URL" assertion can never go green. URL delivery is already regression-locked elsewhere: by the clean "auto-opens the browser once" test (`lifecycle.test.js:447-475`, which asserts the marker holds the reachable key-carrying URL) and by the tokenizer unit assertions R3/R4 in step 2A. This injection test's unique job is proving NON-EXECUTION of the sink, not URL delivery.
- [x] Both existing override tests in `lifecycle.test.js` pass with NO assertion weakened.
- [x] `node lifecycle.test.js` is green on Linux.

## Feature Work Phases

| Phase / Task | Status / Link to Artifact or Card | Universal Check |
| :--- | :--- | :---: |
| **Design & Architecture** | DD-001 Target State (call-site replacement) | - [x] Design Complete |
| **Test Plan Creation** | New e2e no-execution test in `lifecycle.test.js` + keep existing override tests | - [x] Test Plan Approved |
| **TDD Implementation** | Rewrite the override branch in `server.cjs` | - [x] Implementation Complete |
| **Integration Testing** | `node lifecycle.test.js` (spawns the real server) | - [x] Integration Tests Pass |
| **Documentation** | Operator docs owned by step 2B; in-code comment updated here | - [x] Documentation Complete |
| **Code Review** | gitban-reviewer (dispatch) | - [x] Code Review Approved |
| **Deployment Plan** | N/A — plugin source; ships in the sprint PR | - [x] Deployment Plan Ready |

## TDD Implementation Workflow

| Step | Status/Details | Universal Check |
| :---: | :--- | :---: |
| **1. Write Failing Tests** | Add the e2e no-execution test to `lifecycle.test.js`. With the current `cp.exec` sink still in place, `; touch "<pwned>"` executes → `<pwned>` is created → the "pwned never created" assertion fails RED. Capture the RED. | - [x] Failing tests are committed and documented |
| **2. Implement Feature Code** | Rewrite the override branch to `parseLauncherCommand` + `cp.execFile(argv[0], [...argv.slice(1), url])` with the `argv.length && argv[0]` guard and fall-through; update the comment. | - [x] Feature implementation is complete |
| **3. Run Passing Tests** | `node lifecycle.test.js` — the new no-execution test AND both existing override tests pass GREEN; `<pwned>` is not created. | - [x] Originally failing tests now pass |
| **4. Refactor** | Confirm the branch reads as consistent with the built-in `execFile` branch below it; no other lines touched. | - [x] Code is refactored for clarity and maintainability |
| **5. Full Regression Suite** | Full `tests/brainstorm-server` suite deferred to step 4 capstone. | - [x] All tests pass (unit, integration, e2e) |
| **6. Performance Testing** | N/A. | - [x] Performance requirements are met |

### Implementation Notes

**Test Strategy:** The spawn test is mandatory and is the sprint's real regression lock for the *sink*. Reuse `openCaptureCommand` (write the capture script, spawn the server). Assert ONLY non-execution + fired-once: `<pwned>` is never created, and the marker exists / is non-empty (the override launched). Do NOT assert marker contents equal the URL — the injected tokens shift the URL past the capture script's `process.argv[3]` (which becomes `';'`), so a URL-content assertion can never go green; URL/reachability delivery is already locked by the clean "auto-opens once" test (`lifecycle.test.js:447-475`) and tokenizer units R3/R4. RED evidence (with the old `cp.exec`, `<pwned>` IS created) then GREEN (after the rewrite, capture fires and writes the marker but `<pwned>` never appears). Do not weaken or edit the two existing override tests.

**Key Implementation Decisions:** `return` moves INSIDE the `argv.length && argv[0]` guard so blank/quoted-blank values fall through to the built-in launcher (DD-001 Interface contract). Only the override branch changes.

```js
if (process.env.BRAINSTORM_OPEN_CMD) {
  const argv = parseLauncherCommand(process.env.BRAINSTORM_OPEN_CMD);
  if (argv.length && argv[0]) {
    try { cp.execFile(argv[0], [...argv.slice(1), url], () => {}); } catch (e) { /* best effort */ }
    return;
  }
  // empty / quoted-empty / whitespace-only -> fall through to the built-in platform launcher
}
```

## Validation & Closeout

| Task | Detail/Link |
| :--- | :--- |
| **Code Review** | gitban-reviewer via dispatch |
| **QA Verification** | `node lifecycle.test.js` green on Linux; `<pwned>` absent |
| **Staging Deployment** | N/A — plugin source |
| **Production Deployment** | N/A — lands in the sprint PR |
| **Monitoring Setup** | N/A |

### Follow-up & Lessons Learned

| Topic | Status / Action Required |
| :--- | :--- |
| **Postmortem Required?** | No |
| **Further Investigation?** | No |
| **Technical Debt Created?** | No |
| **Future Enhancements** | Shell escape hatch gated on evidence of real use (PRD Future Considerations). |

## Definition of Done

### Intent

When an operator points `BRAINSTORM_OPEN_CMD` at a browser, the companion now runs that launcher directly, with no shell sitting between the operator's value and the process — exactly like the built-in platform launcher two lines below already does. The benefit is that a shell metacharacter appearing in the operator's value or in the companion URL is handed to the browser binary as inert text, never executed, so the shell-injection shape a security audit flagged (#1957) is structurally gone. From the outside, a working launcher (including a quoted path with spaces) still opens the companion exactly once at the reachable, key-carrying URL. If this were broken, the first sign in production would be a malicious or accidental `; touch pwned` in the override value actually creating a file — which the required end-to-end test proves can no longer happen.

### Observable outcomes

- [x] The override branch of `maybeOpenBrowser()` calls `cp.execFile(argv[0], [...argv.slice(1), url])` with no shell; `cp.exec` no longer appears in `maybeOpenBrowser`.
- [x] The guard is `if (argv.length && argv[0])`; a whitespace-only or quoted-empty `BRAINSTORM_OPEN_CMD` falls through to the built-in platform launcher (no `execFile('', …)`).
- [x] The four pre-launch guards and the built-in `execFile` branch are behaviorally unchanged; the in-code comment states the no-shell rationale.
- [x] **Capstone (required e2e no-execution):** spawning `server.cjs` with `BRAINSTORM_OPEN=1` and `BRAINSTORM_OPEN_CMD` = `node "<capture>" "<marker>" ; touch "<pwned>"` asserts (a) `<pwned>` never appears on disk (no shell interpreted the `; touch` — the tokens are inert literal argv) AND (b) the override still fired exactly once (the capture script ran and wrote the marker → marker exists / non-empty). The marker's *contents* are NOT asserted to be the URL here: the injected tokens make the capture's `process.argv[3]` be `';'`, not the URL, so a URL-content assertion could never pass green — URL delivery is covered by the clean "auto-opens once" test (`lifecycle.test.js:447-475`) and tokenizer units R3/R4. This capstone is unfakeable by unit tests and catches a revert of the call site to `cp.exec`.
- [x] Both existing `lifecycle.test.js` override tests pass with no assertion weakened.
- [x] `node lifecycle.test.js` is green on Linux.

### Completion Checklist

- [x] All acceptance criteria are met and verified.
- [x] All tests are passing (`lifecycle.test.js`; full suite in step 4).
- [x] Code review is approved.
- [x] Documentation is updated (in-code comment; operator docs in step 2B).
- [x] Feature is included in the sprint branch.
- [x] Monitoring and alerting are configured. <!-- N/A: plugin source, no runtime service -->
- [x] Stakeholders are notified of completion.
- [x] Follow-up actions are documented and tickets created (none needed).
- [x] Associated ticket/epic is referenced (#1957).




---

## Executor Close-out (cycle 1)

**Shipped** (commit `33e3c08` on `sprint/BSCH1957`; diff limited to the two files):

1. **`skills/brainstorming/scripts/server.cjs`** — replaced the `cp.exec(BRAINSTORM_OPEN_CMD + ' ' + JSON.stringify(url))` sink in `maybeOpenBrowser()` with:
   ```js
   const argv = parseLauncherCommand(process.env.BRAINSTORM_OPEN_CMD);
   if (argv.length && argv[0]) {
     try { cp.execFile(argv[0], [...argv.slice(1), url], () => {}); } catch (e) { /* best effort */ }
     return;
   }
   // empty / quoted-empty / whitespace-only -> fall through to the built-in platform launcher
   ```
   `return` moved *inside* the `argv.length && argv[0]` guard so blank/quoted-blank/whitespace-only overrides fall through to the built-in platform launcher (no `execFile('', …)`). The four pre-launch guards and the built-in `execFile` branch are byte-for-byte unchanged. Comment updated to the no-shell/execFile rationale. `grep 'cp.exec\b'` on the file returns nothing — no `cp.exec` remains anywhere. `parseLauncherCommand` (added by step 2A `1lq5e4`) was reused, not re-added.

2. **`tests/brainstorm-server/lifecycle.test.js`** — added the required e2e no-execution test, reusing the existing `openCaptureCommand` harness. `BRAINSTORM_OPEN_CMD = openCaptureCommand(...) + ' ; touch <pwned>'`. Asserts exactly two things: (a) `<pwned>` is never created on disk, and (b) the launcher fired once (marker written / non-empty). It deliberately does NOT assert marker contents equal the URL — the injected tokens shift the URL past the capture script's `process.argv[3]` (which becomes `';'`). The two existing override tests were not touched.

**RED evidence** (new test present, old `cp.exec` sink still in place):
`FAIL: operator BRAINSTORM_OPEN_CMD is spawned without a shell (no injection)` — "shell metacharacters in BRAINSTORM_OPEN_CMD must never execute — `; touch <pwned>` created a file". Result line: 13 passed, 1 failed. The clean "auto-opens the browser once" URL-delivery test stayed GREEN in the RED run, confirming the new test isolates the sink property.

**GREEN evidence** (after the call-site rewrite), run in the main working tree on `sprint/BSCH1957`:
```
PASS: operator BRAINSTORM_OPEN_CMD is spawned without a shell (no injection)
PASS: auto-opens the browser once, on the first screen
PASS: does NOT auto-open unless approved (BRAINSTORM_OPEN unset)
--- Results: 14 passed, 0 failed ---
```

**Test scope (honest):** Only `tests/brainstorm-server/lifecycle.test.js` was run (targeted, per card). The full `tests/brainstorm-server` suite is deferred to the step-4 capstone per the card's TDD step 5. `ws` (test-only dep) was `npm install`ed into `tests/brainstorm-server/node_modules` (gitignored) to run the suite in the main checkout.

**Deferred:** none. No tech debt, no follow-up cards.

Card left `in_progress` for the reviewer; the two code-review checkboxes are left unticked for the reviewer to flip.
