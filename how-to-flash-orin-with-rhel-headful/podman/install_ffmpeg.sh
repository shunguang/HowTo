#!/bin/bash

set -e

TEST_DIR="/test"
NVMPI_DIR="${TEST_DIR}/jetson-ffmpeg"
FFMPEG_DIR="${TEST_DIR}/ffmpeg"

NVMPI_REPO="https://github.com/gjrtimmer/jetson-ffmpeg.git"
FFMPEG_REPO="https://git.ffmpeg.org/ffmpeg.git"
FFMPEG_BRANCH="release/7.1"

export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:${PKG_CONFIG_PATH:-}"
export LD_LIBRARY_PATH="/usr/local/lib:/usr/lib64/nvidia:/usr/local/cuda/lib64:${LD_LIBRARY_PATH:-}"

echo "============================================================"
echo " Jetson AGX Orin FFmpeg + NVmpi installer"
echo " JetPack/L4T R36.4"
echo "============================================================"


# ----------------------------------------------------------------------
# Configure dynamic linker
# ----------------------------------------------------------------------

echo
echo "=== Configuring library paths ==="

echo "/usr/local/lib" > /etc/ld.so.conf.d/local.conf
echo "/usr/lib64/nvidia" > /etc/ld.so.conf.d/nvidia.conf

ldconfig


# ----------------------------------------------------------------------
# Check NVIDIA Jetson libraries
# ----------------------------------------------------------------------

echo
echo "=== Checking Jetson Multimedia libraries ==="

REQUIRED_LIBS=(
    "/usr/lib64/nvidia/libnvv4l2.so"
    "/usr/lib64/nvidia/libnvbufsurface.so"
    "/usr/lib64/nvidia/libnvbufsurftransform.so"
)

for lib in "${REQUIRED_LIBS[@]}"; do
    if [ ! -e "$lib" ]; then
        echo "ERROR: Required library not found:"
        echo "  $lib"
        exit 1
    fi

    echo "Found: $lib"
done


# ----------------------------------------------------------------------
# Build NVmpi
# ----------------------------------------------------------------------

echo
echo "============================================================"
echo " NVmpi"
echo "============================================================"

if ldconfig -p | grep -q "libnvmpi.so"; then

    echo "NVmpi is already installed."
    ldconfig -p | grep nvmpi

else

    echo "NVmpi is not installed."

    if [ ! -d "${NVMPI_DIR}/.git" ]; then

        echo
        echo "Cloning jetson-ffmpeg..."

        cd "${TEST_DIR}"

        git clone \
            "${NVMPI_REPO}" \
            jetson-ffmpeg

    else

        echo "Using existing source:"
        echo "  ${NVMPI_DIR}"

    fi


    echo
    echo "Building NVmpi..."

    cd "${NVMPI_DIR}"

    rm -rf build
    mkdir build
    cd build


    cmake .. \
        -DJETSON_MULTIMEDIA_API_DIR=/usr/src/jetson_multimedia_api \
        -DJETSON_MULTIMEDIA_LIB_DIR=/usr/lib64/nvidia \
        -DCUDA_INCLUDE_DIR=/usr/local/cuda/include \
        -DCUDA_LIB_DIR=/usr/local/cuda/lib64


    echo
    echo "Compiling NVmpi..."

    make -j"$(nproc)"


    echo
    echo "Installing NVmpi..."

    make install

    ldconfig


    echo
    echo "NVmpi installation:"
    ldconfig -p | grep nvmpi || true

fi


# ----------------------------------------------------------------------
# Verify pkg-config
# ----------------------------------------------------------------------

echo
echo "=== Checking NVmpi pkg-config ==="

if ! pkg-config --exists nvmpi; then

    echo "ERROR: pkg-config cannot find nvmpi."
    echo
    echo "PKG_CONFIG_PATH=${PKG_CONFIG_PATH}"
    echo
    echo "Installed nvmpi.pc files:"

    find /usr/local \
        -name "nvmpi.pc" \
        -print 2>/dev/null || true

    exit 1

fi

echo "NVmpi version:"
pkg-config --modversion nvmpi

echo "NVmpi libraries:"
pkg-config --libs nvmpi


# ----------------------------------------------------------------------
# Download FFmpeg
# ----------------------------------------------------------------------

echo
echo "============================================================"
echo " FFmpeg"
echo "============================================================"


if [ -x /usr/local/bin/ffmpeg ]; then

    if /usr/local/bin/ffmpeg -version 2>&1 | grep -q -- "--enable-nvmpi"; then

        echo "FFmpeg with NVmpi is already installed."
        /usr/local/bin/ffmpeg -version | head -5

        echo
        echo "NVmpi decoders:"
        /usr/local/bin/ffmpeg -decoders 2>/dev/null | grep nvmpi || true

        echo
        echo "NVmpi encoders:"
        /usr/local/bin/ffmpeg -encoders 2>/dev/null | grep nvmpi || true

        echo
        echo "Nothing to install."
        exit 0

    fi

fi


if [ ! -d "${FFMPEG_DIR}/.git" ]; then

    echo
    echo "Cloning FFmpeg ${FFMPEG_BRANCH}..."

    cd "${TEST_DIR}"

    git clone \
        --depth=1 \
        --branch "${FFMPEG_BRANCH}" \
        "${FFMPEG_REPO}" \
        ffmpeg

else

    echo "Using existing FFmpeg source:"
    echo "  ${FFMPEG_DIR}"

fi


# ----------------------------------------------------------------------
# Patch FFmpeg for NVmpi
# ----------------------------------------------------------------------

echo
echo "=== Patching FFmpeg for NVmpi ==="

cd "${NVMPI_DIR}"

./scripts/ffpatch.sh "${FFMPEG_DIR}"


# ----------------------------------------------------------------------
# Configure FFmpeg
# ----------------------------------------------------------------------

echo
echo "=== Configuring FFmpeg ==="

cd "${FFMPEG_DIR}"


./configure \
    --prefix=/usr/local \
    --enable-nvmpi \
    --enable-shared \
    --enable-pic


# ----------------------------------------------------------------------
# Build FFmpeg
# ----------------------------------------------------------------------

echo
echo "=== Building FFmpeg ==="

make -j"$(nproc)"


# ----------------------------------------------------------------------
# Install FFmpeg
# ----------------------------------------------------------------------

echo
echo "=== Installing FFmpeg ==="

make install

ldconfig


# ----------------------------------------------------------------------
# Verification
# ----------------------------------------------------------------------

echo
echo "============================================================"
echo " Installation verification"
echo "============================================================"

echo
echo "FFmpeg:"
/usr/local/bin/ffmpeg -version | head -10


echo
echo "NVmpi decoders:"
/usr/local/bin/ffmpeg -decoders 2>/dev/null | grep nvmpi || true


echo
echo "NVmpi encoders:"
/usr/local/bin/ffmpeg -encoders 2>/dev/null | grep nvmpi || true


echo
echo "NVmpi libraries:"
ldconfig -p | grep nvmpi || true


echo
echo "============================================================"
echo " FFmpeg + NVmpi installation complete"
echo "============================================================"

