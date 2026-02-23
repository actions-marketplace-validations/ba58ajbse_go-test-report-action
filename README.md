# Go Test PR Reporter

A GitHub Composite Action that executes Go tests and visualizes the results in one step.
Test results are displayed in PR comments and Actions Job Summary.

## Features

- Execute `go test`, parse JSON, and display results in one step
- Post test result summary and failed test logs to PR comments
- Display detailed table of all tests in Actions Job Summary
- Automatically update existing comments (when re-running on the same PR)
- Aggregate test counts (pass / fail / skip) and execution time

## Usage

### Basic

```yaml
- uses: actions/checkout@v4
- uses: actions/setup-go@v5
  with:
    go-version: "1.25"
- uses: ba58ajbse/go-test-report-action@v1
```

### With options

```yaml
- uses: ba58ajbse/go-test-report-action@v1
  with:
    test-path: "./internal/..."
    working-directory: "backend"
    test-flags: "-race -count=1 -timeout 60s"
```

## Inputs

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `test-path` | No | `./...` | Go package pattern to test |
| `working-directory` | No | `.` | Directory to run `go test` in (where go.mod is located) |
| `test-flags` | No | `""` | Additional flags to pass to `go test` (e.g., `-race`, `-count=1`) |
| `token` | No | `${{ github.token }}` | GitHub token for posting PR comments |
| `post-comment` | No | `"true"` | Whether to post results as a PR comment (`"true"` / `"false"`) |
| `comment-tag` | No | `"go-test-results-${{ github.workflow }}"` | Tag to identify the comment for updates. Defaults include the workflow name, so each workflow posts a separate comment. Override to customize. |

## Outputs

| Name | Description |
|------|-------------|
| `total` | Total number of tests |
| `passed` | Number of passed tests |
| `failed` | Number of failed tests |
| `skipped` | Number of skipped tests |
| `elapsed` | Total elapsed time in seconds |
| `summary` | Markdown-formatted test result summary |

## Display

### PR Comment

Displays a summary table (test counts and execution time) and logs of failed tests.

### Actions Job Summary

Displays a summary table along with a detailed table of all tests including status, package, and execution time.

## License

MIT
