# Claude Code Settings ガイド

このドキュメントは `.claude/settings.json` の設定内容を説明します。

## 参考資料

- [Claude Code を安全に使うための Tips](https://zenn.dev/ytksato/articles/057dc7c981d304)
- [Claude Code 公式ドキュメント](https://code.claude.com/docs/)

## 設計思想

**安全寄り・慎重運用を基本とし、攻撃コストを高める設計**

## 設定内容

### 最重要セキュリティ設定

#### `disableBypassPermissionsMode`
```json
"disableBypassPermissionsMode": "disable"
```

パーミッションバイパスモードを無効化します。これにより、`--dangerously-skip-permissions` コマンドラインフラグが機能しなくなります。

**重要**: マネージド設定専用で、ユーザーやプロジェクトレベルでは上書きできません。

---

### Permissions（権限設定）

権限は以下の優先順位で評価されます：
1. **deny**（拒否）- 最優先
2. **ask**（確認）- 次に評価
3. **allow**（許可）- 最後に評価

最初にマッチしたルールが適用されます。

#### deny ルール（拒否リスト）

**機密ファイルへのアクセス拒否:**
- `.env`, `.env.*` - 環境変数ファイル
- `secrets/**` - シークレット管理ディレクトリ
- `~/.ssh/**` - SSH鍵
- `~/.aws/**` - AWS認証情報
- `~/.config/gcloud/**` - Google Cloud認証情報

**Git の破壊的操作:**
- `git reset --hard` - ハードリセット
- `git push --force` / `git push -f` - 強制プッシュ
- `git clean -fd` - 追跡されていないファイルの強制削除

**危険なファイル操作:**
- `rm -rf` / `rm -fr` - 再帰的強制削除
- `sudo rm` - 管理者権限での削除

**ネットワーク経由の任意コード実行:**
- `curl`, `wget` - HTTP通信
- `nc`, `netcat` - ネットワーク接続

#### ask ルール（確認が必要な操作）

**パッケージ管理:**
- `npm install/uninstall`
- `yarn add/remove`
- `pnpm add/remove`
- `pip install/uninstall`

**データベース操作:**
- `psql`, `mysql`, `mongosh`

**Docker操作:**
- `docker rm`, `docker rmi`, `docker system prune`

**Git の重要な操作:**
- `git commit` - コミット
- `git push` - プッシュ
- `git merge` - マージ
- `git pull` - プル
- `git rebase` - リベース
- `git tag -f` - タグの強制上書き
- `git push --delete` - リモートブランチ/タグの削除

**設定ファイルの書き込み:**
- `package.json`, `tsconfig.json`
- `.gitignore`
- `Dockerfile`, `docker-compose.yml`

#### allow ルール（許可リスト）

**読み取り専用操作:**
- `Read`, `Glob`, `Grep` - ファイル読み取り・検索

**Git の読み取り専用操作:**
- `git status`, `git log`, `git diff`, `git show`
- `git branch`, `git remote -v`

**ビルド・テスト:**
- `npm run *`, `yarn run *`, `pnpm run *`
- `npm test`, `npm run test`

**安全なコマンド:**
- `ls`, `pwd`, `echo`, `cat`, `grep`, `find`
- `mkdir`, `touch`

**注意**: `Edit` と `Write` の包括許可はセキュリティリスクのため削除しました。deny/ask で指定されていないファイル操作はデフォルトで ask になります。

---

### MCP Server 設定

```json
"enableAllProjectMcpServers": false
```

プロジェクトの `.mcp.json` を自動承認しません。信頼されていないリポジトリからの自動実行を防ぎます。

---

### 環境変数（env）

```json
"env": {
  "BASH_DEFAULT_TIMEOUT_MS": "120000",
  "BASH_MAX_TIMEOUT_MS": "600000",
  "BASH_MAX_OUTPUT_LENGTH": "30000",
  "CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR": "true"
}
```

#### `BASH_DEFAULT_TIMEOUT_MS`
デフォルトタイムアウト: 2分（120000ミリ秒）

#### `BASH_MAX_TIMEOUT_MS`
最大タイムアウト: 10分（600000ミリ秒）

#### `BASH_MAX_OUTPUT_LENGTH`
出力の最大長: 30000文字

#### `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR`
コマンド実行後、元のディレクトリに戻る: true

---

### Sandbox 設定

```json
"sandbox": {
  "enabled": false,
  ...
}
```

#### `enabled`
Windows では未対応のため `false`。macOS/Linux/WSL2 では `true` を推奨。

#### `autoAllowBashIfSandboxed`
サンドボックス有効時でも自動承認しない（より慎重）: `false`

#### `filesystem.denyWrite`
書き込みを拒否するパス:
- `~/.ssh` - SSH鍵
- `~/.aws` - AWS認証情報
- `~/.config/gcloud` - Google Cloud認証情報

#### `filesystem.denyRead`
読み取りを拒否するファイル:
- `~/.ssh/id_rsa`, `~/.ssh/id_ed25519` - SSH秘密鍵
- `~/.aws/credentials` - AWS認証情報

#### `network.allowedDomains`
許可するドメインのホワイトリスト。空の配列 = すべて拒否。

---

### その他の設定

#### `respectGitignore`
`@` ファイル選択時に `.gitignore` を尊重: `true`

#### `defaultMode`
デフォルトの権限モード: `"ask"`（都度確認）

---

## 設定のカスタマイズ

### 特定のプロジェクトでネットワークアクセスが必要な場合

プロジェクトルートに `.claude/settings.json` を作成し、以下を追加：

```json
{
  "sandbox": {
    "network": {
      "allowedDomains": ["api.example.com", "cdn.example.com"]
    }
  }
}
```

### git rebase を完全に禁止したい場合

`ask` ルールから `deny` ルールに移動：

```json
{
  "permissions": {
    "deny": [
      ...
      "Bash(git rebase *)"
    ],
    "ask": [
      ...
      // "Bash(git rebase *)" を削除
    ]
  }
}
```

---

## トラブルシューティング

### 設定が反映されない

1. Claude Code を再起動
2. `/status` コマンドで設定の読み込み状態を確認
3. JSON構文エラーがないか確認（JSONLintなどでバリデーション）

### 必要な操作がブロックされる

一時的に許可する場合は、プロジェクトレベルの設定で上書きできます。
ただし、セキュリティリスクを理解した上で実施してください。

---

## 参考: 評価順序の例

```
操作: Write(./app.js)

1. deny ルールをチェック
   → マッチなし

2. ask ルールをチェック
   → マッチなし

3. allow ルールをチェック
   → "Edit" と "Write" の包括許可を削除したため、マッチなし

4. デフォルト動作
   → defaultMode: "ask" により確認を求める
```

この設計により、明示的に許可されていない操作は必ず確認を求めるようになります。
