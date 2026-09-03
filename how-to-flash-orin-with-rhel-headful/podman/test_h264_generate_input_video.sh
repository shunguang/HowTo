#!/bin/bash
cd /test/ffmpeg

/usr/local/bin/ffmpeg \ 
  -f lavfi \ 
  -i"testsrc2=size=1920x1080:rate=30" \ 
  -t120 \ 
  -c:v h264_nvmpi \ 
  -b:v 8M \ 
  input264.mp4

/usr/local/bin/ffmpeg -i input264.mp4