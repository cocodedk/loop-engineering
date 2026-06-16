#!/bin/sh
# setup-repo.sh — configure repository settings and branch protection via gh.
#
# This repo has NO CI status check, so branch protection does NOT require any
# status check (required_status_checks is null in the payload below).
#
# Requires: GitHub CLI (gh) authenticated with admin rights on the repo.
set -eu

# --- Derive repo identity from the current gh context ------------------------
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)

echo "Repository:      $REPO"
echo "Default branch:  $DEFAULT_BRANCH"
echo

# --- Repository-level merge settings ----------------------------------------
echo "Applying repository merge settings..."
gh repo edit "$REPO" \
  --delete-branch-on-merge \
  --enable-squash-merge \
  --enable-rebase-merge \
  --enable-merge-commit=false

# --- Branch protection -------------------------------------------------------
# required_status_checks is null on purpose: there is no CI in this repo, so we
# must not require any status check (that would make the branch un-mergeable).
echo "Applying branch protection to '$DEFAULT_BRANCH'..."

PAYLOAD='{"required_status_checks":null,"enforce_admins":false,"required_pull_request_reviews":{"dismiss_stale_reviews":false,"require_code_owner_reviews":false,"required_approving_review_count":0},"restrictions":null,"allow_force_pushes":false,"allow_deletions":false,"required_linear_history":false,"required_conversation_resolution":false,"lock_branch":false,"block_creations":false}'

# Capture output so we can detect the free-plan limitation gracefully.
if PROTECT_OUT=$(printf '%s' "$PAYLOAD" | gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/$REPO/branches/$DEFAULT_BRANCH/protection" \
  --input - 2>&1); then
  PROTECT_OK=1
else
  PROTECT_OK=0
fi

if [ "$PROTECT_OK" -eq 0 ]; then
  if printf '%s' "$PROTECT_OUT" | grep -q "Upgrade to GitHub Pro"; then
    echo
    echo "NOTE: Branch protection was SKIPPED."
    echo "  GitHub refused with 'Upgrade to GitHub Pro' — branch protection on"
    echo "  private repositories requires a paid plan (free-plan private repo)."
    echo "  The local pre-push hook is the fallback enforcement mechanism."
    echo
    echo "  (This repo is PUBLIC, so reaching this branch is unexpected — check"
    echo "   that gh is authenticated with admin rights on $REPO.)"
    exit 0
  fi
  echo "ERROR: Failed to apply branch protection:" >&2
  printf '%s\n' "$PROTECT_OUT" >&2
  exit 1
fi

# --- Success summary ---------------------------------------------------------
echo
echo "Branch protection applied to '$DEFAULT_BRANCH' on $REPO:"
echo "  - Pull request required before merging"
echo "  - 0 approvals required (solo-friendly)"
echo "  - Force-pushes:  blocked"
echo "  - Deletions:     blocked"
echo "  - Admins can bypass (enforce_admins = false)"
echo "  - No status check required (this repo has no CI)"
echo
echo "Done."
