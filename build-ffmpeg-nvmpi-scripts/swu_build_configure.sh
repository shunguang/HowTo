#!/bin/bash

CUDA_ROOT=/osi/tools/osi_sys26_0_0_int_tml3/cuda

./configure \
    --enable-static \
    --enable-shared \
    --enable-nonfree \
    --enable-libnpp \
    --enable-nvmpi \
    --enable-gpl \
    --disable-opencl \
    --extra-cflags="-I${CUDA_ROOT}/include -I/usr/local/include" \
    --extra-ldflags="-L${CUDA_ROOT}/lib64 -L/usr/local/lib -L/usr/lib/aarch64-linux-gnu" \
    --enable-libx264 \
    --extra-libs="-ldl -lm -lstdc++ -lpthread -lnuma" \
    --prefix=/usr/local

