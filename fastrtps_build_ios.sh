#!/bin/bash
export PATH=$HOME/Developer/tools/polly/bin:$PATH
set -e
echo "$1" # Build type
export POLLY_IOS_DEVELOPMENT_TEAM=$DEVELOPMENT_TEAM

if ! which polly > /dev/null; then
  echo "error: polly is not installed. Vistit https://github.com/DimaRU/polly.git to learn more."
  exit 1
fi

if [ ! -f "build/ios/lib/libfastrtps.1.dylib" ]; then
if [ ! -d memory ]; then
git clone --quiet --recurse-submodules -b ios https://github.com/DimaRU/memory.git
fi
rm -rf "$PROJECT_TEMP_DIR/memory"
mkdir -p "$PROJECT_TEMP_DIR/memory" || true
polly.py --toolchain ios-13-1-dep-12-1-x86-64-arm64 \
--verbose --install --ios-combined --ios-multiarch \
--config Release \
--home memory \
--output "$PROJECT_TEMP_DIR/memory" \
--fwd CMAKE_CONFIGURATION_TYPES=Release \
CMAKE_INSTALL_PREFIX=build/ios \
FOONATHAN_MEMORY_BUILD_EXAMPLES=OFF \
FOONATHAN_MEMORY_BUILD_TESTS=OFF \
FOONATHAN_MEMORY_BUILD_TOOLS=OFF

rm -rf $PROJECT_TEMP_DIR/Fast-RTPS
if [ ! -d Fast-RTPS ]; then
git clone --quiet --recurse-submodules https://github.com/DimaRU/Fast-RTPS.git
fi
mkdir -p "$PROJECT_TEMP_DIR/Fast-RTPS" || true
polly.py --toolchain ios-13-1-dep-12-1-x86-64-arm64 \
--verbose --install --ios-combined --ios-multiarch \
--config $1 \
--home Fast-RTPS \
--output "$PROJECT_TEMP_DIR/Fast-RTPS" \
--fwd CMAKE_CONFIGURATION_TYPES=$1 \
BUILD_SHARED_LIBS=YES \
EXPORT_FILE=NO \
CMAKE_INSTALL_PREFIX=build/ios \
foonathan_memory_DIR=build/ios/foonathan_memory/cmake \
THIRDPARTY=ON \
BUILD_JAVA=OFF \
COMPILE_EXAMPLES=OFF \
BUILD_DOCUMENTATION=OFF
fi
