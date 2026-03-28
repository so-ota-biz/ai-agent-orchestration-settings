# Design

## Ticket

[GitHub Issue #39](https://github.com/so-ota-biz/ai-agent-orchestration-settings/issues/39)

## Background

Issue/Backlog チケットドリブン開発の成果物（設計書・テスト仕様書・PR本文ドラフト）は、現状では各作業対象プロジェクト内の `<project-root>/docs/ai_work/` に出力される。

この設計では、成果物をプロジェクト外のホームディレクトリ配下の共通ディレクトリ `~/docs/issue-driven/` に一元管理する変更を行う。

**変更前:**
```
<project-root>/docs/ai_work/designs/<ticket-id>-design.md
<project-root>/docs/ai_work/test-plans/<ticket-id>-test-plan.md
<project-root>/docs/ai_work/pr-body-drafts/<ticket-id>-pr-body.md
```

**変更後:**
```
~/docs/issue-driven/<repo-name>/<issue-number>/<ticket-id>-design.md       (GitHub)
~/docs/issue-driven/<project-key>/<ticket-key>/<ticket-id>-design.md       (Backlog)
```

## Scope

### 変更対象ファイル

| ファイル | 変更箇所 |
|---------|---------|
| `.agent/AGENTS.md` | 成果物パス記述 6箇所 |
| `autonomous-ai-agent-development/issue-driven/master-prompt.md` | 成果物パス記述 3箇所 |
| `.agent/commands/issue-driven-start.md` | 成果物パス記述 3箇所 |
| `.agent/templates/issue-driven/pr-template.md` | コメント内パス記述 1箇所 |
| `README.md` | 運用モード説明内パス記述 2箇所 |

### 変更しないもの

- 正本テンプレートの配置場所 (`~/.agent/templates/issue-driven/`)
- ファイル名の命名規則（`<ticket-id>-design.md` 等）

### `.github/PULL_REQUEST_TEMPLATE/issue-driven.md` の廃止

- **目的**: PRを所定のテンプレートに沿って作成する
- **制約**: テンプレートをGit管理下（`<project-root>/.github/`）に置きたくない
- **優先ルール**: 作業対象リポジトリに既存のPRテンプレートがあればそれを優先

上記を踏まえ、プロジェクト内への `issue-driven.md` 生成を廃止する。

## Design Decisions

### 1. ディレクトリ構造（GitHub）

```
~/docs/issue-driven/{repo-name}/{issue-number}/
  {issue-number}-design.md
  {issue-number}-test-plan.md
  {issue-number}-pr-body.md
```

- `{repo-name}`: GitHub リポジトリ名（owner は含まない）
- `{issue-number}`: Issue番号（例: `39`）

### 2. ディレクトリ構造（Backlog）

Issue では "要調査" と記載されているが、Backlog の一般的な URL 形式
`https://{space}.backlog.com/view/{PROJECT_KEY}-{ISSUE_NUM}` を元に以下の構造を採用する：

```
~/docs/issue-driven/{project-key}/{ticket-key}/
  {ticket-key}-design.md
  {ticket-key}-test-plan.md
  {ticket-key}-pr-body.md
```

- `{project-key}`: Backlog プロジェクトキー（例: `MYPROJ`）
- `{ticket-key}`: チケットキー（例: `MYPROJ-42`）

これは Issue の「Backlog チケットURL のプロジェクト以下」という表現に基づく合理的な解釈であり、URL の `/view/{PROJECT_KEY}-{ISSUE_NUM}` の部分から `view/` を除いて階層化したもの。

### 3. ディレクトリ自動作成

Issue に明記された通り、`~/docs/issue-driven` が存在しなければユーザー確認なしに作成してよい。サブディレクトリも同様に自動作成する。

### 4. PR テンプレートの扱い

プロジェクト内への `issue-driven.md` 生成は行わない。代わりに以下の優先順位で使用する：

1. `<project-root>/.github/pull_request_template.md` または `<project-root>/.github/PULL_REQUEST_TEMPLATE/` 配下に既存のPRテンプレートがある場合 → それを優先
2. 既存テンプレートがない場合 → `~/.agent/templates/issue-driven/pr-template.md` を雛形として直接参照して組み立てる

## Risks

- **他プロジェクトへの影響なし**: 変更対象は設定ファイルとドキュメントのみ。実装コードへの影響はない。
- **既存の `docs/ai_work/` への影響**: 過去の成果物はそのまま残る（削除しない）。新規作業から新パスが適用される。
- **Backlog パスの解釈**: "要調査" とあるため、上記の解釈が意図と異なる可能性がある。実装後に確認推奨。
- **既存PRテンプレートの検出**: `<project-root>/.github/` 配下の複数パターン（`pull_request_template.md`、`PULL_REQUEST_TEMPLATE/*.md`）を確認する必要がある。
