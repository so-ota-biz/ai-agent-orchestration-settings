#!/usr/bin/env sh

# ステータスライン表示スクリプト - POSIX sh 互換

# ステータスライン表示スクリプト
# 2行表示: 1行目にプロジェクト情報、2行目にセッション情報

# JSONデータを取得
input=$(cat)

# jq の存在確認とフォールバック準備
use_jq=true
if ! command -v jq >/dev/null 2>&1; then
    use_jq=false
fi


# 基本情報の抽出
if [ "$use_jq" = "true" ]; then
    current_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
    project_dir=$(echo "$input" | jq -r '.workspace.project_dir // empty')
    model_name=$(echo "$input" | jq -r '.model.display_name // .model.id // "Claude"')
    session_id=$(echo "$input" | jq -r '.session_id // ""')
    output_style=$(echo "$input" | jq -r 'if .output_style | type == "object" then .output_style.name else (.output_style // "default") end' 2>/dev/null || echo "default")
    total_duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
    exceeds_200k=$(echo "$input" | jq -r '.exceeds_200k_tokens // false')
else
    # jq不要のフォールバック (簡易JSON解析)
    model_name=$(echo "$input" | sed -n 's/.*"display_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
    [ -z "$model_name" ] && model_name="Claude"
    output_style=$(echo "$input" | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
    [ -z "$output_style" ] && output_style="default"
    
    # workspace.current_dir の抽出
    current_dir=$(echo "$input" | sed -n 's/.*"current_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
    
    # workspace.project_dir の抽出
    project_dir=$(echo "$input" | sed -n 's/.*"project_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
    
    # cost.total_duration_ms の抽出
    total_duration_ms=$(echo "$input" | sed -n 's/.*"total_duration_ms"[[:space:]]*:[[:space:]]*\([0-9]\+\).*/\1/p' | head -1)
    
    # exceeds_200k_tokens の抽取
    exceeds_200k=$(echo "$input" | sed -n 's/.*"exceeds_200k_tokens"[[:space:]]*:[[:space:]]*\(true\|false\).*/\1/p' | head -1)
    [ -z "$exceeds_200k" ] && exceeds_200k="false"
    
    session_id=""
fi

# Windowsパスの正規化
if [ -n "$project_dir" ]; then
    normalized_project_dir=$(echo "$project_dir" | sed 's|\\|/|g')
else
    normalized_project_dir=""
fi
if [ -n "$current_dir" ]; then
    normalized_current_dir=$(echo "$current_dir" | sed 's|\\|/|g')
else
    normalized_current_dir=""
fi

# ディレクトリ情報の整理
if [ -n "$normalized_project_dir" ]; then
    repo_name=$(basename "$normalized_project_dir")
    if [ "$normalized_current_dir" = "$normalized_project_dir" ]; then
        work_dir="/"
    else
        work_dir=${normalized_current_dir#$normalized_project_dir}
        work_dir=${work_dir:-"/"}
    fi
elif [ -n "$normalized_current_dir" ]; then
    repo_name=$(basename "$normalized_current_dir")
    work_dir="/"
else
    # フォールバック: PWDを使用
    repo_name=$(basename "$PWD")
    work_dir="/"
fi

# Git情報の取得 (安全な git -C を使用)
git_target_dir=""
if [ -n "$normalized_project_dir" ]; then
    git_target_dir="$normalized_project_dir"
elif [ -n "$normalized_current_dir" ]; then
    git_target_dir="$normalized_current_dir"
fi

# timeout コマンドの検出
run_with_timeout() {
    if command -v timeout >/dev/null 2>&1; then
        timeout 1 "$@"
    elif command -v gtimeout >/dev/null 2>&1; then
        gtimeout 1 "$@"
    else
        "$@"
    fi
}

# Git情報 (git -C による安全なディレクトリ指定)
git_info=""
if [ -n "$git_target_dir" ] && run_with_timeout git -C "$git_target_dir" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(run_with_timeout git -C "$git_target_dir" branch --show-current 2>/dev/null || echo "detached")
    
    # 変更ファイル数を取得 (軽量化)
    changes=$(run_with_timeout git -C "$git_target_dir" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "$changes" -gt 0 ]; then
        git_info=" ${branch}(${changes})"
    else
        git_info=" ${branch}"
    fi
else
    git_info=" no-git"
fi

# セッション経過時間の計算
session_time=""
if [ -n "$total_duration_ms" ] && [ "$total_duration_ms" != "null" ] && echo "$total_duration_ms" | grep -q '^[0-9]\+$'; then
    # ミリ秒を秒に変換
    elapsed_seconds=$((total_duration_ms / 1000))
    
    if [ "$elapsed_seconds" -gt 0 ]; then
        hours=$((elapsed_seconds / 3600))
        minutes=$(((elapsed_seconds % 3600) / 60))
        
        if [ "$hours" -gt 0 ]; then
            session_time="${hours}h${minutes}m"
        elif [ "$minutes" -gt 0 ]; then
            session_time="${minutes}m"
        else
            session_time="<1m"
        fi
    else
        session_time="0m"
    fi
else
    session_time="--"
fi

# コンテキスト使用率の計算
context_pct="--"
context_bar="        "

# Unicode文字の対応確認（ロケールベース）
case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in
    *UTF-8*|*utf-8*|*UTF8*|*utf8*)
        use_unicode=true ;;
    *)
        use_unicode=false ;;
esac

if [ "$use_unicode" = "true" ]; then
    # Unicode対応環境
    if [ "$exceeds_200k" = "true" ]; then
        context_pct=">200K"
        context_bar="████████"  # 満杯表示
    else
        context_pct="<200K"
        context_bar="▓▓▓     "  # 部分的に埋める
    fi
else
    # ASCII文字での代替表示
    if [ "$exceeds_200k" = "true" ]; then
        context_pct=">200K"
        context_bar="########"  # ASCII満杯
    else
        context_pct="<200K"
        context_bar="===     "  # ASCII部分表示
    fi
fi

# 1行目: プロジェクト情報 (明るい青と緑)
printf "\033[1;36m%s\033[0m:\033[1;32m%s\033[0m\033[1;33m%s\033[0m" "$repo_name" "$work_dir" "$git_info"

# 2行目: セッション情報 (見やすい色で表示)
printf "\n\033[0;37m%s\033[0m \033[0;35m[%s]\033[0m \033[0;34m%s\033[0m \033[0;36mctx:%s%s\033[0m" \
    "$model_name" "$output_style" "$session_time" "$context_pct%" "[$context_bar]"
