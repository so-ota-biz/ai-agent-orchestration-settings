#!/bin/bash

# Claude Code ステータスライン設定
# 入力: JSON形式のセッション情報
# 出力: 3行構成のステータスライン

input=$(cat)

# JSON から必要な情報を抽出
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model_name=$(echo "$input" | jq -r '.model.display_name // .model.id')

# Windowsパスの正規化
normalized_dir=$(echo "$current_dir" | sed 's|\\|/|g')

# カレントディレクトリの表示（Windows パス対応）
current_dir_display=$(echo "$normalized_dir" | sed "s|^C:/Users/$(whoami)|~|")

# Git情報の取得 (git -C による安全なディレクトリ指定)
if [ -d "${normalized_dir}/.git" ] || git -C "$normalized_dir" rev-parse --git-dir >/dev/null 2>&1; then
    repo_name=$(basename "$(git -C "$normalized_dir" rev-parse --show-toplevel 2>/dev/null || echo "$normalized_dir")")
    branch_name=$(git -C "$normalized_dir" branch --show-current 2>/dev/null || echo "unknown")
    
    # Git状態の取得
    git_status=$(git -C "$normalized_dir" status --porcelain 2>/dev/null || echo "")
    added=$(echo "$git_status" | grep -c "^A" 2>/dev/null | tr -d '\n' || echo "0")
    modified=$(echo "$git_status" | grep -c "^.M\|^M" 2>/dev/null | tr -d '\n' || echo "0")
    deleted=$(echo "$git_status" | grep -c "^.D\|^D" 2>/dev/null | tr -d '\n' || echo "0")
    untracked=$(echo "$git_status" | grep -c "^??" 2>/dev/null | tr -d '\n' || echo "0")
    
    # 変更状況の表示
    changes=""
    [ "$added" -gt 0 ] && changes="${changes}+${added}"
    [ "$modified" -gt 0 ] && changes="${changes} ~${modified}"
    [ "$deleted" -gt 0 ] && changes="${changes} -${deleted}"
    [ "$untracked" -gt 0 ] && changes="${changes} ?${untracked}"
    
    git_info="🐙 ${repo_name} │ 🌿 ${branch_name}${changes:+ $changes}"
else
    git_info="📁 $(basename "$current_dir_display")"
fi

# コンテキスト使用率（プレースホルダー）
context_percent="--"
context_bar="--"

# モデル名の短縮
case "$model_name" in
    *"claude-sonnet-4"*) model_display="💪 claude-sonnet-4" ;;
    *"claude-3-5-sonnet"*) model_display="🧠 claude-3.5-sonnet" ;;
    *"claude-3-5-haiku"*) model_display="⚡ claude-3.5-haiku" ;;
    *) model_display="🤖 $(echo "$model_name" | cut -c1-20)" ;;
esac

# ステータスラインの出力
printf "📂 %s\n" "$current_dir_display"
printf "%s\n" "$git_info"
printf "🧠 %s %s │ %s\n" "$context_bar" "$context_percent" "$model_display"