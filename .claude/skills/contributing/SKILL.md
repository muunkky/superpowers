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
  "should we take this one?", or asks how the local→fork→upstream split works. It carries: how
  PRs actually die here (84.5% closed unmerged; the fatal disqualifier is any false statement in
  the body — they verify it — while "batch" is far rarer and more specific than it looks);
  socialize-before-you-build and why that comment is your alibi; write-like-a-person (AI-sounding
  text gets closed regardless of merit); the one-line
  disclosure; deriving a clean code-only branch targeted at `dev`; keeping every gitban artifact
  and all `.claude/` tooling on the fork only; and the credibility ledger (CREDIBILITY.md) that
  tracks what is actually working. Pairs with `gitban-pr`, which writes the PR body itself.
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

## Know how PRs actually die here

> **The evidence is a report, not this skill.** All 42 AI-triage closures are hand-coded in
> **[`docs/reports/obra-triage-analysis.md`](../../../docs/reports/obra-triage-analysis.md)** — every PR,
> its author, its size, the primary reason, whether the code was conceded correct, and every retry
> invitation quoted. **Read it before a contentious call.** What follows is only the operating summary.

**84.5% of decided PRs are closed unmerged** (714 / 131). Of the 131 merges, 89 are obra + arittr — only
**42 are genuinely external**, and those are **median 6 lines, 1 file**. Closed PRs: median 133 lines,
3 files. **Small and boring wins.**

### A correct diff is not sufficient, and it isn't close

