#!/usr/bin/env bash
# -*- coding: utf-8 -*-
set -euo pipefail

# ========================================
# Codex 設定同期スクリプト
# ========================================
#
# 前提: UTF-8 ロケール（ja_JP.UTF-8, en_US.UTF-8 など）
# 文字化けする場合: export LANG=ja_JP.UTF-8 または export LANG=en_US.UTF-8
# ========================================
#
# 目的:
#   共有設定ファイル（config.shared.toml）の内容を
#   ローカル設定ファイル（~/.codex/config.toml）に同期しつつ、
#   Codex が自動生成する [projects."..."] セクションは保持する
#
# 使い方:
#   sync-codex-config
#   または
#   sync-codex-config <共有設定パス> <ターゲット設定パス>
# ========================================

# シンボリックリンク経由で実行された場合でも、
# 実際のスクリプトの場所を正しく解決する
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

# スクリプトのディレクトリとリポジトリルートを特定
SCRIPT_DIR="$(cd -P "$(dirname "${SOURCE}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# 引数で指定されていない場合はデフォルトパスを使用
SHARED_CONFIG="${1:-${REPO_ROOT}/.codex/config.shared.toml}"
TARGET_CONFIG="${2:-${HOME}/.codex/config.toml}"

# 共有設定ファイルの存在確認
if [[ ! -f "${SHARED_CONFIG}" ]]; then
  echo "[sync-codex-config] エラー: 共有設定ファイルが見つかりません: ${SHARED_CONFIG}" >&2
  echo "まず ${SHARED_CONFIG} を作成してください（[projects.\"...\"] セクションは含めないでください）。" >&2
  exit 1
fi

# 共有設定ファイルに [projects."..."] セクションが含まれていないか確認
# （これらは Codex が自動生成するため、共有設定には含めない）
if rg -q '^\[projects\."' "${SHARED_CONFIG}"; then
  echo "[sync-codex-config] エラー: 共有設定ファイルに [projects.\"...\"] セクションを含めることはできません: ${SHARED_CONFIG}" >&2
  exit 1
fi

# ターゲット設定ファイルのディレクトリを作成（存在しない場合）
mkdir -p "$(dirname "${TARGET_CONFIG}")"

# 一時ファイルを作成
tmp_target="$(mktemp "${TARGET_CONFIG}.tmp.XXXXXX")"
tmp_projects="$(mktemp "${TARGET_CONFIG}.projects.XXXXXX")"

# スクリプト終了時に一時ファイルを削除
cleanup() {
  rm -f "${tmp_target}" "${tmp_projects}"
}
trap cleanup EXIT

# 既存のターゲット設定ファイルから [projects."..."] セクションのみを抽出
# 以前は最初の [projects."..."] 以降を末尾まで保持していたため、
# 非 projects セクションが後段にあると重複キーが発生する可能性があった。
if [[ -f "${TARGET_CONFIG}" ]]; then
  awk '
    BEGIN { in_projects = 0 }

    /^[[:space:]]*\[projects\."/ {
      in_projects = 1
      print
      next
    }

    /^[[:space:]]*\[/ {
      in_projects = 0
    }

    in_projects {
      print
    }
  ' "${TARGET_CONFIG}" > "${tmp_projects}"
fi

# 共有設定ファイルの内容を一時ファイルにコピー
cat "${SHARED_CONFIG}" > "${tmp_target}"

# 抽出したプロジェクトセクションがあれば、一時ファイルに追記
if [[ -s "${tmp_projects}" ]]; then
  printf "\n" >> "${tmp_target}"
  cat "${tmp_projects}" >> "${tmp_target}"
fi

# 一時ファイルでターゲット設定ファイルを置き換え
mv "${tmp_target}" "${TARGET_CONFIG}"

# 同期完了メッセージ
echo "[sync-codex-config] ${SHARED_CONFIG} から ${TARGET_CONFIG} に同期しました"
if [[ -s "${tmp_projects}" ]]; then
  project_count="$(rg -c '^\[projects\."' "${tmp_projects}" || true)"
  echo "[sync-codex-config] ${project_count} 個のプロジェクトセクションを保持しました"
else
  echo "[sync-codex-config] 保持するプロジェクトセクションはありませんでした"
fi
