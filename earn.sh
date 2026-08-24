#!/usr/bin/env bash
#
# earn.sh - earn the mechanical GitHub profile achievements in a repo you own.
#
# Earns: Quickdraw, YOLO, Pull Shark (2/2), and optionally Pair Extraordinaire.
# Cannot earn: Galaxy Brain, Starstruck, Public Sponsor. See README.md.
#
# Requires: gh (authenticated, repo scope), git.
# Safe by design: only ever acts on a repository owned by the authenticated user.

set -euo pipefail

REPO_NAME="gh-achievements-sandbox"
DRY_RUN=0
PAIR_USER=""

usage() {
  cat <<'USAGE'
Usage: ./earn.sh [options]

  --repo NAME       Sandbox repo name to create/use (default: gh-achievements-sandbox)
  --pair USERNAME   Also earn Pair Extraordinaire, co-authoring with this GitHub user
  --dry-run         Print every command without executing it
  -h, --help        Show this help

Before running: enable Settings -> Profile -> "Show Achievements on my profile".
Achievements only count in PUBLIC repositories.
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)    REPO_NAME="${2:?--repo needs a value}"; shift 2 ;;
    --pair)    PAIR_USER="${2:?--pair needs a username}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
  esac
done

say()  { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
note() { printf '    %s\n' "$*"; }

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '    [dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

# --- preflight ---------------------------------------------------------------
say "Preflight"
command -v gh  >/dev/null 2>&1 || { echo "gh is not installed: https://cli.github.com" >&2; exit 1; }
command -v git >/dev/null 2>&1 || { echo "git is not installed" >&2; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "gh is not authenticated. Run: gh auth login" >&2; exit 1; }

OWNER="$(gh api user --jq .login)"
note "Authenticated as: $OWNER"
note "Target repo:      $OWNER/$REPO_NAME (public)"
[ "$DRY_RUN" -eq 1 ] && note "MODE: dry-run, nothing will be changed"

if [ -n "$PAIR_USER" ]; then
  if ! PAIR_ID="$(gh api "users/$PAIR_USER" --jq .id 2>/dev/null)"; then
    echo "No such GitHub user: $PAIR_USER" >&2; exit 1
  fi
  PAIR_NAME="$(gh api "users/$PAIR_USER" --jq '.name // .login')"
  COAUTHOR="$PAIR_NAME <${PAIR_ID}+${PAIR_USER}@users.noreply.github.com>"
  note "Co-author:        $COAUTHOR"
fi

# --- repo --------------------------------------------------------------------
say "Repository"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

if gh repo view "$OWNER/$REPO_NAME" >/dev/null 2>&1; then
  note "Repo exists, cloning"
  run gh repo clone "$OWNER/$REPO_NAME" "$WORKDIR/repo"
else
  note "Creating public repo"
  run gh repo create "$REPO_NAME" --public --add-readme --clone -- "$WORKDIR/repo" 2>/dev/null \
    || run gh repo create "$REPO_NAME" --public --add-readme
  [ "$DRY_RUN" -eq 0 ] && [ ! -d "$WORKDIR/repo" ] && gh repo clone "$OWNER/$REPO_NAME" "$WORKDIR/repo"
fi

if [ "$DRY_RUN" -eq 0 ]; then
  cd "$WORKDIR/repo"
  BASE="$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name)"
else
  BASE="main"
fi
note "Default branch:   $BASE"

# --- Quickdraw ---------------------------------------------------------------
say "Quickdraw: open an issue and close it inside the 5-minute window"
if [ "$DRY_RUN" -eq 1 ]; then
  run gh issue create --title "Quickdraw" --body "Opened and closed immediately."
  run gh issue close "<issue-url>"
else
  ISSUE_URL="$(gh issue create --title "Quickdraw" --body "Opened and closed immediately." | tail -1)"
  note "$ISSUE_URL"
  gh issue close "$ISSUE_URL" >/dev/null
  note "closed"
fi

# --- helper: one PR ----------------------------------------------------------
make_pr() {
  branch="$1"; line="$2"; msg="$3"; strategy="$4"; trailer="${5:-}"

  run git checkout "$BASE"
  run git pull --quiet
  run git checkout -b "$branch"

  if [ "$DRY_RUN" -eq 1 ]; then
    run sh -c "printf '%s\n' '$line' >> LOG.md"
  else
    printf '%s\n' "$line" >> LOG.md
  fi

  run git add LOG.md
  if [ -n "$trailer" ]; then
    run git commit -m "$msg" -m "Co-authored-by: $trailer"
  else
    run git commit -m "$msg"
  fi
  run git push --quiet -u origin "$branch"
  run gh pr create --fill --base "$BASE"
  run gh pr merge "--$strategy" --delete-branch
}

say "YOLO + Pull Shark 1 of 2: merge a PR with no review approval"
make_pr "achv/pr-1" "- entry one" "chore: add log entry one" "squash"

say "Pull Shark 2 of 2"
make_pr "achv/pr-2" "- entry two" "chore: add log entry two" "squash"

if [ -n "$PAIR_USER" ]; then
  say "Pair Extraordinaire: merge commit (NOT squash) so the trailer survives"
  make_pr "achv/pair" "- paired entry" "chore: add paired log entry" "merge" "$COAUTHOR"
fi

# --- done --------------------------------------------------------------------
say "Done"
note "Badges lag a few hours, sometimes a day."
note "Check: https://github.com/$OWNER?tab=achievements"
note "If a badge is missing there, toggle its visibility off and on."
note "Keep the sandbox: archive it rather than deleting it (see README.md)."
