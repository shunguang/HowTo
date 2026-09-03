#!/bin/bash

#we are working inside the container
cd /test
# if you are not checked out x264 rep., do this:
# git clone https://code.videolan.org/videolan/x264.git

cd x264

# configure x264
./configure \
    --prefix=/usr/local \
    --enable-shared \
    --enable-pic


#compile and install
make -j$(nproc)
make install
ldconfig

#verify
pkg-config --modversion x264
ldconfig -p | grep x264

#config pkg-config:
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:$PKG_CONFIG_PATH

# verify
pkg-config --modversion x264
pkg-config --cflags x264
pkg-config --libs x264

