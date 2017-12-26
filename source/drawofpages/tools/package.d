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
module drawofpages.tools;

private
{
	import drawofpages.draw;
	import drawofpages.elements.basetypes;
	import drawofpages.gui;
	import structuresd.dimension;
	import structuresd.dimension.rtree;
}

public class Document
{
	public RTree!(Line, Cuboid!2, 127, 64) data;

	public this()
	{
		this.data = new RTree!(Line, Cuboid!2, 127, 64)();
	}

	public void redraw(Square area, Draw target)
	{
		foreach(Line line; this.data.query(area))
		{
			target.drawLine(line.a, line.b, line.size, line.color);
		}
	}
}

public interface Tool
{
	void cursorDown(Document doc, Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID);
	void cursorContin(Document doc, Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID);
	void cursorUp(Document doc, Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID);
}

private class VoidTool : Tool
{
	void cursorDown(Document doc, Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID) {}
	void cursorContin(Document doc, Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID) {}
	void cursorUp(Document doc, Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID) {}
}

public __gshared Tool voidTool = new VoidTool();

public mixin template CURSOR_FROM_TO()
{
	private Point2D __cursorPosition;
	private double __cursorPressure;

	public void cursorDown(Document doc, Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID)
	{
		this.__cursorPosition = point;
		this.__cursorPressure = pressure;
	}
	public void cursorContin(Document doc, Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID)
	{
		this._cursorFromTo(doc, this.__cursorPosition, this.__cursorPressure, point, pressure, cursor, cursorID);
		this.__cursorPosition = point;
		this.__cursorPressure = pressure;
	}
	public void cursorUp(Document doc, Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID)
	{
		this._cursorFromTo(doc, this.__cursorPosition, this.__cursorPressure, point, pressure, cursor, cursorID);
	}
	private void _cursorFromTo(Document doc, Point2D from, double fromPressure, Point2D to, double toPressure, CURSOR_TYPE cursor, string cursorID);
}
