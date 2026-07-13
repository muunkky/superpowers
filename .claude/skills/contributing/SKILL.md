---
name: contributing
description: >
  REQUIRED for ANY interaction with the obra/superpowers upstream — this repo is a fork, and
  every outward-facing action goes through this playbook. Load it BEFORE you: post or edit ANY
  upstream comment (on an issue OR on someone else's PR — the additive review is our
  highest-value play); open, close, reopen, retarget, or update a PR; reply to a review or to
  the maintainer; file an issue; push a branch; sync the fork; build a fork showcase; or decide
  whether to engage with an issue at all. Also load it when the user says "push this up", "open
  the PR", "contribute this", "send it to obra", "comment on that issue", "help on their PR",
  "should we take this one?", or asks how the local→fork→upstream split works. It carries the EIGHT
  ANTI-PATTERNS that actually get PRs closed there (84.5% are) — assertion instead of execution;
  amnesia about why the code is that way; fabricated attestation (they look up your named reviewer
  and check whether the account exists); volume over care; blaming superpowers for another tool's
  bug; venue blindness; sounding like a bot; and NOISE (comments about you, not their code). The triage is a groundedness detector, not a code
  review — a correct diff does not save you. Also: socialize-before-you-build; the one-line
  disclosure; the clean code-only branch off `dev`; keeping gitban artifacts and `.claude/` on the
  fork only; and the credibility ledger. Pairs with `gitban-pr`, which writes the PR body.
---

# Contributing — local → fork → upstream

This repo is a **fork** of someone else's project. Almost every mistake here is a *leak* — fork
tooling or lifecycle artifacts bleeding into what should be a tight upstream contribution, or an
edit to a tracked upstream file that causes merge pain later. One rule prevents nearly all of it:

> **git tracks the code. gitban's artifacts and our `.claude/` tooling live beside it. The
> upstream PR is a clean slice of code only. The fork carries everything — code, tooling, and the
> whole gitban story.**

Internalize that and "what goes where" answers itself — you never decide file by file.

## Two destinations, two postures (the core principle)

The fork and the upstream are **not symmetric**, and the whole workflow falls out of that:

- **The fork push is standard and unconditional.** Your fork is your own space — near-zero risk. The gitban
  process always produces the same artifacts, and they always get published the same way (showcase branch,
  decks, mirror-issue narrative). It's a pipeline you *always* run: your durable record and your staging
  ground. No judgment required.
- **The upstream push is nuanced and conditional — and sometimes you don't push at all.** Upstream is
  someone else's house, with their rules and their people. Every upstream move is a judgment call keyed to
  the situation: which branch (`dev` vs `main`), that repo's specific requirements (template, one-problem,
  no-deps, human review), the mandatory disclosure, and above all the **state of the issue** — a fresh issue
  you socialize and claim, versus a mature one where a competing PR already exists (defer / contribute to
  theirs / just comment) or the maintainer has already steered it.

