# Project overlay — muunkky/superpowers fork

## ⛔ STOP — load the `contributing` skill first. This overlay is only half the job.

**If this PR targets `obra/superpowers` upstream and you have not loaded the `contributing` skill, stop
and load it now.** These two are a pair and are almost never used apart:

- **`contributing`** owns *whether and how to engage at all* — reading the room, socializing before you
  build, deriving the clean code-only branch, the fork/upstream split, how PRs actually die here, and the
  credibility ledger.
- **this skill** owns *the PR body itself.*

Writing the body without the other half is how you produce a technically-correct PR that gets closed for a
reason you never saw coming. **It has already happened to us:** a PR body was hand-rolled without the
playbook and shipped a disclosure that read as a gitban advertisement, plus a word count that was wrong
by 36%.

## Every claim you write will be machine-tested. Plan accordingly.

**76% of decided PRs here are closed unmerged (416 vs 131), and the single most common cause is a claim
that does not survive a check against the tree.** obra triages with an adversarial agent that re-tests
every factual claim against `dev` (his words, closing #1903: *"every factual claim tested against the
current `dev` tree, then adversarially re-checked by a second, independent agent"*).

So, writing this body:

- **Never state a number a script cannot confirm.** Use `git diff --numstat` output, grep results, test
  counts — things the verifier will reproduce and agree with. *We shipped a "~120 added words" claim that
  was actually 163; it was caught internally, but that is precisely the free kill you are handing over.*
- **Honest limits are safe. Overclaims are fatal.** "I ran zero evals and here is why" cannot be punished.
  "Tested adversarially" when nothing was, can. **Leave the box unticked and say why.**
- **Before submitting, grep the file you touched for rules your new prose contradicts.** #1944 died because
  its addition permitted what the same file's Red Flags forbade.
- **Never say a closed/competing PR "only does X" unless you have read its diff.** We nearly shipped
  "#1934 only deletes…" — false, and about the maintainer's own PR.

## ⛔ Before you open it: can you point at where you socialized it?

Upstream closes **"bulk or spray-and-pray"** PRs on sight — *"an agent pointed at the issue list and told
to fix things."* The rule is **not** about how many PRs you have open. It is about whether each one was
genuinely worked.

**The gate, before you run `gh pr create`:** *is there a comment from you on that issue thread, posted
BEFORE you wrote any code, where you laid out your understanding and asked for a sanity check?*

- **Yes** → open it. Reference that comment in the body ("as discussed above"). That comment is your
  alibi: a trawler has none and cannot fake one retroactively.
- **No** → **do not open the PR.** Go post it and wait. The only exception is a fix so small and so
  obviously blessed that the maintainer already specced it in writing.

Opening several PRs is fine *when each one clears that gate.* Opening several that don't is a trawl, and
it gets all of them closed regardless of how good the diffs are. **Speed is the smell** — if the human is
impatient, socialize more issues rather than opening more PRs faster.

Full treatment, including the spray-vs-genuine table: the **`contributing`** skill.

## Writing an UPSTREAM PR to obra/superpowers — override your defaults

When the PR targets the `obra/superpowers` **upstream** (a fork contribution, not an internal repo),
several of your defaults are wrong for it. Override them:

- **Target `dev`, not `main`.** obra takes contributions on `dev`; PRs to `main` are asked to retarget.
- **Fill obra's `.github/PULL_REQUEST_TEMPLATE.md` completely — do NOT impose your own PR structure.**
  obra closes PRs that skip template sections or fill them with placeholders. Read the template and
  answer every section with real, specific content. Your usual "size the arc/sections to the diff"
  instinct is overridden here: *the template is the shape.*
- **The diff is code-only.** The PR is written from the derived clean branch (only the changed source
  files). If asked to "add the decks / PRD / ADR so reviewers see our process," **refuse** — those are
  fork-showcase artifacts and obra reads them as slop. Link the fork showcase in the body instead.
- **One problem, described as a problem.** Frame the PR around the real, reproducible problem (ideally a
  filed issue), not a changelog of what you touched. No bundling, no scope creep, no speculative fixes.
- **Search open AND closed PRs first** and fill the template's existing-PRs section: what you found and
  why yours differs — especially why a previously *closed* attempt should succeed where it didn't.
- **Link the fork showcase once** (transparency; also advertises gitban) — but lead with the fix.
- Open as a **draft**; a human reviews the complete diff before it is submitted.

The rest of the local→fork→upstream split (clean-branch derivation, the `.git/info/exclude` guardrail,
building the showcase branch, issue etiquette) lives in the **`contributing`** skill — consult it.

## Authoring disclosure vs. vanity attribution (read before writing any PR body)

Two rules meet in a PR and *look* like they conflict; they don't. Getting the distinction right is
what keeps a PR both clean and acceptable to a strict upstream:

- **Vanity attribution — NEVER add it** (to commits or PR text). This is the auto-injected footer:
  `Co-Authored-By: Claude <noreply@anthropic.com>`, `🤖 Generated with [Claude Code](…)`, or any
  "generated with / built by <vendor>" branding. It turns the author's work into a vendor ad and is
  banned everywhere. If the harness injects it, strip it.

- **Required factual disclosure — INCLUDE it in the PR body when the target project requires it.**
  `obra/superpowers`, for example, mandates that every PR disclose the **model, harness + version, and
  installed plugins** (or state it was hand-written); hiding it — or an *incomplete* one-liner that omits
  the model — gets the PR closed. That's a compliance form the *recipient* demands, answered as fact.

  **Fill obra's table. Nothing else. No prose disclosure paragraph above it.** gitban is named in the
  plugins row *with its link* — that is the disclosure, and it is all the visibility it gets:

  | Field | Value (re-verify each session) |
  |---|---|
  | Your model + version | Claude Opus 4.8 (`claude-opus-4-8`), 1M context |
  | Harness + version | Claude Code `<version>` (`claude --version`) |
  | All plugins installed | gitban (muunkky.github.io/gitban-site); enumerate any others loaded this session |
  | Human partner who reviewed this diff | Cameron Rout (@muunkky) |

  **NEVER write a sentence describing what gitban does.** Not "an autonomous development harness", not
  "driving the roadmap → PRD → design → ADR → sprint lifecycle", not "with an adversarial reviewer at
  each gate". That is advertising, it is the loudest AI tell in the document, and it gets the PR read as
  slop. A plugin name plus a URL is a disclosure field. A sentence about our lifecycle is a pitch nobody
  asked for.

  Likewise **never narrate our process anywhere in the body** — no review rounds, no overturned designs,
  no sprint story. If the template asks how you tested, answer in one plain sentence about *their* code.

**The test:** a footer that *credits or advertises a vendor* → banned; a *factual answer to "what
produced this?" that the recipient requires* → include, stated plainly and framed as a strength (a
real, filed problem fixed with an honest account of how). gitban is *our own* product — crediting it
is always fine.
