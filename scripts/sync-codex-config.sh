#!/usr/bin/env bash
set -euo pipefail

# Resolve script directory even when this script is invoked via symlink.
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

SHARED_CONFIG="${1:-${REPO_ROOT}/.codex/config.shared.toml}"
TARGET_CONFIG="${2:-${HOME}/.codex/config.toml}"

if [[ ! -f "${SHARED_CONFIG}" ]]; then
  echo "[sync-codex-config] shared config not found: ${SHARED_CONFIG}" >&2
  echo "Create ${SHARED_CONFIG} first (without [projects.\"...\"] sections)." >&2
  exit 1
fi

if rg -q '^\[projects\."' "${SHARED_CONFIG}"; then
  echo "[sync-codex-config] shared config must not contain [projects.\"...\"] sections: ${SHARED_CONFIG}" >&2
  exit 1
fi

mkdir -p "$(dirname "${TARGET_CONFIG}")"

tmp_target="$(mktemp "${TARGET_CONFIG}.tmp.XXXXXX")"
tmp_projects="$(mktemp "${TARGET_CONFIG}.projects.XXXXXX")"

cleanup() {
  rm -f "${tmp_target}" "${tmp_projects}"
}
trap cleanup EXIT

if [[ -f "${TARGET_CONFIG}" ]]; then
  awk '
    BEGIN { copy = 0 }
    /^\[projects\."/ { copy = 1 }
    copy { print }
  ' "${TARGET_CONFIG}" > "${tmp_projects}"
fi

cat "${SHARED_CONFIG}" > "${tmp_target}"

if [[ -s "${tmp_projects}" ]]; then
  printf "\n" >> "${tmp_target}"
  cat "${tmp_projects}" >> "${tmp_target}"
fi

mv "${tmp_target}" "${TARGET_CONFIG}"

echo "[sync-codex-config] synced ${TARGET_CONFIG} from ${SHARED_CONFIG}"
if [[ -s "${tmp_projects}" ]]; then
  project_count="$(rg -c '^\[projects\."' "${tmp_projects}" || true)"
  echo "[sync-codex-config] preserved ${project_count} project section(s)"
else
  echo "[sync-codex-config] no project sections found to preserve"
fi
