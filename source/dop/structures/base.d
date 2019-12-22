/* DrawOfPages: Take notes with touchscreen input.
 * Copyright (C) 2019  Marko Semet
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
module dop.structures.base;


public
{
    /++
     + Color in RGBA format
     +/
    struct ColorRGBA
    {
        double r = 0; /++ Red channel +/
        double g = 0; /++ Green channel +/
        double b = 0; /++ Blue channel +/
        double a = 1; /++ Alpha channel +/

        /++
         + Calculate the luminance of the color.
         + Returns: The luminance
         +/
        @property
        double getLuma() const
        {
            return ((65.481 * this.r) + (128.553 * this.g) + (24.966 * this.b)) / 255.;
        }
    }
}