# ai-agent-orchestration-settings

このリポジトリのコンセプトは、どの端末でもこのリポジトリをクローンして適切なシンボリックリンクを貼るだけで、Claude Code、Codex CLI、Gemini CLI の設定（skills / commands / 共通ルール運用を含む）を再現できる状態を作ることです。

## ディレクトリ構造

```
ai-agent-orchestration-settings/
├── .agent/                      # 共通リソース
│   ├── AGENTS.md                # 共通ルール
│   ├── skills/                  # 共通スキル（Codex/Claude/Gemini対応）
│   ├── commands/                # 共通カスタムコマンド（Codex/Claude/Gemini対応）
│   ├── templates/
│   │   └── issue-driven/        # Issue/チケットドリブン用の正本テンプレート
│   └── notification/
│       └── notify.sh            # クロスプラットフォーム通知スクリプト
├── .claude/
│   ├── mcp.json                 # Claude Code MCP サーバー設定
│   └── settings.json            # Claude Code セキュリティ設定
├── .codex/
│   └── config.shared.toml       # Codex 共有設定（セキュリティ設定含む）
├── .gemini/
│   └── settings.json            # Gemini CLI セキュリティ設定
├── .github/
│   └── pull_request_template.md # この設定リポジトリ自身の通常PRテンプレート
├── docs/
│   ├── claude/
│   │   └── SETTINGS_GUIDE.md    # Claude Code 設定ガイド
│   ├── codex/
│   │   └── SETTINGS_GUIDE.md    # Codex CLI 設定ガイド
│   └── gemini/
│       └── SETTINGS_GUIDE.md    # Gemini CLI 設定ガイド
├── autonomous-ai-agent-development/
│   └── issue-driven/
│       └── master-prompt.md     # Issue/チケットドリブン開発の開始テンプレート
├── prompts/                     # 人間向けドキュメント用
└── scripts/
    ├── check-and-cleanup.sh     # クリーンアップ確認スクリプト
    ├── setup-mcp.sh             # Claude Code MCP設定同期スクリプト
    └── sync-codex-config.sh     # Codex設定同期スクリプト
```

## 使い方

### 運用モード

- **通常指示**: `.agent/AGENTS.md` の通常指示ルールに従って作業します。PR本文は `.github/pull_request_template.md` を使います。
- **Issue/チケットドリブン開発**: `.agent/AGENTS.md` の Issue/チケットドリブン開発ルールに従い、開始時に `.agent/commands/issue-driven-start.md` または `autonomous-ai-agent-development/issue-driven/master-prompt.md` を使います。
- このリポジトリは**共通設定を配布するためのリポジトリ**であり、Issue/チケットドリブン開発で使う正本テンプレートは `.agent/templates/issue-driven/` に置きます。
- 実際に作業対象プロジェクトへ出力する成果物や専用PRテンプレートは、`~/.agent/templates/issue-driven/` の正本テンプレートを元に `<project-root>` 配下へ生成して使います。
- Issue/チケットドリブン開発の成果物は `<project-root>/docs/ai_work/designs/`、`<project-root>/docs/ai_work/test-plans/`、`<project-root>/docs/ai_work/pr-body-drafts/` に保存し、存在しなければ作成します。
- Issue/チケットドリブン開発のPR本文は `~/.agent/templates/issue-driven/pr-template.md` を元に `<project-root>/.github/PULL_REQUEST_TEMPLATE/issue-driven.md` を生成して使います。
- 例外条件に入った場合は、利用中エージェントの標準通知機構を優先し、必要な場合のみ `sh ~/.agent/notification/notify.sh` をフォールバックとして試行してから承認待ちを通知します。

### 1. クローン

```bash
git clone https://github.com/so-ota-biz/ai-agent-orchestration-settings.git
```

### 2. スクリプトの実行権限確認（重要）

クローン直後に、スクリプトファイルに実行権限が付与されているか確認します。

```bash
# 例: ホームディレクトリにクローンした場合
cd ~/ai-agent-orchestration-settings

# 絶対パスで指定する場合
cd /path/to/ai-agent-orchestration-settings
```

