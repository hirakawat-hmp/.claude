---
name: kie-ai
description: >
  kie.ai API を使って画像・動画・音楽・音声などを生成するスキル。
  「Kling で猫の動画を作って」「Suno で jazz を生成して」「Imagen4 で富士山の画像を作って」
  のようにユーザーが生成を依頼したときは必ずこのスキルを使うこと。
  kie.ai / KIE API / AI生成 に関するリクエストには積極的にこのスキルを適用すること。
---

# kie-ai スキル

kie.ai API を通じて画像・動画・音楽・音声を生成するワークフローを担う。

## セットアップ

`~/.claude/skills/kie-ai/.env` に API キーを記載する（初回のみ）：

```bash
cp ~/.claude/skills/kie-ai/.env.example ~/.claude/skills/kie-ai/.env
# KIE_API_KEY=your_api_key_here を書き換える
```

取得先: https://kie.ai/api-key

## ドキュメントの参照方法

ローカルドキュメントが `/Users/hdymacuser/Desktop/dev/kie-artwork/docs/` に保存されている。

1. まず `docs/INDEX.md` を Read して目的のモデル・APIを特定する
2. INDEX.md 内のリンクは相対パスなので `docs/<path>` で Read する
3. 該当ドキュメントからエンドポイント・必須パラメータ・モデル名を確認する

## APIリクエストの組み立て

### xh 使用上の注意

**必ず `--ignore-stdin` を付けること。** Claude Code のパイプ環境では stdin が開いており、付けないと `Request body and request data cannot be mixed` エラーになる。

**ネストしたパラメータは `'input[key]=value'` 形式で渡す（JSON文字列は使わない）：**

```bash
source ~/.claude/skills/kie-ai/.env

xh --ignore-stdin POST https://api.kie.ai/api/v1/jobs/createTask \
  "Authorization:Bearer $KIE_API_KEY" \
  model="<model-name>" \
  'input[prompt]=...' \
  'input[aspect_ratio]=9:16'
```

### Market系モデル（画像・動画・音声の大半）

エンドポイント: `POST https://api.kie.ai/api/v1/jobs/createTask`

### Suno（音楽生成）は別エンドポイント

```bash
xh --ignore-stdin POST https://api.kie.ai/api/v1/generate \
  "Authorization:Bearer $KIE_API_KEY" \
  prompt="..." \
  customMode:=false \
  instrumental:=false \
  model="V4"
```

レスポンスから `data.taskId` を取得する。

## ポーリングとダウンロード

**サブエージェントは権限の問題で xh が動かないことがある。ポーリングとダウンロードはこのセッション（メインエージェント）から直接 Bash で行うこと。**

```bash
source ~/.claude/skills/kie-ai/.env
TASK_ID="<task_id>"
for i in $(seq 1 60); do
  RESP=$(xh --ignore-stdin GET https://api.kie.ai/api/v1/jobs/recordInfo \
    "Authorization:Bearer $KIE_API_KEY" "taskId==$TASK_ID")
  STATE=$(echo "$RESP" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['state'])" 2>/dev/null)
  echo "[$i] $STATE"
  if [ "$STATE" = "success" ]; then
    URL=$(echo "$RESP" | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.loads(d['data']['resultJson'])['resultUrls'][0])")
    xh --ignore-stdin GET "$URL" --output ~/.claude/skills/kie-ai/downloads/<filename>
    break
  elif [ "$STATE" = "fail" ]; then
    echo "FAIL: $(echo $RESP | python3 -c "import sys,json; print(json.load(sys.stdin)['data'].get('failMsg','?'))")"
    break
  fi
  sleep 5
done
```

### ポーリングの仕組み

`GET https://api.kie.ai/api/v1/jobs/recordInfo?taskId=<id>`

state の遷移: `waiting` → `queuing` → `generating` → `success` / `fail`

成功時は `data.resultJson` の `resultUrls` にURLが入っている。

## ElevenLabs 音声生成の注意事項

- `language_code=ja` を指定すると日本語で自然に読み上げられる（自動検出でも動くが精度が下がる）
- テキスト中の `…` や `...` はそのまま「てんてんてん」と読まれることがある → 句読点や `[pause]` タグに置き換える
- 感情タグ: `[pause]`、`[exhale]`、`[sigh]` などが使える

```bash
xh --ignore-stdin POST https://api.kie.ai/api/v1/jobs/createTask \
  "Authorization:Bearer $KIE_API_KEY" \
  model="elevenlabs/text-to-dialogue-v3" \
  'input[dialogue][0][text]=セリフ本文' \
  'input[dialogue][0][voice]=EiNlNiXeDU1pqqOPrYMO' \
  'input[stability]=0.5' \
  'input[language_code]=ja'
```

## 実行フロー（まとめ）

1. `docs/INDEX.md` を Read してモデルを特定
2. 該当 `.md` を Read してエンドポイント・パラメータを確認
3. `xh --ignore-stdin` でタスクを作成 → `task_id` を取得
4. **このセッションから直接 Bash でポーリング・ダウンロード**（上記のループを使う）
5. ダウンロード完了後 `afplay` で再生確認（音声の場合）

## エラーハンドリング

| コード | 意味 | 対処 |
|--------|------|------|
| 401 | APIキー不正 | `KIE_API_KEY` を確認 |
| 402 | クレジット不足 | https://kie.ai/pricing でチャージ |
| 429 | レート超過 | 少し待ってリトライ |
| 501 | 生成失敗 | パラメータを見直して再試行 |

## 注意事項

- 生成ファイルは14日で自動削除されるため、重要なものはすぐにダウンロードすること
- HTTP 200 はタスク作成成功を意味するだけで、生成完了ではない
- `KIE_API_KEY` をコードやログに出力しないこと
