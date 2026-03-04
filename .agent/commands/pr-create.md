# Role

あなたは優秀なシニアフルスタックエンジニアです。

# Goal

現在 checkout 中の作業ブランチ（リモートに push 済み）を使って、GitHub MCP 経由で Pull Request を作成する。
Backlog の情報が必要な場合は、Backlog MCP を適宜利用してください。

# Git操作ルール（厳守）

- タスク内の **すべての Git 関連作業は GitHub MCP を使う**。
- ただし、ローカルで現在ブランチ名を確認する `git branch --show-current` だけは許可なしで実行してよい。
- ローカル差分は信用せず、**必ずリモートのブランチ状態を基準**に差分・本文を作成する。

# 前提

- リポジトリ: `<owner>/<repo>`
- ベースブランチ: `<main または develop>`
- 現在ブランチ: `git branch --show-current` の結果

# 実施手順

1. `git branch --show-current` で現在ブランチ名を取得する。
2. GitHub MCP で対象リポジトリとブランチの存在を確認する。
3. GitHub MCP でベースブランチとの差分（コミット/変更ファイル/要点）を確認する。
4. PR タイトルを **Conventional Commits 形式**（`feat:`, `fix:`, `chore:` など）で作成する。
5. PR本文テンプレートはプロンプトに直書きせず、**`.github/pull_request_template.md` を参照**して作成する。
6. GitHub MCP で PR を作成する。
7. 作成した PR URL を報告する。

# PR本文作成ルール（重要）

- `.github/pull_request_template.md` の見出し構造に準拠する。
- テンプレート内の案内文としての `>` 行（blockquote のプレースホルダ）は、**本文では使用しない**。
- 各セクションは、以下のように **通常のテキスト**で記載する。
  - 例（NG）: `> 影響なし（...）`
  - 例（OK）: `影響なし（...）`
- 情報がない項目はルールに従って `なし` または `未記載` と明記する。
- 起因 issue の Backlog チケットが不明な場合は空欄でよい。
- 事実ベースで簡潔に記載し、推測は書かない。

# 出力要件

- 最終報告には以下を含める。
  - 現在ブランチ名
  - ベースブランチ
  - 差分サマリ（変更ファイルと要点）
  - PRタイトル
  - PR URL

# 完了通知

- すべての作業が終わった直後に、必ず以下のシェルコマンドを一度だけ実行してください。
  `sh ~/.agent/notification/notify.sh`
