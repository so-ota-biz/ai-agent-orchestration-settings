# Gemini CLI Settings ガイド

このドキュメントは `.gemini/settings.json` の設定内容を説明します。

## 参考資料

- [Gemini CLI 公式ドキュメント](https://geminicli.com/docs/)
- [Gemini CLI Configuration Reference](https://geminicli.com/docs/reference/configuration/)
- [Gemini CLI GitHub Repository](https://github.com/google-gemini/gemini-cli)

## 設計思想

**安全寄り・慎重運用を基本とし、攻撃コストを高める設計**

Claude Code、Codex CLI と同様のセキュリティポリシーを Gemini CLI にも適用します。

## 設定内容

### 一般設定（general）

#### `defaultApprovalMode`
```json
"defaultApprovalMode": "default"
```

**承認モード:**
- `default`: 通常モード（各ツールで確認） - **推奨**
- `auto_edit`: 編集操作は自動承認
- `plan`: プランモード（実行前に計画を確認、読み取り専用）

**推奨**: `default`（最も安全）

---

### セキュリティ設定（security）

#### `disableYoloMode`
```json
"disableYoloMode": true
```

YOLO モード（全ツール自動承認）を無効化します。すべてのツール実行に確認が必要になります。

**重要**: 管理者レベル設定（`admin.secureModeEnabled`）と組み合わせることで、より強固な制限が可能です。

---

#### `enablePermanentToolApproval`
```json
"enablePermanentToolApproval": false
```

「今後すべてのセッションで承認」オプションを無効化します。セッションごとに明示的な承認が必要になります。

---

#### `environmentVariableRedaction`
```json
"environmentVariableRedaction": {
  "enabled": true,
  "redactedVariablePatterns": [
    ".*TOKEN.*",
    ".*SECRET.*",
    ".*PASSWORD.*",
    ".*KEY.*",
    ".*AUTH.*",
    ".*CREDENTIAL.*",
    ".*PRIVATE.*",
    ".*CERT.*"
  ]
}
```

**機密環境変数の自動マスキング:**
- ツール実行時に機密情報を含む環境変数を自動的にマスク
- パターンマッチングで柔軟に対応

---

### ツール設定（tools）

#### `sandbox`
```json
"sandbox": true
```

サンドボックス実行環境を有効化します。ツールの実行を隔離された環境で行います。

**注意**: Windows では一部機能に制限がある場合があります。macOS/Linux/WSL2 での利用を推奨します。

---

#### `allowed`（許可リスト）
```json
"allowed": [
  "Read",
  "Glob",
  "Grep",
  "BashCommand(git status)",
  "BashCommand(git log *)",
  ...
]
```

**確認なしで実行可能なツール:**
- 読み取り専用操作（Read, Glob, Grep）
- Git の読み取り専用コマンド
- 安全なシェルコマンド（ls, pwd, echo, cat など）

---

#### `exclude`（禁止リスト）
```json
"exclude": [
  "BashCommand(rm -rf *)",
  "BashCommand(sudo rm *)",
  "BashCommand(git reset --hard *)",
  "BashCommand(git push --force *)",
  "BashCommand(curl *)",
  "BashCommand(wget *)",
  ...
]
```

**完全に禁止するツール:**
- 破壊的なファイル操作（rm -rf）
- Git の破壊的操作（reset --hard, push --force）
- ネットワーク経由の任意コード実行（curl, wget）

---

#### `shell`
```json
"shell": {
  "enableInteractiveShell": false,
  "inactivityTimeout": 120
}
```

**シェル実行設定:**
- インタラクティブシェルを無効化（セキュリティ強化）
- 非アクティブタイムアウト: 2分（120秒）

---

#### `truncateToolOutputThreshold`
```json
"truncateToolOutputThreshold": 30000
```

ツール出力の最大文字数: 30000文字

---

### MCP Server 設定

```json
"mcpServers": {
  "github-mcp-server": {
    "url": "https://api.githubcopilot.com/mcp",
    "env": {
      "GITHUB_MCP_API_TOKEN": "$GITHUB_MCP_API_TOKEN"
    },
    "trust": false,
    "timeout": 30000
  }
}
```

**GitHub MCP Server 設定:**
- `url`: GitHub Copilot の MCP エンドポイント
- `env`: 環境変数から API トークンを取得（`$VAR_NAME` 構文）
- `trust`: false（確認ダイアログを表示）
- `timeout`: 30秒（30000ミリ秒）

**その他の MCP Server（オプション）:**
- Docker MCP: `docker mcp gateway run`
- Draw.io MCP: `npx -y @drawio/mcp@latest`
- Playwright MCP: `npx -y @playwright/mcp@latest`

Codex の `.codex/config.shared.toml` を参考に追加可能です。

---

### コンテキスト設定（context）

```json
"context": {
  "fileName": "GEMINI.md",
  "fileFiltering": {
    "respectGitIgnore": true
  }
}
```

#### `fileName`
コンテキストファイル名: `GEMINI.md`（デフォルト）

**シンボリックリンク設定:**
```bash
# リポジトリローカルのパスを使用
ln -s ~/ai-agent-orchestration-settings/.agent/AGENTS.md ~/.gemini/GEMINI.md

# または絶対パスで
ln -s /path/to/ai-agent-orchestration-settings/.agent/AGENTS.md ~/.gemini/GEMINI.md
```

#### `fileFiltering.respectGitIgnore`
`.gitignore` パターンを尊重: `true`

---

### モデル設定（model）

```json
"model": {
  "maxSessionTurns": 50,
  "summarizeToolOutput": {
    "run_shell_command": {
      "tokenBudget": 10000
    }
  }
}
```

#### `maxSessionTurns`
チャット履歴の保持ターン数: 50

#### `summarizeToolOutput`
ツール出力の要約トークン制限:
- `run_shell_command`: シェルコマンド出力の最大保持トークン数（10000トークン）
- コンテキストウィンドウ管理のため、冗長なコマンド出力を制限

---

### 管理者設定（admin）

```json
"admin": {
  "secureModeEnabled": true,
  "extensions": {
    "enabled": false
  },
  "mcp": {
    "enabled": true
  }
}
```

#### `secureModeEnabled`
セキュアモード: `true`（YOLO モードを完全に禁止）

#### `extensions.enabled`
拡張機能のインストール: `false`（無効化）

#### `mcp.enabled`
MCP サーバーの使用: `true`（有効化）

---

### プライバシー設定（privacy）

```json
"privacy": {
  "usageStatisticsEnabled": false
}
```

匿名使用統計の収集を無効化します。

---

### UI 設定（ui）

```json
"ui": {
  "hideContextSummary": false,
  "hideBanner": false
}
```

- コンテキストサマリーを表示
- アプリケーションバナーを表示

---

## 設定のカスタマイズ

### 特定のプロジェクトで npm install を自動承認したい場合

プロジェクトルートに `.gemini/settings.json` を作成し、以下を追加：

```json
{
  "tools": {
    "allowed": [
      "BashCommand(npm install)",
      "BashCommand(npm ci)"
    ]
  }
}
```

### 特定の MCP Server を追加したい場合

```json
{
  "mcpServers": {
    "docker": {
      "command": "docker",
      "args": ["mcp", "gateway", "run"],
      "trust": false
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"],
      "trust": false
    }
  }
}
```

---

## Claude Code / Codex CLI との違い

| 項目 | Claude Code | Codex CLI | Gemini CLI |
|------|------------|-----------|-----------|
| **設定形式** | JSON | TOML | JSON |
| **パーミッション** | deny/ask/allow | approval_policy | allowed/exclude |
| **サンドボックス** | sandbox.enabled | sandbox_mode | tools.sandbox |
| **YOLO防止** | disableBypassPermissionsMode | approval_policy="untrusted" | security.disableYoloMode |
| **環境変数保護** | sandbox.filesystem.denyRead | shell_environment_policy.exclude | security.environmentVariableRedaction |
| **MCP設定** | mcpServers（簡易） | [mcp_servers.name] | mcpServers（詳細） |
| **コンテキストファイル** | CLAUDE.md | AGENTS.md | GEMINI.md |

---

## トラブルシューティング

### 設定が反映されない

1. Gemini CLI を再起動
2. `/settings` コマンドで設定の読み込み状態を確認
3. JSON構文エラーがないか確認（JSONLintなどでバリデーション）

### 必要な操作がブロックされる

一時的に許可する場合は、プロジェクトレベルの設定で上書きできます。
ただし、セキュリティリスクを理解した上で実施してください。

### MCP Server が動作しない

1. 環境変数が正しく設定されているか確認
   ```bash
   echo $GITHUB_MCP_API_TOKEN
   ```
2. `trust: false` の場合、確認ダイアログで承認が必要
3. タイムアウト設定（`timeout`）を調整

---

## 環境変数の設定

### 必須環境変数

```bash
# Gemini API キー
export GEMINI_API_KEY="your-api-key"

# GitHub MCP トークン（オプション）
export GITHUB_MCP_API_TOKEN="your-github-token"
```

### シェル設定ファイルに追加

```bash
# ~/.bashrc または ~/.zshrc に追加
export GEMINI_API_KEY="your-api-key"
export GITHUB_MCP_API_TOKEN="your-github-token"
```

---

## 参考: 設定の優先順位

1. デフォルト値（ハードコード）
2. システムデフォルト（`/etc/gemini-cli/system-defaults.json`）
3. **ユーザー設定（`~/.gemini/settings.json`）** ← このリポジトリで管理
4. プロジェクト設定（`.gemini/settings.json`）
5. システムオーバーライド（`/etc/gemini-cli/settings.json`）
6. 環境変数
7. コマンドライン引数

下の番号ほど優先度が高くなります。
