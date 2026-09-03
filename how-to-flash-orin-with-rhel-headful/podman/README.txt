how to use this tool
by wus1@jhuapl.edu 08/31/26

1. connect Orin in DMZ network

2. ~/test/podman_script.sh build               #build image r36.4.0-ffmpeg 

3. ~/test/podman_script.sh run_ffmpeg          #create container "fmpeg-nvmpi" from image "r36.4.0-ffmpeg"

4. inside "fmpeg-nvmpi" container:      #build new image: localhost/l4t-jetpack:r36.4.0-ffmpeg-built
    /test/$ ./build_install_nvmpi.sh
    /test/$ ./build_install_x264.sh
    /test/$ ./build_install_x265.sh
    /test/$ ./build_install_ffmpeg_w_nvmpi.sh
 
5. open a new terminal window, create a new image 
   $podman commit ffmpeg-nvmpi localhost/l4t-jetpack:r36.4.0-ffmpeg-built

6. run "fmpeg-nvmpi-test" container
   $~/test/podman_script.sh run_ffmpeg_test

7. inside "fmpeg-nvmpi-test" container
   /test$
   /test/$./test_h264_generate_input_video.sh
   /test/$./test_h264_nvmpi.sh
   /test/$./test_h265_generate_input_video.sh
   /test/$./test_h265_nvmpi.sh
------eof-------
