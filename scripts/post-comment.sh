#!/usr/bin/env bash
set -euo pipefail

comment_tag="$1"
summary_file="${SUMMARY_FILE:-${RUNNER_TEMP:-/tmp}/go-test-summary.md}"
marker="<!-- ${comment_tag} -->"

repo="${GITHUB_REPOSITORY}"
pr_number="${GITHUB_EVENT_NAME:-}"

# Extract PR number from the event payload
if [[ -n "${GITHUB_EVENT_PATH:-}" ]] && [[ -f "${GITHUB_EVENT_PATH}" ]]; then
  pr_number=$(jq -r '.pull_request.number // empty' "$GITHUB_EVENT_PATH")
fi

if [[ -z "$pr_number" ]]; then
  echo "::warning::Could not determine PR number. Skipping comment."
  exit 0
fi

if [[ ! -f "$summary_file" ]]; then
  echo "::error::Summary file not found: $summary_file"
  exit 1
fi

body=$(cat "$summary_file")

# Search for an existing comment with the marker
existing_comment_id=$(
  gh api "repos/${repo}/issues/${pr_number}/comments" \
    --paginate \
    --jq ".[] | select(.body | contains(\"${marker}\")) | .id" \
  | head -n 1
)

if [[ -n "$existing_comment_id" ]]; then
  # Update existing comment
  gh api "repos/${repo}/issues/comments/${existing_comment_id}" \
    --method PATCH \
    --field body="$body"
  echo "Updated existing comment (ID: $existing_comment_id)"
else
  # Create new comment
  gh api "repos/${repo}/issues/${pr_number}/comments" \
    --method POST \
    --field body="$body"
  echo "Created new comment on PR #${pr_number}"
fi
