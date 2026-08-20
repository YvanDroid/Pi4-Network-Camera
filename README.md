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
Default selection is unicast mode, which sends it to only one computer, uncomment 

Place start-camera.sh somewhere known and ensure executable permissions
```bash
chmod +X start-camera.sh
./start-camera.sh
```


# PC Setup
