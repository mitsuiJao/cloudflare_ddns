#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVICE_FILE="$SCRIPT_DIR/ddns.service"
TIMER_FILE="$SCRIPT_DIR/ddns.timer"

chmod +x "$SCRIPT_DIR/ddns.sh"

# user systemd を試みる（root不要）
if systemctl --user daemon-reload &>/dev/null 2>&1; then
  USER_SYSTEMD_DIR="$HOME/.config/systemd/user"
  mkdir -p "$USER_SYSTEMD_DIR"

  ln -sf "$SERVICE_FILE" "$USER_SYSTEMD_DIR/ddns.service"
  ln -sf "$TIMER_FILE"   "$USER_SYSTEMD_DIR/ddns.timer"

  systemctl --user daemon-reload
  systemctl --user enable --now ddns.timer

  echo "User systemd timer enabled."
  echo "Status: systemctl --user status ddns.timer"

# system systemd（root必要）
elif sudo systemctl daemon-reload &>/dev/null 2>&1; then
  SYSTEM_SYSTEMD_DIR="/etc/systemd/system"

  sudo ln -sf "$SERVICE_FILE" "$SYSTEM_SYSTEMD_DIR/ddns.service"
  sudo ln -sf "$TIMER_FILE"   "$SYSTEM_SYSTEMD_DIR/ddns.timer"

  sudo systemctl daemon-reload
  sudo systemctl enable --now ddns.timer

  echo "System systemd timer enabled."
  echo "Status: systemctl status ddns.timer"

else
  echo "systemd が使えない環境です。"
  echo "cron で代替する場合: crontab -e で以下を追加"
  echo "*/15 * * * * $SCRIPT_DIR/ddns.sh"
fi
