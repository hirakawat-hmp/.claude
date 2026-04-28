# CLI Tools

Bash でコマンド実行する際は以下のモダンツールを優先して使用すること:

| 用途 | 使うツール | 代わりに使わないもの |
|------|-----------|-------------------|
| ファイル一覧 | eza | ls |
| ファイル検索 | fd | find |
| テキスト検索 | ripgrep (rg) | grep |
| Web ページ取得 | WebFetch ツール | curl, wget |
| HTTP API リクエスト | xh | curl, wget |
| JSON 処理 | jq | - |
| ファイルサイズ確認 | dust | du |
| ディスク使用量 | duf | df |
| diff 表示 | delta | diff |
| ベンチマーク | hyperfine | time |
| ファイル閲覧 | bat | cat |
| コード行数 | tokei | wc -l, cloc |

## 開発ツール

| 用途 | ツール |
|------|--------|
| VCS | jj (Jujutsu) - Git互換 |
| タスクランナー | task (go-task) |
| Python パッケージ管理 | uv |
| Node.js パッケージ管理 | pnpm |
| Python リンター | ruff |
| Python 型チェッカー | ty |
| GCP CLI | gcloud |
| IaC | terraform |
| 組版 | typst |
| スライド生成 | marp-cli |

## Python スクリプト実行

`python3` は使わず、必ず `uv run` 経由で実行すること:

```bash
uv run script.py
uv run --with requests script.py  # 追加パッケージが必要な場合
```

`uv run ruff` / `uv run ty` はプロジェクト venv に入っていればそちらを優先し、なければグローバル（mise）にフォールバックする。チーム開発では `uv add --dev ruff ty` でプロジェクト依存に追加すること。

## 注意事項

- VPN (Prisma) の SSL inspection 対策として `NODE_EXTRA_CA_CERTS` を設定済み（`~/.config/prisma-ca.pem`）。WebFetch は通常動作する。
- VPN 切断時や証明書更新時に WebFetch が SSL エラーになる場合は `xh` を Bash 経由で代替すること。
