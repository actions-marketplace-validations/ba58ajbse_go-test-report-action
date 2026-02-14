# Go Test Results Action

Go テストの実行から結果の可視化までを一括で行う GitHub Composite Action です。
テスト結果を PR コメントおよび Actions Job Summary に表示します。

## Features

- `go test` の実行・JSON パース・結果表示をワンステップで実行
- PR コメントにテスト結果サマリーと失敗テストのログを投稿
- Actions Job Summary に全テストの詳細テーブルを表示
- 既存コメントの自動更新（同一 PR への再実行時）
- テスト数（pass / fail / skip）と実行時間の集計

## Usage

### Basic

```yaml
- uses: actions/checkout@v4
- uses: actions/setup-go@v5
  with:
    go-version: "1.25"
- uses: ba58ajbse/go-test-report-action@main
```

### With options

```yaml
- uses: ba58ajbse/go-test-report-action@main
  with:
    test-path: "./internal/..."
    working-directory: "backend"
    test-flags: "-race -count=1 -timeout 60s"
```

## Inputs

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `test-path` | No | `./...` | テスト対象の Go パッケージパターン |
| `working-directory` | No | `.` | `go test` の実行ディレクトリ（go.mod の場所） |
| `test-flags` | No | `""` | `go test` への追加フラグ（`-race`, `-count=1` など） |
| `token` | No | `${{ github.token }}` | PR コメント投稿用の GitHub トークン |
| `post-comment` | No | `"true"` | PR コメントを投稿するかどうか (`"true"` / `"false"`) |
| `comment-tag` | No | `"go-test-results"` | コメント識別用タグ（同一タグのコメントを更新） |

## Outputs

| Name | Description |
|------|-------------|
| `total` | テスト総数 |
| `passed` | 成功したテスト数 |
| `failed` | 失敗したテスト数 |
| `skipped` | スキップされたテスト数 |
| `elapsed` | 合計実行時間（秒） |
| `summary` | Markdown 形式のテスト結果サマリー |

## Display

### PR Comment

サマリーテーブル（テスト数・実行時間）と失敗テストのログを表示します。

### Actions Job Summary

サマリーテーブルに加え、全テストのステータス・パッケージ・実行時間の詳細テーブルを表示します。

## License

MIT