権限を確認：

```bash
ls -la scripts/
```

`check-and-cleanup.sh`、`setup-mcp.sh`、`sync-codex-config.sh` が `-rwxr-xr-x` になっていれば OK です。

実行権限がない場合（`-rw-r--r--` など）は、以下を実行してください：

```bash
chmod +x scripts/check-and-cleanup.sh scripts/setup-mcp.sh scripts/sync-codex-config.sh
```

**注意**: 通常、Gitリポジトリには実行権限が含まれているため、このステップは不要です。ただし、環境によっては権限が保持されない場合があるため、念のため確認することを推奨します。

### 3. ディレクトリ準備

```bash
mkdir -p ~/.codex ~/.claude ~/.gemini ~/.agent ~/.agent/notification ~/.local/bin
```

### 4. PATH 設定の確認

`~/.local/bin` にパスが通っていない場合は、`~/.bashrc` や `~/.zshrc` などに次を追加してください。

```bash
export PATH="$HOME/.local/bin:$PATH"
```

設定後は、シェルを再起動するか以下を実行してください。

```bash
source ~/.bashrc  # または source ~/.zshrc
```

### 5. クリーンアップ確認（重要）

シンボリックリンクを作成する前に、既存の設定との衝突を確認・解消します。

#### 自動チェックスクリプトの実行（推奨）

```bash
# 例: ホームディレクトリにクローンした場合
bash ~/ai-agent-orchestration-settings/scripts/check-and-cleanup.sh

# 絶対パスで指定する場合
bash /path/to/ai-agent-orchestration-settings/scripts/check-and-cleanup.sh
```

このスクリプトは以下を実行します：

1. **チェック対象**: 作成予定のシンボリックリンク先（`~/.codex/skills`, `~/.claude/commands`, `~/.gemini/GEMINI.md`, `~/.gemini/settings.json` など）
2. **判定ロジック**:
   - 存在しない → ✓ OK（そのままリンク作成可能）
   - シンボリックリンク → ⚠ 削除可能（確認後に自動削除）
   - 空のディレクトリ → ⚠ 削除可能（確認後に自動削除）
   - 空でないディレクトリ → ✗ 手動整理が必要（警告して停止）
   - ファイル → ✗ 手動整理が必要（警告して停止）

3. **結果**:
   - すべてクリーンな場合 → 次のステップへ進める
   - 自動削除可能な項目がある場合 → 確認後に削除
   - 手動整理が必要な場合 → 該当パスを表示して停止

#### 手動確認（スクリプトを使わない場合）

以下のパスを手動で確認してください：

```bash
ls -la ~/.codex/AGENTS.md
ls -la ~/.codex/skills
ls -la ~/.codex/prompts
ls -la ~/.codex/config.shared.toml
ls -la ~/.claude/CLAUDE.md
ls -la ~/.claude/skills
ls -la ~/.claude/commands
ls -la ~/.claude/settings.json
ls -la ~/.gemini/GEMINI.md
ls -la ~/.gemini/skills
ls -la ~/.gemini/commands
ls -la ~/.gemini/settings.json
ls -la ~/.agent/notification/notify.sh
ls -la ~/.agent/templates
ls -la ~/.local/bin/setup-mcp
ls -la ~/.local/bin/sync-codex-config
```

**既存のファイル・ディレクトリがある場合の対処:**

```bash
# シンボリックリンクや空ディレクトリの削除
rm ~/.codex/skills
# または
rmdir ~/.codex/skills

# 空でないディレクトリの場合は、内容を確認して手動で整理
ls -la ~/.codex/skills
# バックアップを取るなど、必要に応じて対処
mv ~/.codex/skills ~/.codex/skills.backup
```

**重要**: 空でないディレクトリがある場合、既存の設定が存在します。必要に応じてバックアップを取り、内容を確認してから削除してください。

---

クリーンアップが完了したら、次のステップに進んでください。

### 6. 共通リソースのリンク

`.agent` 配下の共通リソースを Codex、Claude Code、Gemini CLI の3つのツールにリンクします。

