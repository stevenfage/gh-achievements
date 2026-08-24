# gh-achievements

A **sourced** runbook for earning GitHub profile achievements, plus a script that does the
mechanical ones for you.

Most guides on this topic repeat numbers nobody verified. This one links every claim to the
GitHub Community discussion it came from, and says plainly where the answer is *unknown*.

> **Correction to a widely-copied error:** several popular guides state Quickdraw requires closing
> an issue within **10 seconds**. It is **5 minutes**.
> ([community #144773](https://github.com/orgs/community/discussions/144773))

---

## The two rules that break everything

1. **Achievements only count on public repositories.** Work in a private repo earns nothing.
   ([community #45578](https://github.com/orgs/community/discussions/45578))
2. **Earned is not the same as visible.** `Settings → Profile → Show Achievements on my profile`
   is an account-level toggle, and each badge has its own hide switch. Most "my badge didn't
   work" reports are this. ([community #73377](https://github.com/orgs/community/discussions/73377))

Flip the toggle *before* you start, or you will debug a workflow that already succeeded.

---

## Status of every achievement

| Achievement | Requirement | Scriptable | Notes |
|---|---|---|---|
| **Quickdraw** | Close an issue or PR within **5 minutes** of opening it | Yes | Your own issue counts |
| **YOLO** | Merge a PR with **no** review approval | Yes | Self-merge counts |
| **Pull Shark** | **2** merged PRs (tiers: 2 / 16 / 128 / 1024) | Yes | PRs to your own repo count |
| **Pair Extraordinaire** | Merged PR with a `Co-authored-by:` trailer (tiers: 1 / 10 / 24 / 48) | Partly | Needs a real second GitHub account |
| **Galaxy Brain** | **2** accepted Discussions answers (tiers: 2 / 8 / 16 / 32) | No | See caveat below |
| **Starstruck** | **16** stars on one repo (tiers: 16 / 128 / 512 / 4096) | No | Requires real people |
| **Public Sponsor** | Sponsor anyone via GitHub Sponsors | No | Costs money |
| Heart On Your Sleeve | — | **Retired** | Unobtainable |
| Open Sourcerer | — | **Retired** | Unobtainable |
| Mars 2020 Contributor | — | **Retired** | Unobtainable |
| Arctic Code Vault Contributor | — | **Retired** | Unobtainable |

### Galaxy Brain is a trap

You cannot self-answer. The question must be asked by someone else, in a **public** repo, and the
asker or a maintainer must click **Mark as answer**. Worse: if any of your *own* answers to your
*own* questions were ever marked as the solution, that can block the badge, and deleting the repo
afterward does **not** undo it. GitHub also disabled achievement-earning inside the GitHub
Community discussions themselves (Feb 2024, anti-spam), so it has to be some other project's
Discussions. ([community #45578](https://github.com/orgs/community/discussions/45578),
[#189913](https://github.com/orgs/community/discussions/189913))

### Does deleting the repo revoke the badges?

**Unknown.** GitHub does not document achievements anywhere official. Community threads about
badges vanishing list "repo was made private or deleted" as a *suspected* cause, but no GitHub
staff member ever confirmed it.
([community #54038](https://github.com/orgs/community/discussions/54038))

**Recommendation: archive the repo instead of deleting it.** Archiving is free, makes the repo
read-only, keeps it public, and removes the risk entirely.

---

## Usage

Requires [`gh`](https://cli.github.com) authenticated with `repo` scope.

```bash
git clone https://github.com/stevenfage/gh-achievements.git
cd gh-achievements
./earn.sh --dry-run          # print every command without running it
./earn.sh                    # create a sandbox repo and earn Quickdraw + YOLO + Pull Shark
./earn.sh --repo my-sandbox  # use a specific repo name
./earn.sh --pair octocat     # additionally earn Pair Extraordinaire with a co-author
```

The script only ever acts on a repository **you own**. It does not touch other people's projects.

---

## Timing

Badges lag. Expect a few hours, occasionally a full day, before
`https://github.com/<you>?tab=achievements` updates. If a badge still isn't showing after that,
go to the achievements tab and toggle its visibility off and on.

## Sources

- [githubachievements.com](https://githubachievements.com/) — the badge catalogue
- [community #144773](https://github.com/orgs/community/discussions/144773) — Quickdraw, 5 minutes
- [community #45578](https://github.com/orgs/community/discussions/45578) — Galaxy Brain restrictions
- [community #189913](https://github.com/orgs/community/discussions/189913) — Galaxy Brain, no self-answers
- [community #157912](https://github.com/orgs/community/discussions/157912) — Pair Extraordinaire trailer
- [community #73377](https://github.com/orgs/community/discussions/73377) — badge earned but hidden
- [community #54038](https://github.com/orgs/community/discussions/54038) — badges disappearing

## License

MIT
