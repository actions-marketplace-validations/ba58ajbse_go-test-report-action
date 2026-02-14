#!/usr/bin/env bash
set -euo pipefail

results_file="$1"

if [[ ! -f "$results_file" ]]; then
  echo "::error::Test results file not found: $results_file"
  exit 1
fi

failed_details_file="${RUNNER_TEMP:-/tmp}/go-test-failed-details.json"

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

# Extract failed test details: name, package, elapsed time, and output log
jq -s '
  [.[] | select(.Test != null)] |
  group_by(.Package + "/" + .Test) |
  [
    .[] |
    select(any(.[]; .Action == "fail")) |
    {
      test: .[0].Test,
      package: .[0].Package,
      elapsed: ([.[] | select(.Action == "fail") | .Elapsed // 0] | first),
      output: ([.[] | select(.Action == "output") | .Output] | join(""))
    }
  ]
' "$results_file" > "$failed_details_file"

# Set outputs
{
  echo "total=$total"
  echo "passed=$passed"
  echo "failed=$failed"
  echo "skipped=$skipped"
} >> "$GITHUB_OUTPUT"

echo "Parsed test results: total=$total passed=$passed failed=$failed skipped=$skipped"
