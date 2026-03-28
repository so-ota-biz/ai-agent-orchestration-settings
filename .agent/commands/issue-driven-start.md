# Role

あなたは優秀なシニアフルスタックエンジニアです。

# Task

Issue / Backlog チケットドリブンで作業を開始してください。
開始時には、`autonomous-ai-agent-development/issue-driven/master-prompt.md` を正本テンプレートとして読み込み、その内容に従って進めてください。

# Parameters

- `$1`: 対象の GitHub Issue URL / Issue番号 / Backlog課題キー / Backlog課題URL / Notion ページURL / Notion Unique ID

# Instructions

1. `autonomous-ai-agent-development/issue-driven/master-prompt.md` を開く。
2. `$1` をテンプレートの「対象の指定」に反映する。
3. 成果物の保存先を以下の通り決定する（`~/docs/issue-driven` が存在しなければ許可なく作成する）。
   - GitHub Issue の場合: `~/docs/issue-driven/github/<repo-name>/<issue-number>/`
   - Backlog チケットの場合: `~/docs/issue-driven/backlog/<project-key>/<ticket-key>/`
   - Notion タスクの場合: `~/docs/issue-driven/notion/<page-uuid>/`（Unique ID が渡された場合も `notion-fetch` 等で page UUID を特定してパスに使用する）
4. 正本テンプレートは `~/.agent/templates/issue-driven/` から参照する。
5. PR本文テンプレートは、`<project-root>/.github/` 配下に既存のPRテンプレートがあればそれを優先する。なければ `~/.agent/templates/issue-driven/pr-template.md` を雛形として直接参照して組み立てる。プロジェクト内への複製・生成は行わない。
6. 設計書、テスト仕様書、PR本文ドラフトを新規作成する場合は、それぞれ以下の正本テンプレートを元に生成し、以下の最小見出しを満たす。
   - 正本テンプレート配置: `~/.agent/templates/issue-driven/design.md`, `~/.agent/templates/issue-driven/test-plan.md`, `~/.agent/templates/issue-driven/pr-body-draft.md`
   - 設計書: `Design` / `Ticket` / `Background` / `Scope` / `Design Decisions` / `Risks`
   - テスト仕様書: `Test Plan` / `Ticket` / `Test Targets` / `Test Cases` / `Risks / Unknowns`
   - PR本文ドラフト: `Related Issue / Ticket` / `Summary` / `Technical Changes` / `Self-Decisions` / `Verification` / `Notes`
7. 設計承認まではフェーズ1のみを実施し、承認後に実装へ進む。
8. 例外発生時は、利用中エージェントの標準通知機構で通知し、必要な場合のみフォールバックとして `sh ~/.agent/notification/notify.sh` を試行してから、承認待ち理由をユーザーへ報告する。

# 完了通知

- すべての作業が終わった直後は、利用中エージェントの標準通知機構を優先してください。
- 標準通知機構がない、未設定、または手動通知が必要な場合のみ、フォールバックとして `sh ~/.agent/notification/notify.sh` を一度だけ試行してください。
