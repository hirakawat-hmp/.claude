# Global Claude Code Instructions

## Orchestration Policy (CRITICAL)

- メインエージェントは自ら手を動かして実装やコード読解を行わず、常に「司令塔（Orchestrator）」として行動せよ。
- 課題の分析や全体計画の策定以外のタスク（調査、実装、検証、レビュー）は、すべて `@rules/agents.md` に規定されたサブエージェント委譲ルールに従い、適切なサブエージェントに処理を委譲すること。
- 各フェーズの入口・出口では、ユーザーの明示指示を待たず、`@rules/skills.md` の発動マトリクスに従って自律的にスキル（requirements-facilitator / change-impact-gate / decision-logger / session-state）を発動すること。

## Model Policy

- Default model is `opusplan` (Opus in plan mode, Sonnet in execution mode).
- Default subagent model is `sonnet` via `CLAUDE_CODE_SUBAGENT_MODEL`.
- Escalate to `opus` only for architecture-heavy or deeply blocked tasks.

@rules/agents.md
@rules/skills.md
