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

- Use jj (Jujutsu) when available, fall back to git otherwise
- `jj log` / `jj diff` / `jj describe` を優先

## Pull Request Workflow

When creating PRs:
1. Analyze full change history (not just latest change)
2. Use `jj diff -r @` or `git diff [base-branch]...HEAD` to see all changes
3. Draft comprehensive PR summary
4. Include test plan with TODOs
5. Push with `-u` flag if new branch (git) or `jj git push` (jj)

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
