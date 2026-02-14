#!/usr/bin/env bash
set -uo pipefail

test_path="$1"
results_file="${RESULTS_FILE:-go-test-results.json}"
test_flags="${TEST_FLAGS:-}"

echo "Running: go test -json ${test_flags} ${test_path}"

# Run go test -json and save to file
# shellcheck disable=SC2086
go test -json ${test_flags} "${test_path}" > "$results_file" 2>&1 || true

# Display human-readable output extracted from JSON
echo ""
echo "--- Test Output ---"
jq -rj 'select(.Output != null) | .Output' "$results_file" || true
echo "-------------------"
