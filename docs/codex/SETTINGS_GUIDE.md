# Codex CLI Settings ガイド

このドキュメントは `.codex/config.shared.toml` の設定内容を説明します。

## 参考資料

- [Codex CLI Security](https://developers.openai.com/codex/security/)
- [Codex CLI Configuration Reference](https://developers.openai.com/codex/config-reference/)
- [Claude Codeを安全に使うためのTips](https://zenn.dev/ytksato/articles/057dc7c981d304)

## 設計思想

**安全寄り・慎重運用を基本とし、攻撃コストを高める設計**

Codex CLIはClaude Code、Gemini CLIと異なる設定方式（TOML形式）を採用していますが、同等の安全性を確保できます。
本ガイドでは、Claude Codeの安全設定（`.claude/settings.json`）と同等の保護レベルをCodexで実現する方法を説明します。

## 設定内容

### Codex のセキュリティレイヤー

Codex は2層のセキュリティ制御を提供します：

1. **サンドボックスモード（Sandbox Mode）**: 技術的なアクセス制限（ファイル書き込み、ネットワークアクセス）
2. **承認ポリシー（Approval Policy）**: エージェントが実行前に確認を求めるタイミング

### ~/.codex/config.toml の推奨設定

```toml
# ========================================
# Codex CLI 安全設定（共有設定として管理）
# 参考: https://zenn.dev/ytksato/articles/057dc7c981d304
# ========================================

# デフォルトの承認ポリシー
# "untrusted" = すべての操作に承認が必要（最も安全）
# "on-request" = 対話型実行で承認を求める（バランス型）
# "never" = 承認をスキップ（危険、使用非推奨）
approval_policy = "untrusted"

# デフォルトのサンドボックスモード
# "read-only" = 読み取り専用（最も安全）
# "workspace-write" = プロジェクト領域への書き込みを許可（推奨）
# "danger-full-access" = すべてのアクセスを許可（危険、使用非推奨）
sandbox_mode = "workspace-write"

# ワークスペース書き込みモードの詳細設定
[sandbox_workspace_write]
# ネットワークアクセスをデフォルトで無効化
network_access = false

# ログインシェルの使用を禁止（セキュリティ強化）
allow_login_shell = false

# 追加で書き込みを許可するディレクトリ（必要に応じて）
# writable_roots = []

# シェル環境変数のポリシー
[shell_environment_policy]
# 環境変数の継承レベル
# "none" = 環境変数を一切継承しない（最も安全）
# "core" = 最小限の環境変数のみ継承（推奨）
# "all" = すべての環境変数を継承（注意が必要）
inherit = "core"

# 機密情報を含む環境変数を除外
exclude = [
  "AWS_*",
  "GITHUB_TOKEN",
  "OPENAI_API_KEY",
  "*_SECRET",
  "*_PASSWORD",
  "*_API_KEY"
]

# MCP サーバー設定（プロジェクト固有のものは .codex/config.toml で管理）
# 必要なMCPサーバーのみ有効化
# [mcp_servers.github]
# enabled = true
# timeout_ms = 30000

# プロジェクト信頼レベルの管理
# 信頼していないプロジェクトは明示的に "untrusted" に設定
# [projects."/path/to/untrusted/project"]
# trust_level = "untrusted"

# テレメトリ（デフォルトで無効）
# [otel]
# enabled = false
```

---

## 設定のカスタマイズ

### プロジェクト固有の設定（.codex/config.toml）

プロジェクトごとに必要な設定を `.codex/config.toml` で上書きできます。
ただし、プロジェクトの設定は「信頼レベル」が "trusted" の場合のみ読み込まれます。

```toml
# プロジェクト固有の設定例
# このプロジェクトでのみネットワークアクセスを許可
[sandbox_workspace_write]
network_access = true

# プロジェクト固有の MCP サーバー
[mcp_servers.project_specific_tool]
enabled = true
command = "npx"
args = ["-y", "some-mcp-server"]
```

---

## 管理者向け設定

### 要件ファイル（requirements.toml）

企業環境や複数ユーザーで安全性を強制する場合、`requirements.toml` を使用します。
このファイルはユーザーが上書きできない制約を定義します。

### 配置場所

- **macOS/Linux**: `/etc/codex/requirements.toml` または `~/.codex/requirements.toml`
- **Windows**: `C:\ProgramData\codex\requirements.toml` または `%USERPROFILE%\.codex\requirements.toml`

### 推奨内容

```toml
# ========================================
# Codex CLI 管理者要件ファイル
# ユーザーが上書きできない強制設定
# ========================================

# 許可されたサンドボックスモード
allowed_sandbox_modes = ["read-only", "workspace-write"]

# 許可された承認ポリシー
allowed_approval_policies = ["untrusted", "on-request"]

# 危険な設定を禁止
[sandbox_workspace_write]
network_access = false  # ネットワークアクセスを強制的に無効化
allow_login_shell = false  # ログインシェルを強制的に無効化

# ウェブ検索モードの制限
# allowed_web_search_modes = ["cached"]  # ライブ検索を禁止
```

---

## Claude Code / Gemini CLI との比較

| 設定項目 | Claude Code | Codex CLI | Gemini CLI |
|---------|------------|-----------|-----------|
| **設定形式** | JSON | TOML | JSON |
| **全自動承認防止** | `disableBypassPermissionsMode: "disable"` | `approval_policy = "untrusted"` | `security.disableYoloMode: true` |
| **プロジェクトMCP自動承認防止** | `enableAllProjectMcpServers: false` | `trust_level = "untrusted"` | プロジェクト設定は自動承認されない |
| **ネットワーク制限** | `sandbox.network.allowedDomains: []` | `network_access = false` | `tools.sandbox: true` |
| **機密ファイル保護** | `permissions.deny: ["Read(~/.ssh/**)"]` | 環境変数除外 + サンドボックス | `security.allowedExtensions` (拡張子制限) |
| **環境変数保護** | `sandbox.filesystem.denyRead` | `shell_environment_policy.exclude` | `security.environmentVariableRedaction` |
| **コンテキストファイル** | CLAUDE.md | AGENTS.md | GEMINI.md |

---

## 安全性チェックリスト

プロジェクト開始前に以下を確認してください：

- [ ] `~/.codex/config.toml` で `approval_policy = "untrusted"` または `"on-request"` に設定
- [ ] `sandbox_mode = "workspace-write"` 以下に設定（`danger-full-access`は使用しない）
- [ ] `sandbox_workspace_write.network_access = false` に設定（必要な場合のみ有効化）
- [ ] 機密情報を含む環境変数を `shell_environment_policy.exclude` で除外
- [ ] 信頼していないプロジェクトは `trust_level = "untrusted"` に設定
- [ ] 不要なMCPサーバーは無効化

---

## トラブルシューティング

### ネットワークアクセスが必要な場合

特定のプロジェクトでのみネットワークアクセスが必要な場合：

```toml
# プロジェクトの .codex/config.toml
[sandbox_workspace_write]
network_access = true
```

全体で有効化する場合は、`~/.codex/config.toml` で設定しますが、セキュリティリスクが高まります。

### MCPサーバーが起動しない場合

信頼レベルが "untrusted" の場合、プロジェクト固有の `.codex/config.toml` は読み込まれません。
以下のいずれかで対処：

1. プロジェクトを信頼する: `codex trust /path/to/project`
2. ユーザー設定（`~/.codex/config.toml`）でMCPサーバーを定義
