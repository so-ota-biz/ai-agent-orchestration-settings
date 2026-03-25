#!/usr/bin/env sh

# ステータスライン表示スクリプト - POSIX sh 互換
# 2行表示: 1行目にプロジェクト情報、2行目にセッション情報 + Pattern 4 gradient bars

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
    # v2.1.80+ フィールド
    ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
    five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
    seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
else
    # jq不要のフォールバック (簡易JSON解析)
    model_name=$(echo "$input" | sed -n 's/.*"display_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
    [ -z "$model_name" ] && model_name="Claude"
    output_style=$(echo "$input" | sed -n 's/.*"output_style"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
    [ -z "$output_style" ] && output_style=$(echo "$input" | sed -n 's/.*"output_style"[[:space:]]*:[[:space:]]*{[^}]*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
    [ -z "$output_style" ] && output_style="default"

    # workspace.current_dir の抽出
    current_dir=$(echo "$input" | sed -n 's/.*"current_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)

    # workspace.project_dir の抽出
    project_dir=$(echo "$input" | sed -n 's/.*"project_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)

    # cost.total_duration_ms の抽出
    total_duration_ms=$(echo "$input" | sed -n 's/.*"total_duration_ms"[[:space:]]*:[[:space:]]*\([0-9]\+\).*/\1/p' | head -1)

    # exceeds_200k_tokens の抽出
    exceeds_200k=$(echo "$input" | sed -n 's/.*"exceeds_200k_tokens"[[:space:]]*:[[:space:]]*\(true\|false\).*/\1/p' | head -1)
    [ -z "$exceeds_200k" ] && exceeds_200k="false"

    session_id=""
    ctx_pct=""
    five_hour_pct=""
    seven_day_pct=""
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
    normalized_current_dir=$(echo "$PWD" | sed 's|\\|/|g')
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

# Unicode文字の対応確認（ロケールベース）
case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in
    *UTF-8*|*utf-8*|*UTF8*|*utf8*)
        use_unicode=true ;;
    *)
        use_unicode=false ;;
esac

# Pattern 4: Fine Bar + Gradient
# 使用率をグラデーションカラー付き分数ブロックバーで表示
# 引数: <label> <pct_float>
# 出力: "label colorbar pct%"  (ESCシーケンス含む)
make_rate_bar() {
    _label="$1"
    _pct="$2"

    if [ -z "$_pct" ] || [ "$_pct" = "null" ]; then
        return 1
    fi

    if [ "$use_unicode" = "true" ]; then
        printf '%s' "$_pct" | awk -v label="$_label" '
        BEGIN {
            blocks[0] = " "
            blocks[1] = "▏"
            blocks[2] = "▎"
            blocks[3] = "▍"
            blocks[4] = "▌"
            blocks[5] = "▋"
            blocks[6] = "▊"
            blocks[7] = "▉"
            full_block = "█"
            empty_block = "░"
        }
        {
            pct = $0 + 0
            if (pct < 0) pct = 0
            if (pct > 100) pct = 100
            pct_int = int(pct + 0.5)

            # Pattern 4 グラデーション: 緑 → 黄 → 赤
            if (pct < 50) {
                r = int(pct * 5.1)
                g = 200
                b = 80
            } else {
                r = 255
                g = int(200 - (pct - 50) * 4)
                if (g < 0) g = 0
                b = 60
            }

            # バー生成 (width=8)
            width = 8
            filled = pct * width / 100
            full  = int(filled)
            frac  = int((filled - full) * 8)

            bar = ""
            for (i = 0; i < full; i++) bar = bar full_block
            if (full < width) {
                if (frac > 0) {
                    bar = bar blocks[frac]
                    for (i = 0; i < width - full - 1; i++) bar = bar empty_block
                } else {
                    for (i = 0; i < width - full; i++) bar = bar empty_block
                }
            }

            printf "%s \033[38;2;%d;%d;%dm%s\033[0m %d%%", label, r, g, b, bar, pct_int
        }
        '
    else
        # ASCII フォールバック (幅8, # で埋め・- で空)
        _pct_int=$(printf '%s' "$_pct" | awk '{printf "%d", int($1 + 0.5)}')
        [ "$_pct_int" -lt 0 ] && _pct_int=0
        [ "$_pct_int" -gt 100 ] && _pct_int=100
        _filled=$((_pct_int * 8 / 100))
        _bar=""
        _i=0
        while [ "$_i" -lt "$_filled" ]; do _bar="${_bar}#"; _i=$((_i+1)); done
        while [ "$_i" -lt 8 ]; do _bar="${_bar}-"; _i=$((_i+1)); done
        printf "%s [%s] %d%%" "$_label" "$_bar" "$_pct_int"
    fi
}

# コンテキストバーの生成
# context_window.used_percentage が取れれば Pattern 4、なければ従来の exceeds_200k 表示
if [ -n "$ctx_pct" ] && [ "$ctx_pct" != "null" ]; then
    ctx_display=$(make_rate_bar "ctx" "$ctx_pct")
else
    if [ "$exceeds_200k" = "true" ]; then
        ctx_display="ctx >200K"
    else
        ctx_display="ctx <200K"
    fi
fi

# レートリミットバーの生成
five_display=""
if [ -n "$five_hour_pct" ] && [ "$five_hour_pct" != "null" ]; then
    five_display=$(make_rate_bar "5h" "$five_hour_pct")
fi

seven_display=""
if [ -n "$seven_day_pct" ] && [ "$seven_day_pct" != "null" ]; then
    seven_display=$(make_rate_bar "7d" "$seven_day_pct")
fi

# セパレータ
if [ "$use_unicode" = "true" ]; then
    SEP="\033[2m│\033[0m"
else
    SEP="|"
fi

# 1行目: プロジェクト情報 (明るい青と緑)
printf "\033[1;36m%s\033[0m:\033[1;32m%s\033[0m\033[1;33m%s\033[0m" "$repo_name" "$work_dir" "$git_info"

# 2行目: モデル・スタイル・経過時間 + Pattern 4 バー群
printf "\n\033[0;37m%s\033[0m \033[0;35m[%s]\033[0m \033[0;34m%s\033[0m" \
    "$model_name" "$output_style" "$session_time"

printf " ${SEP} %s" "$ctx_display"
[ -n "$five_display" ]  && printf " ${SEP} %s" "$five_display"
[ -n "$seven_display" ] && printf " ${SEP} %s" "$seven_display"
