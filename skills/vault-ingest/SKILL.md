---
name: vault-ingest
description: Ingest sources into the vault knowledge base. Use when the user wants to add knowledge — from Clippings, URLs, raw/ files, or web research topics.
user-invocable: true
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob, WebFetch, WebSearch]
argument-hint: "[URL, file path, or topic to research]"
---

# Vault Ingest

ナレッジベースにソースを取り込み、wiki ページを生成する。

## Vault のパス

vault のルートは `${CLAUDE_PLUGIN_ROOT}` にある。
- wiki ページ: `${CLAUDE_PLUGIN_ROOT}/vault/wiki/`
- ニュースレター: `${CLAUDE_PLUGIN_ROOT}/vault/newsletters/`
- 元ソース: `${CLAUDE_PLUGIN_ROOT}/vault/raw/`
- Clippings: `${CLAUDE_PLUGIN_ROOT}/vault/Clippings/`
- index: `${CLAUDE_PLUGIN_ROOT}/vault/index.md`
- log: `${CLAUDE_PLUGIN_ROOT}/vault/log.md`

## 現在の未処理 Clippings

!`bash ${CLAUDE_PLUGIN_ROOT}/plugins/vault/scripts/check-pending.sh`

## 処理フロー

引数: $ARGUMENTS

### 引数がある場合

1. URL なら WebFetch で取得し `raw/` に保存
2. ファイルパスなら Read で読み込み
3. トピック名なら WebSearch で調査し、重要なソースを WebFetch で取得して `raw/` に保存

### 引数がない場合

上記の未処理 Clippings を全件処理する。

### 共通の後処理

各ソースについて:

1. 内容を読み、要約・分析する
2. `vault/wiki/` にページを作成:
   - ファイル名は英語 kebab-case
   - フロントマターに tags, sources, created, updated を含める
   - 適切なタグを付与（source, entity, concept, insight, comparison）
   - 本文は日本語で記述
   - 関連する既存 wiki ページへ `[[wiki/ページ名]]` でリンク
3. 言及されたエンティティや概念に専用ページがなければ作成
4. 既存ページとの矛盾があれば明記
5. Clippings の場合、フロントマターの status を `ingested` に更新
6. `vault/index.md` の適切なカテゴリにページを追加
7. `vault/log.md` に記録: `## [YYYY-MM-DD] ingest | ソースの要約`

## ページフォーマット

```markdown
---
type: <type>
status: []
tags:
  - <tag>
sources:
  - "URL or reference"
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# タイトル

本文。他の wiki ページへは `[[wiki/ページ名]]` でリンクする。
```

## 重要事項

- すべての wiki コンテンツは **日本語** で記述
- ファイル名は **英語 kebab-case**
- raw/ のファイルは immutable（一度保存したら変更しない）
- リサーチは深く行う。表面的な要約ではなく技術的な詳細まで踏み込む
- 1つのソースから複数ページを作成してよい
