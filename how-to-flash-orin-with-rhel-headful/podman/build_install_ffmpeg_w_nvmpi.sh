#!/bin/bash

#we are working inside the container
cd /test

# 1 Clone FFmpeg
# if you are not checked out jetson-ffmpeg, do this:
# git clone --depth=1 --branch release/7.1 https://git.ffmpeg.org/ffmpeg.git ffmpeg

# 2 Patch FFmpeg for NVmpi
cd /test/jetson-ffmpeg
./scripts/ffpatch.sh /test/ffmpeg
cd /test/ffmpeg

#3 Configure FFmpeg

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:$PKG_CONFIG_PATH

#Configure NVmpi
./configure \
  --prefix=/usr/local \
  --enable-gpl \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nvmpi \
  --enable-shared \
  --enable-pic


#4. compile and install nvmpi
make-j$(nproc)
make install
ldconfig

#5. verify
/usr/local/bin/ffmpeg -version
/usr/local/bin/ffmpeg -decoders | grep nvmpi
/usr/local/bin/ffmpeg -encoders | grep nvmpi
/usr/local/bin/ffmpeg -encoders | grep -E 'libx264|libx265'

#config pkg-config:
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:$PKG_CONFIG_PATH

# verify
pkg-config --modversion ffmpeg
pkg-config --cflags ffmpeg
pkg-config --libs ffmpeg

