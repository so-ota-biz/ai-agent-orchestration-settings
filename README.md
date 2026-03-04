# ai-agent-orchestration-settings

このリポジトリのコンセプトは、どの端末でもこのリポジトリをクローンして適切なシンボリックリンクを貼るだけで、Claude Code と Codex CLI の設定（skills / commands / 共通ルール運用を含む）を再現できる状態を作ることです。

## ディレクトリ構造

```
ai-agent-orchestration-settings/
├── .agent/                    # 共通リソース
│   ├── AGENTS.md              # 共通ルール
│   ├── skills/                # 共通スキル（Codex/Claude両対応）
│   └── commands/              # 共通カスタムコマンド（Codex/Claude両対応）
├── .codex/
│   └── config.shared.toml     # Codex固有の共有設定
├── prompts/                   # 人間向けドキュメント用
└── scripts/
    └── sync-codex-config.sh   # Codex設定同期スクリプト
```

## 使い方

### 1. クローン

```bash
git clone git@github.com:so-ota-biz/ai-agent-orchestration-settings.git
```

### 2. ディレクトリ準備

```bash
mkdir -p ~/.codex ~/.claude ~/.local/bin
```

### 3. PATH 設定の確認

`~/.local/bin` にパスが通っていない場合は、`~/.bashrc` や `~/.zshrc` などに次を追加してください。

```bash
export PATH="$HOME/.local/bin:$PATH"
```

設定後は、シェルを再起動するか以下を実行してください。

```bash
source ~/.bashrc  # または source ~/.zshrc
```

### 4. 共通リソースのリンク

`.agent` 配下の共通リソースを Codex と Claude Code の両方にリンクします。

#### 共通ルールのリンク

```bash
# 例: ホームディレクトリにクローンした場合
ln -s ~/ai-agent-orchestration-settings/.agent/AGENTS.md ~/.codex/AGENTS.md
ln -s ~/ai-agent-orchestration-settings/.agent/AGENTS.md ~/.claude/CLAUDE.md

# 絶対パスで指定する場合
ln -s /path/to/ai-agent-orchestration-settings/.agent/AGENTS.md ~/.codex/AGENTS.md
ln -s /path/to/ai-agent-orchestration-settings/.agent/AGENTS.md ~/.claude/CLAUDE.md
```

#### 共通スキルのリンク

```bash
# 例: ホームディレクトリにクローンした場合
ln -s ~/ai-agent-orchestration-settings/.agent/skills ~/.codex/skills
ln -s ~/ai-agent-orchestration-settings/.agent/skills ~/.claude/skills

# 絶対パスで指定する場合
ln -s /path/to/ai-agent-orchestration-settings/.agent/skills ~/.codex/skills
ln -s /path/to/ai-agent-orchestration-settings/.agent/skills ~/.claude/skills
```

#### 共通カスタムコマンドのリンク

```bash
# 例: ホームディレクトリにクローンした場合
ln -s ~/ai-agent-orchestration-settings/.agent/commands ~/.codex/prompts
ln -s ~/ai-agent-orchestration-settings/.agent/commands ~/.claude/commands

# 絶対パスで指定する場合
ln -s /path/to/ai-agent-orchestration-settings/.agent/commands ~/.codex/prompts
ln -s /path/to/ai-agent-orchestration-settings/.agent/commands ~/.claude/commands
```

**注意:** Codex では `prompts` ディレクトリ、Claude Code では `commands` ディレクトリとして認識されますが、実体は同じ `.agent/commands` を参照します。

### 5. Codex 固有の設定

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

**注意:** リンク先のスクリプトに実行権限がない場合は、以下を実行してください。

```bash
# リポジトリ内のスクリプトに実行権限を付与
chmod +x ~/ai-agent-orchestration-settings/scripts/sync-codex-config.sh
# または
chmod +x /path/to/ai-agent-orchestration-settings/scripts/sync-codex-config.sh
```

#### 初回同期

```bash
sync-codex-config
```

### 6. 環境変数（必要なもののみ）

例: GitHub MCP / Backlog MCP を使う場合

```bash
export GITHUB_MCP_API_TOKEN="..."
export BACKLOG_DOMAIN="your-space.backlog.com"
export BACKLOG_API_KEY="..."
```

永続化する場合は `~/.bashrc` や `~/.zshrc` に追記してください。

### 7. 検証

設定が正しく反映されているか確認します。

#### シンボリックリンクの確認

```bash
ls -la ~/.codex
ls -la ~/.claude
ls -la ~/.local/bin/sync-codex-config
```

#### 同期スクリプトの動作確認（Codex のみ）

```bash
sync-codex-config
```

エラーなく実行でき、`~/.codex/config.toml` が生成または更新されていれば成功です。

#### Codex / Claude での動作確認

```bash
# Codex でスキルが認識されているか確認
codex --help

# Claude Code でスキルが認識されているか確認
claude --help
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