#### 共通ルールのリンク

```bash
# 例: ホームディレクトリにクローンした場合
ln -s ~/ai-agent-orchestration-settings/.agent/AGENTS.md ~/.codex/AGENTS.md
ln -s ~/ai-agent-orchestration-settings/.agent/AGENTS.md ~/.claude/CLAUDE.md
ln -s ~/ai-agent-orchestration-settings/.agent/AGENTS.md ~/.gemini/GEMINI.md

# 絶対パスで指定する場合
ln -s /path/to/ai-agent-orchestration-settings/.agent/AGENTS.md ~/.codex/AGENTS.md
ln -s /path/to/ai-agent-orchestration-settings/.agent/AGENTS.md ~/.claude/CLAUDE.md
ln -s /path/to/ai-agent-orchestration-settings/.agent/AGENTS.md ~/.gemini/GEMINI.md
```

#### 共通スキルのリンク

```bash
# 例: ホームディレクトリにクローンした場合
ln -s ~/ai-agent-orchestration-settings/.agent/skills ~/.codex/skills
ln -s ~/ai-agent-orchestration-settings/.agent/skills ~/.claude/skills
ln -s ~/ai-agent-orchestration-settings/.agent/skills ~/.gemini/skills

# 絶対パスで指定する場合
ln -s /path/to/ai-agent-orchestration-settings/.agent/skills ~/.codex/skills
ln -s /path/to/ai-agent-orchestration-settings/.agent/skills ~/.claude/skills
ln -s /path/to/ai-agent-orchestration-settings/.agent/skills ~/.gemini/skills
```

#### 共通カスタムコマンドのリンク

```bash
# 例: ホームディレクトリにクローンした場合
ln -s ~/ai-agent-orchestration-settings/.agent/commands ~/.codex/prompts
ln -s ~/ai-agent-orchestration-settings/.agent/commands ~/.claude/commands
ln -s ~/ai-agent-orchestration-settings/.agent/commands ~/.gemini/commands

# 絶対パスで指定する場合
ln -s /path/to/ai-agent-orchestration-settings/.agent/commands ~/.codex/prompts
ln -s /path/to/ai-agent-orchestration-settings/.agent/commands ~/.claude/commands
ln -s /path/to/ai-agent-orchestration-settings/.agent/commands ~/.gemini/commands
```

**注意:** Codex では `prompts` ディレクトリ、Claude Code と Gemini CLI では `commands` ディレクトリとして認識されますが、実体は同じ `.agent/commands` を参照します。

#### 共通通知スクリプトのリンク

標準通知機構が使えない場合の共通フォールバック通知スクリプトとして利用するため、以下のリンクを作成します。

```bash
# 例: ホームディレクトリにクローンした場合
ln -s ~/ai-agent-orchestration-settings/.agent/notification/notify.sh ~/.agent/notification/notify.sh

# 絶対パスで指定する場合
ln -s /path/to/ai-agent-orchestration-settings/.agent/notification/notify.sh ~/.agent/notification/notify.sh
```

#### 共通テンプレートのリンク

Issue/チケットドリブン開発で使う正本テンプレートを `~/.agent/templates` から参照できるようにします。

```bash
# 例: ホームディレクトリにクローンした場合
ln -s ~/ai-agent-orchestration-settings/.agent/templates ~/.agent/templates

# 絶対パスで指定する場合
ln -s /path/to/ai-agent-orchestration-settings/.agent/templates ~/.agent/templates
```

### 7. セキュリティ設定のリンク（重要）

#### Claude Code のセキュリティ設定

**Unix/Linux/macOS の場合:**

```bash
# 例: ホームディレクトリにクローンした場合
ln -s ~/ai-agent-orchestration-settings/.claude/settings.json ~/.claude/settings.json

# 絶対パスで指定する場合
ln -s /path/to/ai-agent-orchestration-settings/.claude/settings.json ~/.claude/settings.json
```

**Windows (PowerShell) の場合:**

