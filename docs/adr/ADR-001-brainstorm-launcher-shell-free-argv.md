# ADR-001: Retire the brainstorm operator-launcher shell shape with an in-tree quote-aware argv tokenizer

> **Status**: Accepted | **Date**: 2026-07-11 | **Deciders**: cameron (muunkky fork) | **Distilled from**: [DD-001](../designs/DD-001-brainstorm-launcher-shell-free-argv.md) | **PRD**: [PRD-001](../prds/PRD-001-brainstorm-companion-launcher-injection-shape.md)

## In Plain Terms (ELI5)

The brainstorming companion can auto-open a browser using a command an operator supplies (`BRAINSTORM_OPEN_CMD`). Today it runs that command through a shell, which is the classic shell-injection shape a security audit flagged as blocking. We will instead split the operator's command into a program plus its arguments ourselves — honoring quotes so a quoted path with spaces stays one argument — and run the program directly with no shell, exactly like the built-in launcher two lines below already does. The tradeoff we accept: shell-only conveniences (pipes, `$VAR`, `~`, backslash-escaping) stop working — and that is precisely the point, because the shell layer we remove *is* the vulnerability.

## Context

`skills/brainstorming/scripts/server.cjs` (`maybeOpenBrowser()`, ~line 540) hands the operator's `BRAINSTORM_OPEN_CMD` value concatenated with the companion URL to a shell via `cp.exec(cmd + url)`. An org's skill-based / AI security audit (upstream obra/superpowers issue [#1957](https://github.com/obra/superpowers/issues/1957)) classified this shape **High — "Not usable as-is"**, gating that org's adoption of the plugin. The path's four pre-launch guards (opt-in `BRAINSTORM_OPEN`, loopback-only bind, skip-if-connected, open-at-most-once) mitigate but do not remove the structural injection *shape*, and a static/structural scan re-fires on the `cp.exec(string)` sink regardless of the guards or of any prose about the trust model. In the very next branch (the finding returns at `server.cjs:541`; the built-in launcher's `execFile` is `server.cjs:547`), the built-in platform-launcher already does the shell-free thing: `cp.execFile(bin, args)` with the URL as a discrete argv element. Superpowers is zero-dependency, so no shell-parsing library may be added.

A decision was needed because "make the audit stop flagging it" admits several mechanisms (parse shell-free, document the trust model, or offer an alternative form). DD-001 weighed them against the PRD's "solved" and converged; this ADR records that conclusion.

## Decision

Replace the operator-override branch's shell exec with an **in-tree, quote-aware argv tokenizer** (`parseLauncherCommand`) plus `cp.execFile(argv[0], [...argv.slice(1), url])` — **no shell** — making the override branch structurally identical to the built-in platform-launcher branch that is the very next branch (`server.cjs:547`). The tokenizer splits on whitespace outside quotes and keeps single/double-quoted spans intact (stripping the quotes), is ~16 lines of standard-library JavaScript, is exported for unit testing, and never throws. The call site guards with `if (argv.length && argv[0])` — a whitespace-only, empty, or quoted-empty (`['']`) value falls through to the built-in platform launcher rather than reaching `execFile('', …)`. The four pre-launch guards and the built-in branch are untouched.

## Rationale

This removes the flagged sink *structurally* — with no shell, the audit's structural match can no longer fire — while preserving realistic launcher use (a binary, flags, and quoted/spaced path arguments) because the tokenizer honors quotes exactly as shell word-splitting did for the launcher case. It keeps the existing lifecycle test green unchanged: that test sets `BRAINSTORM_OPEN_CMD` to `node "<abs>" "<abs>"`, and the tokenizer strips the JSON double-quotes to yield the argv the capture script needs. It reads as consistent with the `execFile` reference pattern in the very next branch rather than as a new idiom. See DD-001 for the full four-candidate weigh-off.

**The key tradeoff, stated honestly:** removing the shell drops shell-only features of `BRAINSTORM_OPEN_CMD` — pipelines, redirection, command substitution, logical/sequencing operators, globbing, `$VAR` expansion, **`~` (tilde/home) expansion, and backslash-escaping**. All *quoted* launcher forms (including quoted spaced paths) are preserved; two forms that worked under the shell now regress and require the operator to quote instead — backslash-escaped spaces (`/opt/My\ Browser/bin`) and tilde-prefixed paths (`~/bin/browser`, which now `ENOENT`s) must be rewritten as a quoted absolute path. This is acceptable — indeed intended — because **the dropped shell layer is itself the security property**: an injected `; rm -rf ~` becomes an inert literal argv token handed to a browser binary, never a command. The PRD's Non-Goals decline to commit to shell pipelines, and its Future Considerations gate re-adding any shell path on evidence of real use.

## Consequences

### Positive
- The structurally-flagged `cp.exec(string)` sink is gone; an equivalent audit no longer matches the shell shape on the override path. Both launch branches now use `execFile` with the URL as a discrete argv element.
- Injected shell metacharacters (in the operator value *or* the URL) are inert literal tokens — the injection class is closed, not merely mitigated by the guards.
- `BRAINSTORM_OPEN_CMD` gains operator-facing documentation (shape + trust posture + explicit no-shell note) it entirely lacked.

### Negative (honest)
- Shell-only capability through `BRAINSTORM_OPEN_CMD` is lost. Operators using backslash-escaped or `~`-prefixed paths face a minor, operator-visible migration (quote the absolute path); anyone relying on pipes/redirection/substitution loses it. Documented, not silent.
- The tokenizer is a deliberately minimal quote handler (whitespace + single/double quotes only); it does not emulate every shell quoting edge case (e.g. backslash-escaping, nested quoting), by design.

### Neutral
- One new exported pure function and a one-branch call-site edit in a single file; no new modules, call paths, state, schema, or external surface. No new dependency. Rollback is a single-commit revert.

## Alternatives Considered

Weighed in full in DD-001 against the PRD's "solved"; recorded here by reference, not re-argued:

- **(b) Naive whitespace split + `execFile`** — smallest code, but retains the literal quote characters, so it breaks the existing lifecycle test's JSON-quoted paths and splits quoted spaced paths. Fails "existing tests stay green" and "realistic use." Rejected.
- **(c) Documentation-only trust-model clarification** — zero code change, but leaves the structurally-flagged `cp.exec(string)` sink in place, so a structural scan re-fires regardless of prose; bets the outcome on this org's reviewer overriding their own tooling. Its documentation deliverable is kept and folded into the chosen approach. Rejected as the primary fix.
- **(d) Keep the shell string + add a pre-split array env var** — preserves full shell capability, but leaves the flagged sink on the default variable and adds a second config surface (precedence, docs, tests) for a capability (arbitrary pipelines) the PRD declines to commit to. Rejected.

## Validation

- **Security shape removed and regression-locked** by a **required end-to-end no-execution test** in `tests/brainstorm-server/lifecycle.test.js`: spawn the server with a malicious `BRAINSTORM_OPEN_CMD` = `node "<capture>" "<marker>" ; touch "<pwned>"`; assert (a) `<pwned>` never appears on disk (no shell interpreted the `; touch`) and (b) the override still fired once (the capture ran). This test's sole purpose is proving non-execution of the sink — it deliberately does **not** assert URL delivery, because post-fix the injection command tokenizes to `[node, capture, marker, ';', 'touch', pwned]` and `execFile` appends the URL last, so the capture's argument for the marker is `';'`, not the URL. URL delivery is separately locked by the existing clean "auto-opens once" test and the tokenizer unit assertions. This spawn test — not the tokenizer unit tests — is what catches a future revert of the call site to `cp.exec(argv.join(' '))`, which would keep every unit test green while reopening injection.
- Unit assertions on `parseLauncherCommand` in `browser-launcher.test.js` (metacharacters inert, quoted spaced path stays one arg, lifecycle shape strips quotes, empty/quoted-empty/unmatched-quote edge cases).
- Both existing `lifecycle.test.js` override tests pass with no assertion weakened; the full `tests/brainstorm-server` suite is green on Linux; the diff adds no dependency.
- **Necessary but not sufficient:** clearing the structural shell shape removes the single *confirmed* finding (#1957), but the reporter's org adopting the plugin also rests on the PRD-scope assumption that #1957 is the whole product problem — if the org has undisclosed audit findings, this change clears the scan without unblocking adoption (see DD-001's residual-risk row, "the org's specific auditor still flags something after the shell is gone").
- **Revisit trigger:** evidence that real operators depend on shell features through `BRAINSTORM_OPEN_CMD` (the migration proves too costly in practice) — at which point a deliberate, documented shell path is reconsidered per the PRD's Future Considerations. Absent such evidence, the shell-free form stands.

## Related Decisions

First ADR in this repo (accepted from NOM-001); supersedes nothing. Records the decision DD-001 deliberated; satisfies PRD-001's "solved." Downstream: the sprint-architect decomposes DD-001's single implementation phase into cards.

## References

- Design doc (full deliberation, four-candidate weigh-off): [DD-001](../designs/DD-001-brainstorm-launcher-shell-free-argv.md)
- PRD ("solved" + invariants): [PRD-001](../prds/PRD-001-brainstorm-companion-launcher-injection-shape.md)
- Upstream finding: obra/superpowers issue [#1957](https://github.com/obra/superpowers/issues/1957)
- Code: `skills/brainstorming/scripts/server.cjs` (`maybeOpenBrowser`, ~line 540); safe reference pattern two lines below
- Tests: `tests/brainstorm-server/lifecycle.test.js`, `tests/brainstorm-server/browser-launcher.test.js`
- Roadmap: `m1/s3/brainstorming/companion-security-hardening`

---
## Revision History
| Date | Status | Notes |
| :--- | :--- | :--- |
| 2026-07-11 | Proposed | Distilled from DD-001 as NOM-001 — records candidate (a): in-tree quote-aware argv tokenizer + `execFile`, dropping shell-only features deliberately. |
| 2026-07-11 | Accepted | ADR reviewer returned APPROVED; applied polish M1 (necessary-but-not-sufficient adoption clause) and M2 (precise `server.cjs:541`/`:547` branch references); promoted NOM-001 → ADR-001. |
| 2026-07-11 | Accepted | Sprint-reviewer factual correction: the end-to-end no-execution test asserts only non-creation of `<pwned>` and that the override fired once — not URL delivery (the injection tokens shift the marker argument to `';'`); URL delivery is locked by the clean "auto-opens once" test and tokenizer units. No change to the Decision or tradeoff. |
