# ai-agent-orchestration-settings

このリポジトリのコンセプトは、どの端末でもこのリポジトリをクローンして適切なシンボリックリンクを貼るだけで、Claude Code、Codex CLI、Gemini CLI の設定（skills / commands / 共通ルール運用を含む）を再現できる状態を作ることです。

## ディレクトリ構造

```
ai-agent-orchestration-settings/
├── .agent/                      # 共通リソース
│   ├── AGENTS.md                # 共通ルール
│   ├── skills/                  # 共通スキル（Codex/Claude/Gemini対応）
│   ├── commands/                # 共通カスタムコマンド（Codex/Claude/Gemini対応）
│   └── notification/
│       └── notify.sh            # クロスプラットフォーム通知スクリプト
├── .claude/
│   └── settings.json            # Claude Code セキュリティ設定
├── .codex/
│   └── config.shared.toml       # Codex 共有設定（セキュリティ設定含む）
├── .gemini/
│   └── settings.json            # Gemini CLI セキュリティ設定
├── docs/
│   ├── claude/
│   │   └── SETTINGS_GUIDE.md    # Claude Code 設定ガイド
│   ├── codex/
│   │   └── SECURITY_GUIDE.md    # Codex セキュリティ設定ガイド
│   └── gemini/
│       └── SETTINGS_GUIDE.md    # Gemini CLI 設定ガイド
├── prompts/                     # 人間向けドキュメント用
└── scripts/
    ├── check-and-cleanup.sh     # クリーンアップ確認スクリプト
    └── sync-codex-config.sh     # Codex設定同期スクリプト
```

## 使い方

### 1. クローン

```bash
git clone git@github.com:so-ota-biz/ai-agent-orchestration-settings.git
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

`check-and-cleanup.sh` と `sync-codex-config.sh` が `-rwxr-xr-x` になっていれば OK です。

実行権限がない場合（`-rw-r--r--` など）は、以下を実行してください：

```bash
chmod +x scripts/check-and-cleanup.sh scripts/sync-codex-config.sh
```

**注意**: 通常、Gitリポジトリには実行権限が含まれているため、このステップは不要です。ただし、環境によっては権限が保持されない場合があるため、念のため確認することを推奨します。

### 3. ディレクトリ準備

```bash
mkdir -p ~/.codex ~/.claude ~/.gemini ~/.local/bin
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

1. **チェック対象**: 作成予定のシンボリックリンク先（`~/.codex/skills`, `~/.claude/commands` など）
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

詳細なガイドは `docs/codex/SECURITY_GUIDE.md` を参照してください。

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

### 9. 環境変数（必要なもののみ）

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

### 10. 検証

設定が正しく反映されているか確認します。

#### シンボリックリンクの確認

```bash
ls -la ~/.codex
ls -la ~/.claude
ls -la ~/.gemini
ls -la ~/.local/bin/sync-codex-config
```

#### 同期スクリプトの動作確認（Codex のみ）

```bash
sync-codex-config
```

エラーなく実行でき、`~/.codex/config.toml` が生成または更新されていれば成功です。

#### Codex / Claude / Gemini での動作確認

```bash
# Codex でスキルが認識されているか確認
codex --help

# Claude Code でスキルが認識されているか確認
claude --help

# Gemini CLI でスキルが認識されているか確認
gemini --help
```

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

### sync-codex-config が見つからない

- `~/.local/bin` にPATHが通っているか確認してください
- シンボリックリンクが正しく作成されているか確認してください

### スクリプトに実行権限がない

```bash
chmod +x /path/to/ai-agent-orchestration-settings/scripts/sync-codex-config.sh
```

### カスタムコマンドが認識されない

- Codex: `~/.codex/prompts` が `.agent/commands` にリンクされているか確認
- Claude Code: `~/.claude/commands` が `.agent/commands` にリンクされているか確認
- ツールを再起動して設定を再読み込みしてください
