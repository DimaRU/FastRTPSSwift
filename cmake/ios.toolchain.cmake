#include("${CMAKE_CURRENT_LIST_DIR}/Utilities.cmake")

set(MACOSX_BUNDLE_GUI_IDENTIFIER in.ioshack)
set(CMAKE_MACOSX_BUNDLE YES)
set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED NO)

unset(CMAKE_XCODE_ATTRIBUTE_INSTALL_PATH)
set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++")

set(CMAKE_OSX_SYSROOT "iphoneos")

set(CMAKE_CXX_FLAGS "-std=c++14 -Wno-shorten-64-to-32")
set(CMAKE_XCODE_ATTRIBUTE_SUPPORTED_PLATFORMS "iphoneos iphonesimulator")
set(CMAKE_XCODE_EFFECTIVE_PLATFORMS "-iphoneos;-iphonesimulator")
set(CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "12.1")
set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "")
set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO")

set(IPHONEOS_ARCHS arm64 arm64e)
set(IPHONESIMULATOR_ARCHS x86_64)

# Set iPhoneOS architectures
set(archs "")
foreach(arch ${IPHONEOS_ARCHS})
  set(archs "${archs} ${arch}")
endforeach()
set(CMAKE_XCODE_ATTRIBUTE_ARCHS[sdk=iphoneos*] "${archs}")
set(CMAKE_XCODE_ATTRIBUTE_VALID_ARCHS[sdk=iphoneos*] "${archs}")

# Set iPhoneSimulator architectures
set(archs "")
foreach(arch ${IPHONESIMULATOR_ARCHS})
  set(archs "${archs} ${arch}")
endforeach()
set(CMAKE_XCODE_ATTRIBUTE_ARCHS[sdk=iphonesimulator*] "${archs}")
set(CMAKE_XCODE_ATTRIBUTE_VALID_ARCHS[sdk=iphonesimulator*] "${archs}")


set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE[sdk=iphone*] "YES")
set(CMAKE_XCODE_ATTRIBUTE_BITCODE_GENERATION_MODE "\$(BITCODE_GENERATION_MODE_\$(CONFIGURATION))")
set(CMAKE_XCODE_ATTRIBUTE_BITCODE_GENERATION_MODE_Debug "marker")
set(CMAKE_XCODE_ATTRIBUTE_BITCODE_GENERATION_MODE_Release "bitcode")
