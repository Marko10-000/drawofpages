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
module drawofpages.gui.drawArea;

private
{
	import cairo.Context;
	import cairo.ImageSurface;
	import cairo.Surface;
	import drawofpages.draw;
	import drawofpages.gui;
	import gdk.Device;
	import gtk.DrawingArea;
	import gdk.Event;
	import gtk.Widget;
	import std.math;
}

private final class DrawPart
{
	package ImageSurface surface;
	private Context context;

	public Point2D pos;
	public double scale;
	public Square box;

	pragma(inline, true)
	private pure nothrow void updatePoint(ref Point2D p)
	{
		p = (p - this.pos) * this.scale;
	}
	pragma(inline, true)
	private pure nothrow void updateScale(ref double s)
	{
		s *= this.scale;
	}

	public this(Point2D pos, double scale)
	{
		this.surface = ImageSurface.create(cairo_format_t.ARGB32, 512, 512);
		this.context = Context.create(this.surface);
		this.pos = pos;
		this.scale = scale;

		// Set background color
		this.context.setSourceRgb(1, 1, 1);
		this.context.rectangle(0, 0, 512, 512);
		this.context.fill();

		// Box
		this.box = Square(pos, pos + Point2D([512 / this.scale, 512 / this.scale]));
	}
	public ~this()
	{
		this.surface.destroy;
	}

	public void drawLine(Point2D from, Point2D to, double size, Color color)
	{
		this.updatePoint(from);
		this.updatePoint(to);
		this.updateScale(size);

		this.context.setSourceRgba(color.r, color.g, color.b, color.a);
		this.context.moveTo(from.dims[0], from.dims[1]);
		this.context.setLineWidth(size);
		this.context.lineTo(to.dims[0], to.dims[1]);
		this.context.stroke();
		this.context.moveTo(0, 0);
	}
}

private final class PardDraw : Draw
{
	private DrawPart dp;

	public this(DrawPart dp)
	{
		this.dp = dp;
	}

	public void drawCirc(Point2D center, float radius, Color color)
	{
		assert(false);
	}
	public void drawLine(Point2D from, Point2D to, double size, Color color)
	{
		dp.drawLine(from, to, size, color);
	}
	public void drawRect(Square square, Color color)
	{
		assert(false); // TODO: draw rect
	}
	public void redraw() {}
}

private final class Grid
{
	public DrawPart[][] parts;

	public Point2D rel;
	public Point2D relZero;
	public double scale;
	public long x;
	public long y;
	public ulong width;
	public ulong height;

	private pure void calcRelZero()
	{
		this.relZero = Point2D([this.x, this.y]) * this.scale;
	}

	public this()
	{
		this.scale = 1;
		this.x = -256;
		this.y = -256;
		this.rel = Point2D([this.x, this.y]);
		this.width = 0;
		this.height = 0;
		this.parts = new DrawPart[][0];
		this.calcRelZero();
	}

	public void resize(ulong width, ulong height, GuiInteraction interatcion)
	{
		synchronized
		{
			ulong partsX = (width - this.x) / 512 + ((width - this.x) % 512 == 0 ? 0 : 1);
			ulong partsY = (height - this.y) / 512 + ((height - this.y) % 512 == 0 ? 0 : 1);
			DrawPart[][] newParts = new DrawPart[][partsY];
			for(ulong y = 0; y < partsY; y++)
			{
				if(this.parts.length > y)
				{
					// Use old data
					DrawPart[] old = this.parts[y];
					DrawPart[] tmp = new DrawPart[partsX];
					for(ulong x = 0; x < partsX; x++)
					{
						if(old.length > x)
						{
							tmp[x] = old[x];
						}
						else
						{
							tmp[x] = new DrawPart(Point2D([x, y]) * (512 / this.scale) + this.rel, this.scale);
							interatcion.redraw(tmp[x].box, new PardDraw(tmp[x]));
						}
					}
					newParts[y] = tmp;
				}
				else
				{
					// Gen new array
					DrawPart[] tmp = new DrawPart[partsX];
					for(ulong x = 0; x < partsX; x++)
					{
						tmp[x] = new DrawPart(Point2D([x, y]) * (512 / this.scale) + this.rel, this.scale);
						interatcion.redraw(tmp[x].box, new PardDraw(tmp[x]));
					}
					newParts[y] = tmp;
				}
			}

			// Set new data
			{
				DrawPart[][] tmp = this.parts;
				this.parts = newParts;
				tmp.destroy;
				this.width = width;
				this.height = height;
			}
		}
	}
}

