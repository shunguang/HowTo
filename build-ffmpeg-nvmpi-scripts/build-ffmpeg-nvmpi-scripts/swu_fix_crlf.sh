#!/bin/bash

echo "Removing CRLF line endings from FFmpeg source tree..."

find . -type f \
    ! -path "./.git/*" \
    -exec sed -i 's/\r$//' {} +

echo "Done."

echo "Checking for remaining CRLF files..."
find . -type f \
    ! -path "./.git/*" \
    -exec file {} \; | grep CRLF

echo "Finished."



