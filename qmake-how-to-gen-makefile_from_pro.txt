how to write x.pro for qmake

1. edit x.pro
   /home/swu/projects/xEyes/src/makefiles\qmake_x.pro

   (ref: http://doc.qt.io/qt-5/qmake-manual.html)
 
2. run qmake
 /home/swu/projects/xEyes/src/makefiles$ /usr/local/Qt-5.9.2/bin/qmake -makefile qmake_x.pro 
  it will generate a makefile: 
  /home/swu/projects/xEyes/src/makefiles/Makefile_x.mak 
  
4. run make 
 $pwd
 $/home/swu/projects/xEyes/src/makefiles
 $make -f Makefile_x.mak 
 