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
module drawofpages.elements;

private
{
	import drawofpages.draw;
	import drawofpages.elements.basetypes;
	import drawofpages.gui;
	import structuresd.dimension;
	import structuresd.dimension.rtree;
}

public class Interaction : GuiInteraction
{
	private Point2D c;
	private Draw draw;
	private RTree!(Line, Cuboid!2, 127, 64) data;

	public this(Draw draw)
	{
		this.draw = draw;
		this.data = new RTree!(Line, Cuboid!2, 127, 64);
	}

	public void down(Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID)
	{
		this.c = point;
	}
	public void contin(Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID)
	{
		this.draw.drawLine(this.c, point, 2, Color.BLUE);
		this.data.insert(Line(Point!2([this.c.dims[0], this.c.dims[1]]), Point!2([point.dims[0], point.dims[1]]), 2));
		this.draw.redraw();
		this.c = point;
	}
	public void up(Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID)
	{
		this.draw.drawLine(this.c, point, 2, Color.BLUE);
		this.data.insert(Line(Point!2([this.c.dims[0], this.c.dims[1]]), Point!2([point.dims[0], point.dims[1]]), 2));
		this.draw.redraw();
	}
	public void redraw(Square area, Draw target)
	{
		foreach(Line line; this.data.query(area))
		{
			target.drawLine(line.a, line.b, line.size, Color.RED);
		}
	}
}
