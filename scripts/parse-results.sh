#!/usr/bin/env bash
set -euo pipefail

results_file="$1"

if [[ ! -f "$results_file" ]]; then
  echo "::error::Test results file not found: $results_file"
  exit 1
fi

failed_details_file="${RUNNER_TEMP:-/tmp}/go-test-failed-details.json"

# Filter to valid JSON lines only (go test -json may include non-JSON output)
filtered_file="${RUNNER_TEMP:-/tmp}/go-test-filtered.json"
grep '^\s*{' "$results_file" | jq -c '.' 2>/dev/null > "$filtered_file" || true
results_file="$filtered_file"

# Parse go test -json output using jq
# Count pass/fail/skip from test-level events (where .Test is present)
jq -s '
  [.[] | select(.Test != null and .Action != null)] |
  {
    passed: [.[] | select(.Action == "pass")] | length,
    failed: [.[] | select(.Action == "fail")] | length,
    skipped: [.[] | select(.Action == "skip")] | length
  } |
  .total = (.passed + .failed + .skipped)
' "$results_file" > "${RUNNER_TEMP:-/tmp}/go-test-counts.json"

total=$(jq -r '.total' "${RUNNER_TEMP:-/tmp}/go-test-counts.json")
passed=$(jq -r '.passed' "${RUNNER_TEMP:-/tmp}/go-test-counts.json")
failed=$(jq -r '.failed' "${RUNNER_TEMP:-/tmp}/go-test-counts.json")
skipped=$(jq -r '.skipped' "${RUNNER_TEMP:-/tmp}/go-test-counts.json")

# Calculate total elapsed time from package-level events
elapsed=$(jq -s '
  [.[] | select(.Test == null and (.Action == "pass" or .Action == "fail")) | .Elapsed // 0] | add // 0
' "$results_file")

# Extract all test details: name, package, result, elapsed time
all_tests_file="${RUNNER_TEMP:-/tmp}/go-test-all-details.json"
jq -s '
  [.[] | select(.Test != null)] |
  group_by(.Package + "/" + .Test) |
  [
    .[] |
    {
      test: .[0].Test,
      package: .[0].Package,
      action: ([.[] | select(.Action == "pass" or .Action == "fail" or .Action == "skip") | .Action] | last),
      elapsed: ([.[] | select(.Action == "pass" or .Action == "fail" or .Action == "skip") | .Elapsed // 0] | last),
      output: ([.[] | select(.Action == "output") | .Output] | join(""))
    }
  ]
' "$results_file" > "$all_tests_file"

# Extract failed test details (subset for backward compat)
jq '[.[] | select(.action == "fail")]' "$all_tests_file" > "$failed_details_file"

# Set outputs
{
  echo "total=$total"
  echo "passed=$passed"
  echo "failed=$failed"
  echo "skipped=$skipped"
  echo "elapsed=$elapsed"
} >> "$GITHUB_OUTPUT"

echo "Parsed test results: total=$total passed=$passed failed=$failed skipped=$skipped elapsed=${elapsed}s"
