# Upstream contributions log

A running record of our engagement with the `obra/superpowers` upstream — the issues and PRs we've touched,
the comments we've posted, and the decision behind each. The `contributing` skill points here; keep it
current, and mirror the key refs into the matching **roadmap node** (see each entry's node path).

One entry per upstream area we engage, newest first.

---

## pi tool-mapping test — RED on `dev`, and the maintainer already specced the fix

- **Date:** 2026-07-13
- **Roadmap node:** `m1/s1/new-harness-onboarding/pi-tool-mapping-test-stale`
- **The bug (reproduced first-hand, not asserted):** on pristine `upstream/dev` @ `096e15aa`,
  `node --test tests/pi/test-pi-extension.mjs` → **5 pass / 1 fail**. Line 126 asserts `pi-tools.md` still
  matches `/read/ /write/ /edit/ /bash/` — the generic rows **obra's own commit `e7ddc25`** ("Prune per-harness
  tool-mapping boilerplate") *deliberately removed*. The test was never updated. Red ~3 weeks, in the shipped tree.
- **Acceptance signal:** obra reproduced it himself on the closed #1903 and **named the fix he wants** —
  *"A trim of the test's assertions … would fix the real breakage **without reverting that decision**."* That is a
  spec, and it is explicitly **not** the patch that was rejected.
- **The ethics call:** #1903 was @tianma-if's. It was closed for spray-and-pray (10 PRs in 34 seconds, fabricated
  human reviewer) **and** on the merits (it restored the pruned rows). We are **not** re-filing their diff — we're
  writing the different fix obra asked for. But they found it, so we
  [gave them first refusal in public](https://github.com/obra/superpowers/pull/1903#issuecomment-4956472239) and
  credit either way. **Corollary:** the *antigravity* test is red from the same commit, but obra called
  tianma-if's antigravity diff *"a welcome, correct change"* — re-filing **that** one would be poaching. Left alone.
- **Why it's the cleanest bet we have:** test-file only → **no eval evidence required** (the expensive gate on skill
  prose). Verification is one command, red → green.
- **Status:** intent posted; awaiting tianma-if's first refusal window, then build.

---

## #1481 — SDD's double review (obra wrote the spec, then half-fixed it without noticing)

- **Date:** 2026-07-13
- **Roadmap node:** `m1/s2/review-integrity/sdd-double-review`
- **Upstream issue:** [obra/superpowers#1481](https://github.com/obra/superpowers/issues/1481) (@qinhaihong-red,
  2026-05-06) — **0 comments, unclaimed for 4 weeks.**
- **The contradiction, verbatim on `dev`:** `requesting-code-review` says the whole-branch reviewer is
  **"Mandatory: — After each task in subagent-driven development"**, while `subagent-driven-development` scopes it to
  the **"Final whole-branch review"** and hands per-task review to `task-reviewer-prompt.md`. Follow the shipped tree
  and you review the whole branch after *every* task, on top of SDD's own per-task reviewer.
- **Acceptance signal:** obra wrote the spec himself closing #1572 — *"A fresh PR that points at
  `task-reviewer-prompt.md` … would be **very welcome** on #1481."* (#1572 died on a technicality: it referenced
  `code-quality-reviewer-prompt.md`, which 6.0.0 deleted. Known-known now.)
- **The find nobody had connected:** obra's own draft **#1934** (detritus-strip, eval-gated) **deletes the
  `## Integration with Workflows` block** containing *"Review after EACH task"* — **half of #1481 resolves as a
  side-effect of an unrelated cleanup**. The other half (the `**Mandatory:**` bullet) survives untouched. *That
  bullet is the entire fix.* We told him.
