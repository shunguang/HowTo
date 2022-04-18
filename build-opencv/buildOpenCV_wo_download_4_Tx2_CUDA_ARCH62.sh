#!/bin/bash
# License: MIT. See license file in root directory
# Copyright(c) JetsonHacks (2017-2019)

OPENCV_VERSION=4.1.1
# Jetson Nano
ARCH_BIN=6.2
INSTALL_DIR=/usr/local
# Download the opencv_extras repository
# If you are installing the opencv testdata, ie
#  OPENCV_TEST_DATA_PATH=../opencv_extra/testdata
# Make sure that you set this to YES
# Value should be YES or NO
DOWNLOAD_OPENCV_EXTRAS=NO
# Source code directory
OPENCV_SOURCE_DIR=$HOME/pkg
WHEREAMI=$PWD
# NUM_JOBS is the number of jobs to run simultaneously when using make
# This will default to the number of CPU cores (on the Nano, that's 4)
# If you are using a SD card, you may want to change this
# to 1. Also, you may want to increase the size of your swap file
NUM_JOBS=$(nproc)

CLEANUP=false

PACKAGE_OPENCV="-D CPACK_BINARY_DEB=ON"

CMAKE_INSTALL_PREFIX=$INSTALL_DIR

# Print out the current configuration
echo "Build configuration: "
echo " NVIDIA Jetson Nano"
echo " OpenCV binaries will be installed in: $CMAKE_INSTALL_PREFIX"
echo " OpenCV Source will be installed in: $OPENCV_SOURCE_DIR"
if [ "$PACKAGE_OPENCV" = "" ] ; then
   echo " NOT Packaging OpenCV"
else
   echo " Packaging OpenCV"
fi

echo " Packaging OpenCV"

# Create the build directory and start cmake
cd $OPENCV_SOURCE_DIR/opencv
mkdir build
cd build

# Here are some options to install source examples and tests
#     -D INSTALL_TESTS=ON \
#     -D OPENCV_TEST_DATA_PATH=../opencv_extra/testdata \
#     -D INSTALL_C_EXAMPLES=ON \
#     -D INSTALL_PYTHON_EXAMPLES=ON \

# If you are compiling the opencv_contrib modules:
# curl -L https://github.com/opencv/opencv_contrib/archive/3.4.1.zip -o opencv_contrib-3.4.1.zip

# There are also switches which tell CMAKE to build the samples and tests
# Check OpenCV documentation for details
#       -D WITH_QT=ON \

echo $PWD
time cmake -D CMAKE_BUILD_TYPE=RELEASE \
      -D CMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \
      -D WITH_CUDA=ON \
      -D CUDA_ARCH_BIN=${ARCH_BIN} \
      -D CUDA_ARCH_PTX="" \
      -D ENABLE_FAST_MATH=ON \
      -D CUDA_FAST_MATH=ON \
      -D WITH_CUBLAS=ON \
      -D WITH_LIBV4L=ON \
      -D WITH_V4L=ON \
      -D WITH_GSTREAMER=ON \
      -D WITH_GSTREAMER_0_10=OFF \
      -D WITH_QT=OFF \
      -D WITH_OPENGL=ON \
      -D BUILD_opencv_python2=OFF \
      -D BUILD_opencv_python3=OFF \
      -D BUILD_TESTS=OFF \
      -D BUILD_PERF_TESTS=OFF \
      -D OPENCV_ENABLE_NONFREE=ON \
      -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
      $"PACKAGE_OPENCV" \
      ../


if [ $? -eq 0 ] ; then
  echo "CMake configuration make successful"
else
  # Try to make again
  echo "CMake issues " >&2
  echo "Please check the configuration being used"
  exit 1
fi

# Consider the MAXN performance mode if using a barrel jack on the Nano
time make -j$NUM_JOBS
if [ $? -eq 0 ] ; then
  echo "OpenCV make successful"
else
  # Try to make again; Sometimes there are issues with the build
  # because of lack of resources or concurrency issues
  echo "Make did not build " >&2
  echo "Retrying ... "
  # Single thread this time
  make
  if [ $? -eq 0 ] ; then
    echo "OpenCV make successful"
  else
    # Try to make again
    echo "Make did not successfully build" >&2
    echo "Please fix issues and retry build"
    exit 1
  fi
fi

echo "Installing ... "
sudo make install
sudo ldconfig
if [ $? -eq 0 ] ; then
   echo "OpenCV installed in: $CMAKE_INSTALL_PREFIX"
else
   echo "There was an issue with the final installation"
   exit 1
fi

# If PACKAGE_OPENCV is on, pack 'er up and get ready to go!
# We should still be in the build directory ...
if [ "$PACKAGE_OPENCV" != "" ] ; then
   echo "Starting Packaging"
   sudo ldconfig  
   time sudo make package -j$NUM_JOBS
   if [ $? -eq 0 ] ; then
     echo "OpenCV make package successful"
   else
     # Try to make again; Sometimes there are issues with the build
     # because of lack of resources or concurrency issues
     echo "Make package did not build " >&2
     echo "Retrying ... "
     # Single thread this time
     sudo make package
     if [ $? -eq 0 ] ; then
       echo "OpenCV make package successful"
     else
       # Try to make again
       echo "Make package did not successfully build" >&2
       echo "Please fix issues and retry build"
       exit 1
     fi
   fi
fi

# check installation
IMPORT_CHECK="$(python -c "import cv2 ; print cv2.__version__")"
if [[ $IMPORT_CHECK != *$OPENCV_VERSION* ]]; then
  echo "There was an error loading OpenCV in the Python sanity test."
  echo "The loaded version does not match the version built here."
  echo "Please check the installation."
  echo "The first check should be the PYTHONPATH environment variable."
fi
