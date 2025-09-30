# raspberry-pi-rtsp-monitor
Turn any Raspberry Pi into a dedicated **RTSP camera monitor**.  
This project provides a fool-proof setup script and systemd service that automatically plays one or more RTSP camera feeds fullscreen over HDMI.

## ✨ Features

- 🎥 Auto-plays RTSP camera streams over HDMI
- 🔄 Cycles through multiple cameras endlessly
- ⚡ Lightweight playback (uses GPU acceleration where possible)
- 🔁 Auto-restarts after disconnects or errors
- 🚀 Boots straight into camera feed (kiosk-style)

## 📦 Installation

1. Clone this repository to your Pi:

```bash
git clone https://github.com/tim661811/raspberry-pi-rtsp-monitor.git
cd pi-rtsp-monitor
````

2. Run the setup script:

```bash
chmod +x setup-rtsp-monitor.sh
./setup-rtsp-monitor.sh
```

This will:

* Update your system
* Install **omxplayer** (or verify it’s already installed)
* Create a config file for your streams (`/home/pi/rtsp-streams.txt`)
* Create and enable a systemd service (`rtsp-monitor.service`)
* Start playback automatically

## ⚙️ Configuration

Edit the stream list:

```bash
nano /home/pi/rtsp-streams.txt
```

Example:

```text
# Add one RTSP URL per line
# Example (Reolink substream)
rtsp://user:password@192.168.1.50:554/h264Preview_01_sub
rtsp://user:password@192.168.1.51:554/h264Preview_01_sub
```

Save and reboot:

```bash
sudo reboot
```

## 🔍 Logs & Debugging

View logs for the service:

```bash
journalctl -u rtsp-monitor -f
```

Restart the service manually:

```bash
sudo systemctl restart rtsp-monitor
```
