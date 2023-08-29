-include Makefile.inc

PROJ_NAME=unitCuTest
include Makefile_app_header.mak
CFLAGS = $(APP_CFLAGS)


#the target binary name
TARGETFILE=$(ODIR_BIN)/test.out


#-L/usr/lib/aarch64-linux-gnu/tegra

# link libs
LIBS    := -lMyCuda -lUtil \
        -lgtest -lgtest_main \
        -lnppc_static -lnppif_static -lnppig_static -lnppial_static -lnppicc_static -lnppisu_static -lnppidei -lculibos -lcublas_static -lcudart_static \
        -lboost_timer -lboost_filesystem -lboost_system -lboost_date_time -lboost_regex -lboost_chrono -lpthread -lboost_thread \
        -lv4l2 -lEGL -lGLESv2 -lX11 -lnvbuf_utils \
        -llzma -ldl -lm -lpthread -lrt

#        -lnvjpeg -lavcodec -lavformat -lavutil -lswresample -lswscale
#        -lboost_timer -lboost_filesystem -lboost_system -lboost_date_time -lboost_regex \
#        -lboost_chrono -lpthread -lboost_thread \
#        -lopencv_highgui -lopencv_videoio  -lopencv_imgcodecs -lopencv_imgproc -lopencv_core \
#        -lgthread-2.0 -lgstvideo-1.0 -lgstbase-1.0 -lgstreamer-1.0 -lgobject-2.0 -lglib-2.0 -lgstapp-1.0 -lglib-2.0 -lpng -lz -lv4l2 \

#        -ljetson-utils -lncurses\
#        -lopencv_ml -lopencv_shape -lopencv_video -lopencv_calib3d -lopencv_features2d -lopencv_flann \
#        -lopencv_stitching -lopencv_superres -lopencv_videostab \
#       -lavcodec -lavformat -lavutil -lswresample -lswscale -llzma -ldl -lm -lpthread -lrt
#       -lopencv_cudaarithm -lopencv_cudaimgproc -lopencv_cudafeatures2d -lopencv_cudawarping \

OBJS = \
        $(ODIR_OBJ)/test_CuMat.o \
        $(ODIR_OBJ)/main.o


default:  directories $(TARGETFILE)

directories:
	mkdir -p $(ODIR_OBJ)
	mkdir -p $(ODIR_LIB)
	mkdir -p $(ODIR_BIN)

$(info $$LFLAGS is [${LFLAGS}])

#the output binary file name is <$(TARGETFILE)>
$(TARGETFILE)   :       $(OBJS)
	$(CXX) $(LFLAGS) $(OBJS) $(LIBS) $(LIBS) -o $(TARGETFILE)


$(ODIR_OBJ)/main.o      :       $(SDIR_PROJ)/main.cpp
	$(CXX) -o $(ODIR_OBJ)/main.o $(CFLAGS) $(SDIR_PROJ)/main.cpp

$(ODIR_OBJ)/test_CuMat.o     :       $(SDIR_PROJ)/test_CuMat.cpp
	$(CXX) -o $(ODIR_OBJ)/test_CuMat.o $(CFLAGS) $(SDIR_PROJ)/test_CuMat.cpp

clean:
	\rm $(ODIR_OBJ)/*.o $(TARGETFILE)

rm_wami:
	\rm $(TARGETFILE)
