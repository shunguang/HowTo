#!/bin/bash

VER=r36.4.0

#VER=r36.3.0

podman run --rm -it \
  -e DISPLAY \
  --net=host \
  --device=nvidia.com/gpu=all \
  --group-add=keep-groups \
  --security-opt=label=disable \
  -v "${HOME}/test:/test" \
  "nvcr.io/nvidia/l4t-jetpack:${VER}"
