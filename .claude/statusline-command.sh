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

# ディレクトリ情報の整理
if [[ -n "$project_dir" ]]; then
    repo_name=$(basename "$project_dir")
    if [[ "$current_dir" == "$project_dir" ]]; then
        work_dir="/"
    else
        work_dir=${current_dir#$project_dir}
        work_dir=${work_dir:-"/"}
    fi
else
    repo_name=$(basename "$current_dir")
    work_dir="/"
fi

# Git情報の取得 (エラーを抑制し、軽量化)
if [[ -n "$project_dir" ]]; then
    cd "$project_dir" 2>/dev/null
elif [[ -n "$current_dir" ]]; then
    cd "$current_dir" 2>/dev/null
fi

# Git情報 (タイムアウトとエラー抑制で軽量化)
git_info=""
if timeout 1 git rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(timeout 1 git branch --show-current 2>/dev/null || echo "detached")
    
    # 変更ファイル数を取得 (軽量化)
    changes=$(timeout 1 git status --porcelain 2>/dev/null | wc -l)
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