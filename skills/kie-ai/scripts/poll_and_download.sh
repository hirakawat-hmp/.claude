#!/bin/bash
# kie.ai タスクをポーリングして完了後にファイルをダウンロードする
# Usage: poll_and_download.sh <task_id> <api_key> [download_dir] [copy_to]

TASK_ID="$1"
API_KEY="$2"
DOWNLOAD_DIR="${3:-$HOME/.claude/skills/kie-ai/downloads}"
COPY_TO="$4"

POLL_URL="https://api.kie.ai/api/v1/jobs/recordInfo"
MAX_WAIT=900   # 15分
INTERVAL=5     # 5秒間隔でスタート
ELAPSED=0

echo "[kie-ai] ポーリング開始: $TASK_ID"

while [ $ELAPSED -lt $MAX_WAIT ]; do
  RESPONSE=$(xh GET "$POLL_URL" \
    "Authorization:Bearer $API_KEY" \
    "taskId==$TASK_ID" 2>/dev/null)

  STATE=$(echo "$RESPONSE" | /usr/bin/python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('data',{}).get('state','unknown'))" 2>/dev/null)

  echo "[kie-ai] state=$STATE (${ELAPSED}s経過)"

  case "$STATE" in
    success)
      RESULT_JSON=$(echo "$RESPONSE" | /usr/bin/python3 -c "
import sys, json
d = json.load(sys.stdin)
rj = d.get('data', {}).get('resultJson', '{}')
print(rj)
" 2>/dev/null)

      URLS=$(echo "$RESULT_JSON" | /usr/bin/python3 -c "
import sys, json
d = json.loads(sys.stdin.read())
urls = d.get('resultUrls', [])
for u in urls:
    print(u)
" 2>/dev/null)

      if [ -z "$URLS" ]; then
        osascript -e "display notification \"タスク完了しましたが、URLが見つかりませんでした: $TASK_ID\" with title \"kie-ai\"" 2>/dev/null
        echo "[kie-ai] 完了しましたがURLが見つかりません"
        echo "$RESULT_JSON"
        exit 1
      fi

      /bin/mkdir -p "$DOWNLOAD_DIR"
      SAVED=()
      while IFS= read -r URL; do
        FILENAME="${TASK_ID}_$(basename "$URL" | cut -d'?' -f1)"
        DEST="$DOWNLOAD_DIR/$FILENAME"
        echo "[kie-ai] ダウンロード中: $URL"
        xh GET "$URL" --output "$DEST" 2>/dev/null
        SAVED+=("$DEST")
        echo "[kie-ai] 保存: $DEST"

        if [ -n "$COPY_TO" ]; then
          /bin/mkdir -p "$COPY_TO"
          /bin/cp "$DEST" "$COPY_TO/"
          echo "[kie-ai] コピー: $COPY_TO/$FILENAME"
        fi
      done <<< "$URLS"

      MSG="生成完了！${#SAVED[@]}件保存: $DOWNLOAD_DIR"
      osascript -e "display notification \"$MSG\" with title \"kie-ai\" sound name \"Glass\"" 2>/dev/null
      echo "[kie-ai] $MSG"
      exit 0
      ;;

    fail)
      FAIL_MSG=$(echo "$RESPONSE" | /usr/bin/python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('data',{}).get('failMsg','不明なエラー'))" 2>/dev/null)
      osascript -e "display notification \"生成失敗: $FAIL_MSG\" with title \"kie-ai\"" 2>/dev/null
      echo "[kie-ai] 失敗: $FAIL_MSG"
      exit 2
      ;;

    waiting|queuing|generating)
      # 経過時間に応じてインターバルを伸ばす（指数バックオフ）
      if [ $ELAPSED -gt 60 ]; then
        INTERVAL=15
      elif [ $ELAPSED -gt 30 ]; then
        INTERVAL=10
      fi
      sleep $INTERVAL
      ELAPSED=$((ELAPSED + INTERVAL))
      ;;

    *)
      echo "[kie-ai] 予期しない状態: $STATE"
      sleep $INTERVAL
      ELAPSED=$((ELAPSED + INTERVAL))
      ;;
  esac
done

osascript -e "display notification \"タイムアウト: $TASK_ID\" with title \"kie-ai\"" 2>/dev/null
echo "[kie-ai] タイムアウト (${MAX_WAIT}秒)"
exit 3
