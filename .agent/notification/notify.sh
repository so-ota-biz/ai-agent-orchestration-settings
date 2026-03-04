#!/bin/sh
# -*- coding: utf-8 -*-

# ========================================
# クロスプラットフォーム通知スクリプト
# ========================================
#
# 前提: UTF-8 ロケール（ja_JP.UTF-8, en_US.UTF-8 など）
# 文字化けする場合: export LANG=ja_JP.UTF-8 または export LANG=en_US.UTF-8
# ========================================
#
# 対応環境:
#   - macOS (terminal-notifier / osascript)
#   - Windows Git Bash (PowerShell経由)
#   - WSL (Windows Subsystem for Linux) (PowerShell経由)
#   - Linux (notify-send)
#
# 事前準備:
#   【macOS】
#     1. terminal-notifier をインストール（推奨）
#        brew install terminal-notifier
#     2. このスクリプトに実行権限を付与
#        chmod +x ~/.agent/notification/notify.sh
#
#   【Windows Git Bash / WSL】
#     1. このスクリプトに実行権限を付与
#        chmod +x ~/.agent/notification/notify.sh
#     2. PowerShellが使用可能であること（Windows 10以降は標準搭載）
#
#   【Linux】
#     1. notify-send をインストール（多くのディストリビューションで標準搭載）
#        Ubuntu/Debian: sudo apt install libnotify-bin
#        Fedora/RHEL: sudo dnf install libnotify
#     2. このスクリプトに実行権限を付与
#        chmod +x ~/.agent/notification/notify.sh
#
# 使い方:
#   sh ~/.agent/notification/notify.sh
# ========================================

# stdinで渡されるイベント入力を無視
exec </dev/null

# 通知の内容設定
MSG="処理が完了しました"
TITLE="Codex/Claude"
SOUND="Submarine"

# OS判定
OS_TYPE="$(uname -s)"

case "${OS_TYPE}" in
  Darwin*)
    # ========================================
    # macOS環境
    # ========================================
    if command -v terminal-notifier >/dev/null 2>&1; then
      # terminal-notifier が利用可能な場合（推奨）
      terminal-notifier -title "$TITLE" -message "$MSG" -sound "$SOUND" || \
      /usr/bin/osascript -e "display notification \"$MSG\" with title \"$TITLE\" sound name \"$SOUND\"" >/dev/null 2>&1 || true
    else
      # osascript を使用（macOS標準搭載）
      /usr/bin/osascript -e "display notification \"$MSG\" with title \"$TITLE\" sound name \"$SOUND\"" >/dev/null 2>&1 || true
    fi
    ;;

  MINGW* | MSYS*)
    # ========================================
    # Windows Git Bash環境
    # ========================================
    # PowerShellを使用してWindows通知を表示
    # Windows 10以降で動作
    powershell.exe -Command "
      Add-Type -AssemblyName System.Windows.Forms;
      \$notification = New-Object System.Windows.Forms.NotifyIcon;
      \$notification.Icon = [System.Drawing.SystemIcons]::Information;
      \$notification.BalloonTipTitle = '$TITLE';
      \$notification.BalloonTipText = '$MSG';
      \$notification.Visible = \$true;
      \$notification.ShowBalloonTip(5000);
      Start-Sleep -Seconds 6;
      \$notification.Dispose();
    " >/dev/null 2>&1 || true
    ;;

  Linux*)
    # ========================================
    # Linux環境（WSLを含む）
    # ========================================
    # WSLかどうかを判定
    if grep -qEi "(microsoft|wsl)" /proc/version 2>/dev/null; then
      # WSL環境: PowerShellを使用してWindows通知を表示
      if command -v powershell.exe >/dev/null 2>&1; then
        powershell.exe -Command "
          Add-Type -AssemblyName System.Windows.Forms;
          \$notification = New-Object System.Windows.Forms.NotifyIcon;
          \$notification.Icon = [System.Drawing.SystemIcons]::Information;
          \$notification.BalloonTipTitle = '$TITLE';
          \$notification.BalloonTipText = '$MSG';
          \$notification.Visible = \$true;
          \$notification.ShowBalloonTip(5000);
          Start-Sleep -Seconds 6;
          \$notification.Dispose();
        " >/dev/null 2>&1 || true
      else
        # PowerShellが見つからない場合は何もしない
        true
      fi
    else
      # 通常のLinux環境: notify-send を使用
      if command -v notify-send >/dev/null 2>&1; then
        notify-send "$TITLE" "$MSG" >/dev/null 2>&1 || true
      else
        # notify-sendが見つからない場合は何もしない
        true
      fi
    fi
    ;;

  *)
    # ========================================
    # その他の環境（対応なし）
    # ========================================
    # 何もせずに正常終了
    true
    ;;
esac

exit 0