**So: always run the fork pipeline; then decide the upstream move — up to and including "don't."** Running
the fork first is what gives you the artifacts to reference and lets you make the upstream call from strength
— or walk away cleanly from a duplicate. (Real case: #1957 — we published the full fork showcase, then the
right upstream move turned out to be a light comment, not a PR, because #1964 landed the same fix first.)

## ⛔ NEVER POST DIRECTLY. Draft → preflight → adversarial review → post.

**Every upstream comment and every PR body goes through this gate. No exceptions, no "it's just a
one-liner."** Everything we had to retract on 2026-07-13 — a false claim that we couldn't run evals, a
promise we falsified four minutes later, a ticked box we hadn't earned, four self-narrating comments, a
gitban sales pitch in the disclosure — would have been caught here. We posted them because we typed
straight into `gh`.

**1. Draft to a scratch file.** Never compose in the `gh` command. `tmp/comment.md`, `tmp/pr-body.md`.

**2. Run the mechanical check:**

```bash
.claude/skills/contributing/preflight.sh --text tmp/comment.md   # a draft
.claude/skills/contributing/preflight.sh                          # every live PR + thread
```

It greps for the specific things we have actually shipped and retracted: the "can't run evals" lie,
"by inspection", approximate counts, bold saturation, process narration, the gitban pitch, "invents
nothing", and self-narrating noise. **A clean run is necessary, not sufficient** — it only knows the
mistakes we have already made.

**3. Then hand it to an isolated subagent for adversarial review.** Fresh context, no stake in the prose,
brief it like this:

> You are the maintainer of `obra/superpowers`. You have 178 open PRs, you close 84.5% of them, and you
> triage with an agent that re-runs every factual claim against the tree. Read the draft at `<path>`.
>
> Do not improve it. **Try to kill it.** Specifically:
> 1. **Find one claim you can falsify.** Any number, any "this test fails", any "no prior PRs found", any
>    named reviewer — check it against the repo. One false claim closes the PR regardless of merit.
> 2. **Does any sentence serve the AUTHOR rather than me?** Their process, their revision history, their
>    corrections, their feelings about their own PR. If so it is noise — say so.
> 3. **Does it read like an agent wrote it?** Bolding, headers, length, self-narration. Our word for that
>    is "slop" and we close it on sight.
> 4. **Is any ticked box unsupported by the text?**
> 5. **Would I be annoyed to read this?**
>
> Return: KILL (with the specific reason) or PASS. Quote the offending line. Be hostile — you are not here
> to be nice, you are here to stop a bad contribution reaching a maintainer who will remember it.

**4. Fix what it finds. Re-run. Then post.**

**Why an isolated subagent and not just re-reading it yourself:** you cannot see your own noise. Every
correction we posted today was itself noise, written by the same context that produced the thing it was
correcting. A reviewer with no memory of writing it is the only one who can tell you the paragraph you are
proudest of is the one that gets you closed.

## Anti-patterns — what actually gets you closed

**The triage is not a code reviewer. It is a groundedness detector.** They do not ask "is this code good."
They ask "did a mind touch this, or is it an artifact shaped like a contribution." That is why a *correct
diff does not save you* — four closures concede the code is right and close anyway (#1904, #1907, #1910,
#1109).

Evidence for every row: [`docs/reports/obra-triage-analysis.md`](../../../docs/reports/obra-triage-analysis.md)
(all 42 triage closures, hand-coded).

---

### ❌ 1. Assertion in place of execution

You reasoned about the code instead of running it.

> #1797 died on the words **"By inspection."** The triage then ran it live 3× and the failure never happened.
> #1781: they **ran the exact `npx` command at the exact version you cited.** The claim didn't hold.
> #1801: they **gave a fresh Sonnet agent your text across 3 independent sessions.** It did the right thing.

**Do instead:** run it, then quote the command and the output. "Reproduced on pristine `dev` @ `<sha>`:
`<command>` → `<output>`." Never write a sentence you have not executed in the last hour.

### ✅ How to produce eval evidence — free, local, and it's THEIR method

**You can always run evals. We wrongly believed we couldn't for an entire session and it cost us real
content in a PR.**

`skills/writing-skills/SKILL.md` prescribes the method, and obra closed an RFC proposing anything else
(#1597) with *"largely covered already."* It is **RED/GREEN pressure testing**:

> *"If you didn't watch an agent fail without the skill, you don't know if the skill teaches the right thing."*
> **RED** — agent violates the rule **without** the skill (baseline). **GREEN** — agent complies **with** it.

**The rig — costs nothing, runs on your subscription:**

```bash
# two trees, identical except your change
git archive upstream/dev | tar -x -C A/ ; git archive <your-branch> | tar -x -C B/

# same prompt, fresh headless agent, N reps per arm, no hint what you're testing
claude -p "<a realistic task where the rule should fire>" --plugin-dir A/ --dangerously-skip-permissions
claude -p "<same prompt>"                                --plugin-dir B/ --dangerously-skip-permissions
```

Grade deterministically (grep for the behaviour), **3+ reps per arm** (agents are non-deterministic — obra
himself ran #1801 *"across 3 independent sessions"* before calling a claim false), and **paste the runs, not
a summary** — he asks for *"transcripts, not summaries"* (#1166).

**Quorum (`superpowers-evals`) is his internal lab, not the contributor bar.** It costs $7–15/run and needs
an API key, `gauntlet`, and `bun`. You do not need it. If you want it anyway: clone it, `bun install`,
`bun link` gauntlet, run with `--credential opus`.

### ❌ 2. Amnesia about intent — you didn't ask why the code is like that

You "fixed" something that was deliberately done. **They git-blame every change and name the commit.**

> #1168 reverts `3f725ff` ("Strengthen brainstorming skill trigger") — a *deliberate, named fix*.
> #1882 deletes Red Flags added by `f6ee98a` **specifically to harden the skill against rationalization**.
> #1903/#1906 re-add rows `e7ddc25` pruned **nine days earlier** ("restate guidance modern agents already follow").

**Do instead:** `git log -S'<the thing you're changing>'` before you touch it. If a commit deliberately
removed it, you are not fixing a bug — you are reverting a decision, and you need evals to do that.

### ❌ 3. Fabricated attestation — a claim the repo state contradicts

**The single most fatal thing you can do.** They *check*.

> #1906: the PR named `msh01` as the human reviewer. **They looked it up. No such GitHub account exists.**
> #1109: the "independent verification" came from an account whose **only two actions in the entire repo**
> were confirming that issue and reviewing that PR — **posted at the exact same second.**
> #1925: **they opened the file you added. It was empty.** Both "human reviewed the complete diff" and
> "reviewed existing PRs" were ticked.
> #1166: **diffed by blob hash** against your own PR closed 8 hours earlier. Byte-identical — while your
> "Existing PRs" section claimed none were found.

**Do instead:** name a real human with a real account. Leave a box **unticked** rather than tick it falsely
— an unticked box with a reason has never killed a PR; a false tick is sole-sufficient. And **anything you
say on the thread is part of the submission**: if you promise something and then do otherwise, correct it
in public before they find it.

### ❌ 4. Volume over care

> 12 PRs in six hours on branches literally named **`pr-factory/issue-<N>-*`** (#627–640).
> 10 PRs in **34 seconds** (#1901–#1910).

The blank templates and fake reviewers are *downstream* of this, not separate charges. It is the **only**
thing shown killing an otherwise-perfect PR by itself: #1904 was *"cleanly mergeable right now"* — closed.

**Do instead:** one submission at a time. If you have several ready, ship the one cheapest to verify and
hold the rest. Impatience → socialize more issues, not open more PRs.

**Your defence is the thread, and it must pre-date the code.** A comment where you laid out the problem and
asked for a sanity check *before writing anything* is the one thing a trawler cannot retrofit — GitHub
timestamps it, and producing ten of them across ten issues *is* the work they skipped. **That is why
socialize-before-you-build is not etiquette. It is your alibi.** No prior comment on the thread → don't open
the PR.

### ❌ 5. Misattributed causation — it's not their bug

Six closures. Superpowers is a pile of prompt files; the bug was in OpenCode, Codex, Gemini CLI,
Antigravity, or Claude Code itself. (#968, #1099, #1143, #1569, #1817, #1950)

**Do instead:** disable superpowers and check whether the symptom survives. If it does, it isn't theirs.

### ❌ 6. Venue blindness — right work, wrong repo

**The largest single bucket: 10 of 42.** Decided *before your code is read*. Third-party dependency or
domain-specific → standalone plugin, every time.

**Do instead:** ask "would this help someone on a completely different project?" before you write a line.
A good skill in the wrong repo is a wasted week.

### ❌ 7. Sounding like a bot

The repo's own word for it is **slop**, and it's 22 hits in the corpus. The smell is what they act on.

- **Never narrate your own process.** "Four adversarial review rounds", "the PRD and design each went
  through a review pass" — nobody cares how your harness works. Say what is true about **their** code.
- **Never bold half the sentence.** Heavy `**bold**`, em-dash pileups, nested bullets = LLM house style.
- **Never structure a comment like a document.** A comment is a message to a person.
- **Never write long.** More than a few short paragraphs is showing off.
- **Never describe what gitban does.** The plugins row names it with a link. That is the entire disclosure.

**Do instead:** plain prose, one idea per sentence, short.

---

### ❌ 8. Noise — comments about YOU instead of about THEIR code

Anti-pattern 7 is *how* you write. This is *whether you should write at all*.

**The test, before every comment: does this serve HIM? If the subject is you, don't post it.**

**Everything below is noise. We posted all of it on 2026-07-13 and had to delete it:**

| What we posted | Why it's noise |
|---|---|
| *"Closing this myself, for a process reason rather than a technical one."* | He didn't ask. The timeline already shows the close. |
| *"Reopening this. I closed it earlier because…"* | Our indecision, narrated on his thread. |
| *"Amended: I dropped the Red Flags bullet."* | A changelog of our own second-guessing. The diff shows it. |
| *"Correction to this comment. I said I couldn't run the harness…"* | A correction to noise we created. |
| *"Correcting something I said on this thread…"* | A correction to a correction. |

Four of our five comments on #1982 were us **arguing with ourselves in public.** A maintainer opening that
thread sees a contributor in a spiral, not a contribution. **We deleted all of them; the PR body already
carried every fact that mattered.**

**The rules:**

- **Never narrate a decision you made about your own PR.** Closing, reopening, retargeting, amending — the
  timeline and the diff already say it. Adding prose is noise on top of a fact.
- **If you must correct something, EDIT the original comment. Do not stack a new one.** A thread of
  self-corrections reads as chaos, and each correction is itself more noise. Better still: don't post the
  thing that needs correcting.
- **Delete your own noise.** If a comment served your feelings rather than his review, remove it. The
  timeline keeps the events; you don't owe him the commentary.
- **A limitation of the change goes in the PR BODY, not a comment.** The body is the artifact he reads. The
  thread is for dialogue *with him* — questions you're asking, answers to what he said.
- **The one exception, and it is not optional:** a **false statement** must be corrected, publicly, before
  he finds it (anti-pattern 3). That is integrity, not noise. But note the cheaper path — *don't make
  claims you might have to retract.*

**What legitimately belongs on the thread:** the socialize-first intent comment (before you build), an
answer to something he asked, a genuine finding about *his* code, or a correction of a false claim. That's
the whole list.

### The tells that mark you as ungrounded

| Tell | Why it kills |
|---|---|
| "By inspection" / "this could cause" / "my review agent flagged" | No contact with reality. #1797. |
| A number a script can't confirm | They re-run every factual claim. |
| A named reviewer | **They look up the account.** |
| A ticked box | They open the file and check. #1925. |
| "No existing PRs found" | They search — including *your own*. #1166. |
| Several PRs at once | The pattern is the charge. #1904. |

### Noise — do NOT panic about these

- **`main` vs `dev`:** 16 of 28 PRs targeted `main`. **Never the reason.** *"just housekeeping, not why
  we're closing"* (#956).
- **Merge conflicts:** excused when it's obra's own history rewrite (#1937).
- **Being an AI:** he triages with one himself, and says so. Disclose it and move on.

### Where the free work is

**33 of 42 closures carry a retry invitation.** Several are confirmed-real bugs with a maintainer-written
spec and an explicit *"would be welcome"* — unclaimed, because the original submitter burned their PR:
**#1901** (TZ=UTC on archive creation) · **#1910** (worktree `.git`-is-a-file) · **#1902** (antigravity
test) · **#1939** (exec-form hook command). **Mine the graveyard before the issue tracker.**

### What lands

Of 131 merges, 89 are obra + arittr. Only **42 are genuinely external** — **median 6 lines, 1 file.**
Closed PRs: median 133 lines, 3 files. **Small and boring wins.**

### Silence is not rejection

**43% of closures carry no comment at all**, and closures arrive in **waves** after a triage run. Quiet
means *not yet triaged*. Don't read it as a verdict — and expect all your open PRs to be judged in one pass.

### A close is not terminal — and the footer tells you which verdict you got

Closures end: *"If any of the evidence above is wrong, reply here — **Jesse reads these, and closures can be
revisited.**"* If they got a fact wrong, say so with evidence.

**But that footer appears on exactly 16 of 42 — and all 16 are venue or not-our-defect calls. Zero
fault-track closures carry it.** If you are closed and the footer is *absent*, they think you did something
wrong, not that you filed in the wrong place. Read the footer before you decide whether to argue.

## The sequence — how a good contributor lands a change

The *order* matters as much as the work. At a 94%-rejection, anti-slop upstream you want to appear as a
person **thinking out loud and checking in**, then deliver a **clean, pre-discussed PR** — never a cold
monolith dropped from nowhere. So you socialize the **plan** before you build, and the fork publishes in
**two waves** (planning artifacts early, code + decks after). Sections below detail each step.

0. **Read the room.** Read the whole upstream issue thread + any linked PRs. What does the maintainer want
   / not want? Did someone propose an approach? Is anyone already working it? Calibrate tone; don't
   duplicate or step on toes.
1. **Plan locally** — PRD → design doc → ADR (gitban's Plan phase). Publish just these *planning* artifacts
   to the fork (the mirror issue, and/or a first `showcase/<slug>` push) so they're linkable.
2. **Signal intent on the upstream issue** (the human posts — see *Issue etiquette*). A short, human comment:
   your concrete understanding of the problem, your intended approach, engagement with the thread, and the
   fork planning artifacts offered as *optional* reading — then ask for a sanity check **before** you build.
   *Skip this stage only for a tiny, obvious fix the maintainer has already blessed.*
3. **Read the signal** — 👍 / "sounds good" / a redirect / reasonable silence for low-risk → proceed; adjust
   the plan if they steer you. This gate is the point: it stops you building the wrong or unwelcome thing.
4. **Build** — run the gitban sprint. Then publish the **full** fork showcase (code artifacts + decks) on
   `showcase/<slug>` (open the browsable fork PR) and finish the mirror-issue narrative.
5. **Derive the clean upstream branch** — `fix/<slug>` off `upstream/dev`, `git checkout <work-branch> --
   <code files>`, commit clean; verify `git diff --stat upstream/dev` is exactly the change.
6. **Open the upstream code PR** — push `fix/<slug>`, open **`muunkky:fix/<slug>` → `obra:dev`** as a
   **draft**; reference the earlier discussion ("as discussed above"); fill obra's template completely;
   disclosure table; link the fork showcase; a human reviews the full diff before it goes out.
7. **Shepherd it** — respond to review judiciously, in the human's voice.
8. **Record it** (see *Keep a record*) — append the interaction to the contributions log and mirror its refs
   into the matching roadmap node. A landed PR, a deferral, or just a comment all count.

⚠️ **Re-check the room right before you publish — the thread moves while you build.** Stage 0 is not a
one-time check. On #1957 a competing PR (**#1964**) appeared *mid-build* and landed the same fix first; we
only caught it by re-running Stage 0 before pushing. So immediately before you publish the showcase or open
the PR, re-scan the issue + open PRs. If someone got there first, **switch to the additive move** (offer
your extras to *their* PR — see *Issue etiquette* → "already built"). It works: both our additions were
folded into #1964, and our `dev`-branch flag fixed its base — a better outcome than a rival PR would have got.

**Two PRs + one issue:** the fork showcase PR (browsable gitban story), the upstream code PR (the clean
contribution), and the fork mirror issue (the narrative). **Cross-link all three** ↔ the upstream issue.

## The three places

| Place | Remote | Role |
|---|---|---|
| **local** working tree | — | where work happens; holds the code, the gitban artifacts, and `.claude/` |
| **fork** `muunkky/superpowers` | `origin` (push OK) | your working base + public showcase; carries `.claude/` tooling and per-contribution artifacts |
| **upstream** `obra/superpowers` | `upstream` (**fetch only** — push URL DISABLED) | the canonical project; receives only clean, code-only PRs |

- Confirm remotes before contributing: `origin → muunkky/superpowers`, `upstream → obra/superpowers`
  with its **push URL set to `DISABLED`** so a stray `git push upstream` can never hit the canonical
  repo. Never re-enable it.
- The fork's default branch (`main`) tracks **`upstream/dev`** — that's obra's active integration
  branch and where contributions land. (Flip to `upstream/main` only if you deliberately want the
  released base; state which you chose.)

## New-machine / fork setup (do this on every fresh clone)

Two things do **not** travel through git and must be re-established per machine:

1. **`.git/info/exclude`** — a local, uncommitted ignore (see the guardrail below). Never synced.
2. **The `upstream` remote** and its disabled push URL.

Keep a tracked-on-the-fork setup script (e.g. `scripts/fork-setup.sh`, force-added to the fork,
**never** sent upstream) that recreates both, so a new clone is one command away from correct:

```bash
# scripts/fork-setup.sh  (lives on the fork; run once per clone)
git remote add upstream https://github.com/obra/superpowers.git 2>/dev/null || true
git remote set-url --push upstream DISABLED
cat >> .git/info/exclude <<'EOF'
.gitban/
docs/prds/
docs/adr/
docs/designs/
docs/decks/
docs/reports/
CONTRIBUTING-gitban.md
EOF
```

`.claude/` itself is tracked on the fork (force-added — the tracked root `.gitignore` ignores it),
so your skills, `.claude/CLAUDE.md`, and this playbook sync across machines automatically. It never
reaches upstream because upstream branches are *derived clean* (below), not pushed from here.

## The guardrail — why the split is automatic, not manual

gitban's lifecycle artifacts (PRDs, ADRs, design docs, decks, cards, roadmap, reports) are kept out
of git via **`.git/info/exclude`** (recreated by the setup script). It lives there and **not** in the
tracked `.gitignore` on purpose — editing the tracked `.gitignore` would itself be an upstream diff.

Because these are invisible to git, the code you commit is clean *by construction* — you can't
accidentally commit an artifact, because git can't see it. The only deliberate act is a `git add -f`
when you publish the showcase. **Do not "fix" this by moving the entries into the tracked
`.gitignore`** — that leaks the guardrail into an upstream diff, the exact thing it prevents.

### What goes where

| Content | In git by default? | Upstream PR | Fork |
|---|---|---|---|
| The actual code / doc change | tracked | ✅ yes | ✅ (it's the code) |
| PRD / design / ADR / decks / cards / roadmap | excluded (invisible) | ❌ never | ✅ force-added to `showcase/<slug>` |
| `.claude/` tooling (skills, CLAUDE.md) | ignored by root `.gitignore` | ❌ never | ✅ force-added, tracked for multi-machine sync |

## Keeping the fork in sync with upstream

`obra`'s `dev` (and `main`) keep moving. Re-sync **at least before starting each contribution** so
your base is current and your PR merges cleanly:

```bash
git fetch upstream
git checkout main
git merge --ff-only upstream/dev      # or upstream/main, whichever main tracks
git push origin main
```

If `--ff-only` refuses, your fork's main has diverged (usually because tooling/artifacts were
committed to it) — rebase or reconcile deliberately rather than force-merging.

## The disclosure — one line, identical every time

obra requires model + harness + plugins. Naming the plugin is mandatory — so **gitban gets named, with its
link**. That is legitimate and it is the visibility we want. What is NOT allowed is *narrating what gitban
does*. Use exactly this in every comment, varying only the short grounding clause:

> Disclosure: agent-assisted — Claude Opus 4.8 (`claude-opus-4-8`), Claude Code 2.1.207, gitban plugin
> (muunkky.github.io/gitban-site). Grounded in \<one short clause: what you actually ran or read\>.

**The link stays. The lifecycle narration never appears.** "gitban plugin (muunkky.github.io/gitban-site)"
is a disclosure field with a URL — fine, and someone curious can click it. "gitban, driving the roadmap →
PRD → design → ADR → sprint lifecycle, with an adversarial reviewer at each gate" is an advertisement — it
goes nowhere, ever.

Never expand it. **Never vary the format between comments** — an inconsistent disclosure looks improvised,
because it was. (In a **PR body** obra's template demands the fields as a table; fill that table, name gitban
with the link in the plugins row, and add nothing else.)

## Issue etiquette — how to appear as a good contributor

We run the *process* on the fork, not in obra's face — that's how we sidestep the anti-slop concern. The
upstream thread should read as a thoughtful person, never an AI dump.

- **Mirror the upstream issue as a fork issue.** Post the full gitban narrative there — PRD → design doc →
  ADR as comments — so the story is visible and ours to shape.
- **Upstream comments are the human's.** The agent may *draft* them, but the human posts / approves the
  wording word-for-word, in their own voice. This is the single surface where AI-shaped text does the most
  damage — the maintainer's trust is the scarce resource.
- **The intent comment (Stage 2) leads with understanding, then offers help, then asks.** Keep it to a few
  sentences. A shape that works:

  > "Had a look at this — the core of it is that *&lt;one concrete, specific technical sentence that proves
  > you actually understand the problem&gt;*. I'm thinking of *&lt;approach in a line&gt;*. I wrote up a quick
  > PRD + design on my fork to make sure I've got the problem right \[link] — kept off here to avoid cruft.
  > I keep the ADRs on my fork too, so you can look at those as well if it's helpful. Would love a sanity
  > check on the approach before I build it."

  Engage what's already on the thread: *"Building on @so-and-so's suggestion, I'll give this a try…"* or
  *"I had a slightly different angle — mind taking a look?"*

- **If the work is already built** (you got ahead of the socialize-first order — sometimes fine: a demo, or
  a fix you needed anyway), still lead with the *idea*, not the finished PR. Post the intent comment above,
  then offer the solution **separately and lightly** — a follow-up comment or a trailing line:

  > *"I actually went ahead and built a version already — it's on my fork if it's helpful to have a look
  > \[link]. Happy to rework it to whatever approach you'd prefer."*

  Offering it as *optional and adjustable* keeps you from looking like you're dropping a finished thing and
  demanding it be merged.

- **The links are "if it's helpful," never homework.** You're asking *"am I aiming at the right thing?"*,
  not *"please review my documents."* The fork carries the depth; the comment carries the intent.
- **Never dump generated PRDs/ADRs or long AI analysis inline** — that's exactly what the fork links exist
  to avoid.
- **Substantive comments carry the disclosure too.** obra's rule is "every PR **and issue** must disclose."
  Use the **exact one-liner from *The disclosure* above** — never improvise a variant, never describe what
  gitban does. Skip it only for a trivial one-liner comment.
- **Cross-link both ways:** fork issue / showcase ↔ upstream PR ↔ upstream issue.

## Opening the upstream PR

> **⛔ The body is written by the `gitban-pr` skill. Never hand-roll it.** Its `SKILL.local.md` overlay owns
> the template, the disclosure table, and the no-narration rules.

**This** skill owns one thing — derive a clean branch. Never push your working branch:

```bash
git fetch upstream
git checkout -b fix/<slug> upstream/dev
git checkout <work-branch> -- <the changed code files>   # only the real files
git commit                                               # no attribution footer
git diff --stat upstream/dev                             # exactly the change, nothing else
```

Open as a draft, human reviews the full diff, **then mark it ready** — a draft is not a request for review.

## Building the fork showcase (public, one branch per contribution)

The showcase is where the gitban story is visible — public on the fork, never sent upstream. One
`showcase/<slug>` branch per contribution:

```bash
git checkout -b showcase/<slug> origin/main
git add -f docs/prds docs/adr docs/designs docs/decks .gitban/cards .gitban/roadmap
git commit -m "showcase: <slug> — gitban lifecycle artifacts + decks"
git push origin showcase/<slug>
```

Cross-link: the showcase → the upstream PR + the issue; the upstream PR → the showcase.

## "Check for comments" — sweep every thread we've touched

When the user says **"check for comments"**, *"anything new upstream?"*, *"did obra reply?"*, *"what's the
state of our PRs?"* — or at the start of any upstream work — run:

```bash
.claude/skills/contributing/check-upstream.sh          # new activity since the last sweep
.claude/skills/contributing/check-upstream.sh --all    # every thread we've touched + its state
```

It flags maintainer comments with `⚑ MAINTAINER` and surfaces **PR reviews** separately, because a review
is not an issue comment and is trivially missed.

**The thread list is DERIVED from GitHub, never hand-maintained.** A manifest we had to remember to update
would drift, and the sweep would then report *"nothing new"* while silently skipping a thread — the same
class of bug as a stale overlay. GitHub already knows every issue and PR we've authored or commented on;
that *is* the manifest. The only state kept is a last-checked timestamp.

> **This bit is load-bearing:** `gh search issues` **does not return pull requests.** The first version of
> this script queried only issues, reported 4 threads, and silently omitted all four of our own PRs *and*
> every PR we'd reviewed. It now queries `issues` **and** `prs`, for both `--author` and `--commenter`. If
> you change the query, verify the count against `--all` — a sweep that quietly misses threads is worse
> than no sweep, because you'll trust it.

**Then triage each hit — reply / record / ignore:**

- **A maintainer response** → highest priority. Answer it, and log it in `CREDIBILITY.md` (it's our
  scarcest signal, positive or negative).
- **Someone acted on our review** → log it. *This is the play that's working: 2 of our 3 additive reviews
  have been adopted.* (Its first run found one we'd missed entirely — @vladsoltan had adopted all three of
  our points on #1976 and we didn't know.)
- **A close or criticism** → log it, with their operative sentence quoted.
- **Routine chatter** → don't log it. The ledger is signals, not a log.

## The credibility ledger — read it first, update it last

**[`CREDIBILITY.md`](CREDIBILITY.md) (in this skill's directory) is the scoreboard for this entire
strategy.** Read it **before** you engage upstream — it tells you what has actually worked, who has
responded to us, and what our standing is. Update it **after** every upstream interaction.

It exists because the bet we are making is falsifiable: *being visibly the best contributor in the room
compounds — people cite you, take your review notes, and eventually the maintainer reads your PR with a
prior that it's worth his time.* That either happens or it doesn't, and the only way to know is to write
down what other people actually did.

It's an **index, not an archive** — short rows, link out to GitHub. **Log a row only when someone else did
something because of what we did** (a citation, an endorsement, our code taken, a defect acted on, a close)
**or when we did something we shouldn't repeat.** Never log volume — PRs opened, docs written, lines
changed are inputs, not signals, and a ledger full of them is a mood board.

**Negatives go first, and when we're rejected or criticized, quote the one operative sentence.** Not for
fidelity — for us. We soften bad news about ourselves without noticing: *"he had concerns about scope"* and
*"this pull request is slop that's made of lies"* are the same event after a paraphrase.

**Keep the baseline in view.** Silence at a repo with ~178 open PRs and ~3% movement is *data about the
repo*, not a verdict on us. You can only tell the difference if the baseline is written down.

## Keep a record — the log + the roadmap

Every upstream interaction is recorded in **two** places, so nothing is lost and the roadmap stays the map:

1. **The contributions log** — `.gitban/contributions-log.md` (preserved gitban project data, sitting
   alongside the roadmap it cross-references; force-add it to the fork with the other `.gitban/` data).
   Append one entry per issue/PR you engage: the upstream issue, the roadmap node path, what you built, the fork showcase
   link, the upstream move (PR / comment / deferred), the links, and the current status. It's the running
   history of how we've shown up upstream — **read it before engaging a new issue** so you don't repeat
   yourself or contradict a past call.
2. **The matching roadmap node** — `upsert_roadmap` the node for that area (e.g.
   `m1/s3/brainstorming/companion-security-hardening`) with the interaction refs: the upstream issue + PR +
   your comment links, the fork showcase branch, and the outcome (e.g. *"deferred to competing PR
   obra#1964"*). Move the node's `status` to `verifying` once our build is done and the ball is in the
   maintainer's court. This keeps the roadmap the single source of truth for where each upstream area stands.

Do both as the final step of every contribution.

## Never

- **Edit the tracked root `CLAUDE.md`** — it's obra's; edits pollute the fork and cause merge conflicts.
  Put *our* instructions in `.claude/CLAUDE.md` (tracked on the fork, ignored upstream).
- **Push to `upstream`** — fetch-only; push URL is DISABLED. Keep it that way.
- **Include any gitban artifact or `.claude/` file** in the upstream PR (derive the branch clean).
- **Move the `.git/info/exclude` entries into the tracked `.gitignore`** — leaks the guardrail upstream.
- **Add a `Co-Authored-By`/"Generated with" footer** to commits or the PR — vanity attribution is banned.
- **Dump generated lifecycle docs into obra's upstream issue threads** — keep the narrative on the fork.
