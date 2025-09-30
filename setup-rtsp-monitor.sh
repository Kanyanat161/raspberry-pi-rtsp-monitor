#!/bin/bash
# setup-rtsp-monitor.sh
# Raspberry Pi RTSP HDMI monitor setup script (VLC 3.x)

set -euo pipefail

FORCE_REINSTALL=0
if [[ "${1:-}" == "--force" ]]; then
  FORCE_REINSTALL=1
fi

# Detect current user and home directory
USERNAME=$(whoami)
HOME_DIR=$(eval echo ~"$USERNAME")

CONFIG_FILE="$HOME_DIR/rtsp-streams.txt"
SERVICE_FILE="/etc/systemd/system/rtsp-monitor.service"
PLAYER_SCRIPT="$HOME_DIR/rtsp-monitor.sh"

echo "=== RTSP HDMI Monitor Setup ==="

# 1. Ensure VLC (cvlc) is installed
if ! command -v cvlc >/dev/null 2>&1; then
  echo "[*] Installing VLC (cvlc)..."
  sudo apt-get update -y
  sudo apt-get install -y vlc
else
  echo "[✓] VLC (cvlc) already installed."
fi

# 2. Create default stream config if missing or force update comments
if [ ! -f "$CONFIG_FILE" ]; then
  echo "[*] Creating default stream list at $CONFIG_FILE"
  cat <<EOF > "$CONFIG_FILE"
# Add one RTSP URL per line
# Example (Reolink substream):
# rtsp://user:password@192.168.1.50:554/h264Preview_01_sub
EOF
  chown "$USERNAME":"$USERNAME" "$CONFIG_FILE"
elif [[ $FORCE_REINSTALL -eq 1 ]]; then
  echo "[*] Updating explanatory comments in $CONFIG_FILE"

  # Backup existing file
  cp "$CONFIG_FILE" "$CONFIG_FILE.bak"

  # Find first non-comment line
  FIRST_NON_COMMENT_LINE=$(grep -n -v '^[[:space:]]*#' "$CONFIG_FILE" | head -n1 | cut -d: -f1 || echo 0)
  if [[ "$FIRST_NON_COMMENT_LINE" -eq 0 ]]; then
    FIRST_NON_COMMENT_LINE=$(( $(wc -l < "$CONFIG_FILE") + 1 ))
  fi

  # Preserve user streams (all lines from first non-comment line)
  tail -n +"$FIRST_NON_COMMENT_LINE" "$CONFIG_FILE" > "$CONFIG_FILE.tmp.streams"

  # Write updated comments
  cat <<EOF > "$CONFIG_FILE"
# Add one RTSP URL per line
# Example (Reolink substream):
# rtsp://user:password@192.168.1.50:554/h264Preview_01_sub
EOF

  # Append user streams back
  cat "$CONFIG_FILE.tmp.streams" >> "$CONFIG_FILE"
  rm "$CONFIG_FILE.tmp.streams"
fi

# 3. Create player script using VLC
if [[ ! -f "$PLAYER_SCRIPT" ]] || [[ $FORCE_REINSTALL -eq 1 ]]; then
  echo "[*] Creating (or overwriting) player script at $PLAYER_SCRIPT"
  cat <<'EOF' > "$PLAYER_SCRIPT"
#!/bin/bash
CONFIG_FILE="$HOME/rtsp-streams.txt"

# Read streams (ignore comments and empty lines)
mapfile -t STREAMS < <(grep -v '^[[:space:]]*#' "$CONFIG_FILE" | grep -v '^[[:space:]]*$')

if [ ${#STREAMS[@]} -eq 0 ]; then
  echo "No RTSP streams configured in $CONFIG_FILE"
  echo "Please edit $CONFIG_FILE and add at least one RTSP URL."
  exit 1
fi

while true; do
  for URL in "${STREAMS[@]}"; do
    echo "[*] Playing: $URL"
    cvlc "$URL" \
      --no-video-title-show \
      --fullscreen \
      --no-audio \
      --no-xlib \
      --vout=fb 
    echo "[!] Stream ended or error. Restarting..."
    sleep 2
  done
done
EOF

  chmod +x "$PLAYER_SCRIPT"
  chown "$USERNAME":"$USERNAME" "$PLAYER_SCRIPT"
else
  echo "[✓] Player script already exists: $PLAYER_SCRIPT"
fi

# 4. Create systemd service
if [ ! -f "$SERVICE_FILE" ] || [[ $FORCE_REINSTALL -eq 1 ]]; then
  echo "[*] Creating (or overwriting) systemd service at $SERVICE_FILE"
  sudo bash -c "cat <<EOF > $SERVICE_FILE
[Unit]
Description=RTSP HDMI Monitor
After=network-online.target
Wants=network-online.target

[Service]
User=$USERNAME
Environment=HOME=$HOME_DIR
ExecStart=$PLAYER_SCRIPT
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF"
else
  echo "[✓] Service already exists: $SERVICE_FILE"
fi

# 5. Enable and start service
echo "[*] Reloading systemd and starting service..."
sudo systemctl daemon-reload
sudo systemctl enable rtsp-monitor.service
sudo systemctl restart rtsp-monitor.service

echo "=== Setup complete! ==="
echo "➡️  Edit your streams in: $CONFIG_FILE"
echo "➡️  Logs: journalctl -u rtsp-monitor -f"
