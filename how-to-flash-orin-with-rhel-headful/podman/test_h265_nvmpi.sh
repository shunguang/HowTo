#!/bin/bash

/usr/local/bin/ffmpeg \
    -benchmark \
    -c:v hevc_nvmpi \
    -i input265.mp4 \
    -c:v hevc_nvmpi \
    -b:v 8M \
    -an \
    output265_hw_hw.mp4


