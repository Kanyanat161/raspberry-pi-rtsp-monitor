# raspberry-pi-rtsp-monitor

Turn any Raspberry Pi into a dedicated **RTSP camera monitor**.
This project provides a fool-proof setup script and systemd service that automatically plays one or more RTSP camera feeds fullscreen over HDMI.

Tested and working on **Raspberry Pi Zero W** with **Raspberry Pi OS Lite 32-bit (Debian Bookworm)**.
This solution uses **VLC (cvlc)** — not the obsolete OMXPlayer.

## ✨ Features

* 🎥 Auto-plays RTSP camera streams over HDMI
* 🔄 Cycles through multiple cameras endlessly
* ⚡ Uses VLC to stream the RTSP streams
* 🔁 Auto-restarts after disconnects or errors
* 🚀 Boots straight into camera feed (kiosk-style, console mode)

## 📦 Installation

1. Clone this repository to your Pi:

```bash
git clone https://github.com/tim661811/raspberry-pi-rtsp-monitor.git
cd raspberry-pi-rtsp-monitor
```

2. Run the setup script:

```bash
chmod +x setup-rtsp-monitor.sh
./setup-rtsp-monitor.sh
```

This will:

* Install **VLC (cvlc)** if missing
* Create a config file for your streams (`~/rtsp-streams.txt`)
* Create and enable a systemd service (`rtsp-monitor.service`)
* Start playback automatically at boot

💡 Run with `--force` to overwrite existing configs and service (can be used for updating the application):

```bash
./setup-rtsp-monitor.sh --force
```

## ⚙️ Configuration

Edit the stream list:

```bash
nano ~/rtsp-streams.txt
```

Example:

```text
# Add one RTSP URL per line
# Example (Reolink substream):
rtsp://user:password@192.168.1.50:554/h264Preview_01_sub
rtsp://user:password@192.168.1.51:554/h264Preview_01_sub
```

Save and reboot:

```bash
sudo reboot
```

## ⚠️ RTSP URL Encoding

When adding RTSP URLs to `~/rtsp-streams.txt`, **special characters must be URL-encoded**.

Common characters that need encoding:

| Character | Encoded |
| --------- | ------- |
| `@`       | `%40`   |
| `#`       | `%23`   |
| `%`       | `%25`   |
| `&`       | `%26`   |
| `:`       | `%3A`   |
| `/`       | `%2F`   |

For example, if your camera password is `P@ssw#rd%42&XY` it should be url encoded as `P%40ssw%23rd%2542%26XY`. Meaning the URL should look like this:

```text
rtsp://admin:P%40ssw%23rd%2542%26XY@192.168.1.50:554/h264Preview_01_sub
```

Failing to encode special characters may cause VLC to **fail to connect or play the stream**.

## 🔍 Logs & Debugging

View logs for the service:

```bash
journalctl -u rtsp-monitor -f
```

Restart the service manually:

```bash
sudo systemctl restart rtsp-monitor
```