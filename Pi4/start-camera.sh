#!/usr/bin/env bash
WIDTH=1280
HEIGHT=720
HOST=[HOST_IP_ADDRESS]
MULTICAST_IP_ADDR=[MULTICAST_ADDRESS] # Find it using ifconfig
PORT=8090 # Or any port that is free and allowed through firewall
BITRATE=7000000
GST_DEBUG=v4l2*:7
# Basic -- direct h264 stream. Realtime if you use ffprobe. Not supported in vlc
#rpicam-vid -t 0 --width=$WIDTH --height=$HEIGHT --inline -n --denoise cdn_off -o  udp://$HOST:$PORT

# Basic -- h264 -> MPEG stream. Better support. VLC presents extremely large delay
#rpicam-vid --width $WIDTH --height $HEIGHT -t 0 -n --codec libav --libav-format mpegts -o udp://$HOST:$PORT

# Basic -- h264 -> MPEG stream. Done through GStreamer. Needs gstreamer-tools
#rpicam-vid --width $WIDTH --height $HEIGHT --bitrate $BITRATE --denoise cdn_off -t 0 -n --codec libav --libav-format mpegts -o - | gst-launch-1.0 fdsrc fd=0 ! udpsink host=$HOST port=$PORT

# Gstreamer libcamera example. Needs gstreamer-libcamera application from apt repositories alongside all others found in the documentation
#gst-launch-1.0 -v libcamerasrc ! capsfilter caps=video/x-raw,width=$WIDTH,height=$HEIGHT,format=NV12,interlace-mode=progressive ! v4l2h264enc extra-controls="controls,repeat_sequence_header=1" ! 'video/x-h264,level=(string)4' ! h264parse ! mpegtsmux ! udpsink host=$HOST,port=$PORT

# GStreamer Working Example. Autofocus support. h264 -> MPEG
# gst-launch-1.0 libcamerasrc af-mode=continuous ! capsfilter caps=video/x-raw,width=$WIDTH,height=$HEIGHT,format=NV12,framerate=30/1,interlace-mode=progressive ! v4l2h264enc extra-controls="controls,repeat_sequence_header=1" ! 'video/x-h264,level=(string)4' ! h264parse ! mpegtsmux latency=20000000 alignment=7 ! udpsink host=$HOST port=$PORT buffer-size=65536

# GStreamer MPEG Stream
#rpicam-vid --width $WIDTH --height $HEIGHT -t 0 -n --codec libav --libav-format mpegts -o - | gst-launch-1.0 fdsrc fd=0 ! udpsink host=$HOST port=$PORT

# GStreamer h264 stream -- unicast
gst-launch-1.0 libcamerasrc af-mode=manual lens-position=10.0 brightness=0.2 contrast=1.2 ! capsfilter caps=video/x-raw,width=$WIDTH,height=$HEIGHT,format=NV12,framerate=30/1,interlace-mode=progressive ! v4l2h264enc extra-controls="controls,repeat_sequence_header=1" ! 'video/x-h264,level=(string)4' !  h264parse ! rtph264pay ! queue ! udpsink host=$HOST port=$PORT

# GStreamer h264 stream -- multicast
#gst-launch-1.0 -v libcamerasrc af-mode=manual lens-position=10.0 brightness=0.2 contrast=1.2 ! capsfilter caps=video/x-raw,width=$WIDTH,height=$HEIGHT,format=NV12,framerate=30/1,interlace-mode=progressive ! v4l2h264enc extra-controls="controls,repeat_sequence_header=1" ! 'video/x-h264,level=(string)4' !  h264parse ! rtph264pay ! queue ! udpsink host=$MULTICAST_IP_ADDR auto-multicast=true port=$PORT

