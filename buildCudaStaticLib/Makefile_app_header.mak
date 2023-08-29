-include Makefile.inc

#-----------------------------------------------------------------------
# Todo: generic for different users
#
# env variables need to defined in /home/nvidia/.bashrc 
#
# export CGE_SRC_ROOT=/home/nvidia/gst-ffmpeg-evaluation
# export CUDA_INC=/usr/local/cuda-10.0/targets/aarch64-linux/include
# export CUDA_LIB=/usr/local/cuda-10.0/targets/aarch64-linux/lib
# ...
#----------------------------------------------------------------------

#build intermediat output paths

APP_SRC_ROOT=/home/nvidia/wus1/app/src
APP_ODIR_ROOT=/home/nvidia/wus1/app/build

SDIR_PROJ=$(APP_SRC_ROOT)/$(PROJ_NAME)

ODIR_OBJ=$(APP_ODIR_ROOT)/$(PROJ_NAME)
ODIR_LIB=$(APP_ODIR_ROOT)/libs
ODIR_BIN=$(APP_ODIR_ROOT)/bin

#include and lib paths of the platform
PLTF_INC=/usr/include
PLTF_LIB=/usr/lib
BOOST_INC=/usr/include
BOOST_LIB=/usr/lib

# CV_INC=/usr/include/opencv4
# CV_LIB=/usr/lib

CUDA_INC=/usr/local/cuda-11.4/targets/aarch64-linux/include
CUDA_LIB=/usr/local/cuda-11.4/targets/aarch64-linux/lib

# JETSON_INFER_INC=/usr/local/include/jetson-inference
# JETSON_UTIL_INC=/usr/local/include/jetson-utils
# JETSON_LIB=/usr/local/lib

# I_GST_INC=-I/usr/include/gstreamer-1.0 -I/usr/include/glib-2.0 -I/usr/lib/aarch64-linux-gnu/glib-2.0/include
# GST_LIB=/usr/lib/aarch64-linux-gnu/gstreamer-1.0

#CC=/usr/bin/gcc
CXX=/usr/bin/g++
NVCC=/usr/local/cuda-11.4/bin/nvcc

#DEBUG = -g
DEBUG = -DNDEBUG -g
#DEBUG = -DDEBUG -g

#include flags
APP_CFLAGS = -Wall -c $(DEBUG) -DqDNGDebug=1 -D__xlC__=1 -DNO_FCGI_DEFINES=1 -DqDNGUseStdInt=0 -DUNIX_ENV=1 -D__LITTLE_ENDIAN__=1 -DqMacOS=0 -DqWinOS=0 -std=gnu++17 \
	-I$(SDIR_PROJ) -I$(SDIR_ROOT) -I$(APP_SRC_ROOT) -I$(CUDA_INC) -I$(BOOST_INC) -I$(PLTF_INC)

#link flags and lib searching paths
LFLAGS  := -Wall $(DEBUG) -L$(ODIR_LIB) -I$(BOOST_LIB) -L$(CUDA_LIB) -L/usr/lib/aarch64-linux-gnu/tegra -L/usr/lib/aarch64-linux-gnu -L$(PLTF_LIB)

TARGETFILE=$(ODIR_LIB)/$(PROJ_NAME).a

$(info $$SDIR_PROJ is [${SDIR_PROJ}])
$(info $$APP_ODIR_ROOT is [${APP_ODIR_ROOT}])
$(info $$ODIR_OBJ is [${ODIR_OBJ}])
$(info $$ODIR_LIB is [${ODIR_LIB}])
