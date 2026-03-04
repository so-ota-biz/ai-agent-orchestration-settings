#!/bin/bash
# -*- coding: utf-8 -*-
#
# シンボリックリンクを貼る前に、既存の設定をチェック＆クリーンアップするスクリプト
#
# 前提: UTF-8 ロケール（ja_JP.UTF-8, en_US.UTF-8 など）
# 文字化けする場合: export LANG=ja_JP.UTF-8 または export LANG=en_US.UTF-8

set -e

# カラー出力
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# チェック対象のパスリスト
PATHS_TO_CHECK=(
    "$HOME/.codex/AGENTS.md"
    "$HOME/.codex/skills"
    "$HOME/.codex/prompts"
    "$HOME/.codex/config.shared.toml"
    "$HOME/.claude/CLAUDE.md"
    "$HOME/.claude/skills"
    "$HOME/.claude/commands"
    "$HOME/.claude/settings.json"
    "$HOME/.gemini/GEMINI.md"
    "$HOME/.gemini/skills"
    "$HOME/.gemini/commands"
    "$HOME/.gemini/settings.json"
    "$HOME/.local/bin/sync-codex-config"
)

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}AI Agent Orchestration Settings${NC}"
echo -e "${BLUE}クリーンアップチェックスクリプト${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# チェック結果を格納
declare -A ISSUES
CLEAN=true

# 各パスをチェック
for path in "${PATHS_TO_CHECK[@]}"; do
    if [ ! -e "$path" ]; then
        echo -e "${GREEN}✓${NC} $path は存在しません（OK）"
    elif [ -L "$path" ]; then
        echo -e "${YELLOW}⚠${NC} $path はシンボリックリンクです"
        ISSUES["$path"]="symlink"
    elif [ -d "$path" ]; then
        # ディレクトリの場合、中身をチェック
        if [ -z "$(ls -A "$path")" ]; then
            echo -e "${YELLOW}⚠${NC} $path は空のディレクトリです"
            ISSUES["$path"]="empty_dir"
        else
            echo -e "${RED}✗${NC} $path は空でないディレクトリです（手動整理が必要）"
            ISSUES["$path"]="non_empty_dir"
            CLEAN=false
        fi
    elif [ -f "$path" ]; then
        echo -e "${RED}✗${NC} $path はファイルです（手動整理が必要）"
        ISSUES["$path"]="file"
        CLEAN=false
    fi
done

echo ""

# 問題がある場合の処理
if [ ${#ISSUES[@]} -eq 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}すべてクリーンです！${NC}"
    echo -e "${GREEN}シンボリックリンクの作成を開始できます。${NC}"
    echo -e "${GREEN}========================================${NC}"
    exit 0
fi

# 自動削除可能なものがあるか確認
AUTO_REMOVABLE=false
for path in "${!ISSUES[@]}"; do
    issue_type="${ISSUES[$path]}"
    if [[ "$issue_type" == "symlink" ]] || [[ "$issue_type" == "empty_dir" ]]; then
        AUTO_REMOVABLE=true
        break
    fi
done

# 手動整理が必要なものがある場合
if [ "$CLEAN" = false ]; then
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}手動整理が必要なパスがあります${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo "以下のパスを手動で確認・整理してください："
    echo ""
    for path in "${!ISSUES[@]}"; do
        issue_type="${ISSUES[$path]}"
        if [[ "$issue_type" == "non_empty_dir" ]] || [[ "$issue_type" == "file" ]]; then
            echo "  - $path"
            if [ -d "$path" ]; then
                echo "    内容: $(ls -A "$path" | head -3 | tr '\n' ' ')..."
            fi
        fi
    done
    echo ""
    echo "整理後、再度このスクリプトを実行してください。"
    echo ""
fi

# 自動削除可能なものがある場合
if [ "$AUTO_REMOVABLE" = true ]; then
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}自動削除可能な項目${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo ""
    echo "以下のパスは自動削除できます："
    echo ""
    for path in "${!ISSUES[@]}"; do
        issue_type="${ISSUES[$path]}"
        if [[ "$issue_type" == "symlink" ]]; then
            echo "  - $path (シンボリックリンク)"
        elif [[ "$issue_type" == "empty_dir" ]]; then
            echo "  - $path (空のディレクトリ)"
        fi
    done
    echo ""

    # 削除するか確認
    read -p "これらを削除しますか？ (y/N): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for path in "${!ISSUES[@]}"; do
            issue_type="${ISSUES[$path]}"
            if [[ "$issue_type" == "symlink" ]] || [[ "$issue_type" == "empty_dir" ]]; then
                echo -e "${BLUE}削除中:${NC} $path"
                rm -rf "$path"
            fi
        done
        echo ""
        echo -e "${GREEN}削除完了！${NC}"

        # 再チェック
        if [ "$CLEAN" = true ]; then
            echo -e "${GREEN}すべてクリーンになりました。${NC}"
            echo -e "${GREEN}シンボリックリンクの作成を開始できます。${NC}"
            exit 0
        else
            echo ""
            echo -e "${YELLOW}手動整理が必要なパスが残っています。${NC}"
            echo "整理後、再度このスクリプトを実行してください。"
            exit 1
        fi
    else
        echo ""
        echo "削除をキャンセルしました。"
        echo "手動で整理するか、再度このスクリプトを実行してください。"
        exit 1
    fi
fi

exit 1
