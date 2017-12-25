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
module drawofpages.tools.drawer;

private
{
	import drawofpages.draw;
	import drawofpages.elements.basetypes;
	import drawofpages.gui;
	import drawofpages.tools;
}

public final class DrawLine : Tool
{
	mixin CURSOR_FROM_TO!();

	private Draw draw;

	public this(Draw draw)
	{
		this.draw = draw;
	}

	private void _cursorFromTo(Document doc, Point2D from, double fromPressure, Point2D to, double toPressure, CURSOR_TYPE cursor, string cursorID)
	{
		doc.data.insert(Line(from, to, 2, Color.BLACK));
		this.draw.drawLine(from, to, 2, Color.BLUE);
	}
}
