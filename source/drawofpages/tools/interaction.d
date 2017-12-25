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
	import std.stdio;
}

package struct CursorInteraction
{
	Point2D pos;
	CURSOR_TYPE ctype;
	double pressure;
	string id;
}

public class DrawThread : Thread
{
	private enum INTERACTION_TYPE
	{
		CURSOR_DOWN = 0,
		CURSOR_CONTIN = 1,
		CURSOR_UP = 2
	}
	private static struct Interaction
	{
		public INTERACTION_TYPE itype;
		public Document doc;
		public Tool tool;
		union
		{
			public CursorInteraction cursor;
		}
	}

	private Draw draw;
	private Queue!(Interaction, true) queue;
	public bool stop;

	private void run()
	{
		Interaction tmp;
		while(!this.stop)
		{
			bool redraw = false;
			while(this.queue.fetch(tmp))
			{
				if(tmp.tool is null)
				{
					continue;
				}
				final switch(tmp.itype)
				{
					case INTERACTION_TYPE.CURSOR_DOWN:
						redraw = true;
						tmp.tool.cursorDown(tmp.doc, tmp.cursor.pos, tmp.cursor.ctype, tmp.cursor.pressure, tmp.cursor.id);
						break;
					case INTERACTION_TYPE.CURSOR_CONTIN:
						redraw = true;
						tmp.tool.cursorContin(tmp.doc, tmp.cursor.pos, tmp.cursor.ctype, tmp.cursor.pressure, tmp.cursor.id);
						break;
					case INTERACTION_TYPE.CURSOR_UP:
						redraw = true;
						tmp.tool.cursorUp(tmp.doc, tmp.cursor.pos, tmp.cursor.ctype, tmp.cursor.pressure, tmp.cursor.id);
						break;
				}
			}
			if(redraw)
			{
				this.draw.redraw();
			}
			yield();
		}
	}

	public this(Draw draw)
	{
		this.draw = draw;
		this.queue = new Queue!(Interaction, true);
		this.stop = false;
		super(&this.run);
		this.start();
	}

	pragma(inline, true)
	public void add(string TYPE)(Document doc, Tool tool, CursorInteraction ci)
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
		this.queue.insert(tmp);
	}
};

public class InteractionSafer : GuiInteraction
{
	private Document document;
	public Tool currentTool;
	private DrawThread thread;

	public this(DrawThread thread)
	{
		this.document = new Document();
		this.currentTool = null;
		this.thread = thread;
	}

	public void down(Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID)
	{
		CursorInteraction ci;
		ci.pos = point;
		ci.ctype = cursor;
		ci.pressure = pressure;
		ci.id = cursorID;
		thread.add!"DOWN"(this.document, this.currentTool, ci);
	}
	public void contin(Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID)
	{
		CursorInteraction ci;
		ci.pos = point;
		ci.ctype = cursor;
		ci.pressure = pressure;
		ci.id = cursorID;
		thread.add!"CONTIN"(this.document, this.currentTool, ci);
	}
	public void up(Point2D point, CURSOR_TYPE cursor, double pressure, string cursorID)
	{
		CursorInteraction ci;
		ci.pos = point;
		ci.ctype = cursor;
		ci.pressure = pressure;
		ci.id = cursorID;
		thread.add!"UP"(this.document, this.currentTool, ci);
	}
	public void redraw(Square area, Draw target)
	{
		this.document.redraw(area, target);
	}
}
