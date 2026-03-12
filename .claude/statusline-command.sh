#!/bin/bash

# ステータスライン表示スクリプト
# 2行表示: 1行目にプロジェクト情報、2行目にセッション情報

# JSONデータを取得
input=$(cat)

# 基本情報の抽出
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // empty')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // empty')
model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')
session_id=$(echo "$input" | jq -r '.session_id // ""')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')

# Windowsパスの正規化
if [[ -n "$project_dir" ]]; then
    normalized_project_dir=$(echo "$project_dir" | sed 's|\\|/|g')
else
    normalized_project_dir=""
fi
if [[ -n "$current_dir" ]]; then
    normalized_current_dir=$(echo "$current_dir" | sed 's|\\|/|g')
else
    normalized_current_dir=""
fi

# ディレクトリ情報の整理
if [[ -n "$normalized_project_dir" ]]; then
    repo_name=$(basename "$normalized_project_dir")
    if [[ "$normalized_current_dir" == "$normalized_project_dir" ]]; then
        work_dir="/"
    else
        work_dir=${normalized_current_dir#$normalized_project_dir}
        work_dir=${work_dir:-"/"}
    fi
else
    repo_name=$(basename "$normalized_current_dir")
    work_dir="/"
fi

# Git情報の取得 (安全な git -C を使用)
git_target_dir=""
if [[ -n "$normalized_project_dir" ]]; then
    git_target_dir="$normalized_project_dir"
elif [[ -n "$normalized_current_dir" ]]; then
    git_target_dir="$normalized_current_dir"
fi

# Git情報 (git -C による安全なディレクトリ指定)
git_info=""
if [[ -n "$git_target_dir" ]] && timeout 1 git -C "$git_target_dir" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(timeout 1 git -C "$git_target_dir" branch --show-current 2>/dev/null || echo "detached")
    
    # 変更ファイル数を取得 (軽量化)
    changes=$(timeout 1 git -C "$git_target_dir" status --porcelain 2>/dev/null | wc -l)
    if [[ "$changes" -gt 0 ]]; then
        git_info=" ${branch}(${changes})"
    else
        git_info=" ${branch}"
    fi
else
    git_info=" no-git"
fi

# セッション経過時間の計算 (session_idから推定)
session_time=""
if [[ -n "$session_id" ]]; then
    # session_idが数値部分を含む場合の簡易時間計算
    session_start=$(echo "$session_id" | grep -o '[0-9]\+' | head -1)
    if [[ -n "$session_start" ]]; then
        current_time=$(date +%s)
        if [[ "$session_start" -lt 9999999999 ]]; then  # 10桁以下なら秒でなく調整
            session_start=$((session_start + 1700000000))  # 2023年ベースに調整
        fi
        elapsed=$((current_time - session_start))
        if [[ "$elapsed" -gt 0 && "$elapsed" -lt 86400 ]]; then  # 1日以内なら表示
            hours=$((elapsed / 3600))
            minutes=$(((elapsed % 3600) / 60))
            if [[ "$hours" -gt 0 ]]; then
                session_time="${hours}h${minutes}m"
            else
                session_time="${minutes}m"
            fi
        else
            session_time="--"
        fi
    else
        session_time="--"
    fi
else
    session_time="--"
fi

# コンテキスト使用率の簡易推定
context_pct="--"
context_bar="        "

# 1行目: プロジェクト情報 (明るい青と緑)
printf "\033[1;36m%s\033[0m:\033[1;32m%s\033[0m\033[1;33m%s\033[0m" "$repo_name" "$work_dir" "$git_info"

# 2行目: セッション情報 (暗めの色でコンパクト)
printf "\n\033[2;37m%s\033[0m \033[2;35m[%s]\033[0m \033[2;34m%s\033[0m \033[2;36mctx:%s%s\033[0m" \
    "$model_name" "$output_style" "$session_time" "$context_pct%" "[$context_bar]"