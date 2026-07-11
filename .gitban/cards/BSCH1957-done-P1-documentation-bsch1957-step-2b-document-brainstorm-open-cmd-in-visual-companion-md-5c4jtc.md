# Documentation: operator guide for `BRAINSTORM_OPEN_CMD`

## Documentation Scope & Context

* **Related Work:** BSCH1957 sprint; DD-001 req 7; PRD-001 success criterion #7; upstream issue #1957.
* **Documentation Type:** Operator/config documentation for the brainstorm visual companion.
* **Target Audience:** Operators who set the companion's auto-open launcher, and security auditors looking for the variable's trust model.

**Required Checks:**
- [x] Related work/context is identified above.
- [x] Documentation type and audience are clear.
- [x] Existing documentation locations are known (avoid creating duplicates).

**Depends on:** step 1 `g4eaj9`. **Runs parallel with:** step 2A (different file — this card touches only `skills/brainstorming/visual-companion.md`; step 2A touches `server.cjs` + `browser-launcher.test.js`). **Behavior is fully specified by DD-001**, so it does not need to wait on the code cards.

### Required Reading

| Path / Location | Why |
| :--- | :--- |
| `skills/brainstorming/visual-companion.md` lines 33–46 ("Starting a Session") | The insertion point — the new block goes immediately after this section, where `--open` / `--host` / `--url-host` are already documented. |
| `docs/designs/DD-001-brainstorm-launcher-shell-free-argv.md` "Documentation" (Phase 1) | The exact content contract: (a) purpose, (b) accepted shape, (c) trust posture, (d) explicit no-shell note naming the dropped features including tilde and backslash. |
| `docs/adr/ADR-001-brainstorm-launcher-shell-free-argv.md` Rationale | The "dropped shell layer IS the security property" framing and the tilde/backslash regression + workaround (quote the absolute path). |

## Pre-Work Documentation Audit

