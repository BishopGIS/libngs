################################################################################
#  Project: libngmap
#  Purpose: NextGIS native mapping library
#  Author: Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
#  Language: C/C++
################################################################################
#  GNU Lesser General Public Licens v3
#
#  Copyright (c) 2016 NextGIS, <info@nextgis.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

# some content get from here https://github.com/Itseez/opencv/blob/master/platforms/ios/cmake/Modules/Platform/iOS.cmake

if(NOT CMAKE_BUILD_TYPE STREQUAL "Debug" AND NOT CMAKE_BUILD_TYPE STREQUAL "Release")
    message(FATAL_ERROR "iOS not support build type ${CMAKE_BUILD_TYPE}")
endif()

if(IOS_SIMULATOR)
    set(CMAKE_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/cmake/iossimulator.toolchain.cmake
        CACHE PATH "Select android toolchain file path")
else()
    set(CMAKE_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/cmake/ios.toolchain.cmake
        CACHE PATH "Select android toolchain file path")
endif()

set (IOS ON)

# Darwin versions:
#   6.x == Mac OSX 10.2
#   7.x == Mac OSX 10.3
#   8.x == Mac OSX 10.4
#   9.x == Mac OSX 10.5
#  10.x == Mac OSX 10.6 (Snow Leopard)
string (REGEX REPLACE "^([0-9]+)\\.([0-9]+).*$" "\\1" DARWIN_MAJOR_VERSION "${CMAKE_SYSTEM_VERSION}")
string (REGEX REPLACE "^([0-9]+)\\.([0-9]+).*$" "\\2" DARWIN_MINOR_VERSION "${CMAKE_SYSTEM_VERSION}")

# Do not use the "-Wl,-search_paths_first" flag with the OSX 10.2 compiler.
# Done this way because it is too early to do a TRY_COMPILE.
if (NOT DEFINED HAVE_FLAG_SEARCH_PATHS_FIRST)
    set (HAVE_FLAG_SEARCH_PATHS_FIRST 0)
    if ("${DARWIN_MAJOR_VERSION}" GREATER 6)
        set (HAVE_FLAG_SEARCH_PATHS_FIRST 1)
    endif ()
endif ()
# More desirable, but does not work:
#INCLUDE(CheckCXXCompilerFlag)
#CHECK_CXX_COMPILER_FLAG("-Wl,-search_paths_first" HAVE_FLAG_SEARCH_PATHS_FIRST)

find_program(XCODE_CONFIG xcode-select)
if(NOT XCODE_CONFIG)
    message(FATAL_ERROR "iOS SDK is not install or xcode-select is not found")
endif()

exec_program(${XCODE_CONFIG} ARGS -print-path OUTPUT_VARIABLE XCODE_ROOT)
set(XCODE_ARM_ROOT "${XCODE_ROOT}/Platforms/iPhoneOS.platform/Developer")
set(XCODE_SIM_ROOT "${XCODE_ROOT}/Platforms/iPhoneSimulator.platform/Developer")
set(XCODE_TOOLCHAIN_BIN "${XCODE_ROOT}/Toolchains/XcodeDefault.xctoolchain/usr/bin")
set(CMAKE_CXX_COMPILER "${XCODE_TOOLCHAIN_BIN}/clang++")
set(CMAKE_C_COMPILER "${XCODE_TOOLCHAIN_BIN}/clang")
 
message(STATUS "cxx compiler: ${CMAKE_CXX_COMPILER}") 
 
set (CMAKE_C_OSX_COMPATIBILITY_VERSION_FLAG "-compatibility_version ")
set (CMAKE_C_OSX_CURRENT_VERSION_FLAG "-current_version ")
set (CMAKE_CXX_OSX_COMPATIBILITY_VERSION_FLAG "${CMAKE_C_OSX_COMPATIBILITY_VERSION_FLAG}")
set (CMAKE_CXX_OSX_CURRENT_VERSION_FLAG "${CMAKE_C_OSX_CURRENT_VERSION_FLAG}")

# Hidden visibilty is required for cxx on iOS
set (no_warn "-Wno-unused-function -Wno-overloaded-virtual")
set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${no_warn}")
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ -fvisibility=hidden -fvisibility-inlines-hidden ${no_warn}")

