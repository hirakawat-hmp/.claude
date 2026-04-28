# CLI Tools

Bash でコマンド実行する際は以下のモダンツールを優先して使用すること:

| 用途 | 使うツール | 代わりに使わないもの |
|------|-----------|-------------------|
| ファイル一覧 | eza | ls |
| ファイル検索 | fd | find |
| テキスト検索 | ripgrep (rg) | grep |
| HTTP リクエスト | xh | curl, wget |
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
| Python リンター | ruff |
| GCP CLI | gcloud |
| IaC | terraform |
| 組版 | typst |
| スライド生成 | marp-cli |

## 注意事項

- VPN (Prisma) の SSL inspection 対策として `NODE_EXTRA_CA_CERTS` を設定済み（`~/.config/prisma-ca.pem`）。WebFetch は通常動作する。
- VPN 切断時や証明書更新時に WebFetch が SSL エラーになる場合は `xh` を Bash 経由で代替すること。
