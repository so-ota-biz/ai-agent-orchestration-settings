# ai-agent-orchestration-settings

このリポジトリのコンセプトは、どの端末でもこのリポジトリをクローンして適切なシンボリックリンクを貼るだけで、Claude Code と Codex CLI の設定（skills / prompts / カスタムコマンド運用を含む）を再現できる状態を作ることです。

## 使い方

### 1. クローン

```bash
git clone git@github.com:so-ota-biz/ai-agents-orchestration.git
```

### 2. ディレクトリ準備

```bash
mkdir -p ~/.agent ~/.codex ~/.claude ~/.local/bin
```

### 3. 共通ルールとスキルのリンク

#### `.agent` 全体をホーム配下へ

```bash
ln -s /path/to/ai-agents-orchestration/.agent ~/.agent
```

#### 共通ルールを Codex / Claude へ

```bash
ln -s /path/to/ai-agents-orchestration/.agent/AGENTS.md ~/.codex/AGENTS.md
ln -s /path/to/ai-agents-orchestration/.agent/AGENTS.md ~/.claude/CLAUDE.md
```

#### スキルを Codex / Claude へ

```bash
ln -s ~/.agent/skills ~/.codex/skills
ln -s ~/.agent/skills ~/.claude/skills
```

### 4. Codex 設定の同期運用

`~/.codex/config.toml` は Codex が `[projects."..."]` を自動追記するため、**ここはシンボリックリンクにしない**運用を推奨します。  
代わりに、Git 管理対象の共有設定 `.codex/config.shared.toml` をリンクし、同期スクリプトで `~/.codex/config.toml` を生成・更新します。

#### 共有設定ファイルをリンク

```bash
ln -s /path/to/ai-agents-orchestration/.codex/config.shared.toml ~/.codex/config.shared.toml
```

#### 同期スクリプトを実行しやすい場所へリンク

```bash
ln -s /path/to/ai-agents-orchestration/scripts/sync-codex-config.sh ~/.local/bin/sync-codex-config
chmod +x ~/.local/bin/sync-codex-config
```

#### 初回同期

```bash
sync-codex-config
```

### 5. 環境変数（必要なもののみ）

例: GitHub MCP / Backlog MCP を使う場合

```bash
export GITHUB_MCP_API_TOKEN="..."
export BACKLOG_DOMAIN="your-space.backlog.com"
export BACKLOG_API_KEY="..."
```

### 6. （任意）共有プロンプトをホーム配下で参照したい場合

```bash
ln -s /path/to/ai-agents-orchestration/prompts ~/.agent/prompts
```

`~/.local/bin` にパスが通っていない場合は、`~/.zshrc` などに次を追加してください。

```bash
export PATH="$HOME/.local/bin:$PATH"
```
