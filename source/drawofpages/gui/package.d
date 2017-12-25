/* DrawOfPages: Take notes with touchscreen input.
 * Copyright (C) 2017  Marko Semet(Marko10_000)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
module drawofpages.gui;

private import drawofpages.draw;

public enum CURSOR_TYPE
{
	MOUSE,
	PEN,
	ERASER,
	HAND
}

public interface GuiInteraction
{
	void down(Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID);
	void contin(Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID);
	void up(Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID);
	void redraw(Square square, Draw target);
}
