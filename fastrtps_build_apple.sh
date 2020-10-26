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
Foonathan_memory_repo="-b crosscompile https://github.com/DimaRU/memory.git"
export CMAKE_BUILD_PARALLEL_LEVEL=$(sysctl hw.ncpu | awk '{print $2}')

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
cmake -Smemory -B"$PROJECT_TEMP_DIR/memory" \
-D CMAKE_INSTALL_PREFIX=$BUILT_PRODUCTS_DIR/fastrtps \
-D CMAKE_TOOLCHAIN_FILE=$SRCROOT/cmake/maccatalyst.toolchain.cmake \
-D FOONATHAN_MEMORY_BUILD_EXAMPLES=OFF \
-D FOONATHAN_MEMORY_BUILD_TESTS=OFF \
-D FOONATHAN_MEMORY_BUILD_TOOLS=OFF \
-D CMAKE_DEBUG_POSTFIX="" \
-D CMAKE_OSX_DEPLOYMENT_TARGET="10.15" \
-D CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET="13.0" \
-D CMAKE_CONFIGURATION_TYPES=Release \
-G Xcode

xcodebuild build -scheme install -destination 'generic/platform=macOS,variant=Mac Catalyst' -project "$PROJECT_TEMP_DIR/memory/FOONATHAN_MEMORY.xcodeproj"

cmake -SFast-DDS -B"$PROJECT_TEMP_DIR/Fast-DDS" \
-D CMAKE_INSTALL_PREFIX=$BUILT_PRODUCTS_DIR/fastrtps \
-D CMAKE_TOOLCHAIN_FILE=$SRCROOT/cmake/maccatalyst.toolchain.cmake \
-D foonathan_memory_DIR=$BUILT_PRODUCTS_DIR/fastrtps/share/foonathan_memory/cmake \
-D SQLITE3_SUPPORT=OFF \
-D THIRDPARTY=ON \
-D COMPILE_EXAMPLES=OFF \
-D BUILD_DOCUMENTATION=OFF \
-D BUILD_SHARED_LIBS=OFF \
-D CMAKE_OSX_DEPLOYMENT_TARGET="10.15" \
-D CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET="13.0" \
-D CMAKE_CONFIGURATION_TYPES=$CONFIGURATION \
-G Xcode

xcodebuild build -scheme install -destination 'generic/platform=macOS,variant=Mac Catalyst' -project "$PROJECT_TEMP_DIR/Fast-DDS/fastrtps.xcodeproj"

  else
cmake -Smemory -B"$PROJECT_TEMP_DIR/memory" \
-D CMAKE_INSTALL_PREFIX=$BUILT_PRODUCTS_DIR/fastrtps \
-D FOONATHAN_MEMORY_BUILD_EXAMPLES=OFF \
-D FOONATHAN_MEMORY_BUILD_TESTS=OFF \
-D FOONATHAN_MEMORY_BUILD_TOOLS=ON \
-D CMAKE_OSX_ARCHITECTURES="$ARCHS" \
-D CMAKE_CONFIGURATION_TYPES=Release \
-G Xcode
cmake --build "$PROJECT_TEMP_DIR/memory" --target install

cmake -SFast-DDS -B"$PROJECT_TEMP_DIR/Fast-DDS" \
-D CMAKE_INSTALL_PREFIX=$BUILT_PRODUCTS_DIR/fastrtps \
-D foonathan_memory_DIR=$BUILT_PRODUCTS_DIR/fastrtps/share/foonathan_memory/cmake \
-D SQLITE3_SUPPORT=OFF \
-D THIRDPARTY=ON \
-D COMPILE_EXAMPLES=OFF \
-D BUILD_DOCUMENTATION=OFF \
-D BUILD_SHARED_LIBS=OFF \
-D CMAKE_OSX_ARCHITECTURES="$ARCHS" \
-D CMAKE_CONFIGURATION_TYPES="${CONFIGURATION}" \
-G Xcode

cmake --build "$PROJECT_TEMP_DIR/Fast-DDS" --target install

  fi
fi

if [ "$PLATFORM_NAME" = "iphoneos" ] || [ "$PLATFORM_NAME" = "iphonesimulator" ]; then
cmake -Smemory -B"$PROJECT_TEMP_DIR/memory" \
-D CMAKE_TOOLCHAIN_FILE="$SRCROOT/cmake/ios.toolchain.cmake" \
-D CMAKE_IOS_INSTALL_COMBINED=$COMBINED \
-D CMAKE_INSTALL_PREFIX="$BUILT_PRODUCTS_DIR/fastrtps" \
-D CMAKE_CONFIGURATION_TYPES=Release \
-D CMAKE_C_COMPILER=clang \
-D CMAKE_CXX_COMPILER=clang++ \
-D FOONATHAN_MEMORY_BUILD_EXAMPLES=OFF \
-D FOONATHAN_MEMORY_BUILD_TESTS=OFF \
-D FOONATHAN_MEMORY_BUILD_TOOLS=OFF \
-G Xcode

cmake --build "$PROJECT_TEMP_DIR/memory" --config Release --target install --

cmake -SFast-DDS -B"$PROJECT_TEMP_DIR/Fast-DDS" \
-D CMAKE_TOOLCHAIN_FILE="$SRCROOT/cmake/ios.toolchain.cmake" \
-D CMAKE_CONFIGURATION_TYPES="${CONFIGURATION}" \
-D CMAKE_DEBUG_POSTFIX="" \
-D BUILD_SHARED_LIBS=NO \
-D CMAKE_INSTALL_PREFIX="$BUILT_PRODUCTS_DIR/fastrtps" \
-D foonathan_memory_DIR="$BUILT_PRODUCTS_DIR/fastrtps/foonathan_memory/cmake" \
-D SQLITE3_SUPPORT=OFF \
-D THIRDPARTY=ON \
-D COMPILE_EXAMPLES=OFF \
-D BUILD_DOCUMENTATION=OFF \
-D CMAKE_C_COMPILER=clang \
-D CMAKE_CXX_COMPILER=clang++ \
-G Xcode

cmake --build "$PROJECT_TEMP_DIR/Fast-DDS" --config ${CONFIGURATION} --target install --
fi
