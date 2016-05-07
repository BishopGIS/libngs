################################################################################
#  Project: libngmap
#  Purpose: NextGIS native mapping library
#  Author: Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
#  Language: C/C++
################################################################################
#  GNU General Public License v2
#
#  Copyright (c) 2016 NextGIS, <info@nextgis.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
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

# http://ph0b.com/new-android-studio-ndk-support/
# http://ph0b.com/android-studio-gradle-and-ndk-integration/
# http://www.sitepoint.com/using-c-and-c-code-in-an-android-app-with-the-ndk/
# https://habrahabr.ru/post/203014/
# http://kvurd.com/blog/compiling-a-cpp-library-for-android-with-android-studio/
# http://stackoverflow.com/questions/19343797/building-a-toolchain-with-cmake-to-cross-compile-for-android
# https://habrahabr.ru/company/alawar/blog/216473/
# https://github.com/taka-no-me/android-cmake
# https://github.com/Uroc327Mirrors/pixellight/blob/master/cmake/Android/Apk.cmake
# https://github.com/Discordia/android-cmake/blob/master/android.apk.cmake
# http://stackoverflow.com/questions/19207721/build-android-ndk-project-with-cmake
# https://github.com/libmx3/mx3/tree/master/src
# https://github.com/mapbox/mapbox-gl-native/tree/master/platform/ios
 
cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

# some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

set(BUILD_TARGET_PLATFORM "Desktop" CACHE STRING "Select build target platform")
set_property(CACHE BUILD_TARGET_PLATFORM PROPERTY STRINGS "ANDROID" "IOS" "Desktop")

if(BUILD_TARGET_PLATFORM STREQUAL "ANDROID")
    include(android)
endif()

project(ngmap)

include(GNUInstallDirs)
set(INSTALL_BIN_DIR ${CMAKE_INSTALL_BINDIR} CACHE INTERNAL "Installation directory for executables" FORCE)
set(INSTALL_LIB_DIR ${CMAKE_INSTALL_LIBDIR} CACHE INTERNAL "Installation directory for libraries" FORCE)
set(INSTALL_INC_DIR ${CMAKE_INSTALL_INCLUDEDIR} CACHE INTERNAL "Installation directory for headers" FORCE)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  add_definitions(-D_DEBUG)
endif()

include(util)

configure_file(${CMAKE_MODULE_PATH}/uninstall.cmake.in ${CMAKE_BINARY_DIR}/cmake_uninstall.cmake IMMEDIATE @ONLY)

check_version(NGM_MAJOR_VERSION NGM_MINOR_VERSION NGM_REV_VERSION)
set(VERSION ${NGM_MAJOR_VERSION}.${NGM_MINOR_VERSION}.${NGM_REV_VERSION})
set(SOVERSION 1)

report_version(${PROJECT_NAME} ${VERSION})

set(TARGET_LIBS "")

add_subdirectory(src)
add_subdirectory(bindings)

# uninstall
add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)