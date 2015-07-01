#!/bin/bash
set LIB=./lib
dmd src/*.d -I../../Libraries/DerelictUtil/source/ -I../../Libraries/DerelictSDL2/source/ -ofDrawClient
# F:/Compilers/D/dmd2/windows/bin/dmd.exe src/*.d -IF:/Projects/Libraries/DerelictUtil/source -IF:/Projects/Libraries/DerelictSDL2/source -ofDrawClient
rm -f DrawClient.obj
./DrawClient.exe