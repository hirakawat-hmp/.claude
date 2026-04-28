---
name: vault-list
description: List wiki pages filtered by type, tag, or status. Use this for agentic search over the vault — narrow down relevant pages before reading them in full.
user-invocable: true
allowed-tools: [Read, Bash, Grep, Glob]
argument-hint: "[type:<type>] [tag:<tag>] [status:<status>] [-tag:<excluded>]"
---

# Vault List

type、tag、status を指定して wiki ページをリストアップする。agentic search の第一段階として使う。

## フィルタ文法

| 記号 | 意味 | 例 |
|------|------|-----|
| スペース | AND（フィールド間） | `type:concept tag:ai/llm` |
| カンマ `,` | OR（同じフィールド内） | `tag:ai/llm,ai/agent` |
| `-` プレフィックス | 除外 | `-tag:project/aaip` |

## 使い方

```
/vault-list                                       # 全ページ（archived 除く）
/vault-list type:concept                          # type フィルタ
/vault-list tag:ai/llm                            # tag フィルタ
/vault-list type:concept tag:ai/llm               # AND
/vault-list tag:ai/llm,ai/agent                   # OR（同じフィールド内）
/vault-list tag:ai/llm -tag:project/aaip          # 除外
/vault-list type:how-to tag:infra/gcp status:verified
```

オプション:
- `--all` — archived ページも含める
- `--json` — JSON 形式で出力

## 利用可能な type と tag

事前に `/vault-tags` で確認、または `vault/tags.md` を直接参照。

## 実行

引数: $ARGUMENTS

!`uv run ${CLAUDE_PLUGIN_ROOT}/plugins/vault/scripts/vault-cli.py list $ARGUMENTS`

## 次のステップ

リストアップされたページから関連度が高いものを選び、`Read` で全文を取得する。
本文中の `[[wiki/X]]` リンクをたどって関連ページを辿ったり、`Grep` でキーワード検索したりしながら知識を収集する。

## 関連コマンド

- `/vault-tags` — 利用可能な type と tag を表示
- `/vault-ingest` — 新しいソースを取り込む
- `/vault-lint` — vault の健全性チェック
