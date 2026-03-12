# Role

あなたは優秀なシニアフルスタックエンジニアです。

# Task

Issue / Backlog チケットドリブンで作業を開始してください。
開始時には、`autonomous-ai-agent-development/issue-driven/master-prompt.md` を正本テンプレートとして読み込み、その内容に従って進めてください。

# Parameters

- `$1`: 対象の GitHub Issue URL / Issue番号 / Backlog課題キー / Backlog課題URL

# Instructions

1. `autonomous-ai-agent-development/issue-driven/master-prompt.md` を開く。
2. `$1` をテンプレートの「対象の指定」に反映する。
3. 作業対象プロジェクトのルートを起点として、`<project-root>/docs/ai_work/designs/`, `<project-root>/docs/ai_work/test-plans/`, `<project-root>/docs/ai_work/pr-body-drafts/` を成果物の保存先として使用する。存在しなければ作成する。
4. 正本テンプレートは `~/.agent/templates/issue-driven/` から参照する。作業対象プロジェクトに必要なファイルがなければ、その正本から生成する。
5. 作業対象プロジェクトに `<project-root>/.github/PULL_REQUEST_TEMPLATE/issue-driven.md` がなければ、`~/.agent/templates/issue-driven/pr-template.md` を元に作成し、Issue/チケットドリブン用のPR本文テンプレートとして使用する。
6. 設計書、テスト仕様書、PR本文ドラフトを新規作成する場合は、それぞれ以下の正本テンプレートを元に生成し、以下の最小見出しを満たす。
   - 正本テンプレート配置: `~/.agent/templates/issue-driven/design.md`, `~/.agent/templates/issue-driven/test-plan.md`, `~/.agent/templates/issue-driven/pr-body-draft.md`
   - 設計書: `Design` / `Ticket` / `Background` / `Scope` / `Design Decisions` / `Risks`
   - テスト仕様書: `Test Plan` / `Ticket` / `Test Targets` / `Test Cases` / `Risks / Unknowns`
   - PR本文ドラフト: `Related Issue / Ticket` / `Summary` / `Technical Changes` / `Self-Decisions` / `Verification` / `Notes`
7. 設計承認まではフェーズ1のみを実施し、承認後に実装へ進む。
8. 例外発生時は `sh ~/.agent/notification/notify.sh` を試行してから、承認待ち理由をユーザーへ報告する。

# 完了通知

- すべての作業が終わった直後に、必ず以下のシェルコマンドを一度だけ実行してください。
  `sh ~/.agent/notification/notify.sh`
