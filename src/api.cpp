/******************************************************************************
 * Project:  libngmap
 * Purpose:  NextGIS native mapping library
 * Author: Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
 ******************************************************************************
 *   Copyright (c) 2016 NextGIS, <info@nextgis.com>
 *
 *    This program is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU Lesser General Public License as published by
 *    the Free Software Foundation, either version 32 of the License, or
 *    (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 ****************************************************************************/
 
 #include "api.h"
 #include "version.h"
 
/**
 * @brief Get library version number as major * 10000 + minor * 100 + rev
 * @return library version number
 */
int GetVersion()
{
    return NGM_VERSION_NUM;
}

/**
 * @brief Get library version string
 * @return library version string
 */
const char* GetVersionString()
{
    return NGM_VERSION;
}
