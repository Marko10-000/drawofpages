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
module drawofpages.tools.interaction;

private
{
	import core.thread;
	import drawofpages.draw;
	import drawofpages.gui;
	import drawofpages.tools;
	import structuresd.containers.queue;
}

package struct CursorInteraction
{
	Point2D pos;
	CURSOR_TYPE ctype;
	double pressure;
	string id;
}
package struct RedrawInteraction
{
	Square box;
	Draw target;
}

public class DrawThread : Thread
{
	private enum INTERACTION_TYPE
	{
		REDRAW = 0,
		CURSOR_DOWN = 1,
		CURSOR_CONTIN = 2,
		CURSOR_UP = 3
	}
	private static struct Interaction
	{
		public INTERACTION_TYPE itype;
		public Document doc;
		public Tool tool;
		public Draw draw;
		union
		{
			public CursorInteraction cursor;
			public RedrawInteraction redraw;
		}
	}

	private Queue!(Interaction, true) queue;
	public bool stop;

	private void run()
	{
		Interaction tmp;
		while(!this.stop)
		{
			bool[Draw] redraw;
			while(this.queue.fetch(tmp))
			{
				if(tmp.tool is null)
				{
					continue;
				}
				final switch(tmp.itype)
				{
					case INTERACTION_TYPE.REDRAW:
						redraw[tmp.draw] = true;
						tmp.doc.redraw(tmp.redraw.box, tmp.redraw.target);
						break;
					case INTERACTION_TYPE.CURSOR_DOWN:
						redraw[tmp.draw] = true;
						tmp.tool.cursorDown(tmp.doc, tmp.cursor.pos, tmp.cursor.ctype, tmp.cursor.pressure, tmp.cursor.id);
						break;
					case INTERACTION_TYPE.CURSOR_CONTIN:
						redraw[tmp.draw] = true;
						tmp.tool.cursorContin(tmp.doc, tmp.cursor.pos, tmp.cursor.ctype, tmp.cursor.pressure, tmp.cursor.id);
						break;
					case INTERACTION_TYPE.CURSOR_UP:
						redraw[tmp.draw] = true;
						tmp.tool.cursorUp(tmp.doc, tmp.cursor.pos, tmp.cursor.ctype, tmp.cursor.pressure, tmp.cursor.id);
						break;
				}
			}
			foreach(Draw draw; redraw.keys)
			{
				draw.redraw();
			}
			this.sleep(dur!("msecs")(10));
		}
	}

	public this()
	{
		this.queue = new Queue!(Interaction, true);
		this.stop = false;
		super(&this.run);
		this.start();
	}

	pragma(inline, true)
	private void add(ref Interaction interact)
	{
		this.queue.insert(interact);
	}

	pragma(inline, true)
	public void add(string TYPE)(Document doc, Draw draw, Tool tool, CursorInteraction ci)
	{
		Interaction tmp;
		static if(TYPE == "DOWN")
		{
			tmp.itype = INTERACTION_TYPE.CURSOR_DOWN;
		}
		else static if(TYPE == "CONTIN")
		{
			tmp.itype = INTERACTION_TYPE.CURSOR_CONTIN;
		}
		else static if(TYPE == "UP")
		{
			tmp.itype = INTERACTION_TYPE.CURSOR_UP;
		}
		else
		{
			static assert(false);
		}
		tmp.doc = doc;
		tmp.tool = tool;
		tmp.cursor = ci;
		tmp.draw = draw;
		this.add(tmp);
	}

	pragma(inline, true)
	public void add(Document doc, Draw draw, RedrawInteraction redraw)
	{
		Interaction tmp;
		tmp.itype = INTERACTION_TYPE.REDRAW;
		tmp.doc = doc;
		tmp.tool = voidTool;
		tmp.draw = draw;
		tmp.redraw = redraw;
		this.add(tmp);
	}
};

public class InteractionSafer : GuiInteraction
{
	private Document document;
	public Tool currentTool;
	private DrawThread thread;
	private Draw draw;

	public this(DrawThread thread, Draw draw)
	{
		this.document = new Document();
		this.currentTool = null;
		this.thread = thread;
		this.draw = draw;
	}

	public void down(Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID)
	{
		CursorInteraction ci;
		ci.pos = point;
		ci.ctype = cursor;
		ci.pressure = pressure;
		ci.id = cursorID;
		thread.add!"DOWN"(this.document, this.draw, this.currentTool, ci);
	}
	public void contin(Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID)
	{
		CursorInteraction ci;
		ci.pos = point;
		ci.ctype = cursor;
		ci.pressure = pressure;
		ci.id = cursorID;
		thread.add!"CONTIN"(this.document, this.draw, this.currentTool, ci);
	}
	public void up(Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID)
	{
		CursorInteraction ci;
		ci.pos = point;
		ci.ctype = cursor;
		ci.pressure = pressure;
		ci.id = cursorID;
		thread.add!"UP"(this.document, this.draw, this.currentTool, ci);
	}
	public void redraw(Square area, Draw target)
	{
		RedrawInteraction ri;
		ri.box = area;
		ri.target = target;
		this.thread.add(this.document, this.draw, ri);
	}
}
