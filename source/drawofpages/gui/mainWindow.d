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
module drawofpages.gui.mainWindow;

private
{
	import drawofpages.gui.drawArea;
	import drawofpages.tools.drawer;
	import drawofpages.tools.interaction;
	import gtk.MainWindow;
}

private class Menu
{
	
}

public class Tab
{
	package string name;
	package DrawElement drawElement;
	private InteractionSafer interaction;

	package this(DrawThread drawThread)
	{
		this.drawElement = new DrawElement();
		this.interaction = new InteractionSafer(drawThread, this.drawElement.getDrawHanlder());
		this.interaction.currentTool = new DrawLine(this.drawElement.getDrawHanlder());
		this.drawElement.getGuiInteraction() = this.interaction;
	}
}

public class DOPMain : MainWindow
{
	DrawThread drawThread;
	Tab tab;

	public this()
	{
		super("DrawOfPapers");
		this.setDefaultSize(800, 600); // TODO: Load size from config
		this.drawThread = new DrawThread();
		this.tab = new Tab(this.drawThread);
		this.add(this.tab.drawElement); // TODO: Tab support
		this.showAll();
	}

	public void stop()
	{
		this.drawThread.stop = true;
	}
}
