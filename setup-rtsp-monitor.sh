#!/bin/bash
# setup-rtsp-monitor.sh
# Raspberry Pi RTSP HDMI monitor setup script (modern VLC version)

set -euo pipefail

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

# 2. Create default stream config if missing
if [ ! -f "$CONFIG_FILE" ]; then
  echo "[*] Creating default stream list at $CONFIG_FILE"
  cat <<EOF > "$CONFIG_FILE"
# Add one RTSP URL per line
# Example (Reolink substream):
# rtsp://user:password@192.168.1.50:554/h264Preview_01_sub
EOF
  chown "$USERNAME":"$USERNAME" "$CONFIG_FILE"
else
  echo "[✓] Config file already exists: $CONFIG_FILE"
fi

# 3. Create player script using VLC
echo "[*] Creating player script at $PLAYER_SCRIPT"
cat <<'EOF' > "$PLAYER_SCRIPT"
#!/bin/bash
CONFIG_FILE="$HOME/rtsp-streams.txt"

# Read streams (ignore comments and empty lines)
mapfile -t STREAMS < <(grep -v '^[[:space:]]*#' "$CONFIG_FILE" | grep -v '^[[:space:]]*$')

if [ ${#STREAMS[@]} -eq 0 ]; then
  echo "No RTSP streams configured in $CONFIG_FILE"
  exit 1
fi

while true; do
  for URL in "${STREAMS[@]}"; do
    echo "[*] Playing: $URL"
    cvlc --fullscreen --no-video-title-show "$URL"
    echo "[!] Stream ended or error. Restarting..."
    sleep 2
  done
 done
EOF

chmod +x "$PLAYER_SCRIPT"
chown "$USERNAME":"$USERNAME" "$PLAYER_SCRIPT"

# 4. Create systemd service
if [ ! -f "$SERVICE_FILE" ]; then
  echo "[*] Creating systemd service at $SERVICE_FILE"
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
echo "[*] Enabling and starting service..."
sudo systemctl daemon-reload
sudo systemctl enable rtsp-monitor.service
sudo systemctl restart rtsp-monitor.service

echo "=== Setup complete! ==="
echo "➡️  Edit your streams in: $CONFIG_FILE"
echo "➡️  Logs: journalctl -u rtsp-monitor -f"
