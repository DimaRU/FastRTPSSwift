#!/bin/bash
set -e
#git submodule update --init --recursive
echo "$1" # Build type
echo MACOSX_DEPLOYMENT_TARGET="$MACOSX_DEPLOYMENT_TARGET"
rm -rf $PROJECT_TEMP_DIR/memory
mkdir -p $PROJECT_TEMP_DIR/memory || true
cmake -Sfoonathan_memory_vendor -B$PROJECT_TEMP_DIR/memory -DCMAKE_INSTALL_PREFIX=build/osx -DCMAKE_BUILD_TYPE="$1"
cmake --build $PROJECT_TEMP_DIR/memory --target install
rm -rf $PROJECT_TEMP_DIR/Fast-RTPS
mkdir -p $PROJECT_TEMP_DIR/Fast-RTPS || true
cmake -SFast-RTPS -B$PROJECT_TEMP_DIR/Fast-RTPS -Dfoonathan_memory_DIR=build/osx/share/foonathan_memory/cmake -DCMAKE_INSTALL_PREFIX=build/osx -DTHIRDPARTY=ON -DCMAKE_BUILD_TYPE="$1"
cmake --build $PROJECT_TEMP_DIR/Fast-RTPS --target install
mkdir Framework || true
cp build/osx/lib/libfastrtps.1.dylib Framework/
cp build/osx/lib/libfastcdr.1.dylib Framework/