if(IOS_SIMULATOR)
    set(IOS_ABI "i386" CACHE STRING "Select IOS ABI")
    set_property(CACHE IOS_ABI PROPERTY STRINGS "i386" "x86_64")

    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -arch ${IOS_ABI} -mios-simulator-version-min=7.0")
else()
    set(IOS_ABI "armv7" CACHE STRING "Select IOS ABI")
    set_property(CACHE IOS_ABI PROPERTY STRINGS "armv7" "armv7s" "arm64")

    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -arch ${IOS_ABI}")
endif()

set (CMAKE_CXX_FLAGS_RELEASE "-DNDEBUG -O3 -fomit-frame-pointer -ffast-math")

if (HAVE_FLAG_SEARCH_PATHS_FIRST)
    set (CMAKE_C_LINK_FLAGS "-Wl,-search_paths_first ${CMAKE_C_LINK_FLAGS}")
    set (CMAKE_CXX_LINK_FLAGS "-Wl,-search_paths_first ${CMAKE_CXX_LINK_FLAGS}")
endif (HAVE_FLAG_SEARCH_PATHS_FIRST)

set (CMAKE_PLATFORM_HAS_INSTALLNAME 1)
set (CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS "-dynamiclib -headerpad_max_install_names")
set (CMAKE_SHARED_MODULE_CREATE_C_FLAGS "-bundle -headerpad_max_install_names")
set (CMAKE_SHARED_MODULE_LOADER_C_FLAG "-Wl,-bundle_loader,")
set (CMAKE_SHARED_MODULE_LOADER_CXX_FLAG "-Wl,-bundle_loader,")
set (CMAKE_FIND_LIBRARY_SUFFIXES ".dylib" ".so" ".a")

# hack: if a new cmake (which uses CMAKE_INSTALL_NAME_TOOL) runs on an old build tree
# (where install_name_tool was hardcoded) and where CMAKE_INSTALL_NAME_TOOL isn't in the cache
# and still cmake didn't fail in CMakeFindBinUtils.cmake (because it isn't rerun)
# hardcode CMAKE_INSTALL_NAME_TOOL here to install_name_tool, so it behaves as it did before, Alex
if (NOT DEFINED CMAKE_INSTALL_NAME_TOOL)
    find_program(CMAKE_INSTALL_NAME_TOOL install_name_tool)
endif (NOT DEFINED CMAKE_INSTALL_NAME_TOOL)

# Setup iOS developer location
if(IOS_SIMULATOR)
    set (_CMAKE_IOS_DEVELOPER_ROOT ${XCODE_SIM_ROOT})
else()
    set (_CMAKE_IOS_DEVELOPER_ROOT ${XCODE_ARM_ROOT})
endif()

# Find installed iOS SDKs
file (GLOB _CMAKE_IOS_SDKS "${_CMAKE_IOS_DEVELOPER_ROOT}/SDKs/*")

# Find and use the most recent iOS sdk
if (_CMAKE_IOS_SDKS)
    list (SORT _CMAKE_IOS_SDKS)
    list (REVERSE _CMAKE_IOS_SDKS)
    list (GET _CMAKE_IOS_SDKS 0 _CMAKE_IOS_SDK_ROOT)

    # Set the sysroot default to the most recent SDK
    set (CMAKE_OSX_SYSROOT ${_CMAKE_IOS_SDK_ROOT} CACHE PATH "Sysroot used for iOS support")
    message(STATUS "sysroot: ${CMAKE_OSX_SYSROOT}")

    set (CMAKE_OSX_ARCHITECTURES "$(IOS_ABI)" CACHE string  "Build architecture for iOS")

    # Set the default based on this file and not the environment variable
    set (CMAKE_FIND_ROOT_PATH ${_CMAKE_IOS_DEVELOPER_ROOT} ${_CMAKE_IOS_SDK_ROOT} CACHE string  "iOS library search path root")

    # default to searching for frameworks first
    set (CMAKE_FIND_FRAMEWORK FIRST)

    # set up the default search directories for frameworks
    set (CMAKE_SYSTEM_FRAMEWORK_PATH
        ${_CMAKE_IOS_SDK_ROOT}/System/Library/Frameworks
        ${_CMAKE_IOS_SDK_ROOT}/System/Library/PrivateFrameworks
        ${_CMAKE_IOS_SDK_ROOT}/Developer/Library/Frameworks
    )
endif (_CMAKE_IOS_SDKS)