- **Scope discipline:** one bullet in `requesting-code-review/SKILL.md`. **Do NOT touch
  `subagent-driven-development/SKILL.md`** — it's in **four** of obra's open PRs (#1931/#1932/#1934/#1943); touching
  it is instant death. Don't touch the Integration block either — he's deleting it.
- **Upstream move:** [intent comment](https://github.com/obra/superpowers/issues/1481#issuecomment-4956469031),
  leading with the #1934 observation and asking two questions (scope; and whether a one-bullet clarification is even
  above the eval bar, since this is behaviour-shaping prose).
- **Status:** posted; awaiting his answer on scope + the eval question before building.

---

## #666 — worktrees in the OS temp dir (the maintainer *invited* this one)

- **Date:** 2026-07-13
- **Roadmap node:** `m1/s2/worktree-management/worktree-location-config` (new project — worktrees had no home on the roadmap)
- **Upstream issue:** [obra/superpowers#666](https://github.com/obra/superpowers/issues/666) (@blackas) — support the OS temp
  directory as a worktree location, so short-lived worktrees are auto-reaped. **Unclaimed** (0 comments).
- **Why this one:** the strongest acceptance signal in the whole roadmap. @obra closed the prior attempt
  ([#668](https://github.com/obra/superpowers/pull/668) — JSON registry + CLI manager + GC daemon + post-merge hooks +
  LaunchAgents) with a written spec *and* an invitation: *"That's a massive amount of complexity for what should be **a
  straightforward configuration option**. If you'd like to take another pass at this with a solution scoped to the actual
  problem in #666, **a new PR would be welcome**."*
- **What Stage-0 reading turned up (the parts a naive PR would step on):**
  - The 2026-04 **worktree rototill** set ownership by *provenance* (“whoever creates the worktree owns its cleanup”) but
    **implements it as a path check** — `.worktrees/`/`worktrees/` → superpowers owns it; *anything else* → host owns it,
    leave it. So a `$TMPDIR` worktree would be **created by superpowers and then disowned at cleanup**, silently
    reintroducing the "branch delete fails, worktree still attached" bug. **That is the whole design problem** — and the
    fix is one line (the owned-path set), which is precisely what #668 built a daemon to avoid.
  - The issue's **option 2** (`~/.config/superpowers/worktrees/`) is **dead** — the rototill removed it and
    `tests/claude-code/test-worktree-path-policy.sh` actively asserts it never comes back. Proposing it = instant close.
  - **Collision watch:** obra's *own* open PR **#1933** rewrites the ownership block in `finishing-a-development-branch`
    (held for evals); **#1782** rewrites the "verify the directory is ignored" block in `using-git-worktrees`. Both are
    files we'd touch.
- **Upstream move:** socialize-first intent comment — scope pinned to obra's own words, the two constraints surfaced, and
  **three questions handed back to him** (sequencing vs #1933; is a temp worktree superpowers-owned or host-owned; and a
  flag that #1542 is the same option-shape so he should pick it deliberately):
  [comment](https://github.com/obra/superpowers/issues/666#issuecomment-4956332060).
- **Status:** posted; **awaiting his answer before building** — the ownership question is his skill's contract, not ours.
- **Lesson:** a closed PR's closing comment can *be* the spec. Read the graveyard before the codebase.

---

## #1899 — PR review: a hunk that went stale when #1959 merged

- **Date:** 2026-07-13
- **Upstream PR:** [obra/superpowers#1899](https://github.com/obra/superpowers/pull/1899) (@stbenjam) — removes 7
  files flagged as orphaned by skillsaw lint. Base `dev`. Legit cleanup.
- **What we found:** its `GEMINI.md` hunk deletes the import
  `@./skills/using-superpowers/references/gemini-tools.md` on the premise that the file doesn't exist — but
  **merged PR #1959 restored it** (2026-07-10). Verified against `upstream/dev`: the file exists (63 lines) and
  the import is valid. Merging as-is would remove a **working** import and drop the tool reference for Gemini
  CLI users. The other six deletions are unaffected.
- **Also noted:** its two reviewer-prompt deletions are the flip side of open issue #1962 (which asks to *wire
  them in*) — flagged so the two threads don't get resolved in opposite directions.
- **Upstream move:** additive comment (not a competing PR):
  [comment](https://github.com/obra/superpowers/pull/1899#issuecomment-4956260273).
- **Status:** posted; watching.

---

## #1976 — PR review: a broad `exec→execFile` sweep that would regress the launcher fix

- **Date:** 2026-07-13
- **Roadmap node:** `m1/s3/brainstorming/companion-security-hardening` (same sink as #1957)
- **Upstream PR:** [obra/superpowers#1976](https://github.com/obra/superpowers/pull/1976) (@vladsoltan) — repo-wide
  security sweep replacing `exec()`/`execSync` with `execFile`/`spawnSync`.
- **What we found (empirically, not asserted):** its `server.cjs` hunk passes the **entire**
  `BRAINSTORM_OPEN_CMD` as argv[0], so any launcher *with arguments* → `ENOENT`. Reproduced on a clean
  `upstream/dev` with only its hunk applied: **baseline 13 passed/0 failed → 12 passed/1 FAILED**
  (`should open exactly once`, `0 !== 1`). **It breaks an existing test on `dev`.** Root cause it couldn't
  see: `BRAINSTORM_OPEN_CMD` is undocumented on `dev` (those docs exist only inside #1964 — ours).
- **Also found:** its `render-graphs.js` hunk **duplicates @obra's own open PR #1805**; and it targets
  `main` (should be `dev`).
- **Upstream move:** additive comment on #1976 — **not** a competing PR — with the reproduction, pointing at
  #1964 as the correct fix (quote-aware tokenizer), offering to help, with disclosure:
  [comment](https://github.com/obra/superpowers/pull/1976#issuecomment-4956175497).
- **Status:** posted; watching. Protects the fix landing via #1964.
- **Why this matters:** silence would have let a test-breaking regression into review. The additive-comment
  play again — second use, and this one caught a duplicate of the maintainer's *own* PR.

---

## #1957 — brainstorm companion: remove the shell-exec injection shape

- **Date:** 2026-07-11
- **Roadmap node:** `m1/s3/brainstorming/companion-security-hardening`
- **Upstream issue:** [obra/superpowers#1957](https://github.com/obra/superpowers/issues/1957) (@mxcoder) — an org
  security audit flagged `cp.exec(BRAINSTORM_OPEN_CMD + url)` in the brainstorming companion; blocks adoption.
- **Built:** full gitban lifecycle — PRD-001 → DD-001 → ADR-001 → sprint `BSCH1957` → dispatch. 4-file fix
  (`server.cjs` tokenizer + `execFile`, operator docs, unit tests, e2e injection test); full suite 144/0 on Linux.
- **Fork showcase:** [`showcase/1957`](https://github.com/muunkky/superpowers/tree/showcase/1957) (public) —
  code + PRD/design/ADR (+ decks) + sprint cards + roadmap.
- **Upstream move:** a **competing PR landed the same core fix first** —
  [#1964](https://github.com/obra/superpowers/pull/1964) (@aznikline). Per the "don't duplicate / read the room"
  rule we did **not** open a rival PR. Instead posted a collaborative, additive comment on #1964 (our operator
  docs + the injection test + a note that #1964 targets `main` not `dev`), with the disclosure —
  [comment](https://github.com/obra/superpowers/pull/1964#issuecomment-4948490335).
- **Outcome — ACCEPTED (2026-07-13):** @aznikline
  [folded both contributions straight into #1964](https://github.com/obra/superpowers/pull/1964#issuecomment-4954024338):
  - **Operator docs** — a `BRAINSTORM_OPEN_CMD` section added to `visual-companion.md` (accepted shapes, trust
    posture, the no-shell note). *"The issue title does call out docs, and #1964 was code-only — good catch."*
  - **Direct injection test** — `BRAINSTORM_OPEN_CMD` with a `; touch <pwned>` tail, asserting `<pwned>` is never
    created; complements their URL-integrity assertion.
  - **Our `dev`-branch flag fixed the PR** — they retargeted `main → dev` (*"good flag — I'd missed that"*),
    rebased, now `mergeable`/`CLEAN`, full suite green (136 tests). Pinged @obra for review; Closes #1957.
- **Status:** our work is going upstream **via #1964** (not a competing PR). Awaiting @obra's review/merge.
- **Lesson (validates the skill):** deferring to the first PR and offering our extras *additively* got the fix
  landed, improved someone else's PR, earned goodwill, and avoided a duplicate-PR rejection. "Read the room →
  don't duplicate → contribute to theirs" is the winning move at a high-rejection upstream.
