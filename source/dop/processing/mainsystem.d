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
module dop.processing.mainsystem;

private
{
    import dop.structures.base;
}

public
{
    /++
     + Interface for the main system to communicate with platform implementation
     +/
    interface BaseSystemCallbacks
    {
        /++
         + Callback when the color was set.
         + Params:
         +     color = The new color
         +/
        shared void setCurrentColor(ColorRGBA color);
        /++
         + Callback when the brush size was set.
         + Params:
         +     size = The new brush size
         +/
        shared void setCurrentSize(float size);

        /++
         + Quit the application
         +/
        shared void quit();
    }

    /++
     + Main system that manage drawing
     +/
    class MainSystem
    {
        private
        {
            shared BaseSystemCallbacks __callbacks;

            ColorRGBA __currentColor;
            float __currentSize = 1;

            this() {}
        }
        public
        {
            /++
             + Creates a new main system
             + Params:
             +     callbaks = Callbacks to the base system implementation
             +/
            shared this(shared BaseSystemCallbacks callbacks)
            in
            {
                assert(callbacks !is null);
            }
            do
            {
                this.__callbacks = callbacks;
            }

            /++
             + Finialize the initalization of the programm
             +/
            shared void finalizeInit()
            {
                // Inform frontend of the current configuration
                this.__callbacks.setCurrentColor(this.__currentColor);
                this.__callbacks.setCurrentSize(this.__currentSize);
            }

            /++
             + Getter for the current color
             + Returns: The current color
             +/
            @property
            shared ColorRGBA currentColor()
            {
                return this.__currentColor;
            }
            /++
             + Setter for the current color
             + Params:
             +     color = The color to set
             + Returns: the current color
             +/
            @property
            shared synchronized ColorRGBA currentColor(ColorRGBA color)
            {
                this.__currentColor = color;
                this.__callbacks.setCurrentColor(color);
                return this.__currentColor;
            }

            /++
             + Getter for the current brush size
             + Returns: The current brush size
             +/
            @property
            shared float currentSize()
            {
                return this.__currentSize;
            }
            /++
             + Setter for the current brush size
             + Params:
             +     size = The new brush size
             + Returns: The new set brush size
             +/
            @property
            shared synchronized float currentSize(float size)
            {
                this.__currentSize = size;
                this.__callbacks.setCurrentSize(size);
                return this.__currentSize;
            }

            /++
             + Quit the application
             +/
            shared void quit()
            {
                this.__callbacks.quit();
            }
        }
    }
}