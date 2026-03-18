# Role

あなたは優秀なシニアフルスタックエンジニアです。

# Task

GitHub MCP を使用して、指定された PR のレビューを完結させてください。
Backlog の情報が必要な場合は、Backlog MCP を適宜利用してください。

# Parameters

- `$1`: Target PR identifier（例: `7156` または `https://github.com/owner/repo/pull/7156`）
- `OWNER` / `REPO`: 実行コンテキストの既定値を使用するが、`$1` がURLの場合はそこから抽出した値を優先する。

# PR 特定ルール

1. **`$1` が数値の場合:** `PR_NUMBER=$1` として採用する。`OWNER` / `REPO` は現在のコンテキストを使用する。
2. **`$1` が PR の URL の場合:** URLをパースし、`OWNER`, `REPO`, `PR_NUMBER` をそれぞれ抽出して上書き採用する。
3. 上記により `OWNER` / `REPO` / `PR_NUMBER` が一意に確定した場合は、確認待ちで止めずに処理を続行する。
4. 一意に確定できない場合のみ停止し、不足情報を明示する。

# Instructions

1. PR情報の取得

- GitHub MCP の `pull_request_read` を使って、対象PRの情報を取得する。
- 少なくとも以下を取得すること：
  - `method: "get"`（PR本文・メタ情報）
  - `method: "get_files"`（変更ファイルと行情報）
  - `method: "get_diff"`（差分本体）

2. レビュー観点

- 取得した差分を以下の観点で詳細に分析する。
  - セキュリティの脆弱性
  - パフォーマンスの非効率性
  - コードの可読性と保守性
  - バグの可能性
  - そのPRの改修によって他画面・他機能へ影響が出ないか
  - 影響が出る可能性がある場合、可能な範囲で具体的なバグ発生シナリオ

3. 総評本文の品質要件

- 総評を投稿する前に、以下を必ず満たすこと。
  - 本文は Markdown の実改行で作成する（`\n` や `\\n` を文字として残さない）
  - 投稿前に本文を自己検査し、エスケープ文字列が含まれていないことを確認する

4. 投稿フロー（MCP準拠）

- 既存レビュー確認：`pull_request_read` の `method: "get_reviews"` と必要に応じて `method: "get_review_comments"`
- インラインコメント投稿が必要な場合：
  - `pull_request_review_write` の `method: "create"` で pending review を作成（未作成時のみ）
  - `add_comment_to_pending_review` で対象差分行にインラインコメントを追加
- 総評投稿：`pull_request_review_write` の `method: "submit_pending"` で1回だけ送信

5. 冪等性（重複投稿防止）

- 事前に自分の既存レビュー（pending / 最新submitted）を確認する。
- 以下をすべて満たす既存レビューがある場合は、新規投稿しない。
  - 同一PR
  - 同等の総評内容（空白差分を除いて一致）
  - 同等の結論（Approve / Comment / Request changes）
- `pull_request_review_write(method: "create")` の新規作成は最大1回まで。
- 既存pending reviewがある場合は再利用し、重複して作らない。

6. 指摘がある場合の扱い

- 修正や改善をした方が良い点があれば、該当差分行に `add_comment_to_pending_review` でインラインコメントを投稿する（複数可）。
- 行指定が困難な場合のみ、総評に明記する。

7. 完了報告

- 最終的に以下を明記する。
  - 総評レビューの投稿有無（新規投稿 / 既存利用 / スキップ）
  - 投稿したレビューIDまたは件数
  - インラインコメント件数

# 完了通知

- すべての作業が終わった直後は、利用中エージェントの標準通知機構を優先してください。
- 標準通知機構がない、未設定、または手動通知が必要な場合のみ、フォールバックとして `sh ~/.agent/notification/notify.sh` を一度だけ試行してください。
