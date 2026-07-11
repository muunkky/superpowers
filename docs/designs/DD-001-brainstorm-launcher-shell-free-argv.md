# DD-001: Brainstorm companion — retire the operator-launcher shell shape with a quote-aware argv tokenizer

> **PRD**: [PRD-001](../prds/PRD-001-brainstorm-companion-launcher-injection-shape.md) | **Date**: 2026-07-11 | **Author**: cameron
> **Roadmap**: m1/s3/brainstorming/companion-security-hardening

## Overview

The brainstorming companion server auto-opens a browser the first time a screen is ready. When an operator sets `BRAINSTORM_OPEN_CMD`, the override branch of `maybeOpenBrowser()` hands the operator's value concatenated with the companion URL to a shell via `cp.exec` — the classic shell-injection *shape*. An org's security audit (upstream obra/superpowers issue #1957) flagged this shape as **High / blocking** and gates the org's adoption of the plugin on it being gone or made explicitly trusted. Two lines below the finding, the built-in platform-launcher branch already does the shell-free thing: `cp.execFile(bin, args)` with the URL as a discrete argv element.

**"Solved"** (from the PRD) is an outcome, not a mechanism: an equivalent audit no longer classifies the override path as High/blocking, while five invariants hold — the override still launches a realistic launcher (binary + flags + quoted/spaced path args, the shape the existing tests exercise); the four pre-launch guards are untouched; the built-in launcher path is behaviorally unchanged; the existing `tests/brainstorm-server` suite stays green; and no new dependency is added. Plus, `BRAINSTORM_OPEN_CMD` gains the operator-facing documentation it entirely lacks today.

This design converges on **candidate (a): parse the override string into argv with a small hand-rolled quote-aware tokenizer, then launch via `cp.execFile` with no shell** — making the override branch structurally identical to the built-in branch that the audit already accepts. The tokenizer is ~16 lines of standard-library JavaScript (no dependency), the call-site edit is ~8 lines, and the capability the PRD calls "realistic use" (quoted paths with spaces, flags) is preserved because the tokenizer honors quotes exactly as a shell's word-splitting does for the launcher case. Shell-only features (pipes, redirection, substitution, globbing, env expansion) are deliberately dropped and documented as dropped.

## Requirements

The implementation is complete when:

1. The `BRAINSTORM_OPEN_CMD` branch of `maybeOpenBrowser()` no longer routes through a shell — it invokes `cp.execFile(bin, args)` with the URL as a discrete argv element, matching the built-in branch's shell-free pattern.
2. A shell metacharacter appearing in `BRAINSTORM_OPEN_CMD` *or* in the companion URL is passed as an inert literal argv token and is never interpreted or executed.
3. The existing lifecycle override contract holds: with `BRAINSTORM_OPEN=1` and `BRAINSTORM_OPEN_CMD` = `node "<abs script>" "<abs marker>"` (JSON-double-quoted paths), the companion launches exactly once and the launched process receives the reachable, key-carrying URL — the current `lifecycle.test.js` assertions pass **unchanged**.
4. A quoted path containing a space reaches the launched process as a single argument (not split).
5. The four pre-launch guards (opt-in `BRAINSTORM_OPEN`, loopback-only bind, skip-if-connected, open-at-most-once) and the built-in platform-launcher branch are behaviorally unchanged.
6. No new runtime dependency appears in the diff; the tokenizer is hand-rolled standard-library JavaScript.
7. `BRAINSTORM_OPEN_CMD` is documented in a user-facing location with its accepted command shape, its opt-in/loopback trust posture, and an explicit "no shell — these features are not honored" note.

## Current State

Grounded in `skills/brainstorming/scripts/server.cjs`, `maybeOpenBrowser()` (lines 526–548):

```js
let browserOpened = false;
function maybeOpenBrowser() {
  if (browserOpened) return;
  browserOpened = true;
  if (!process.env.BRAINSTORM_OPEN) return;              // opt-in guard
  if (HOST !== '127.0.0.1' && HOST !== 'localhost') return; // loopback-only guard
  if (clients.size > 0) return;                          // skip-if-connected guard
  const url = companionUrl();                            // carries the session key
  const cp = require('child_process');
  // Operator-provided launcher: run as given (this env var is trusted operator input).
  if (process.env.BRAINSTORM_OPEN_CMD) {
    try { cp.exec(process.env.BRAINSTORM_OPEN_CMD + ' ' + JSON.stringify(url), () => {}); } catch (e) { /* best effort */ }
    return;                                              // <-- the finding: cp.exec invokes a shell
  }
  // Platform launchers: URL as an argv element via execFile (no shell)
  const launcher = browserLauncherForPlatform(url);
  if (!launcher) return;
  try { cp.execFile(launcher.bin, launcher.args, () => {}); } catch (e) { /* best effort */ }
}
```

`browserOpened = true` is set at the top, so the once-only guard is independent of which branch runs. `module.exports` (line 716) already exports a handful of internal functions (`computeAcceptKey`, `browserLauncherForPlatform`, …), so adding one more export for unit testing is idiomatic, not a new pattern.

**Test coverage that pins this behavior:**
- `tests/brainstorm-server/lifecycle.test.js` — `openCaptureCommand()` (line 60) writes a small capture script and returns `` `node ${JSON.stringify(scriptPath)} ${JSON.stringify(markerPath)}` `` — i.e. **`node "<abs>" "<abs>"` with literal double-quotes in the value**. Two tests spawn the real server with this as `BRAINSTORM_OPEN_CMD`: "auto-opens … once" (asserts the launcher fires once and the marker file receives the reachable URL) and "does NOT auto-open unless approved" (opt-in guard).
- `tests/brainstorm-server/browser-launcher.test.js` — a pure-unit file that imports `browserLauncherForPlatform` from `server.cjs` and asserts the built-in launchers never route through `cmd.exe`. No server spawn. This is the natural home for a unit-level tokenizer/injection assertion.

**Documentation:** `BRAINSTORM_OPEN_CMD` has **no** operator-facing documentation — it appears only in an in-code comment and the two tests. `skills/brainstorming/visual-companion.md` is the operator guide for the companion (documents `--open`, `--host`, `--url-host`, idle timeout) but has no environment-variable or trust-model section.

## Target State

The override branch becomes structurally identical to the built-in branch — argv + `execFile`, no shell:

```js
if (process.env.BRAINSTORM_OPEN_CMD) {
  const argv = parseLauncherCommand(process.env.BRAINSTORM_OPEN_CMD);
  if (argv.length && argv[0]) {
    try { cp.execFile(argv[0], [...argv.slice(1), url], () => {}); } catch (e) { /* best effort */ }
    return;
  }
  // empty / quoted-empty / whitespace-only override: fall through to the built-in platform launcher
}
```

The `argv[0]` conjunct in the guard is deliberate: a quoted-empty value (`""`) tokenizes to `['']` (length 1, empty binary), and it prevents an `execFile('', …)` — see the Interface contract. The audit's flagged asymmetry (override → shell, built-in → no shell) is gone: both paths now launch via `execFile`, and the URL is a discrete argv element on both. A metacharacter in the operator value or the URL is a plain string in `args`, never a shell token.

## Design

### Architecture

One new pure function plus a rewritten call site inside one file. No new modules, no new call paths, no change to how `maybeOpenBrowser` is reached.

```
maybeOpenBrowser()
  ├─ [guards unchanged] browserOpened / BRAINSTORM_OPEN / loopback / clients / once
  ├─ url = companionUrl()
  ├─ if BRAINSTORM_OPEN_CMD:
  │     argv = parseLauncherCommand(value)   ← NEW pure fn (quote-aware tokenizer)
  │     if argv.length && argv[0]: cp.execFile(argv[0], [...argv.slice(1), url])   ← was cp.exec(string)
  │     else: fall through                    ← empty / quoted-empty / whitespace-only → built-in launcher
  └─ else: browserLauncherForPlatform(url) → cp.execFile(bin, args)   [UNCHANGED]
```

### Key Design Decisions

**Decision: parse to argv + `execFile`, no shell (candidate a).** The PRD hands four candidates. Weighed against "solved":

- **(b) Naive whitespace split + `execFile`.** Retires the shape and is the smallest code, but **disqualified by the existing lifecycle test**: `openCaptureCommand` produces `node "<abs>" "<abs>"`. Splitting on whitespace yields argv `['node', '"<abs>"', '"<abs>"']` with the double-quote characters *retained*, so `node` is asked to open a file literally named `"…"` and the capture never fires. It also fails requirement 4 (a quoted spaced path splits into two args). Fails "solved" on the "existing tests stay green" and "realistic use" invariants. Recorded, rejected.

- **(c) Documentation-only clarification of the trust model.** Zero code change; make the opt-in/loopback/operator-trust posture explicit so an auditor accepts the shape as shipped. The audit *did* concede a reviewer "could" accept it. But "solved" must clear **the audit's class of check** — a skill-based / static audit that flags the *shape*. Documentation does not remove the shape; the flagged `cp.exec(string)` sink remains, and a structural scan re-fires regardless of prose. It bets the whole outcome on this particular org's reviewer overriding their own tooling — the exact bet the PRD's product risk calls out. Fails "solved" for a structural audit. Rejected as the primary fix, but its documentation deliverable is **kept and folded in** (requirement 7): the trust model should be discoverable regardless of which mechanism ships.

- **(d) Keep the shell string form, add a pre-split array env var.** Preserves full shell capability *and* offers a shell-free alternative — but the flagged `cp.exec(string)` sink stays on the default variable, so a structural audit still fires on it. It also adds a second config surface (two env vars, precedence rules, more docs, more tests) for a capability (arbitrary shell pipelines) the PRD explicitly declines to commit to (Non-Goal: "Supporting arbitrary shell pipelines … as a committed capability"). Fails the removability test — the extra env var earns nothing toward "solved" and enlarges the surface. Rejected.

- **(a) Quote-aware argv tokenizer + `execFile`.** Removes the sink entirely (the audit's structural flag can no longer match — there is no shell), preserves realistic launcher use (binary + flags + quoted/spaced path args) because the tokenizer honors quotes, keeps the lifecycle test green (it strips the JSON double-quotes, producing the argv the test expects), and reads as consistent with the `execFile` reference pattern two lines below rather than as a new idiom. The only cost is ~16 lines of tokenizer — which earns its keep: it is exactly what lets (a) preserve the quoted-path capability that (b) loses. **Chosen.**

**Decision: the tokenizer honors quotes, and operators quote spaced paths — same as the shell already required.** A subtle point that must not be mistaken for a regression: the PRD's UX example `BRAINSTORM_OPEN_CMD='/Applications/My Browser.app/Contents/MacOS/browser'` has its quotes consumed by the operator's *setting* shell, so the env **value** contains literal spaces and no quotes. Under the *old* `cp.exec` path, that value was word-split by the shell too — `/Applications/My` and `Browser.app/…` — so a spaced binary path *already* required the operator to embed quotes in the value (`'"/Applications/My Browser.app/…"'`). The tokenizer reproduces exactly this: it splits on whitespace *outside* quotes and keeps quoted spans intact. So no *quoted* launcher form regresses, and requirement 4's acceptance (`<binary> "<path with a space>"`) is met. **Two shell-quoting forms do regress, deliberately** — the operator must quote the path instead: (1) *backslash-escaped spaces* — `/opt/My\ Browser/bin` tokenizes to `['/opt/My\\', 'Browser/bin']` (the shell gave one arg; the tokenizer does not honor backslash-escaping); (2) *tilde-prefixed paths* — `~/bin/browser` is passed literally (the shell expanded `~`→`$HOME`; `execFile` will `ENOENT`). Both are covered by the "not honored" list below and named in the operator docs, so the workaround (quote the absolute path) is discoverable. This is why (a) is a faithful, near-parity replacement — every quoted launcher form is preserved — rather than a silent narrowing.

**Decision: drop shell-only features, deliberately and documentedly.** `execFile` spawns the binary directly, so pipelines (`|`), redirection (`>`/`<`), command substitution (`$(…)` / backticks), logical/sequencing operators (`&&`/`||`/`;`/`&`), glob expansion (`*`), environment-variable expansion (`$VAR`), tilde expansion (`~`→`$HOME`), and backslash-escaping (`\ ` for a literal space) are **not** honored — their characters survive as inert literal argv tokens. This is the security property itself (an injected `; rm -rf ~` is just a string handed to a browser binary, not a command). The PRD's Non-Goals decline to commit to shell pipelines, and its Future Considerations gate any real shell need on evidence of real use. This loss is intended and must be stated in the operator docs (requirement 7).

### Interface Design

**New exported pure function** in `server.cjs`, added to `module.exports`:

```js
/**
 * Split an operator launcher command into an argv array, honoring single and
 * double quotes so a quoted path containing spaces stays one argument. No shell
 * is involved: metacharacters (; | & $ ` * > <) are inert literal characters.
 * Best-effort and total — never throws; an unmatched quote closes at end-of-string.
 * @param {string} str
 * @returns {string[]}  argv (empty for an empty/whitespace-only input)
 */
function parseLauncherCommand(str) {
  const argv = [];
  let cur = '';
  let quote = null;   // "'" or '"' while inside a quoted span, else null
  let started = false; // does cur hold a token (incl. an empty "" quoted token)?
  for (const ch of str) {
    if (quote) {
      if (ch === quote) quote = null;      // closing quote: drop it, stay in token
      else cur += ch;                      // any char (incl. spaces) is literal
    } else if (ch === '"' || ch === "'") {
      quote = ch; started = true;          // opening quote: drop it, begin token
    } else if (ch === ' ' || ch === '\t' || ch === '\n' || ch === '\r') {
      if (started) { argv.push(cur); cur = ''; started = false; }
    } else {
      cur += ch; started = true;
    }
  }
  if (started) argv.push(cur);             // flush trailing token (also closes unmatched quote)
  return argv;
}
```

**Contract:**
- Whitespace-separated tokens; single **and** double quotes group (and are stripped from the result). `node "a b" c` → `['node', 'a b', 'c']`.
- Lifecycle shape `node "/x/s.cjs" "/y/m"` → `['node', '/x/s.cjs', '/y/m']` (double-quotes stripped — this is what makes the existing test pass).
- **Empty / whitespace-only input** → `[]`. A **quoted-empty** input (`""` or `''`) → `['']` (length 1, `argv[0] === ''`). At the call site both cases **fall through to the built-in platform launcher** — the guard is `if (argv.length && argv[0])`, so an empty binary never reaches `execFile('', …)`. A blank/quoted-blank override is treated as "no override" (the most useful behavior, and it keeps a misconfigured value from silently doing nothing). Note that a truly empty string never reaches the tokenizer anyway (`if (process.env.BRAINSTORM_OPEN_CMD)` is falsy for `''`); the fall-through matters for whitespace-only (`"   "`) and quoted-empty (`'""'`) values.
- **Unmatched quote** → best-effort: the open span is flushed as one token at end-of-string (`open 'foo` → `['open', 'foo']`). Never throws — and the call site is inside `try/catch` regardless.
- Metacharacters have **no special meaning**: `open ; touch pwned` → `['open', ';', 'touch', 'pwned']`. Handed to `execFile('open', [';', 'touch', 'pwned', url])`, nothing but `open` is ever spawned.

**Call-site edit** (the exact replacement for lines 539–542): as shown in Target State. The `return` moves *inside* the `argv.length && argv[0]` guard so a whitespace-only, empty, or quoted-empty value falls through; the four guards above and the built-in branch below are untouched.

## Implementation Phases

Single phase — this is a ~24-line change (tokenizer + call site + one export) plus tests and docs, all vertically complete together.

### Phase 1: Shell-free operator launcher + docs

**Goal.** Replace the `cp.exec(string)` override with `parseLauncherCommand` + `cp.execFile(argv[0], [...argv.slice(1), url])`, document the variable, and lock the behavior with tests.

**Deliverables.**
- `parseLauncherCommand(str)` added to `server.cjs` and to `module.exports`.
- Override branch of `maybeOpenBrowser()` rewritten to the argv/`execFile` form with the whitespace-only fall-through; in-code comment updated to state "no shell — argv via execFile, matching the platform-launcher branch below."
- Operator documentation of `BRAINSTORM_OPEN_CMD` in `visual-companion.md`.

**Test strategy (written first).**
- **New security-regression assertions in `tests/brainstorm-server/browser-launcher.test.js`** (it already imports from `server.cjs`; add `parseLauncherCommand` to the import). Written before the call-site edit:
  1. *Metacharacters are inert* — `parseLauncherCommand('open ; touch pwned')` deep-equals `['open', ';', 'touch', 'pwned']`; likewise assert `$(evil)`, a backtick span, `&&`, and `|` survive as literal tokens, never as operators. The test comment names the guarantee: these tokens are handed to `execFile`, which spawns no shell, so the metacharacter cannot execute.
  2. *Quoted spaced path stays one arg* — `parseLauncherCommand('bin "/A/My Browser.app/x"')` deep-equals `['bin', '/A/My Browser.app/x']` (requirement 4).
  3. *Lifecycle shape strips quotes* — `parseLauncherCommand('node "/x/s.cjs" "/y/m"')` deep-equals `['node', '/x/s.cjs', '/y/m']` (proves requirement 3 at the unit level — the argv the capture script needs).
  4. *Edge cases* — `''` and `'   '` → `[]`; unmatched quote `open 'foo` → `['open', 'foo']` and does not throw.
- **End-to-end no-execution assertion — REQUIRED — in `tests/brainstorm-server/lifecycle.test.js`** (which already has the `openCaptureCommand` spawn harness; reuse it, do **not** duplicate it into `browser-launcher.test.js`). This test is what regression-locks the *sink*, not just the tokenizer: the unit assertions above prove `parseLauncherCommand` doesn't special-case `;`, but a future revert of the call site to `cp.exec(argv.join(' '))` would keep every unit test green while reopening injection — only a spawn test that asserts non-execution catches that. Spawn `server.cjs` with `BRAINSTORM_OPEN=1` and `BRAINSTORM_OPEN_CMD` = `node "<capture>" "<marker>" ; touch "<pwned>"`; assert **(a)** `<pwned>` never appears on disk (the `; touch` was not interpreted by any shell) and **(b)** the override fired exactly once (the capture script ran — the marker file exists and is non-empty). This test intentionally does **not** re-assert URL delivery: post-fix the command tokenizes to `['node', '<capture>', '<marker>', ';', 'touch', '<pwned>']` and `execFile` appends the URL last, so the capture script's `process.argv[3]` is `';'`, not the URL — the URL is no longer at the position the capture script reads, so "marker records the reachable URL" cannot hold green for this deliberately-malformed input. That is fine: URL delivery is separately regression-locked by the existing clean "auto-opens … once" test (`lifecycle.test.js:447–475`, which uses the well-formed `node "<capture>" "<marker>"` shape) and by tokenizer units R3/R4 (lifecycle-shape and quoted-spaced-path). This injection test's sole job is proving non-execution of the sink.
- **Existing tests stay green, unchanged** — the two `lifecycle.test.js` override tests must pass with **no edit to their assertions** (requirement 3, 5). Run the full `tests/brainstorm-server` suite on Linux.

**Infrastructure.** None.

**Documentation.** Add a short subsection to `skills/brainstorming/visual-companion.md` — a new "Operator configuration: `BRAINSTORM_OPEN_CMD`" block placed after "Starting a Session" (where `--open`/`--host` are already documented). It states: (a) the variable overrides the auto-open launcher; (b) the accepted shape — a binary followed by optional flags and arguments, whitespace-separated, with single/double quotes grouping so a path containing spaces must be quoted; (c) the trust posture — it only fires under `BRAINSTORM_OPEN` (opt-in) on a loopback bind, and its value is treated as trusted operator input; (d) an explicit "**no shell**: pipes, redirection, command substitution, globbing, `$VAR` expansion, `~` (tilde/home) expansion, and backslash-escaping are not honored — name a single launcher binary and its arguments, and **quote** any path containing spaces (do not backslash-escape or use `~`; give the absolute path)." Keep it to a compact block; do not create a new standalone doc.

**Dependencies.** None.

**Definition of done (binary).**
- [ ] `parseLauncherCommand` exists in `server.cjs`, is exported, and behaves per the contract above.
- [ ] The override branch calls `cp.execFile(argv[0], [...argv.slice(1), url])` with no shell; `cp.exec` no longer appears in `maybeOpenBrowser`.
- [ ] Empty, quoted-empty, and whitespace-only `BRAINSTORM_OPEN_CMD` fall through to the built-in launcher (guard is `argv.length && argv[0]`); the four guards and the built-in branch are byte-for-byte unchanged in behavior.
- [ ] New `browser-launcher.test.js` unit assertions (metacharacter-inert, quoted-spaced-path, lifecycle-shape, edge cases incl. quoted-empty→`['']`) pass on Linux.
- [ ] New **required** end-to-end no-execution test in `lifecycle.test.js` (malicious `; touch "<pwned>"` override launches the capture but never creates `<pwned>`) passes on Linux.
- [ ] Both existing `lifecycle.test.js` override tests pass with no assertion weakened.
- [ ] The full `tests/brainstorm-server` suite is green on Linux.
- [ ] `visual-companion.md` documents `BRAINSTORM_OPEN_CMD` (shape + trust posture + no-shell note).
- [ ] No new entry in `package.json`/`package-lock.json`; the diff adds no dependency.

## Migration & Rollback

**Migration.** None required for the common case — the built-in launcher path and all guards are untouched, and existing quoted-path overrides (the tested shape) behave identically. **Behavioral break, deliberate and documented:** any operator relying on shell features through `BRAINSTORM_OPEN_CMD` (pipes, redirection, substitution, globbing, `$VAR`, `~` expansion, backslash-escaping) loses them; the new operator docs state this, and the PRD's Future Considerations gate re-adding a shell path on evidence of real use. **Quoting note:** operators who need a spaced binary path must ensure the *value* carries quotes (e.g. `BRAINSTORM_OPEN_CMD='"/Applications/My Browser.app/Contents/MacOS/browser"'`) — the old shell path already required quoting for spaced paths, but the two forms that *did* work under the shell and now don't are backslash-escaped spaces (`My\ Browser`) and `~`-prefixed paths; both must be rewritten as a quoted absolute path. This is documented, not a silent narrowing.

**Rollback.** Revert the single commit; the change is confined to `server.cjs` plus `browser-launcher.test.js`, `lifecycle.test.js`, and `visual-companion.md`. No state, no schema, no external surface.

## Risks

| Risk | Impact | Likelihood | Mitigation |
| :--- | :--- | :--- | :--- |
| An operator depends on shell features through `BRAINSTORM_OPEN_CMD` and their launch silently stops working. | Medium (broken auto-open for that operator) | Low (PRD assumption: overrides are launcher invocations, not pipelines; built-in launchers it mirrors are all single binary + argv) | Operator docs state the no-shell contract and the accepted shape explicitly; auto-open is best-effort and the URL is always shared as a fallback, so a failed override never blocks the session. |
| Tokenizer diverges from shell word-splitting on some quoting edge case and a real override subtly mis-parses. | Medium | Low | Contract is deliberately minimal (whitespace + single/double quotes, matching the launcher forms the tests and built-ins use); unit tests cover the lifecycle shape, spaced quoted path, unmatched quote, and empty input. No attempt to emulate backslash-escaping or nested quoting — out of scope for launcher invocation and would add surface without earning it. |
| The org's specific auditor still flags something after the shell is gone. | High (adoption stays blocked) | Low | The finding is explicitly the shell *shape* (issue #1957); removing `cp.exec` eliminates the structural match. PRD assumption records that this is the single confirmed finding; if the org has undisclosed findings, that is an upstream PRD-scope question, not a design defect here. |
| Whitespace-only fall-through masks a genuine operator typo (they meant to set a launcher, set blanks, and get the platform default instead). | Low | Low | Documented behavior; the alternative (no-op on blank) is strictly worse (silent nothing). Truly empty strings already fell through under the old code too (falsy guard), so this only extends existing behavior to whitespace. |

## Roadmap Connection

Hangs at `m1/s3/brainstorming/companion-security-hardening` (the PRD's node). This design's `docs_ref` should be set on that feature. Next in the lifecycle: an **ADR** distills and locks the decision — "retire the operator-launcher shell shape via an in-tree quote-aware argv tokenizer + `execFile`, dropping shell-only features deliberately" — citing this doc for the deliberation (the four-candidate weigh-off); then the **sprint-architect** decomposes this single phase into cards (the edit is mechanical from the Interface Design and DoD above).

## Open Questions

Written autonomously (no interactive user). Assumptions recorded for the reviewer to challenge:

- **Appetite assumed: minimal, surgical.** The PRD frames this as exactly one finding on a repo with a 94% rejection rate that closes scope creep — so the correct size is the smallest change that removes the shell shape while matching the existing `execFile` pattern, not a configurable launcher subsystem. A larger appetite (e.g. candidate (d)'s dual env vars) would be over-built here. Challenge this if the maintainers actually want a preserved shell escape hatch.
- **Security-regression test placement — resolved.** Two tiers, both required: unit assertions on `parseLauncherCommand` in `browser-launcher.test.js` (tokenizer contract) *and* an end-to-end no-execution spawn test in `lifecycle.test.js` (sink is shell-free). The spawn test is mandatory precisely because the unit tier alone would stay green through a revert of the call site back to `cp.exec(argv.join(' '))` — only asserting non-execution regression-locks the property. No open question remains here.
- **Doc home = `visual-companion.md`.** Chosen because it is the existing companion guide that already documents adjacent knobs (`--open`, `--host`, idle timeout), ships normally with the skill (not scaffold-synced), and keeps the override's trust posture next to the launch flags it modifies. It is **agent-facing prose**, not an operator config reference — no claim is made that operators will "naturally look here"; it is simply the least-surprising existing home, and inventing a standalone config doc is what the PRD warns against. Placement is immediately after "Starting a Session". Challenge if the project later wants a dedicated operator/config reference.

---
## Revision History
| Date | Author | Notes |
| :--- | :--- | :--- |
| 2026-07-11 | cameron | Initial draft — converges on candidate (a): in-tree quote-aware argv tokenizer + `execFile`. |
| 2026-07-11 | cameron | Review refinements: correct the parity claim (backslash/tilde paths regress — quote instead); add `~`/backslash to the no-shell list in Decision-3 and the operator doc; promote the end-to-end no-execution test to required and site it in `lifecycle.test.js`; harden the call-site guard to `argv.length && argv[0]` for quoted-empty input; reframe the doc-home rationale. |
