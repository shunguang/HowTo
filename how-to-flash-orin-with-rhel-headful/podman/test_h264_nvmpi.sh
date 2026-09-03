#!/bin/bash

/usr/local/bin/ffmpeg \
    -benchmark \
    -c:v h264_nvmpi \
    -i input264.mp4 \
    -c:v hevc_nvmpi \
    -b:v 8M \
    -an \
    output264_hw_hw.mp4


