#!/usr/bin/env bash
# session-start.sh
# SessionStart hook: プロジェクトの STATE.md を読み込み、セッションコンテキストに注入する
# stdout の内容は additionalContext として Claude に渡される

set -euo pipefail

# --- 入力を一度読み込む ---
input="$(cat)"

# --- JSON パース: cwd を取得 ---
# jq があれば jq を、なければ python3 を使う
_json_get() {
  local key="$1"
  local data="$2"
  if command -v jq &>/dev/null 2>&1; then
    echo "$data" | jq -r ".${key} // empty" 2>/dev/null || true
  else
    python3 -c "
import sys, json
key = sys.argv[1]
data = sys.argv[2]
try:
    obj = json.loads(data)
    val = obj
    for part in key.split('.'):
        if part and isinstance(val, dict):
            val = val.get(part, '')
        elif part:
            val = ''
    print(val if val is not None else '')
except Exception:
    print('')
" "$key" "$data" 2>/dev/null || true
  fi
}

# --- JSON 出力 ---
_json_output() {
  local ctx="$1"
  local _fallback='{"hookSpecificOutput":{"hookEventName":"SessionStart"}}'
  if command -v jq &>/dev/null 2>&1; then
    if [ -n "$ctx" ]; then
      jq -n --arg ctx "$ctx" '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$ctx}}' 2>/dev/null \
        || python3 -c "
import sys, json
ctx = sys.argv[1] if len(sys.argv) > 1 else ''
if ctx:
    result = {'hookSpecificOutput': {'hookEventName': 'SessionStart', 'additionalContext': ctx}}
else:
    result = {'hookSpecificOutput': {'hookEventName': 'SessionStart'}}
print(json.dumps(result, ensure_ascii=False, indent=2))
" "$ctx" 2>/dev/null \
        || echo "$_fallback"
    else
      jq -n '{hookSpecificOutput:{hookEventName:"SessionStart"}}' 2>/dev/null \
        || echo "$_fallback"
    fi
  else
    python3 -c "
import sys, json
ctx = sys.argv[1] if len(sys.argv) > 1 else ''
if ctx:
    result = {'hookSpecificOutput': {'hookEventName': 'SessionStart', 'additionalContext': ctx}}
else:
    result = {'hookSpecificOutput': {'hookEventName': 'SessionStart'}}
print(json.dumps(result, ensure_ascii=False, indent=2))
" "$ctx" 2>/dev/null \
      || echo "$_fallback"
  fi
}

cwd="$(_json_get "cwd" "$input")"

# cwd が取得できなかった場合は pwd にフォールバック
if [ -z "$cwd" ]; then
  cwd="$(pwd)"
fi

# --- Git 情報の取得 ---
git_info=""
if command -v git &>/dev/null 2>&1; then
  git_branch="$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  git_log="$(git -C "$cwd" log --oneline -3 2>/dev/null || true)"

  if [ -n "$git_branch" ] || [ -n "$git_log" ]; then
    git_info="## Environment"$'\n'
    if [ -n "$git_branch" ]; then
      git_info+="- Branch: ${git_branch}"$'\n'
    fi
    if [ -n "$git_log" ]; then
      git_info+="- Recent commits:"$'\n'
      git_info+="\`\`\`"$'\n'
      while IFS= read -r line; do
        git_info+="${line}"$'\n'
      done <<< "$git_log"
      git_info+="\`\`\`"$'\n'
    fi
  fi
fi

# --- STATE.md の存在確認と本文構築 ---
state_file="${cwd}/.claude/STATE.md"
claude_dir="${cwd}/.claude"
additional_context=""

if [ -f "$state_file" ]; then
  # STATE.md が存在する場合: 全文を読み込む
  state_content="$(cat "$state_file" 2>/dev/null || true)"
  additional_context="# セッション引き継ぎ情報

以下は前回セッションの STATE.md です:

${state_content}"
elif [ -d "$claude_dir" ]; then
  # .claude ディレクトリはあるが STATE.md がない場合: ヒントを出す
  additional_context="# セッション引き継ぎ情報

このプロジェクトには STATE.md がありません。作業終了時に session-state スキルで STATE.md を作成すると、次回以降のセッションで作業状態が自動的に引き継がれます。"
fi

# git 情報を追記
if [ -n "$git_info" ]; then
  if [ -n "$additional_context" ]; then
    additional_context="${additional_context}

${git_info}"
  else
    additional_context="${git_info}"
  fi
fi

# --- JSON 出力 ---
_json_output "$additional_context" || true

exit 0
