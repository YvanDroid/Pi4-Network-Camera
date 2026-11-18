# Pi4-Network-Camera
Repository documenting installation and setup of a real-time h264 feed from a raspberry pi camera to an OBS stream using GStreamer

# Architecture Setup
Using the network camera needs the following:

Raspberry Pi
- Camera Module 3
- Connected to the local network
- Has the following packages installed:
  - rpicam-apps (builtin with Raspberry Pi OS Full)
  - libcamera0
  - gstreamer1.0-tools
  - gstreamer1.0-plugins-base
  - gstreamer1.0-libcamera

GStreamer Receiver (This case, OBS on a PC)
- OBS Studio, GStreamer and obs-gstreamer Plugin all installed

# Raspberry Pi Setup
Install needed packages
```bash
sudo apt update && sudo apt upgrade
sudo apt install rpicam-apps libcamera0 gstreamer1.0-libcamera gstreamer1.0-tools gstreamer1.0-plugins-base
```

Edit parameters inside start-camera.sh
```bash
nano start-camera.sh
```

```bash
HOST=[HOST_IP_ADDRESS]
MULTICAST_IP_ADDR=[MULTICAST_ADDRESS] # If using multicast mode, find using ifconfig
PORT=8090 # Ensure firewall on both machines allows this port on UDP at least
```
Default selection is unicast mode, which sends it to only one computer, uncomment the command below to use multicast mode, ensuring the multicast address is correct.

Place start-camera.sh somewhere known and ensure executable permissions
```bash
chmod +X start-camera.sh
./start-camera.sh
```

[Optional] Set up a systemd service to auto-start the camera on boot (after login)
```bash
sudo nano /etc/systemd/system/network-camera.service
```

```bash
[Unit]
Description=Start Camera Module 3 stream
After=multi-user.target

[Service]
ExecStart=/usr/bin/bash /where/you/put/start-camera.sh
Type=simple
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

After saving, reload services list and start the camera service
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now network-camera.service
```


# PC Setup
Install the needed packages, in this case the target machine is running Arch Linux:
```bash
sudo pacman -S obs-studio obs-gstreamer gstreamer gst-libav
```
If using the commandline interface, you can use the following command if you have a desktop environment installed:
```bash
gst-launch-1.0 udpsrc port=<PORT> ! application/x-rtp, payload=96 ! rtph264depay  ! h264parse ! queue ! avdec_h264 ! autovideosink
```

Inside OBS, use the following steps:
- Create a new GStreamer Source
- Use the following pipeline inside:
```bash
udpsrc port=<PORT> ! application/x-rtp, payload=96 ! rtph264depay  ! h264parse ! queue ! avdec_h264 ! video.
```
Feel free to adjust fixed latency values if there is a delay in audio.

