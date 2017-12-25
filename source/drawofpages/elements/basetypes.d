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
module drawofpages.elements.basetypes;

private
{
	import std.algorithm.comparison;
	import structuresd.dimension;
}

public struct Line
{
	Point!2 a;
	Point!2 b;
	double size;

	@nogc
	public pure nothrow this(Point!2 a, Point!2 b, double size)
	{
		this.a = a;
		this.b = b;
		this.size = size;
	}

	@nogc
	public pure nothrow T opCast(T)() if(is(T == Cuboid!2))
	{
		Cuboid!2 result = Cuboid!2(this.a, this.b);
		result.a -= Point!2([this.size, this.size]);
		result.b += Point!2([this.size, this.size]);
		return result;
	}
}
