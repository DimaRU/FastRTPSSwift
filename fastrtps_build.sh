#!/bin/bash
export MACOSX_DEPLOYMENT_TARGET=10.14
#git submodule update --init --recursive
mkdir temp && cd temp
cmake -DCMAKE_INSTALL_PREFIX=../build -DCMAKE_BUILD_TYPE=Release ../foonathan_memory_vendor
cmake --build . --target install
cd .. && rm -rf temp
mkdir temp && cd temp
cmake -Dfoonathan_memory_DIR=../build/share/foonathan_memory/cmake -DCMAKE_INSTALL_PREFIX=../build -DTHIRDPARTY=ON -INTERNALDEBUG=ON -DCMAKE_BUILD_TYPE="$1" ../Fast-RTPS
cmake --build . --target install
cd .. && rm -rf temp
mkdir Framework || true
cp build/lib/libfastrtps.1.dylib Framework/
cp build/lib/libfastcdr.1.dylib Framework/