- [x] Repository root reviewed for doc cruft (no stray launcher doc exists).
- [x] `/docs` directory reviewed — planning docs are gitignored and NOT the operator home; do not document there.
- [x] Related service/component documentation reviewed (`visual-companion.md` is the companion's operator guide).
- [x] Team wiki or internal docs reviewed — N/A for this plugin.

| Document Location | Current State | Action Required |
| :--- | :--- | :--- |
| **visual-companion.md** | Documents `--open`, `--host`, `--url-host`, idle timeout; has NO environment-variable or trust-model section. `BRAINSTORM_OPEN_CMD` is entirely undocumented (appears only in `server.cjs` comments + tests). | Add one compact block after "Starting a Session" covering shape + trust posture + no-shell note. |
| **README / standalone doc** | None exists for this variable. | Do NOT create a standalone config doc — DD-001 warns against it; keep it in `visual-companion.md`. |
| **docs/prds, docs/adr, docs/designs** | Gitignored planning docs. | MUST NOT appear in the PR diff; not the operator home. |

**Documentation Organization Check:**
- [x] No duplicate documentation found across locations.
- [x] Documentation follows the companion guide's existing structure (block after "Starting a Session").
- [x] Cross-references between docs are working (none required).
- [x] Orphaned or outdated docs identified for cleanup (none).

## Documentation Work

| Task | Status / Link to Artifact | Universal Check |
| :--- | :--- | :---: |
| **Add `BRAINSTORM_OPEN_CMD` block to visual-companion.md** | `skills/brainstorming/visual-companion.md`, after "Starting a Session" | - [x] Complete |
| **State the accepted command shape** | binary + optional flags + args, whitespace-separated; single/double quotes group so a path with spaces must be quoted | - [x] Complete |
| **State the trust posture** | opt-in via `BRAINSTORM_OPEN`, loopback-only bind, value treated as trusted operator input | - [x] Complete |
| **State the explicit no-shell note** | pipes, redirection, command substitution, globbing, `$VAR` expansion, `~` (tilde/home) expansion, and backslash-escaping are NOT honored; name a single binary + args and QUOTE any spaced path (do not backslash-escape or use `~`; give the absolute path) | - [x] Complete |

**Documentation Quality Standards:**
- [x] All code examples tested and working (the example `BRAINSTORM_OPEN_CMD` values are valid for the shell-free tokenizer).
- [x] All commands verified.
- [x] All links working (no 404s).
- [x] Consistent formatting and style (matches the surrounding companion guide).
- [x] Appropriate for target audience (operator + auditor).
- [x] Follows the guide's documentation style.

## Validation & Closeout

| Task | Detail/Link |
| :--- | :--- |
| **Final Location** | `skills/brainstorming/visual-companion.md` (block after "Starting a Session"). |
| **Path to final** | `skills/brainstorming/visual-companion.md` |

### Acceptance Criteria (binary)

- [x] `visual-companion.md` contains a new, compact `BRAINSTORM_OPEN_CMD` block placed immediately after the "Starting a Session" section (not a new standalone file).
- [x] The block states the accepted command shape: a single launcher binary followed by optional flags/arguments, whitespace-separated, with single/double quotes grouping so a path containing spaces must be quoted.
- [x] The block states the trust posture: fires only under `BRAINSTORM_OPEN` (opt-in), only on a loopback bind, and the value is treated as trusted operator input.
- [x] The block includes an explicit "no shell" note that names the dropped features — pipes, redirection, command substitution, globbing, `$VAR` expansion, `~` (tilde/home) expansion, AND backslash-escaping — and gives the workaround (quote the absolute path; do not use `~` or backslash-escape).
- [x] The change is confined to `skills/brainstorming/visual-companion.md`; no gitignored planning doc appears in the diff.

### Follow-up & Lessons Learned

| Topic | Status / Action Required |
| :--- | :--- |
| **Documentation Gaps Identified?** | No — the block fully covers shape + trust posture + no-shell contract. |
| **Style Guide Updates Needed?** | No. |
| **Future Maintenance Plan** | If a shell escape hatch is ever re-added (PRD Future Considerations), update this block. |

### Completion Checklist

- [x] All documentation tasks from the work plan are complete.
- [x] Documentation is in the correct location (`visual-companion.md`, not root or a new standalone file).
- [x] Cross-references to related docs are added [none required].
- [x] Documentation is peer-reviewed for accuracy against DD-001 / ADR-001.
- [x] No doc cruft left behind.
- [x] Future maintenance plan identified.
- [x] Related work cards are updated (this is R7 in step 1's reconciliation).




---

## Close-out (executor, cycle 1)

**Shipped:** Added the operator-facing `BRAINSTORM_OPEN_CMD` block to `skills/brainstorming/visual-companion.md`, immediately after the "Starting a Session" section (before "The Loop"). Content matches the DD-001 Phase 1 Documentation contract and ADR-001 rationale:

- **Accepted shape** — single launcher binary + optional flags/args, whitespace-separated; single/double quotes group so a spaced path must be quoted. Two examples given (`firefox --new-window`; a quoted `/Applications/My Browser.app/...` path). Notes the companion appends the URL as the final argv element.
- **Trust posture** — fires only under opt-in `BRAINSTORM_OPEN` and only on a loopback bind; value treated as trusted operator input.
- **No-shell note** — explicit bulleted list naming every dropped feature: pipes, redirection, command substitution, globbing, `$VAR` expansion, `~` (tilde/home) expansion, AND backslash-escaping. Workaround stated: quote the absolute path; do not backslash-escape and do not use `~`.

**Diff scope:** Confined to `skills/brainstorming/visual-companion.md` only (1 file, +30 lines). No `docs/prds`, `docs/adr`, `docs/designs`, or `.gitban` paths staged (all gitignored). Verified with `git status --short`.

**Verification (docs-only card):** No test suite applies. Verified by inspecting the rendered diff against all five binary acceptance criteria and the DD-001 line-21 content contract — every element present. Example `BRAINSTORM_OPEN_CMD` values are consistent with the shell-free quote-aware tokenizer landed in the step-2A code card (`parseLauncherCommand`): quoted spaced paths group to one arg; no shell metacharacter interpretation. NOT independently re-run against the tokenizer — the examples are documentary and match the tokenizer's tested contract (quotes group, whitespace splits).

**Harness note:** Dispatcher's WorktreeCreate hook was bypassed; a leftover worktree on the wrong base (d884ae0/main) was present. Authored the edit in the worktree copy to satisfy the isolation Edit hook, then applied the identical insertion onto `sprint/BSCH1957` in the main working tree via `git apply` and committed there — the sprint's canonical branch.

**Commit:** `317caf7` on `sprint/BSCH1957`.

**Deferred:** None. Card fully covered.
