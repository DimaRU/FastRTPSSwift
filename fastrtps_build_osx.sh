#!/bin/bash
#
# fastrtps_build_osx.sh
# Copyright © 2019 Dmitriy Borovikov. All rights reserved.
#
set -e

if [ -f "$BUILT_PRODUCTS_DIR/fastrtps/lib/libfastrtps.a" ]; then
echo Already build "$BUILT_PRODUCTS_DIR/fastrtps/lib/libfastrtps.a"
exit 0
fi

export CMAKE_BUILD_PARALLEL_LEVEL=$(sysctl hw.ncpu | awk '{print $2}')

if [ ! -d memory ]; then
git clone --quiet --recurse-submodules --depth 1 -b ios $Foonathan_memory_repo memory
fi
rm -rf "$PROJECT_TEMP_DIR/memory"
cmake -Smemory -B"$PROJECT_TEMP_DIR/memory" \
-DCMAKE_INSTALL_PREFIX=$BUILT_PRODUCTS_DIR/fastrtps \
-DFOONATHAN_MEMORY_BUILD_EXAMPLES=OFF \
-DFOONATHAN_MEMORY_BUILD_TESTS=OFF \
-DFOONATHAN_MEMORY_BUILD_TOOLS=ON \
-DCMAKE_BUILD_TYPE=Release
cmake --build "$PROJECT_TEMP_DIR/memory" --target install

if [ ! -d Fast-DDS ]; then
git clone --quiet --recurse-submodules --depth 1 $FastRTPS_repo Fast-DDS
fi
rm -rf "$PROJECT_TEMP_DIR/Fast-DDS"
cmake -SFast-DDS -B"$PROJECT_TEMP_DIR/Fast-DDS" \
-DCMAKE_INSTALL_PREFIX=$BUILT_PRODUCTS_DIR/fastrtps \
-Dfoonathan_memory_DIR=$BUILT_PRODUCTS_DIR/fastrtps/share/foonathan_memory/cmake \
-DSQLITE3_SUPPORT=OFF \
-DTHIRDPARTY=ON \
-DBUILD_SHARED_LIBS=OFF \
-DCMAKE_BUILD_TYPE=$CONFIGURATION
cmake --build "$PROJECT_TEMP_DIR/Fast-DDS" --target install
