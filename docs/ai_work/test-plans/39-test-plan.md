# Test Plan

## Ticket

[GitHub Issue #39](https://github.com/so-ota-biz/ai-agent-orchestration-settings/issues/39)

## Test Targets

変更対象はすべてドキュメント・設定ファイルのみ（実行コードなし）。

- `.agent/AGENTS.md`
- `autonomous-ai-agent-development/issue-driven/master-prompt.md`
- `.agent/commands/issue-driven-start.md`
- `.agent/templates/issue-driven/pr-template.md`
- `README.md`

## Test Cases

### TC-1: パスの完全置換確認

**手順:** 変更後、`grep -r "docs/ai_work" .` を実行する
**期待値:** 旧パス `<project-root>/docs/ai_work/` の残存がゼロであること

### TC-2: 新パス記述の一貫性確認（GitHub）

**手順:** 各ファイルの変更後内容を目視確認
**期待値:**
- GitHub向けパスが `~/docs/issue-driven/{repo-name}/{issue-number}/` の形式で統一されていること
- ファイル名は `{issue-number}-design.md` / `{issue-number}-test-plan.md` / `{issue-number}-pr-body.md` と記述されていること

### TC-3: 新パス記述の一貫性確認（Backlog）

**手順:** 各ファイルの変更後内容を目視確認
**期待値:**
- Backlog向けパスが `~/docs/issue-driven/{project-key}/{ticket-key}/` の形式で統一されていること

### TC-4: 変更しないパスが維持されていること

**手順:** 各ファイルを確認
**期待値:**
- `~/.agent/templates/issue-driven/` への参照が維持されていること
- `<project-root>/.github/PULL_REQUEST_TEMPLATE/issue-driven.md` への参照が維持されていること

### TC-5: AGENTS.md の symlink 反映確認

**手順:** `~/.claude/CLAUDE.md` の内容を確認（symlink 先が `.agent/AGENTS.md`）
**期待値:** symlink 経由で新パスが反映されていること

## Risks / Unknowns

- **Backlog パス形式**: Issue に "要調査" とあり、実際の Backlog URL 形式の確認が必要な場合がある
- **手動検証のみ**: 設定ファイル変更のため自動テストは存在しない。すべて目視確認
