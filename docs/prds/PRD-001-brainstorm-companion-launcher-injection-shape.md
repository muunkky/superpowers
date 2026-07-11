# PRD-001: Brainstorm companion — remove the operator-launcher shell-injection shape

> **Status**: Draft | **Date**: 2026-07-11 | **Author**: cameron (muunkky fork)
> **Roadmap**: m1/s3/brainstorming/companion-security-hardening
> **Upstream target**: obra/superpowers issue [#1957](https://github.com/obra/superpowers/issues/1957) (mxcoder, filed 2026-07-11, unclaimed, 0 comments, no PR)

## Problem Statement

The reporter of upstream obra/superpowers issue [#1957](https://github.com/obra/superpowers/issues/1957) wants their organization to allow the Superpowers plugin, but their org's (skill-based, AI-driven) security audit flagged a signal that blocks adoption, with the verdict **"Not usable as-is (High)."** The single confirmed signal is the operator-launcher override in `skills/brainstorming/scripts/server.cjs`: when an operator sets `BRAINSTORM_OPEN_CMD`, the server opens the companion by handing a **shell-interpreted command string** — the operator's value concatenated with the companion URL — to a shell. This is the classic shell-injection *shape*, and static/AI audits flag the shape regardless of the guards around it. The audit acknowledged the mitigating context (the path is opt-in, loopback-only, and the value is operator-supplied) and said a reviewer *could* accept it as shipped — but recommended hardening it anyway. Until the shape is gone or the trust model is made explicit enough that an auditor signs off, orgs that gate adoption on a clean security scan cannot use the plugin.

*Provenance:* this PRD is reasoned from issue #1957 plus direct inspection of `server.cjs` — **not** from a first-hand security audit run in our own environment. Per obra/superpowers's contribution rules, that authoring basis (reasoned-from-issue + code inspection, no live session of our own) is disclosed plainly here and must be carried into the eventual PR.

## What "Solved" Means

An equivalent security audit or reviewer re-examining the operator-launcher path — the class of audit that produced #1957 — **no longer classifies it as High-severity or as blocking** — while every one of these invariants continues to hold:

- The opt-in operator override still launches the operator's chosen browser command for its **realistic use** (a binary, optional flags, and path arguments that may be quoted / contain spaces — the command forms the existing test suite and real launcher overrides exercise).
- The four existing pre-launch guards are unchanged: opt-in via `BRAINSTORM_OPEN`, loopback-only bind, skip when a client is already connected, open at most once.
- The built-in platform-launcher path (the non-override branch, which already launches via a shell-free `execFile`) is behaviorally unchanged.
- The existing `tests/brainstorm-server` suite stays green.
- **No new dependency** is introduced (Superpowers is zero-dependency by design).

"Solved" is the audit outcome plus those invariants — deliberately **not** a specific mechanism. Whether the shape is retired by parsing the command shell-free, by documenting the trust model so the auditor accepts it, or by offering a shell-free alternative alongside the current behavior is an engineering decision (see Risks & Open Questions), and the yardstick above is what each candidate is measured against.

## Principles & Assumptions

**Guiding principles**

- **This is exactly one finding — hold that line.** The same audit explicitly *praised* the rest of the server (auth token, timing-safe comparison, Origin check, CSP, path-traversal guards, `chmod 600`). This PRD authorizes work on the operator-launcher path only; it is not a mandate for general "security hardening" of the companion.
- **Do not silently regress the override.** The current design intentionally treats `BRAINSTORM_OPEN_CMD` as a full command so an operator can point it at a real launcher — including quoted paths with spaces and flags. Any change that narrows that capability without a deliberate, recorded decision is a regression, not a fix.
- **Fidelity to upstream norms.** This ships as a PR to a repo with a ~94% rejection rate that closes speculative fixes and scope creep. The change must be crisp, grounded in the real finding, and match the surrounding code's existing safe pattern rather than introduce a new philosophy.

**Assumptions** (each marked as an assumption, not a fact, with what breaks if it is wrong)

- *The single confirmed finding is the whole product problem.* The audit reported one High item on this path and nothing else actionable on the companion. If the org's acceptance actually hinges on additional undisclosed findings, this PRD's "solved" would clear the scan but not unblock adoption. Reason for assuming: the issue and the audit summary describe exactly one finding.
- *"Realistic use" of the override is a launcher invocation — a binary plus flags plus (possibly quoted) path arguments — not arbitrary shell pipelines.* Nobody is relying on `BRAINSTORM_OPEN_CMD` to run `foo | bar && baz`; they are naming a browser and maybe a profile flag or an app path with spaces. If some operator *is* relying on shell features (redirection, pipes, command substitution), a shell-free approach would regress them, and the design decision below must weigh that explicitly. Reason for assuming: the built-in launchers it overrides are all single binary + argv, and the existing test uses `binary + quoted path args`.
- *Keeping the existing lifecycle tests green is a hard boundary the org would recognize as correctness.* The tests set `BRAINSTORM_OPEN_CMD` to `node "<abs path>" "<abs path>"` (double-quoted arguments); a fix that broke them would be breaking the exact behavior contract they encode. Reason for assuming: those tests are the only executable specification of this path.

## Background & Context

The companion server auto-opens a browser the first time a screen is ready to show. Two launch paths exist and are mutually exclusive:

1. **Operator override** (`BRAINSTORM_OPEN_CMD` set): the flagged path. Runs the operator's command string through a shell, with the URL appended.
2. **Built-in platform launcher** (no override): picks `open` / `rundll32.exe` / `xdg-open` per platform and runs it via `execFile` with the URL as a discrete argv element — **no shell**. The in-code comment on this branch explicitly notes it uses `execFile` "so a url-host containing shell metacharacters can't inject a command."

So the repo already contains, two lines below the finding, the shell-free pattern the finding is asking for on the override path. The asymmetry — override goes through a shell, built-in does not — is the entire finding.

`BRAINSTORM_OPEN_CMD` has **no operator-facing documentation**: it appears only in `server.cjs` (in-code comments name it and state its trust posture — "this env var is trusted operator input") and in `tests/brainstorm-server/lifecycle.test.js`. There is no README, skill doc, or config reference — anywhere an operator or auditor would actually look — that tells them the variable exists, what value shape it expects, or that it is treated as trusted. The in-code comments exist but are not where the intended trust model is discoverable. That documentation gap is part of the problem surface: an operator has nothing that tells them how to use the override safely, and an auditor has no user-facing statement of the intended trust model to weigh against the flagged shape.

## Current State

Grounded in `skills/brainstorming/scripts/server.cjs`, `maybeOpenBrowser()` (lines ~526–548):

- Line 531: opens at most once (`browserOpened` guard).
- Line 533: **opt-in** — returns unless `BRAINSTORM_OPEN` is set.
- Line 534: **loopback-only** — returns unless `HOST` is `127.0.0.1` / `localhost`.
- Line 535: **skip-if-connected** — returns if a client is already connected.
- Line 536: builds `companionUrl()` (carries the session key; a keyless URL 403s).
- Lines 538–542 — **the finding**: if `BRAINSTORM_OPEN_CMD` is set, run
  `cp.exec(process.env.BRAINSTORM_OPEN_CMD + ' ' + JSON.stringify(url), () => {})` and `return`. The comment calls the variable "trusted operator input … run as given." `cp.exec` invokes a shell.
- Lines 543–547 — the safe path (only reached when the override is unset): `browserLauncherForPlatform(url)` → `cp.execFile(launcher.bin, launcher.args, () => {})`, no shell.

Test coverage that pins the override behavior (`tests/brainstorm-server/lifecycle.test.js`):

- "auto-opens the browser once, on the first screen" — spawns the server with `BRAINSTORM_OPEN=1` and `BRAINSTORM_OPEN_CMD` = `node "<capture script>" "<marker file>"` (paths JSON-quoted). Asserts the launcher runs exactly once, receives the server URL, and the URL carries a valid key. This encodes the contract: **a multi-token command with quoted path arguments must launch, and the URL must arrive as a usable, reachable argument.**
- "does NOT auto-open unless approved" — same `BRAINSTORM_OPEN_CMD`, but `BRAINSTORM_OPEN` unset; asserts nothing launches. Encodes the opt-in guard.

The delta from here to "solved": retire the shell-injection *shape* on the override path (or make the trust model explicit enough to clear the audit), without disturbing the guards, the built-in path, or those tests — and give the variable the user-facing documentation it currently lacks.

## Goals & Non-Goals

**Goals**

- An org security audit of the companion no longer flags the operator-launcher path High / blocking.
- The opt-in operator override keeps working for realistic launcher commands.
- `BRAINSTORM_OPEN_CMD` gains user-facing documentation of its purpose and trust posture.

**Non-Goals** (with reasoning)

- **General companion "security hardening."** The audit praised auth, CSP, Origin checks, path-traversal guards, and file permissions. Touching them would be unrequested scope on a repo that closes scope creep on sight.
- **Changing the built-in platform-launcher path.** It is already shell-free and was not flagged. Modifying it invites regressions for no benefit. (It stays as the reference pattern, not as edit surface.)
- **Changing the opt-in / loopback / skip-if-connected / once-only guards.** They are correct and out of scope; the finding is about *how* the launch runs, not *whether* it should.
- **Supporting arbitrary shell pipelines through `BRAINSTORM_OPEN_CMD` as a committed capability.** Whether any shell capability is retained at all is the open design decision below; this PRD does not commit to preserving pipes/redirection/substitution, only to preserving realistic launcher invocation.
- **Adding a dependency (e.g., a shell-word-parsing library).** Zero-dependency is a hard repo constraint; the design must stay within the standard library.

## Features

The committed surface is small. Every leaf below must hold for **any** solution the design phase lands on — none of them presupposes a particular parsing strategy.

**Capability: Clear the audit finding on the operator-launcher path**

| Feature (behavior) | Acceptance |
| :--- | :--- |
| The operator-launcher path no longer presents the shell-injection shape a security audit flags. | Re-running the audit's class of check (or a manual review by a skeptical security reviewer) over `maybeOpenBrowser` no longer classifies the `BRAINSTORM_OPEN_CMD` path as High-severity / blocking. The mitigating context and trust posture are either eliminated as a concern or made explicit enough that the reviewer accepts the path as shipped. |

**Capability: Preserve the operator override for realistic use**

| Feature (behavior) | Acceptance |
| :--- | :--- |
| An opt-in operator command consisting of a binary plus arguments still launches the companion, with the URL delivered as a usable argument. | With `BRAINSTORM_OPEN=1` and `BRAINSTORM_OPEN_CMD` set to `node "<script>" "<marker>"`, the companion launches exactly once, the launched process receives the companion URL, and that URL is reachable (carries the valid session key) — i.e. the existing "auto-opens … once" lifecycle test passes unchanged. |
| A command whose argument is a quoted path containing spaces launches with that path intact as a single argument. | An override of the form `<binary> "<path with a space>"` reaches the launched process with the spaced path as one argument, not split — the realistic launcher case (e.g. a browser binary under a path with spaces). |

**Capability: Preserve all surrounding behavior (regression guard)**

| Feature (behavior) | Acceptance |
| :--- | :--- |
| The pre-launch gating is unchanged. | Auto-open still requires `BRAINSTORM_OPEN`, still only fires on a loopback bind, still skips when a client is already connected, and still fires at most once — verified by the existing "does NOT auto-open unless approved" test and the once-only assertion staying green. |
| The built-in platform-launcher path is behaviorally unchanged. | With `BRAINSTORM_OPEN_CMD` unset, platform launcher selection and invocation behave exactly as today (still shell-free, still URL-as-argv). |

**Capability: Document the override**

| Feature (behavior) | Acceptance |
| :--- | :--- |
| `BRAINSTORM_OPEN_CMD` is documented for operators, including its trust posture and the command shape it accepts. | A user-facing doc (the brainstorming skill's operator/config documentation) states that the variable exists, what value it expects, that it is opt-in and loopback-only, and the trust model under which it runs — so an operator and an auditor can both find the intended contract without reading `server.cjs`. |

## User Experience

Two operator scenarios and one auditor scenario the solution must satisfy:

- **Operator override, spaced path (realistic).** An operator on macOS wants the companion to open in a specific browser:
  `BRAINSTORM_OPEN=1 BRAINSTORM_OPEN_CMD='/Applications/My Browser.app/Contents/MacOS/browser' <start companion>`
  The companion opens in that browser, once, at the loopback URL with a valid key. The space in the path does not break the launch.
- **Operator override, binary + flag.** `BRAINSTORM_OPEN_CMD='google-chrome --new-window'` opens Chrome in a new window at the companion URL. (Whether/how flags and quoting are honored precisely is bounded by the open decision; that a plain binary-plus-flag launcher works is committed.)
- **Auditor re-scan.** A security reviewer re-runs the scan (or reads `maybeOpenBrowser`) after the change and does not raise a High/blocking finding on the launcher path; the org proceeds to allow the plugin.

## Success Criteria

Two people should be able to agree on each:

1. The existing `tests/brainstorm-server` suite passes with no test edits that weaken an assertion. (New tests may be *added*.)
2. The operator override launches the companion for a binary-plus-quoted-path command (the lifecycle-test shape) and for a launcher path containing a space.
3. The opt-in, loopback-only, skip-if-connected, and once-only guards remain in force, demonstrated by the guard tests staying green.
4. The built-in platform-launcher branch is unchanged in behavior.
5. No new runtime dependency appears in the diff.
6. A security reviewer, handed the diff, agrees the operator-launcher path no longer warrants a High/blocking finding.
7. `BRAINSTORM_OPEN_CMD` is documented in a user-facing location with its trust posture and accepted command shape.

## Scope & Boundaries

### In Scope
- The `BRAINSTORM_OPEN_CMD` branch of `maybeOpenBrowser` in `skills/brainstorming/scripts/server.cjs`.
- User-facing documentation of `BRAINSTORM_OPEN_CMD`.
- Test additions that lock the chosen behavior (without weakening existing assertions).

### Out of Scope — and why
- Every other security surface of the companion (auth, CSP, Origin, path traversal, permissions) — praised by the audit; not flagged; scope creep upstream will close.
- The built-in platform-launcher branch — already safe, not flagged.
- The pre-launch guards — correct; the finding is about launch mechanism, not gating.
- Any new dependency — violates the zero-dependency constraint.

### Future Considerations
- If real operators turn out to depend on shell features through this variable (pipes, substitution), a deliberate, documented mechanism for that could be revisited — but only on evidence of real use, not speculatively.

## Required Documents

| Artifact | Kind | Status | Lands at |
| :--- | :--- | :--- | :--- |
| How much operator-override capability to retain, and by what means (retire the shell vs. document the trust model vs. offer a shell-free alternative) | ADR | needed | `docs/adr/` |
| The chosen approach for retiring/mitigating the shell-injection shape while preserving realistic override use | design doc | needed | `docs/designs/` |

## Constraints & Technical Context

- **Zero dependency.** Standard library only; no shell-parsing package.
- **Existing tests are a contract.** `tests/brainstorm-server/lifecycle.test.js` sets `BRAINSTORM_OPEN_CMD` to a command with **double-quoted path arguments**; the solution must keep those tests green without weakening their assertions. (Ground-truth consequence, not a design pre-decision: a *naive whitespace split* of the command would retain the literal quote characters as part of the argv and break this test — the design phase must account for that when weighing options.)
- **Match the surrounding pattern.** The safe reference (`execFile`, URL-as-argv) already lives two lines below the finding; the solution should read as consistent with it, not as a new idiom.
- **Upstream target is `dev`, not `main`.** The eventual PR retargets `dev` per the obra/superpowers contributor rules, completes the PR template in full, and discloses the authoring environment.

## Risks & Open Questions

**Open design decision (hand-off to the ADR / design doc — deliberately unresolved here).**
*How much of the operator-override capability is retained, and by what mechanism?* The candidates, with their tradeoffs:

- **(a) Quote-aware argv parsing, no shell** *(the fork's current leaning — recorded as an input, not a mandate).* Retires the shell shape and preserves quoted-path / flag launchers; must implement quote handling in-tree (no dependency) and decide how far to honor quoting edge cases (e.g. nested quotes like `open -a 'Google Chrome'`).
- **(b) Naive whitespace split, no shell.** Simplest to retire the shape, but **regresses** quoted paths with spaces — and, per the constraint above, breaks the existing lifecycle test as written. Likely disqualified by "solved," recorded for completeness.
- **(c) Documentation-only clarification of the trust model.** Leaves the code as-is and makes the opt-in / loopback / operator-trust posture explicit so an auditor accepts it as shipped (the audit conceded a reviewer *could*). Lowest code risk; carries the risk that this particular org's auditor still flags the *shape* regardless of documented context.
- **(d) Keep the shell path and add a pre-split array form.** Preserves full shell capability for those who want it while offering a shell-free alternative; leaves the flagged shape present on the string form, so it may not clear the audit on its own.

The design doc weighs these against the "solved" yardstick; the ADR records the decision. This PRD does not choose.

**Product risks**

- *The audit may not accept a documentation-only or partial fix.* If the org's tooling flags the shape mechanically, only options that remove the shell clear it — a factor the design decision must weigh against the audit's own stated flexibility.
- *Over-narrowing the override.* Choosing a mechanism that drops a launcher form some operator relies on would trade one problem for another; the realistic-use bound in "solved" is the guard.

## Roadmap Fit

    m1/s3/brainstorming/
    └─ companion-security-hardening   (this PRD — in_progress; fork's first upstream contribution)
       ├─ ADR: retain-how-much override capability   (stub — needed)
       └─ design doc: retire/mitigate shell shape     (stub — needed)

This PRD hangs at the existing `companion-security-hardening` feature node and spawns the ADR and design-doc children that Phase-1 planning will carry forward.

## Related Documents

- Upstream issue: obra/superpowers #1957.
- Code: `skills/brainstorming/scripts/server.cjs` (`maybeOpenBrowser`, lines ~526–548; safe reference at 543–547).
- Tests: `tests/brainstorm-server/lifecycle.test.js` (override behavior + opt-in guard).

---
## Revision History
| Date | Author | Notes |
| :--- | :--- | :--- |
| 2026-07-11 | cameron | Initial draft. |
