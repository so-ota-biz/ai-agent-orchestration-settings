# PR Body Draft

## Related Issue / Ticket

https://github.com/so-ota-biz/ai-agent-orchestration-settings/issues/39

## Summary

Issue/Backlog チケットドリブン開発の成果物出力先をプロジェクト内 `docs/ai_work/` からホーム配下の共通ディレクトリ `~/docs/issue-driven/` に変更し、リポジトリ非依存で一元管理できるようにした。

## Technical Changes

- **成果物パス変更** (5ファイル):
  - GitHub: `<project-root>/docs/ai_work/` → `~/docs/issue-driven/<repo-name>/<issue-number>/`
  - Backlog: `<project-root>/docs/ai_work/` → `~/docs/issue-driven/<project-key>/<ticket-key>/`
- **`.github/PULL_REQUEST_TEMPLATE/issue-driven.md` 生成廃止**:
  - 既存のPRテンプレートがあればそれを優先、なければ `~/.agent/templates/issue-driven/pr-template.md` を直接参照

## Self-Decisions

- **Backlog のパス形式**: Issue に「要調査」とあったため、`https://{space}.backlog.com/view/{PROJECT_KEY}-{ISSUE_NUM}` の URL 構造から `~/docs/issue-driven/{project-key}/{ticket-key}/` を採用（`view/` セグメントは除外）。
- **PR テンプレートのプロジェクト内複製廃止**: 「Git 管理下に置きたくない」「既存テンプレートを優先」の要件をユーザーと確認後に設計を変更。生成ステップ自体を廃止し、正本テンプレートを直接参照する運用に変更。

## Verification

- TC-1: `grep -rn "docs/ai_work"` で旧パスの残存がゼロ ✅
- TC-2/3: 新パス記述が全5ファイルで一貫していることを確認 ✅
- TC-4: `~/.agent/templates/issue-driven/` への参照が維持されていることを確認 ✅
- TC-5: `~/.claude/CLAUDE.md` は `.agent/AGENTS.md` へのシンボリックリンクのため自動反映 ✅

## Notes

- `~/docs/issue-driven` ディレクトリは初回使用時に自動作成（Issue 明記の通り許可不要）
- 既存の `<project-root>/docs/ai_work/` 配下の過去の成果物は削除しない