```powershell
# 例: ホームディレクトリにクローンした場合（管理者権限不要）
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\settings.json" -Value "$env:USERPROFILE\ai-agent-orchestration-settings\.claude\settings.json"

# 絶対パスで指定する場合
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\settings.json" -Value "C:\path\to\ai-agent-orchestration-settings\.claude\settings.json"
```

**Windows (コマンドプロンプト) の場合:**

```cmd
:: 管理者権限で実行
:: 例: ホームディレクトリにクローンした場合
mklink "%USERPROFILE%\.claude\settings.json" "%USERPROFILE%\ai-agent-orchestration-settings\.claude\settings.json"

:: 絶対パスで指定する場合
mklink "%USERPROFILE%\.claude\settings.json" "C:\path\to\ai-agent-orchestration-settings\.claude\settings.json"
```

**注意**:

- PowerShell の場合、通常は管理者権限は不要ですが、環境によっては必要な場合があります
- コマンドプロンプトの `mklink` は管理者権限が必要です
- Windows でシンボリックリンクが作成できない場合は、ファイルを直接コピーする方法もあります（ただし、リポジトリの変更が自動反映されません）

**設定内容**:

- パーミッションバイパスモードの無効化
- 機密ファイルへのアクセス拒否（`.env`, `.ssh`, `.aws`など）
- 破壊的Git操作の拒否（`git reset --hard`, `git push --force`など）
- 危険なファイル操作の拒否（`rm -rf`など）
- ネットワーク経由の任意コード実行防止

詳細は `docs/claude/SETTINGS_GUIDE.md` を参照してください。

#### Codex のセキュリティ設定

Codex は `.codex/config.shared.toml` にセキュリティ設定が含まれています。
`sync-codex-config` コマンドで自動的に反映されます。

**主な設定内容**:

- 承認ポリシー: `untrusted`（すべての操作に承認が必要）
- サンドボックスモード: `workspace-write`（プロジェクト領域のみ書き込み可）
- ネットワークアクセス: デフォルトで無効
- 機密環境変数の除外

詳細は `docs/codex/SETTINGS_GUIDE.md` を参照してください。

#### Gemini CLI のセキュリティ設定

**Unix/Linux/macOS の場合:**

```bash
# 例: ホームディレクトリにクローンした場合
ln -s ~/ai-agent-orchestration-settings/.gemini/settings.json ~/.gemini/settings.json

# 絶対パスで指定する場合
ln -s /path/to/ai-agent-orchestration-settings/.gemini/settings.json ~/.gemini/settings.json
```

**Windows (PowerShell) の場合:**

```powershell
# 例: ホームディレクトリにクローンした場合（管理者権限不要）
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.gemini\settings.json" -Value "$env:USERPROFILE\ai-agent-orchestration-settings\.gemini\settings.json"

# 絶対パスで指定する場合
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.gemini\settings.json" -Value "C:\path\to\ai-agent-orchestration-settings\.gemini\settings.json"
```

**Windows (コマンドプロンプト) の場合:**

```cmd
:: 管理者権限で実行
:: 例: ホームディレクトリにクローンした場合
mklink "%USERPROFILE%\.gemini\settings.json" "%USERPROFILE%\ai-agent-orchestration-settings\.gemini\settings.json"

:: 絶対パスで指定する場合
mklink "%USERPROFILE%\.gemini\settings.json" "C:\path\to\ai-agent-orchestration-settings\.gemini\settings.json"
```

**設定内容**:

- YOLO モード（全自動承認）の無効化
- 永続的なツール承認の無効化
- 機密環境変数の自動マスキング
- サンドボックス実行環境の有効化
- 破壊的操作の禁止（`rm -rf`, `git reset --hard`など）
- ネットワーク経由の任意コード実行防止
- セキュアモードの有効化

詳細は `docs/gemini/SETTINGS_GUIDE.md` を参照してください。

### 8. Codex 固有の設定

#### 共有設定ファイルのリンク

