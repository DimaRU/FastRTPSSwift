#!/bin/bash
#
# fastrtps_build_ios.sh
# Copyright © 2019 Dmitriy Borovikov. All rights reserved.
#
set -e
echo "$CONFIGURATION" # Build type

if [ -f "$BUILT_PRODUCTS_DIR/fastrtps/lib/libfastrtps.a" ]; then
echo Already build "$BUILT_PRODUCTS_DIR/fastrtps/lib/libfastrtps.a"
exit 0
fi

export POLLY_IOS_DEVELOPMENT_TEAM=$DEVELOPMENT_TEAM
export CMAKE_BUILD_PARALLEL_LEVEL=$(sysctl hw.ncpu | awk '{print $2}')

export PATH=$HOME/Developer/tools/polly/bin:$PATH
if ! which polly > /dev/null; then
  echo "error: polly is not installed. Vistit https://github.com/ruslo/polly to learn more."
  exit 1
fi

if [ ! -d memory ]; then
git clone --quiet --recurse-submodules --depth 1 -b ios $Foonathan_memory_repo memory
fi
rm -rf "$PROJECT_TEMP_DIR/memory"
mkdir -p "$PROJECT_TEMP_DIR/memory" || true
polly.py --toolchain ios \
--install --ios-combined --ios-multiarch \
--config Release \
--home memory \
--output "$PROJECT_TEMP_DIR/memory" \
--fwd CMAKE_CONFIGURATION_TYPES=Release \
IOS_DEPLOYMENT_SDK_VERSION=$IPHONEOS_DEPLOYMENT_TARGET \
CMAKE_INSTALL_PREFIX=$BUILT_PRODUCTS_DIR/fastrtps \
FOONATHAN_MEMORY_BUILD_EXAMPLES=OFF \
FOONATHAN_MEMORY_BUILD_TESTS=OFF \
FOONATHAN_MEMORY_BUILD_TOOLS=OFF

rm -rf $PROJECT_TEMP_DIR/Fast-RTPS
if [ ! -d Fast-RTPS ]; then
git clone --quiet --recurse-submodules --depth 1 $FastRTPS_repo Fast-RTPS
fi
mkdir -p "$PROJECT_TEMP_DIR/Fast-RTPS" || true
polly.py --toolchain ios \
--install --ios-combined --ios-multiarch \
--config $CONFIGURATION \
--home Fast-RTPS \
--output "$PROJECT_TEMP_DIR/Fast-RTPS" \
--fwd CMAKE_CONFIGURATION_TYPES=$CONFIGURATION \
CMAKE_DEBUG_POSTFIX="" \
IOS_DEPLOYMENT_SDK_VERSION=$IPHONEOS_DEPLOYMENT_TARGET \
BUILD_SHARED_LIBS=NO \
CMAKE_INSTALL_PREFIX=$BUILT_PRODUCTS_DIR/fastrtps \
foonathan_memory_DIR=$BUILT_PRODUCTS_DIR/fastrtps/foonathan_memory/cmake \
THIRDPARTY=ON \
COMPILE_EXAMPLES=OFF \
BUILD_DOCUMENTATION=OFF
