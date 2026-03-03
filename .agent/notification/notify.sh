#!/bin/sh
# 以下を実行しておくこと
# brew install terminal-notifier
# chmod +x /Users/[user_name]/.agents/notification/notify.sh
# sh /Users/[user_name]/.agents/notification/notify.sh

# stdinで渡されるイベント入力を無視
exec </dev/null

MSG="処理が完了しました"
TITLE="Codex/Claude"
SOUND="Submarine"

if command -v terminal-notifier >/dev/null 2>&1; then
terminal-notifier -title "$TITLE" -message "$MSG" -sound "$SOUND" || \
/usr/bin/osascript -e "display notification \"$MSG\" with title \"$TITLE\" sound name \"$SOUND\"" >/dev/null 2>&1 || true
else
/usr/bin/osascript -e "display notification \"$MSG\" with title \"$TITLE\" sound name \"$SOUND\"" >/dev/null 2>&1 || true
fi