`~/.codex/config.toml` は Codex が `[projects."..."]` を自動追記するため、**ここはシンボリックリンクにしない**運用を推奨します。
代わりに、Git 管理対象の共有設定 `.codex/config.shared.toml` をリンクし、同期スクリプトで `~/.codex/config.toml` を生成・更新します。

```bash
# 例: ホームディレクトリにクローンした場合
ln -s ~/ai-agent-orchestration-settings/.codex/config.shared.toml ~/.codex/config.shared.toml

# 絶対パスで指定する場合
ln -s /path/to/ai-agent-orchestration-settings/.codex/config.shared.toml ~/.codex/config.shared.toml
```

#### 同期スクリプトのリンク

```bash
# 例: ホームディレクトリにクローンした場合
ln -s ~/ai-agent-orchestration-settings/scripts/sync-codex-config.sh ~/.local/bin/sync-codex-config

# 絶対パスで指定する場合
ln -s /path/to/ai-agent-orchestration-settings/scripts/sync-codex-config.sh ~/.local/bin/sync-codex-config
```

**注意**: セクション2で実行権限を確認済みであれば、このステップは不要です。

#### 初回同期

```bash
sync-codex-config
```

`sync-codex-config` は、必要に応じて `~/.codex/config.toml` へ machine-local な top-level `notify` を注入し、Codex CLI のフォールバック通知経路として利用できるようにします。

### 9. Claude Code MCP サーバー設定

Claude Code で利用する MCP サーバーは `.claude/mcp.json` で一元管理し、`setup-mcp` スクリプトで `~/.claude.json` に反映します。

> **背景**: Claude Code の MCP サーバー設定は `settings.json` に記述しても読み込まれません。ユーザースコープの MCP 設定は `~/.claude.json` の `mcpServers` フィールドに保存される仕様のため、スクリプトで同期する方式を採用しています。

#### スクリプトのリンク

```bash
# 例: ホームディレクトリにクローンした場合
ln -s ~/ai-agent-orchestration-settings/scripts/setup-mcp.sh ~/.local/bin/setup-mcp

# 絶対パスで指定する場合
ln -s /path/to/ai-agent-orchestration-settings/scripts/setup-mcp.sh ~/.local/bin/setup-mcp
```

#### 初回同期

```bash
setup-mcp
```

以降、`.claude/mcp.json` を変更したら `setup-mcp` を実行して反映してください。

**設定されるサーバー**:

| サーバー名 | 用途 | 必要な環境変数 |
|---|---|---|
| `github-mcp-server` | GitHub 操作 | `GITHUB_MCP_API_TOKEN` |
| `backlog` | Backlog 操作 | `BACKLOG_DOMAIN`, `BACKLOG_API_KEY` |
| `drawio` | Draw.io 図作成 | - |
| `docker` | Docker 操作 | WSL 環境では `DOCKER_MCP_IN_CONTAINER=1` が必要（後述） |
| `chrome-devtools` | ブラウザ操作 | - |
| `playwright` | ブラウザ自動操作 | - |

### 10. 環境変数（必要なもののみ）

#### Gemini CLI の必須環境変数

```bash
export GEMINI_API_KEY="your-gemini-api-key"
```

#### MCP Server を使う場合（オプション）

GitHub MCP / Backlog MCP などを使う場合：

```bash
export GITHUB_MCP_API_TOKEN="your-github-token"
export BACKLOG_DOMAIN="your-space.backlog.com"
export BACKLOG_API_KEY="your-backlog-api-key"
```

永続化する場合は `~/.bashrc` や `~/.zshrc` に追記してください。

### 11. 検証

設定が正しく反映されているか確認します。

#### シンボリックリンクの確認

```bash
ls -la ~/.codex
ls -la ~/.claude
ls -la ~/.gemini
ls -la ~/.agent/notification/notify.sh
ls -la ~/.local/bin/setup-mcp
ls -la ~/.local/bin/sync-codex-config
# ステータスラインスクリプト（Claude Code のみ）
ls -la ~/.claude/statusline-command.sh
```

#### 同期スクリプトの動作確認

```bash
# Codex 設定の同期
sync-codex-config

# Claude Code MCP 設定の同期
setup-mcp
```

