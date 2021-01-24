#!/bin/bash
cd /home/nvidia/suas_wami/build/bin
echo $pwd
./test.out > /dev/null 2>&1

Rem: add & at the end of above line will not work on systemctl

