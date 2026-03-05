#!/usr/bin/env bash
# -*- coding: utf-8 -*-
set -euo pipefail

# ========================================
# Claude MCP サーバー設定同期スクリプト
# ========================================
#
# 目的:
#   .claude/mcp.json に定義した MCP サーバー設定を
#   ~/.claude.json の mcpServers フィールドに反映する
#
# 使い方:
#   setup-mcp
#   または
#   setup-mcp <mcp設定パス> <ターゲットパス>
# ========================================

SOURCE="${BASH_SOURCE[0]}"
while [[ -h "${SOURCE}" ]]; do
  DIR="$(cd -P "$(dirname "${SOURCE}")" && pwd)"
  LINK_TARGET="$(readlink "${SOURCE}")"
  if [[ "${LINK_TARGET}" == /* ]]; then
    SOURCE="${LINK_TARGET}"
  else
    SOURCE="${DIR}/${LINK_TARGET}"
  fi
done

SCRIPT_DIR="$(cd -P "$(dirname "${SOURCE}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

MCP_CONFIG="${1:-${REPO_ROOT}/.claude/mcp.json}"
TARGET_CONFIG="${2:-${HOME}/.claude.json}"

if [[ ! -f "${MCP_CONFIG}" ]]; then
  echo "[setup-mcp] エラー: MCP設定ファイルが見つかりません: ${MCP_CONFIG}" >&2
  exit 1
fi

if [[ ! -f "${TARGET_CONFIG}" ]]; then
  echo "[setup-mcp] エラー: ターゲットファイルが見つかりません: ${TARGET_CONFIG}" >&2
  exit 1
fi

python3 - "${MCP_CONFIG}" "${TARGET_CONFIG}" <<'PYEOF'
import json
import sys
import shutil
import tempfile
import os

mcp_config_path = sys.argv[1]
target_path = sys.argv[2]

with open(mcp_config_path, "r", encoding="utf-8") as f:
    mcp_config = json.load(f)

mcp_servers = mcp_config.get("mcpServers", {})

with open(target_path, "r", encoding="utf-8") as f:
    target = json.load(f)

before = target.get("mcpServers", {})
target["mcpServers"] = mcp_servers

tmp_fd, tmp_path = tempfile.mkstemp(dir=os.path.dirname(target_path), suffix=".tmp")
try:
    with os.fdopen(tmp_fd, "w", encoding="utf-8") as f:
        json.dump(target, f, ensure_ascii=False, indent=2)
        f.write("\n")
    os.replace(tmp_path, target_path)
except Exception:
    os.unlink(tmp_path)
    raise

added = set(mcp_servers) - set(before)
removed = set(before) - set(mcp_servers)
updated = set(mcp_servers) & set(before)

print(f"[setup-mcp] mcpServers を更新しました ({len(mcp_servers)} 件)")
if added:
    print(f"  追加: {', '.join(sorted(added))}")
if removed:
    print(f"  削除: {', '.join(sorted(removed))}")
if updated:
    print(f"  更新: {', '.join(sorted(updated))}")
PYEOF