エラーなく実行でき、`~/.codex/config.toml` の生成・更新と `setup-mcp` の完了メッセージが表示されれば成功です。

#### CLI 動作確認

```bash
# Codex の起動確認
codex --help

# Claude Code の起動確認
claude --help

# Gemini CLI の起動確認
gemini --help
```

#### スキル・コマンド認識の確認

シンボリックリンクが正しく作成されているか確認：

```bash
# Codex のプロンプト（コマンド）ディレクトリを確認
ls -la ~/.codex/prompts

# Claude Code のコマンドディレクトリを確認
ls -la ~/.claude/commands

# Gemini CLI のコマンドディレクトリを確認
ls -la ~/.gemini/commands

# いずれも .agent/commands へのシンボリックリンクになっているはず
```

### 12. Claude Code ステータスライン設定（オプション）

Claude Code のステータスラインをカスタマイズして、現在の作業状況を一目で把握できるようにします。

#### ステータスライン表示内容

- **1行目**: カレントディレクトリ（`~` 省略表記対応）
- **2行目**: リポジトリ名・Gitブランチと変更状況
- **3行目**: コンテキスト使用率・モデル名

#### 設定方法

**推奨：Claude Code の `/statusline` コマンドを使用**

Claude Code 内で以下のコマンドを実行してください：

```
/statusline 📂 現在の作業ディレクトリ
🐙 リポジトリ名 │ 🌿 ブランチ名 変更状況
🧠 ████████░░░░░░░ 使用率% │ 💪 モデル名
```

このコマンドにより、Claude Code が自動的に：
1. `~/.claude/settings.json` にステータスライン設定を追加
2. `~/.claude/statusline-command.sh` スクリプトを自動生成

#### ステータスラインスクリプトのリンク（手動設定の場合）

`/statusline` コマンドではなく手動で設定する場合は、以下の手順でシンボリックリンクを作成してください：

**Unix/Linux/macOS/WSL の場合:**

```bash
# 例: ホームディレクトリにクローンした場合
ln -s ~/ai-agent-orchestration-settings/.claude/statusline-command.sh ~/.claude/statusline-command.sh

# 絶対パスで指定する場合
ln -s /path/to/ai-agent-orchestration-settings/.claude/statusline-command.sh ~/.claude/statusline-command.sh
```

**Windows (PowerShell) の場合:**

```powershell
# 例: ホームディレクトリにクローンした場合（管理者権限不要）
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\statusline-command.sh" -Value "$env:USERPROFILE\ai-agent-orchestration-settings\.claude\statusline-command.sh"

# 絶対パスで指定する場合
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\statusline-command.sh" -Value "C:\path\to\ai-agent-orchestration-settings\.claude\statusline-command.sh"
```

**Windows (コマンドプロンプト) の場合:**

```cmd
:: 管理者権限で実行
:: 例: ホームディレクトリにクローンした場合
mklink "%USERPROFILE%\.claude\statusline-command.sh" "%USERPROFILE%\ai-agent-orchestration-settings\.claude\statusline-command.sh"

:: 絶対パスで指定する場合
mklink "%USERPROFILE%\.claude\statusline-command.sh" "C:\path\to\ai-agent-orchestration-settings\.claude\statusline-command.sh"
```

#### ステータスライン有効化

- `/statusline` コマンドを使用した場合は、自動的に設定が有効になります
- 手動設定の場合は、`~/.claude/settings.json` に以下の設定を追加してください：

```json
{
  "statusLine": {
    "type": "command",
    "command": "sh ~/.claude/statusline-command.sh"
  }
}
```

#### ステータスラインの動作確認

```bash
# ステータスラインスクリプトが正しく動作するか確認（手動テスト）
echo '{"workspace":{"current_dir":"'$(pwd)'"},"model":{"display_name":"claude-sonnet-4"}}' | bash ~/.claude/statusline.sh
```

正常に動作している場合、以下のような2行の出力が表示されます：

```
ai-agent-orchestration-settings:/ main(2)
Sonnet 4 [default] 5m ctx:<200K[▓▓▓     ]
```

