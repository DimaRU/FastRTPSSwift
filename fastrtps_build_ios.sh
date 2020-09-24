#!/bin/bash
#
# fastrtps_build_ios.sh
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
cmake \
-H"$SRCROOT/memory" \
-B"$PROJECT_TEMP_DIR/memory" \
-D CMAKE_TOOLCHAIN_FILE="$SRCROOT/cmake/ios.toolchain.cmake" \
-D CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
-D CMAKE_IOS_INSTALL_COMBINED=YES \
-D IOS_DEPLOYMENT_SDK_VERSION=$IPHONEOS_DEPLOYMENT_TARGET \
-D CMAKE_INSTALL_PREFIX="$BUILT_PRODUCTS_DIR/fastrtps" \
-D CMAKE_CONFIGURATION_TYPES=Release \
-D FOONATHAN_MEMORY_BUILD_EXAMPLES=OFF \
-D FOONATHAN_MEMORY_BUILD_TESTS=OFF \
-D FOONATHAN_MEMORY_BUILD_TOOLS=OFF \
-G Xcode

cmake --build "$PROJECT_TEMP_DIR/memory" --target ZERO_CHECK
cmake --build "$PROJECT_TEMP_DIR/memory" --config Release --target install --

if [ ! -d Fast-DDS ]; then
git clone --quiet --recurse-submodules --depth 1 $FastRTPS_repo Fast-DDS
fi
rm -rf "$PROJECT_TEMP_DIR/Fast-DDS"
cmake \
-H"$SRCROOT/Fast-DDS" \
-B"$PROJECT_TEMP_DIR/Fast-DDS" \
-D CMAKE_TOOLCHAIN_FILE="$SRCROOT/cmake/ios.toolchain.cmake" \
-D CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
-D CMAKE_IOS_INSTALL_COMBINED=YES \
-D CMAKE_CONFIGURATION_TYPES="${CONFIGURATION}" \
-D CMAKE_DEBUG_POSTFIX="" \
-D BUILD_SHARED_LIBS=NO \
-D IOS_DEPLOYMENT_SDK_VERSION=$IPHONEOS_DEPLOYMENT_TARGET \
-D CMAKE_INSTALL_PREFIX="$BUILT_PRODUCTS_DIR/fastrtps" \
-D foonathan_memory_DIR="$BUILT_PRODUCTS_DIR/fastrtps/foonathan_memory/cmake" \
-D SQLITE3_SUPPORT=OFF \
-D THIRDPARTY=ON \
-D COMPILE_EXAMPLES=OFF \
-D BUILD_DOCUMENTATION=OFF \
-G Xcode

cmake --build "$PROJECT_TEMP_DIR/Fast-DDS" --target ZERO_CHECK
cmake --build "$PROJECT_TEMP_DIR/Fast-DDS" --config ${CONFIGURATION} --target install --
