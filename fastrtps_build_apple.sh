#!/bin/bash
#
# fastrtps_build_apple.sh
# Copyright © 2019 Dmitriy Borovikov. All rights reserved.
#
set -e
echo $PLATFORM_DISPLAY_NAME$EFFECTIVE_PLATFORM_NAME $ARCHS

if [ -f "$BUILT_PRODUCTS_DIR/fastrtps/lib/libfastrtps.a" ]; then
echo Already build "$BUILT_PRODUCTS_DIR/fastrtps/lib/libfastrtps.a"
exit 0
fi

FastRTPS_repo="-b feature/remote-whitelist-2.0.1 https://github.com/DimaRU/Fast-DDS.git"
Foonathan_memory_repo="-b ios https://github.com/DimaRU/memory.git"
export CMAKE_BUILD_PARALLEL_LEVEL=$(sysctl hw.ncpu | awk '{print $2}')

if [[ $ARCHS = *" "* ]]; then
    COMBINED="YES"
else
    COMBINED="NO"
fi

if [ ! -d memory ]; then
git clone --quiet --recurse-submodules --depth 1 $Foonathan_memory_repo memory
fi
if [ ! -d Fast-DDS ]; then
git clone --quiet --recurse-submodules --depth 1 $FastRTPS_repo Fast-DDS
fi

rm -rf "$PROJECT_TEMP_DIR/memory"
rm -rf "$PROJECT_TEMP_DIR/Fast-DDS"


if [ "$PLATFORM_NAME" = "macosx" ]; then
  if [ "$EFFECTIVE_PLATFORM_NAME" = "-maccatalyst" ]; then
export CATALYST_BUILD_FLAGS="-target $ARCHS-$LLVM_TARGET_TRIPLE_VENDOR-$LLVM_TARGET_TRIPLE_OS_VERSION-$LLVM_TARGET_TRIPLE_SUFFIX -Wno-overriding-t-option"
cmake -Smemory -B"$PROJECT_TEMP_DIR/memory" \
-D CMAKE_INSTALL_PREFIX=$BUILT_PRODUCTS_DIR/fastrtps \
-D CMAKE_TOOLCHAIN_FILE=$SRCROOT/cmake/maccatalyst.toolchain.cmake \
-D FOONATHAN_MEMORY_BUILD_EXAMPLES=OFF \
-D FOONATHAN_MEMORY_BUILD_TESTS=OFF \
-D FOONATHAN_MEMORY_BUILD_TOOLS=OFF \
-D CMAKE_BUILD_TYPE=Release
cmake --build "$PROJECT_TEMP_DIR/memory" --target install

cmake -SFast-DDS -B"$PROJECT_TEMP_DIR/Fast-DDS" \
-D CMAKE_INSTALL_PREFIX=$BUILT_PRODUCTS_DIR/fastrtps \
-D CMAKE_TOOLCHAIN_FILE=$SRCROOT/cmake/maccatalyst.toolchain.cmake \
-D foonathan_memory_DIR=$BUILT_PRODUCTS_DIR/fastrtps/share/foonathan_memory/cmake \
-D SQLITE3_SUPPORT=OFF \
-D THIRDPARTY=ON \
-D COMPILE_EXAMPLES=OFF \
-D BUILD_DOCUMENTATION=OFF \
-D BUILD_SHARED_LIBS=OFF \
-D CMAKE_BUILD_TYPE=$CONFIGURATION
cmake --build "$PROJECT_TEMP_DIR/Fast-DDS" --target install

  else
cmake -Smemory -B"$PROJECT_TEMP_DIR/memory" \
-D CMAKE_INSTALL_PREFIX=$BUILT_PRODUCTS_DIR/fastrtps \
-D FOONATHAN_MEMORY_BUILD_EXAMPLES=OFF \
-D FOONATHAN_MEMORY_BUILD_TESTS=OFF \
-D FOONATHAN_MEMORY_BUILD_TOOLS=ON \
-D CMAKE_BUILD_TYPE=Release
cmake --build "$PROJECT_TEMP_DIR/memory" --target install

cmake -SFast-DDS -B"$PROJECT_TEMP_DIR/Fast-DDS" \
-D CMAKE_INSTALL_PREFIX=$BUILT_PRODUCTS_DIR/fastrtps \
-D foonathan_memory_DIR=$BUILT_PRODUCTS_DIR/fastrtps/share/foonathan_memory/cmake \
-D SQLITE3_SUPPORT=OFF \
-D THIRDPARTY=ON \
-D COMPILE_EXAMPLES=OFF \
-D BUILD_DOCUMENTATION=OFF \
-D BUILD_SHARED_LIBS=OFF \
-D CMAKE_BUILD_TYPE=$CONFIGURATION
cmake --build "$PROJECT_TEMP_DIR/Fast-DDS" --target install

  fi
fi

if [ "$PLATFORM_NAME" = "iphoneos" ] || [ "$PLATFORM_NAME" = "iphonesimulator" ]; then
cmake -Smemory -B"$PROJECT_TEMP_DIR/memory" \
-D CMAKE_TOOLCHAIN_FILE="$SRCROOT/cmake/ios.toolchain.cmake" \
-D CMAKE_IOS_INSTALL_COMBINED=$COMBINED \
-D CMAKE_INSTALL_PREFIX="$BUILT_PRODUCTS_DIR/fastrtps" \
-D CMAKE_CONFIGURATION_TYPES=Release \
-D FOONATHAN_MEMORY_BUILD_EXAMPLES=OFF \
-D FOONATHAN_MEMORY_BUILD_TESTS=OFF \
-D FOONATHAN_MEMORY_BUILD_TOOLS=OFF \
-G Xcode

cmake --build "$PROJECT_TEMP_DIR/memory" --config Release --target install --

cmake -SFast-DDS -B"$PROJECT_TEMP_DIR/Fast-DDS" \
-D CMAKE_TOOLCHAIN_FILE="$SRCROOT/cmake/ios.toolchain.cmake" \
-D CMAKE_IOS_INSTALL_COMBINED=$COMBINED \
-D CMAKE_CONFIGURATION_TYPES="${CONFIGURATION}" \
-D CMAKE_DEBUG_POSTFIX="" \
-D BUILD_SHARED_LIBS=NO \
-D CMAKE_INSTALL_PREFIX="$BUILT_PRODUCTS_DIR/fastrtps" \
-D foonathan_memory_DIR="$BUILT_PRODUCTS_DIR/fastrtps/foonathan_memory/cmake" \
-D SQLITE3_SUPPORT=OFF \
-D THIRDPARTY=ON \
-D COMPILE_EXAMPLES=OFF \
-D BUILD_DOCUMENTATION=OFF \
-G Xcode

cmake --build "$PROJECT_TEMP_DIR/Fast-DDS" --config ${CONFIGURATION} --target install --
fi