#### トラブルシューティング

- ステータスラインが表示されない場合は、Claude Code を再起動してください
- Windows で権限エラーが発生する場合：`chmod +x ~/.claude/statusline-command.sh`

## 設計思想

### 共通化の原則

- **`.agent/` 配下**: Codex と Claude Code の両方で使える共通リソースを配置
  - `AGENTS.md`: 共通のルール・指示
  - `skills/`: 共通スキル（`SKILL.md` 形式）
  - `commands/`: 共通カスタムコマンド（`.md` 形式）

- **`.codex/` 配下**: Codex 固有の設定のみ
  - `config.shared.toml`: Codex の設定ファイル

### リンク戦略

1. **共通リソース**: `.agent/` から各ツールの設定ディレクトリへシンボリックリンク
2. **ツール固有設定**: 必要最小限のファイルのみ Git 管理
3. **自動生成ファイル**: シンボリックリンクせず、スクリプトで同期

## トラブルシューティング

### シンボリックリンクが作成できない

- リンク先のパスが正しいか確認してください
- 既存のファイル・ディレクトリと名前が衝突していないか確認してください
- 既存のリンクがある場合は削除してから再作成してください

```bash
# 既存のリンクを削除
rm ~/.codex/skills
# 再作成
ln -s ~/ai-agent-orchestration-settings/.agent/skills ~/.codex/skills
```

### setup-mcp / sync-codex-config が見つからない

- `~/.local/bin` にPATHが通っているか確認してください
- シンボリックリンクが正しく作成されているか確認してください

### MCP サーバーが Claude Code に認識されない

`setup-mcp` を実行した後、Claude Code を再起動してください。

```bash
setup-mcp
# → Claude Code を再起動
```

### スクリプトに実行権限がない

```bash
chmod +x /path/to/ai-agent-orchestration-settings/scripts/setup-mcp.sh
chmod +x /path/to/ai-agent-orchestration-settings/scripts/sync-codex-config.sh
```

### カスタムコマンドが認識されない

- Codex: `~/.codex/prompts` が `.agent/commands` にリンクされているか確認
- Claude Code: `~/.claude/commands` が `.agent/commands` にリンクされているか確認
- ツールを再起動して設定を再読み込みしてください

### ステータスラインが表示されない（Claude Code）

**推奨解決方法：`/statusline` コマンドの使用**

Claude Code 内で `/statusline` コマンドを実行して自動設定してください。これにより適切な設定とスクリプトが生成されます。

**手動設定の場合のトラブルシューティング：**

- Claude Code を再起動してください
- `~/.claude/statusline-command.sh` のシンボリックリンクが正しく作成されているか確認してください
- ステータスラインスクリプトが動作するか手動確認してください：

```bash
echo '{"workspace":{"current_dir":"'$(pwd)'"},"model":{"display_name":"claude-sonnet-4"}}' | bash ~/.claude/statusline.sh
```

- Windows で Git Bash を使用している場合、シンボリックリンクの権限に問題がある可能性があります：

```bash
# Windows で権限エラーが発生する場合
chmod +x ~/.claude/statusline-command.sh
```

- `~/.claude/settings.json` にステータスライン設定が含まれているか確認してください：

```bash
grep -A 5 "statusLine" ~/.claude/settings.json
```

### WSL 環境で Docker MCP が connected にならない

WSL（Windows Subsystem for Linux）から `docker mcp gateway run` を実行すると、Docker Desktop が稼働中でも `Docker Desktop is not running` エラーが発生する場合があります。

`.claude/mcp.json` の `docker` エントリに `DOCKER_MCP_IN_CONTAINER=1` 環境変数を追加してください。本リポジトリの設定にはすでに含まれていますが、手動で設定している場合は以下を参考にしてください：

```json
"docker": {
  "command": "docker",
  "args": ["mcp", "gateway", "run"],
  "env": {
    "DOCKER_MCP_IN_CONTAINER": "1"
  }
}
```

設定後、`setup-mcp` を実行して Claude Code を再起動してください。
