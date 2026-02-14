#!/usr/bin/env bash
set -euo pipefail

comment_tag="$1"
summary_file="${SUMMARY_FILE:-${RUNNER_TEMP:-/tmp}/go-test-summary.md}"
failed_details_file="${FAILED_DETAILS_FILE:-${RUNNER_TEMP:-/tmp}/go-test-failed-details.json}"

total="${TOTAL:-0}"
passed="${PASSED:-0}"
failed="${FAILED:-0}"
skipped="${SKIPPED:-0}"

{
  # Marker comment for identifying this comment on PRs
  echo "<!-- ${comment_tag} -->"
  echo "## 🧪 Go Test Results"
  echo ""

  if [[ "$failed" -eq 0 ]]; then
    echo "✅ **All ${total} tests passed**"
  else
    echo "❌ **${failed} test(s) failed**"
  fi

  echo ""
  echo "| Status | Count |"
  echo "|--------|-------|"
  echo "| Total | ${total} |"
  echo "| ✅ Passed | ${passed} |"
  echo "| ❌ Failed | ${failed} |"
  echo "| ⏭️ Skipped | ${skipped} |"

  # Append failed test details if any
  if [[ "$failed" -gt 0 ]] && [[ -f "$failed_details_file" ]]; then
    echo ""
    echo "### Failed Tests"
    echo ""

    jq -r '
      .[] |
      "<details>\n<summary>❌ " + .test + " (" + .package + ") - " + ((.elapsed // 0) | tostring) + "s</summary>\n\n```\n" + .output + "```\n\n</details>\n"
    ' "$failed_details_file"
  fi
} > "$summary_file"

# Set output using delimiter for multiline value
delimiter="EOF_$(date +%s%N)"
{
  echo "summary<<${delimiter}"
  cat "$summary_file"
  echo "${delimiter}"
} >> "$GITHUB_OUTPUT"

echo "Summary written to $summary_file"
