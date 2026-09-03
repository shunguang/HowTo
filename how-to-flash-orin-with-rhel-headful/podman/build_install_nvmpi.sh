#!/bin/bash

#we are working inside the container
cd /test
# if you are not checked out jetson-ffmpeg, do this:
# git clone https://github.com/gjrtimmer/jetson-ffmpeg.git
cd jetson-ffmpeg

#check: On your RHEL/JetPack container, NVIDIA's libraries are under /usr/lib64/nvidia
find /usr -name'libnvbufsurface.so*'2>/dev/null
find /usr -name'libnvbufsurftransform.so*'2>/dev/null
find /usr -name'libnvv4l2.so*'2>/dev/null
find /usr -name'libnvjpeg.so*'2>/dev/null

#create the build folder
cd /test/jetson-ffmpeg
mkdir-p build
cd build

#Configure NVmpi
cmake .. \
-DJETSON_MULTIMEDIA_API_DIR=/usr/src/jetson_multimedia_api \
-DJETSON_MULTIMEDIA_LIB_DIR=/usr/lib64/nvidia \
-DCUDA_INCLUDE_DIR=/usr/local/cuda/include \
-DCUDA_LIB_DIR=/usr/local/cuda/lib64

#compile and install nvmpi

make-j$(nproc)
make install
ldconfig

#verify
find /usr/local -name'libnvmpi*'-o-name'nvmpi.pc'
ldconfig -p | grep nvmpi

#config pkg-config:

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:$PKG_CONFIG_PATH

# verify
pkg-config --modversion nvmpi
pkg-config --cflags nvmpi
pkg-config --libs nvmpi

