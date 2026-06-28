# CLI Tools

Bash でコマンド実行する際は、以下のインストール済みツールを優先して使用すること。
（環境に存在するツールのみを掲載。未導入のものに依存しないこと）

| 用途 | 使うツール | 代わりに使わないもの |
|------|-----------|-------------------|
| テキスト検索 | ripgrep (rg) | grep |
| コード行数 | tokei | wc -l, cloc |
| Web ページ取得 | WebFetch ツール | curl, wget |
| HTTP API リクエスト | xh | curl, wget |
| JSON 処理 | jq | - |

> ファイル一覧 / 検索 / 閲覧（ls・find・cat 相当）は、専用ツールではなく
> Claude Code の組み込みツール（Glob / Grep / Read）を優先する。
> Bash で行う場合は標準の ls / find / cat を使ってよい（eza/fd/bat は未導入）。

## 開発ツール

| 用途 | ツール |
|------|--------|
| VCS | git |
| タスクランナー | task (go-task) |
| Python パッケージ管理 | uv |
| Node.js パッケージ管理 | pnpm |
| Python リンター | ruff |
| Python 型チェッカー | ty |
| GCP CLI | gcloud |
| IaC | terraform |
| GitHub 操作 | gh |

> スライド生成は `slide-creator` スキル（Marp）経由で行う。
> marp-cli を直接叩く前提のルールは置かない。

## Python スクリプト実行

`python3` は使わず、必ず `uv run` 経由で実行すること:

```bash
uv run script.py
uv run --with requests script.py  # 追加パッケージが必要な場合
```

`uv run ruff` / `uv run ty` はプロジェクト venv に入っていればそちらを優先し、なければグローバル（mise）にフォールバックする。チーム開発では `uv add --dev ruff ty` でプロジェクト依存に追加すること。

## 注意事項

- ツールは mise 管理。実シェル（zsh）では mise activate により PATH が通る。
- VPN (Prisma) の SSL inspection 対策として `NODE_EXTRA_CA_CERTS` を設定済み（`~/.config/prisma-ca.pem`）。WebFetch は通常動作する。
- VPN 切断時や証明書更新時に WebFetch が SSL エラーになる場合は `xh` を Bash 経由で代替すること。
