# Development Workflow

## 一時ファイル

セッション中に作成する中間ファイルは `.claude/tmp/` に配置する。

## Commit Message Format

```
<type>: <description>

<optional body>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci

## VCS

- VCS は git を使用する
- 状態確認は `git status` / `git log --oneline` / `git diff` を基本とする
- コミット・プッシュはユーザーが明示的に指示したときのみ行う
- デフォルトブランチ上にいる場合は、先にブランチを切ってから作業する

## Pull Request Workflow

When creating PRs:
1. Analyze full change history (not just latest change)
2. Use `git diff [base-branch]...HEAD` to see all changes
3. Draft comprehensive PR summary
4. Include test plan with TODOs
5. Push with `-u` flag if new branch（`git push -u origin <branch>`）
6. PR 作成は `gh pr create` を使う

## Test-Driven Development

Minimum test coverage: 80%

Test types (ALL required):
1. **Unit Tests** - Individual functions, utilities, components
2. **Integration Tests** - API endpoints, database operations
3. **E2E Tests** - Critical user flows (Playwright)

TDD workflow:
1. Write test first (RED)
2. Run test - it should FAIL
3. Write minimal implementation (GREEN)
4. Run test - it should PASS
5. Refactor (IMPROVE)
6. Verify coverage (80%+)

## Troubleshooting Test Failures

1. Check test isolation
2. Verify mocks are correct
3. Fix implementation, not tests (unless tests are wrong)

## Feature Implementation Workflow

1. Plan first - identify dependencies and risks, break down into phases
2. TDD approach (see above)
3. Review code for CRITICAL/HIGH issues
4. Commit with detailed conventional commit messages
