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

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/cmake/ios.toolchain.cmake
        CACHE PATH "Select android toolchain file path")

set (IOS ON)

set(NGS_APPLE_BUNDLE_NAME "NGS")
set(NGS_APPLE_BUNDLE_ID "com.nextgis")

if(IOS)
  configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake/Info.plist.in"
                 "${CMAKE_BINARY_DIR}/ios/Info.plist")
elseif(APPLE)
  configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake/Info.plist.in"
                 "${CMAKE_BINARY_DIR}/osx/Info.plist")
endif()