if ("${CMAKE_BACKWARDS_COMPATIBILITY}" MATCHES "^1\\.[0-6]$")
    set (CMAKE_SHARED_MODULE_CREATE_C_FLAGS "${CMAKE_SHARED_MODULE_CREATE_C_FLAGS} -flat_namespace -undefined suppress")
endif ("${CMAKE_BACKWARDS_COMPATIBILITY}" MATCHES "^1\\.[0-6]$")

if (NOT XCODE)
      # Enable shared library versioning.  This flag is not actually referenced
      # but the fact that the setting exists will cause the generators to support
      # soname computation.
      set (CMAKE_SHARED_LIBRARY_SONAME_C_FLAG "-install_name")
endif (NOT XCODE)

# Xcode does not support -isystem yet.
if (XCODE)
    set (CMAKE_INCLUDE_SYSTEM_FLAG_C)
    set (CMAKE_INCLUDE_SYSTEM_FLAG_CXX)
endif (XCODE)

# Need to list dependent shared libraries on link line.  When building
# with -isysroot (for universal binaries), the linker always looks for
# dependent libraries under the sysroot.  Listing them on the link
# line works around the problem.
set (CMAKE_LINK_DEPENDENT_LIBRARY_FILES 1)

set (CMAKE_C_CREATE_SHARED_LIBRARY_FORBIDDEN_FLAGS -w)
set (CMAKE_CXX_CREATE_SHARED_LIBRARY_FORBIDDEN_FLAGS -w)

set (CMAKE_C_CREATE_SHARED_LIBRARY
    "<CMAKE_C_COMPILER> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS> <LINK_FLAGS> -o <TARGET> -install_name <TARGET_INSTALLNAME_DIR><TARGET_SONAME> <OBJECTS> <LINK_LIBRARIES>")
set (CMAKE_CXX_CREATE_SHARED_LIBRARY
    "<CMAKE_CXX_COMPILER> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <LINK_FLAGS> -o <TARGET> -install_name <TARGET_INSTALLNAME_DIR><TARGET_SONAME> <OBJECTS> <LINK_LIBRARIES>")

set (CMAKE_CXX_CREATE_SHARED_MODULE
    "<CMAKE_CXX_COMPILER> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_MODULE_CREATE_CXX_FLAGS> <LINK_FLAGS> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>")

set (CMAKE_C_CREATE_SHARED_MODULE
    "<CMAKE_C_COMPILER>  <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_MODULE_CREATE_C_FLAGS> <LINK_FLAGS> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>")

set (CMAKE_C_CREATE_MACOSX_FRAMEWORK
    "<CMAKE_C_COMPILER> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS> <LINK_FLAGS> -o <TARGET> -install_name <TARGET_INSTALLNAME_DIR><TARGET_SONAME> <OBJECTS> <LINK_LIBRARIES>")
set (CMAKE_CXX_CREATE_MACOSX_FRAMEWORK
    "<CMAKE_CXX_COMPILER> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <LINK_FLAGS> -o <TARGET> -install_name <TARGET_INSTALLNAME_DIR><TARGET_SONAME> <OBJECTS> <LINK_LIBRARIES>")


# Add the install directory of the running cmake to the search directories
# CMAKE_ROOT is CMAKE_INSTALL_PREFIX/share/cmake, so we need to go two levels up
get_filename_component (_CMAKE_INSTALL_DIR "${CMAKE_ROOT}" PATH)
get_filename_component (_CMAKE_INSTALL_DIR "${_CMAKE_INSTALL_DIR}" PATH)

# List common installation prefixes.  These will be used for all search types
list (APPEND CMAKE_SYSTEM_PREFIX_PATH
    # Standard
    ${_CMAKE_IOS_DEVELOPER_ROOT}/usr
    ${_CMAKE_IOS_SDK_ROOT}/usr

    # CMake install location
    "${_CMAKE_INSTALL_DIR}"

    # Project install destination.
    "${CMAKE_INSTALL_PREFIX}"
)

set(NGS_APPLE_BUNDLE_NAME "NGS")
set(NGS_APPLE_BUNDLE_ID "com.nextgis")

if(IOS)
  configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake/Info.plist.in"
                 "${CMAKE_BINARY_DIR}/ios/Info.plist")
elseif(APPLE)
  configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake/Info.plist.in"
                 "${CMAKE_BINARY_DIR}/osx/Info.plist")
endif()
