---
name: vault-lint
description: Health-check and maintain the vault wiki. Finds and fixes contradictions, orphan pages, missing cross-references, stale content, and data gaps.
user-invocable: true
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

# Vault Lint

ナレッジベースの健全性をチェックし、問題を修正する。

## Vault のパス

- wiki ページ: `${CLAUDE_PLUGIN_ROOT}/vault/wiki/`
- index: `${CLAUDE_PLUGIN_ROOT}/vault/index.md`
- log: `${CLAUDE_PLUGIN_ROOT}/vault/log.md`
- tag library: `${CLAUDE_PLUGIN_ROOT}/vault/tags.md`

## 機械的チェック結果

!`uv run ${CLAUDE_PLUGIN_ROOT}/plugins/vault/scripts/vault-cli.py lint`

## チェック項目

上記の機械的チェックに加え、以下を確認:

### 1. リンク整合性
- `[[wiki/ページ名]]` のリンク先が実在するか
- index.md に全ページが載っているか

### 2. 孤立ページ
- 他のページからリンクされていないページ
- → 関連ページにリンクを追加するか、不要なら削除を検討

### 3. 矛盾する記述
- 複数ページで同じトピックについて矛盾する情報がないか
- → 新しいソースの情報を優先し、矛盾を明記

### 4. 古い情報
- 新しいソースで上書きされるべき古い記述がないか
- → status に `outdated` を追加、または内容を更新して updated 日付を変更

### 5. 欠けた相互リンク
- 同じトピックに言及しているのにリンクされていないページ
- → 相互リンクを追加

### 6. 不足ページ
- 複数ページで言及されているがまだ専用ページがない概念やエンティティ
- → 必要に応じてページを作成

### 7. Tag library との整合性
- 未登録のドメインタグを使っているページ
- → 正式登録するか既存タグへ統合

## 修正後

1. 修正したページの一覧を報告
2. `vault/log.md` に記録: `## [YYYY-MM-DD] lint | 修正内容の要約`
