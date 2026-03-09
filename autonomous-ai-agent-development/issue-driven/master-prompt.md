> **[テンプレート]** このファイルはテンプレートです。使用前に `[...]` で囲まれた箇所を実際の対象に置き換えてください。

# 指示：自律的開発サイクル（Issue読解〜PR作成）の実行

## 0. 基本原則と設定の尊重（最優先）

作業を開始する前に、以下の設定ファイルを順に確認・ロードし、そこに記載されたルールを本指示よりも優先して遵守せよ：

1. プロジェクトルートの `AGENTS.md` または `CLAUDE.md`（存在する場合）
2. ユーザーレベル（グローバル）の `AGENTS.md` または設定ファイル
3. 本プロンプトの指示
   これらのルールに矛盾がある場合は、プロジェクト固有の設定を最優先せよ。

## 1. 実行対象（Issue/チケットの特定）

以下の対象について、設定済みのMCPツール（GitHub/Backlog用）を使用して直接内容を読み取り、仕様理解・設計・テスト・実装・PR作成までを完結させよ。
成果物は作業対象プロジェクトのルートを起点として扱う。正本テンプレートは `~/.agent/templates/issue-driven/` から参照し、`<project-root>/docs/ai_work/` や `<project-root>/.github/PULL_REQUEST_TEMPLATE/issue-driven.md` がなければ、その正本から生成してから使用すること。このテンプレート自体を開始プロンプトとして使用すること。

**対象の指定:**
[ここに GitHub URL、Issue番号、または Backlogの課題キーを入力。コピペした内容がある場合はそれも併記]

## 2. ワークフロー（フェーズ分割）

### フェーズ1：調査と設計（要承認）

- MCPツールを用いて対象Issueの最新の本文およびコメントを確認せよ。
- 現状のコードベースを分析し、変更方針（Design）とテスト計画（Test Plan）を策定せよ。
- 設計書は `~/.agent/templates/issue-driven/design.md` を元に `<project-root>/docs/ai_work/designs/<ticket-id>-design.md` を生成し、テスト仕様書は `~/.agent/templates/issue-driven/test-plan.md` を元に `<project-root>/docs/ai_work/test-plans/<ticket-id>-test-plan.md` を生成して記録せよ。必要なディレクトリがなければ作成せよ。
- 設計書の最低限の見出しは `Design` / `Ticket` / `Background` / `Scope` / `Design Decisions` / `Risks` とする。
- テスト仕様書の最低限の見出しは `Test Plan` / `Ticket` / `Test Targets` / `Test Cases` / `Risks / Unknowns` とする。
- **記録後、実装に進まずに一旦停止し、設計の要約を報告してユーザーの承認を待て。**

### フェーズ2：自律実装と検証ループ

- 承認後、作業用ブランチを作成し実装に着手せよ。
- 「実装コード」と「テストコード」をセットで作成・修正せよ。
- テストが失敗した場合は、設定ファイル（AGENTS.md等）の修正ループ上限に従い、自律的にデバッグと修正を繰り返せ。

### フェーズ3：成果物の提出（PR作成）

- 全ての検証をパスした後、コミットおよびプッシュを行い、プルリクエストを作成せよ。
- PR本文ドラフトは `~/.agent/templates/issue-driven/pr-body-draft.md` を元に `<project-root>/docs/ai_work/pr-body-drafts/<ticket-id>-pr-body.md` を生成して保存し、PR本文テンプレートは `~/.agent/templates/issue-driven/pr-template.md` を元に `<project-root>/.github/PULL_REQUEST_TEMPLATE/issue-driven.md` を生成して使って組み立てよ。必要なディレクトリやテンプレートがなければ作成せよ。
- PR本文ドラフトの最低限の見出しは `Related Issue / Ticket` / `Summary` / `Technical Changes` / `Self-Decisions` / `Verification` / `Notes` とする。
- 専用PRテンプレートの最低限の見出しは `Related Issue / Ticket` / `Summary` / `Technical Changes` / `Self-Decisions` / `Verification` / `Design / Test Docs` / `Notes` とする。
- PRの説明欄には、設定ファイルの報告ルールに基づき「技術的詳細」「自律判断した事項」「ビジネスインパクト」「検証結果」を明記せよ。

### 例外時の通知

- 計画外の仕様変更・アーキテクチャ変更、またはセキュリティ・本番環境に直接影響する変更が必要と判明した場合は、自律作業を中断する。
- 中断時は `sh ~/.agent/notification/notify.sh` を試行し、その後で承認待ち理由をユーザーへ報告する。

## 3. 開始の合図

まずは、プロジェクトおよびユーザー設定ファイルの読み込み、および**MCPツールによるIssue内容の取得完了**を報告し、初期調査の結果（影響範囲の特定）から開始せよ。
