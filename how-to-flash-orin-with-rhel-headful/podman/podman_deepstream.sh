#!/bin/bash

podman run --rm -it \
  --env DISPLAY \
  --net=host \
  --env=GST_PLUGIN_PATH=/usr/lib64/gstreamer-1.0 \
  --device=nvidia.com/gpu=all \
  --group-add=keep-groups \
  --security-opt=label=disable \
  nvcr.io/nvidia/deepstream:7.0-triton-multiarch