Four closures **concede the code is right and close anyway** (#1904, #1907, #1910, #1109):

> *"it's cleanly mergeable right now… The reason this is closing is separate."* (#1904)
> *"**The problem isn't the code.** The problem is how it arrived."* (#1910)

The triage checks the **diff** against the tree, then *separately* checks the **submission**. Failing the
second kills you even when you pass the first.

### The two sole-sufficient killers

1. **Batch.** 9 of 42 primaries. It is the **only** thing shown killing an otherwise-perfect PR by itself.
   Three incidents: 12 PRs / 6h on `pr-factory/issue-N` branches; 10 PRs / **34 seconds**; one cross-repo
   drive-by. **One submission at a time.**
2. **Any false statement in the submission.** They *execute* your claims: ran the cited `npx` command at
   the cited version (#1781), diffed your PR against your own prior rejected one **by blob hash** (#1166),
   **looked up your named human reviewer on GitHub and found no such account** (#1901/#1906), opened the
   file you added and found it empty while your boxes claimed a human reviewed it (#1925).
   **Never write a sentence you have not verified in the last hour.**

### Check VENUE first — it's the biggest bucket and it's decided before your code is read

**10 of 42.** Third-party dependency or domain-specific → standalone plugin, every time. A good skill in
the wrong repo is a wasted week.

### Noise — do not panic about these

- **`main` vs `dev`:** 16 of 28 PRs targeted `main`. **Never the reason.** *"that's just housekeeping, not
  why we're closing"* (#956). Fix it; don't believe it killed anyone.
- **Merge conflicts / staleness:** explicitly excused when it's obra's own history rewrite (#1937).

### Tuned content: they know the SHA that added it

3 primaries + 7 secondaries. **Git archaeology is routine** — they will name the commit your change reverts
(#1168/`3f725ff`, #1882/`f6ee98a`, #1906/`e7ddc25`). Never touch Red Flags tables, trigger descriptions, or
"1% chance" language without evals.

### "By inspection" is a confession

#1797 died because the reporter answered *"did you hit this?"* with *"By inspection"* — the triage then ran
it live 3× and it didn't happen. **Bring a transcript or don't file.**

### Free, pre-approved work is sitting there

**33 of 42 closures carry a retry invitation** — quoted verbatim in the report. Several are confirmed-real
bugs with a maintainer-written spec and an explicit *"would be welcome"*, unclaimed because the original
submitter burned the PR: **#1901** (TZ=UTC on archive creation), **#1910** (worktree `.git`-is-a-file),
**#1902** (antigravity test), **#1939** (exec-form hook command). **Mine the graveyard first.**

### The footer tells you which track you're on

*"closures can be revisited"* appears on **exactly 16 of 42 — all of them venue or not-our-defect calls.
Zero fault-track closures carry it.** If you get closed and the footer is absent, they think you did
something wrong, not that you filed in the wrong place.

## ⛔ Multiple PRs are fine. A *batch* is not. Know the difference — it is not the count.

Upstream closes "bulk or spray-and-pray" PRs on sight:

> **Bulk or spray-and-pray PRs.** Do not trawl the issue tracker and open PRs for multiple issues in a
> single session… PRs that are part of an obvious batch — where an agent was pointed at the issue list
> and told to "fix things" — will be closed. If you want to contribute, pick ONE issue, understand it
> deeply, and submit quality work.

**Read what that rule is actually policing.** It is not "two PRs is one too many." It is *an agent pointed
at the issue list and told to fix things* — no understanding, no prior engagement, no human in the loop.
The tells obra actually cited when he closed #1903: *"#1903 of ten you opened between 04:19:42 and
04:20:16 UTC, one every 3–4 seconds, spanning unrelated subsystems, each with the identical 'Human
partner who reviewed this diff: msh01' claim. No one reviewed ten independent cross-cutting diffs in 34
seconds."* **The diffs weren't the problem. The absence of any real work behind them was.**

So the question is never *how many*. It is: **can you prove each one was genuinely worked?**

| Spray-and-pray | Genuine parallel work |
|---|---|
| Trawled from the issue list | Each issue chosen for a reason you can state |
| PR is the first anyone hears of it | **Socialized on its own issue thread first**, before code |
| Opened seconds apart, no engagement | Each has a thread where you asked, waited, and adjusted |
| Same boilerplate human-reviewer claim | A human actually read each diff |
| Unrelated subsystems, no thread to point at | Maintainer's own words backing it, where they exist |

**The evidence is what separates you, and you must be able to point at it.** If a maintainer glances at
your PR list and wonders, the first thing that saves you is a link to the issue comment where you raised
it *before* you wrote a line — where you asked for a sanity check and waited. A trawler has no such
comment, and cannot fake one after the fact. **That is why Stage 2 (socialize before you build) is not
etiquette — it is your alibi.**

**What we learned the hard way (2026-07-13).** We opened four PRs in 22 minutes (#1982–#1985), panicked
about the timestamps, and self-closed three. That was an over-correction: every one had been socialized on
its own issue days or hours earlier, three were fixes obra had *personally specced or invited* in closing
comments, and a human had reviewed each diff. They were reopened, each carrying a note pointing at the
thread where it started. **Don't withdraw genuinely-worked contributions on a technicality — but do make
the work visible, because from the outside good work and a spray look identical until someone clicks.**

**Still true, and still the safer default:**
- **If you can't point at prior engagement on the thread, you don't get to open the PR.** Go socialize it.
- **Don't open several at once when they're all speculative or unasked-for.** That *is* a trawl.
- **Speed is the smell.** If a human is impatient, socialize more issues — don't open more PRs faster.
- **When in doubt, lead with the one cheapest for the maintainer to verify** (a red test going green beats
  a nuanced prose change), and let it earn the read for the rest.

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

## Write like a person — the #1 way this fails

**The maintainer's trust is the scarce resource, and AI-sounding text burns it faster than a bad patch.**
A comment that reads as machine-generated gets the contribution closed on sight regardless of merit. This
upstream closes "slop" as a matter of policy; the *smell* is what they act on, not the substance.

**Never do these — each is a loud, unmistakable AI tell:**

- **Never narrate your own process.** Nobody cares that "the design went through four adversarial review
  rounds," that "the PRD and design each went through an adversarial review pass," or that "it was that
  review that killed my option (a)." This is meta about *our* harness. It is self-indulgent, it is
  transparently machine-written, and it is the single most annoying thing you can put in someone else's
  thread. **Say what is true about THEIR code. Never about your workflow.** If a template section
  explicitly asks how you tested, answer it in one plain sentence about the *code* — not a tour of the
  lifecycle.
- **Never bold half the sentence.** Heavy `**bold**`, em-dash pileups, and nested bullet hierarchies are
  LLM house style, not human writing. Plain prose. One idea per sentence.
- **Never structure a comment like a document** — headers, tables, decision records — unless the content
  truly demands it. A comment is a message to a person, not a deliverable.
- **Never write long.** More than a few short paragraphs means you are showing off.
- **Never say "Produced with gitban … driving the roadmap → PRD → design → ADR → sprint lifecycle."**
  That is advertising, not disclosure. It goes nowhere, ever.

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

> **⛔ The PR body is written by the `gitban-pr` skill — load it. Never hand-roll a PR body.**
> These two are a pair: **this** skill decides *whether and how to engage*; **`gitban-pr`**'s
> `SKILL.local.md` overlay owns *the body* — obra's template verbatim, target `dev`, the disclosure table,
> no process narration, and the "every claim gets machine-tested" rules. Hand-rolling it is how we shipped
> a disclosure that read as an advertisement and a word count wrong by 36%.

The one part that is **this** skill's job — **derive a fresh, clean branch. Never push your working branch**
(it may carry force-added artifacts or messy history):

```bash
git fetch upstream
git checkout -b fix/<slug> upstream/dev
git checkout <work-branch> -- <the changed code files>   # only the real files
git commit                                               # no attribution footer
git diff --stat upstream/dev                             # verify: exactly the change, nothing else
```

Open as a **draft**; a human reviews the complete diff; then mark it ready — a draft PR is not a request
for review, and leaving it there means doing all the work and never actually asking.

## The PR-body disclosure

Owned by the **`gitban-pr`** overlay: fill obra's template table, name gitban with its link in the plugins
row, and add nothing else — no prose paragraph, no description of what gitban does. See *The disclosure*
above for the comment form.

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