private final class DrawHandler : Draw
{
	private DrawElement de;
	package Grid grid;

	public this(DrawElement de)
	{
		this.de = de;
		this.grid = new Grid();
	}

	public void drawCirc(Point2D center, float radius, Color color)
	{
		assert(false);
	}
	public void drawLine(Point2D from, Point2D to, double size, Color color)
	{
		foreach(DrawPart[] dps; this.grid.parts)
		{
			foreach(DrawPart dp; dps)
			{
				dp.drawLine(from, to, size, color);
			}
		}
	}
	public void drawRect(Square square, Color color)
	{
		assert(false);
	}
	public void redraw()
	{
		this.de.queueDraw();
	}

	package void _draw(Context cr)
	{
		for(long i = 0; i < this.grid.parts.length; i++)
		{
			DrawPart[] io = this.grid.parts[i];
			for(long j = 0; j < io.length; j++)
			{
				cr.setSourceSurface(io[j].surface, (j * 512) + (cast(long) this.grid.x), (i * 512) + (cast(long) this.grid.y));
				cr.rectangle((j * 512) + (cast(long) this.grid.x), (i * 512) + (cast(long) this.grid.y), 512, 512);
				cr.fill();
			}
		}
		cr.save();
		cr.destroy;
	}
}

public class DrawElement : DrawingArea
{
	private DrawHandler dh;
	private GuiInteraction interatcion = null;
	private bool hasDown = false;

	private static pure CURSOR_TYPE _getCursor(GdkInputSource gis)
	{
		if(gis == GdkInputSource.PEN)
		{
			return CURSOR_TYPE.PEN;
		}
		else if(gis == GdkInputSource.ERASER)
		{
			return CURSOR_TYPE.ERASER;
		}
		else if(gis == GdkInputSource.MOUSE)
		{
			return CURSOR_TYPE.MOUSE;
		}
		return CURSOR_TYPE.HAND;
	}

	private struct _pointerData
	{
		string deviceID = null;
		double pressure;
		CURSOR_TYPE ctype;

		this(Device device)
		{
			if(device.getDeviceType() != GdkDeviceType.MASTER)
			{
				this.deviceID = device.getProductId();
			}
			GdkAxisFlags axes = device.getAxes();
			this.pressure = axes.PRESSURE;
			this.ctype = _getCursor(device.getSource());
		}
	}

	public this()
	{
		super();
		this.dh = new DrawHandler(this);
		this.addOnDraw(delegate bool(Context cr, Widget w) {
			synchronized
			{
				this._draw(cr);
			}
			return false;
		});
		this.addOnButtonPress(delegate bool(Event e, Widget w) {
			if(this.interatcion is null)
			{
				return false;
			}

			GdkEventButton* geb = e.button();
			_pointerData tmp = _pointerData(e.getDevice());
			synchronized
			{
				this.interatcion.down(Point2D([geb.x, geb.y]), tmp.ctype, tmp.pressure, tmp.deviceID);
			}
			this.hasDown = true;
			return false;
		});
		this.addOnMotionNotify(delegate bool(Event e, Widget w) {
			if((this.interatcion is null) || (!this.hasDown))
			{
				return false;
			}

			GdkEventMotion* motion = e.motion();
			_pointerData tmp = _pointerData(e.getDevice());
			synchronized
			{
				this.interatcion.contin(Point2D([motion.x, motion.y]), tmp.ctype, tmp.pressure, tmp.deviceID);
			}
			return false;
		});
		this.addOnButtonRelease(delegate bool(Event e, Widget w) {
			if(this.interatcion is null)
			{
				return false;
			}

			GdkEventButton* geb = e.button();
			_pointerData tmp = _pointerData(e.getDevice());
			this.hasDown = false;
			synchronized
			{
				this.interatcion.up(Point2D([geb.x, geb.y]), tmp.ctype, tmp.pressure, tmp.deviceID);
			}
			return false;
		});
		this.addOnSizeAllocate(delegate void(Allocation alloc, Widget w) {
			synchronized(this)
			{
				this.dh.grid.resize(alloc.width, alloc.height, this.interatcion);
			}
		});
	}

	private void _draw(Context cr)
	{
		this.dh._draw(cr);
	}
	public DrawHandler getDrawHanlder()
	{
		return this.dh;
	}
	public ref GuiInteraction getGuiInteraction()
	{
		return this.interatcion;
	}
}
