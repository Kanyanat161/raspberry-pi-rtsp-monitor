#!/bin/bash
# setup-rtsp-monitor.sh
# Raspberry Pi RTSP HDMI monitor setup script

set -e

CONFIG_FILE="/home/pi/rtsp-streams.txt"
SERVICE_FILE="/etc/systemd/system/rtsp-monitor.service"
PLAYER_SCRIPT="/home/pi/rtsp-monitor.sh"

echo "=== RTSP HDMI Monitor Setup ==="

# 1. Update system
echo "[*] Updating system..."
sudo apt-get update -y
sudo apt-get upgrade -y

# 2. Ensure omxplayer is installed
if ! command -v omxplayer >/dev/null 2>&1; then
  echo "[*] Installing omxplayer..."
  sudo apt-get install -y omxplayer
else
  echo "[✓] omxplayer already installed."
fi

# 3. Create default stream config if missing
if [ ! -f "$CONFIG_FILE" ]; then
  echo "[*] Creating default stream list at $CONFIG_FILE"
  cat <<EOF > "$CONFIG_FILE"
# Add one RTSP URL per line
# Example (Reolink substream):
# rtsp://user:password@192.168.1.50:554/h264Preview_01_sub
EOF
  chown pi:pi "$CONFIG_FILE"
else
  echo "[✓] Config file already exists: $CONFIG_FILE"
fi

# 4. Create player script
echo "[*] Creating player script at $PLAYER_SCRIPT"
cat <<'EOF' > "$PLAYER_SCRIPT"
#!/bin/bash
CONFIG_FILE="/home/pi/rtsp-streams.txt"

# Read streams (ignore comments and empty lines)
mapfile -t STREAMS < <(grep -v '^\s*#' "$CONFIG_FILE" | grep -v '^\s*$')

if [ ${#STREAMS[@]} -eq 0 ]; then
  echo "No RTSP streams configured in $CONFIG_FILE"
  exit 1
fi

while true; do
  for URL in "${STREAMS[@]}"; do
    echo "[*] Playing: $URL"
    omxplayer --no-keys --aspect-mode fill "$URL"
    echo "[!] Stream ended or error. Restarting..."
    sleep 2
  done
done
EOF

chmod +x "$PLAYER_SCRIPT"
chown pi:pi "$PLAYER_SCRIPT"

# 5. Create systemd service
if [ ! -f "$SERVICE_FILE" ]; then
  echo "[*] Creating systemd service at $SERVICE_FILE"
  sudo bash -c "cat <<EOF > $SERVICE_FILE
[Unit]
Description=RTSP HDMI Monitor
After=network-online.target
Wants=network-online.target

[Service]
User=pi
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

# 6. Enable and start service
echo "[*] Enabling and starting service..."
sudo systemctl daemon-reload
sudo systemctl enable rtsp-monitor.service
sudo systemctl restart rtsp-monitor.service

echo "=== Setup complete! ==="
echo "➡️  Edit your streams in: $CONFIG_FILE"
echo "➡️  Logs: journalctl -u rtsp-monitor -f"
