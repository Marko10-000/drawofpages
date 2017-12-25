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
module drawofpages.draw;

private
{
	import structuresd.dimension;
}

public alias Point2D = Point!2;
public alias Square = Cuboid!2;
public alias Circle = Sphere!2;

public struct Color {
	float r = 0;
	float g = 0;
	float b = 0;
	float a = 1;

	public this(float r, float g, float b)
	{
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = 1;
	}
	public this(float r, float g, float b, float a)
	{
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	public enum RED = Color(1, 0, 0);
	public enum GREEN = Color(0, 1, 0);
	public enum BLUE = Color(0, 0, 1);
	public enum YELLOW = Color(1, 1, 0);
	public enum ORANGE = Color(1, 0.5, 0);
	public enum CYAN = Color(0, 1, 1);
	public enum PURPLE = Color(1, 0, 1);
	public enum BLACK = Color(0, 0, 0);
	public enum GRAY = Color(0.5, 0.5, 0.5);
	public enum WHITE = Color(1, 1, 1);
	public enum TRANSPARENT = Color(0, 0, 0, 0);
}

public interface Draw
{
	void drawCirc(Point2D center, float radius, Color color);
	void drawLine(Point2D from, Point2D to, double size, Color color);
	void drawRect(Square square, Color color);
	void redraw();
}
