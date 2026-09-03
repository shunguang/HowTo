#!/bin/bash

#we are working inside the container
cd /test
# if you are not checked out x265 rep., do this:
# git clone https://github.com/Multicorewareinc/x265.git

cd x265
mkdir-p build/linux
cd  build/linux

# configure x264
cmake \
  -G"Unix Makefiles" \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DENABLE_SHARED=ON \
  ../../source

#compile and install
make -j$(nproc)
make install
ldconfig

#verify
pkg-config --modversion x265
ldconfig -p | grep x265

#config pkg-config:
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:$PKG_CONFIG_PATH

# verify
pkg-config --modversion x265
pkg-config --cflags x265
pkg-config --libs x265

