---
name: vault-tags
description: Show the vault tag library — list all available types, status vocabularies, and domain tags. Use this before creating or querying wiki pages to ensure consistent tagging.
user-invocable: true
allowed-tools: [Read, Bash]
---

# Vault Tags

vault で使用可能な type、status、ドメインタグの一覧を表示する。

## Tag library の内容

!`uv run ${CLAUDE_PLUGIN_ROOT}/plugins/vault/scripts/vault-cli.py tags`

## 使い方

このコマンドは tag library (`vault/tags.md`) の内容をそのまま表示する。
新しい wiki ページを作成する際や、既存ページを検索する際に、使用可能な語彙を確認するために使う。

## 関連コマンド

- `/vault-list` — type や tag を指定してページをリストアップ
- `/vault-ingest` — 新しいソースを取り込む
- `/vault-lint` — tag library との整合性をチェック
