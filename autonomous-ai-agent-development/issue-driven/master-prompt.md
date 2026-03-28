> **[テンプレート]** このファイルはテンプレートです。使用前に `[...]` で囲まれた箇所を実際の対象に置き換えてください。

# 指示：自律的開発サイクル（Issue読解〜PR作成）の実行

## 0. 基本原則と設定の尊重（最優先）

作業を開始する前に、以下の設定ファイルを順に確認・ロードし、そこに記載されたルールを本指示よりも優先して遵守せよ：

1. プロジェクトルートの `AGENTS.md` または `CLAUDE.md`（存在する場合）
2. ユーザーレベル（グローバル）の `AGENTS.md` または設定ファイル
3. 本プロンプトの指示
   これらのルールに矛盾がある場合は、プロジェクト固有の設定を最優先せよ。

## 1. 実行対象（Issue/チケットの指定）

設定済みのMCPツール（GitHub/Backlog用）を使用して以下の対象の内容を直接読み取り、仕様理解・設計・テスト・実装・PR作成までを完結させよ。

**対象の指定:**
[ここに GitHub URL、Issue番号、または Backlogの課題キーを入力。コピペした内容がある場合はそれも併記]

## 1-a. 成果物とテンプレートの管理規約

- 正本テンプレートは `~/.agent/templates/issue-driven/` から参照する。
- 成果物の保存先（`~/docs/issue-driven` が存在しなければ許可なく作成する）:
  - GitHub Issue の場合: `~/docs/issue-driven/<repo-name>/<issue-number>/`
  - Backlog チケットの場合: `~/docs/issue-driven/<project-key>/<ticket-key>/`

## 2. ワークフロー（フェーズ分割）

### フェーズ1：調査と設計（要承認）

- MCPツールを用いて対象Issueの最新の本文およびコメントを確認せよ。
- 現状のコードベースを分析し、変更方針（Design）とテスト計画（Test Plan）を策定せよ。
- 設計書は `~/.agent/templates/issue-driven/design.md` を元に `<ticket-id>-design.md`、テスト仕様書は `~/.agent/templates/issue-driven/test-plan.md` を元に `<ticket-id>-test-plan.md` として、上記の成果物保存先ディレクトリに生成して記録せよ。ディレクトリがなければ先に作成せよ。
- 設計書の最低限の見出しは `Design` / `Ticket` / `Background` / `Scope` / `Design Decisions` / `Risks` とする。
- テスト仕様書の最低限の見出しは `Test Plan` / `Ticket` / `Test Targets` / `Test Cases` / `Risks / Unknowns` とする。
- **記録後、実装に進まずに一旦停止し、設計の要約を報告して「設計・ブランチ作成・実装開始」の承認をユーザーから得るまで待て。この承認をもってブランチ作成の確認も兼ねる。**

### フェーズ2：自律実装と検証ループ

- 承認後、作業用ブランチを作成し実装に着手せよ。
- 「実装コード」と「テストコード」をセットで作成・修正せよ。
- テストが失敗した場合は、**最大5回を上限**に自律的にデバッグと修正を繰り返せ（AGENTS.md の修正ループ上限に従う）。5回を超えても解決しない場合は、試行錯誤の経緯と詰まっている箇所を整理して報告し、中断せよ。

### フェーズ3：成果物の提出（PR作成）

- 全ての検証をパスした後、コミットおよびプッシュを行い、プルリクエストを作成せよ。
- PR本文ドラフトは `~/.agent/templates/issue-driven/pr-body-draft.md` を元に `<ticket-id>-pr-body.md` として、上記の成果物保存先ディレクトリに生成して保存せよ。
- PR本文テンプレートは、`<project-root>/.github/` 配下に既存のPRテンプレートがあればそれを優先する。なければ `~/.agent/templates/issue-driven/pr-template.md` を雛形として直接参照して組み立てよ。プロジェクト内への複製・生成は行わない。
- PR本文ドラフトの最低限の見出しは `Related Issue / Ticket` / `Summary` / `Technical Changes` / `Self-Decisions` / `Verification` / `Notes` とする。
- 専用PRテンプレートの最低限の見出しは `Related Issue / Ticket` / `Summary` / `Technical Changes` / `Self-Decisions` / `Verification` / `Design / Test Docs` / `Notes` とする。
- PRの説明欄には、設定ファイルの報告ルールに基づき「技術的詳細」「自律判断した事項」「ビジネスインパクト」「検証結果」を明記せよ。

### 例外時の通知

- 計画外の仕様変更・アーキテクチャ変更、またはセキュリティ・本番環境に直接影響する変更が必要と判明した場合は、自律作業を中断する。
- 中断時は `sh ~/.agent/notification/notify.sh` を試行し、その後で承認待ち理由をユーザーへ報告する。

## 3. 開始の合図

まずは、プロジェクトおよびユーザー設定ファイルの読み込み、および**MCPツールによるIssue内容の取得完了**を報告し、初期調査の結果（影響範囲の特定）から開始せよ。
