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
	import gtk.Box;
	import gtk.DrawingArea;
	import gtk.HBox;
	import gtk.HeaderBar;
	import gtk.MainWindow;
	import gtk.Separator;
	import gtk.SizeGroup;
	import gtk.Widget;
	import std.conv;
	import std.stdio;
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
	private DrawThread drawThread;
	private Tab tab;

	private HeaderBar mainHeaderBar;
	private HeaderBar sideHeaderBar;

	private Box sideBar;
	private Box sideBarContainer;
	private Box main;

	public this()
	{
		// Startup
		super("DrawOfPapers");
		this.setDefaultSize(800, 600); // TODO: Load size from config
		this.drawThread = new DrawThread();

		// Header bar
		{
			this.mainHeaderBar = new HeaderBar();
			this.mainHeaderBar.setTitle("DrawOfPapers");
			this.mainHeaderBar.setShowCloseButton(true);

			this.sideHeaderBar = new HeaderBar();
			this.sideHeaderBar.setTitle("SideTitle");
			this.sideHeaderBar.setShowCloseButton(false);

			HBox head = new HBox(false, 0);
			this.setTitlebar(head);
			head.packStart(this.sideHeaderBar, false, true, 0);
			head.packEnd(this.mainHeaderBar, true, true, 0);
		}

		// Main container
		{
			this.sideBar = new HBox(false, 0);
			this.sideBarContainer = new HBox(false, 0);
			this.sideBarContainer.packStart(this.sideBar, true, true, 0);
			this.sideBarContainer.packEnd(new Separator(GtkOrientation.VERTICAL), false, true, 0);

			this.main = new HBox(false, 0);

			Box tmp = new HBox(false, 0);
			tmp.packStart(this.sideBarContainer, false, true, 0);
			tmp.packEnd(this.main, true, true, 0);
			this.add(tmp);
		}

		// Sizegroup sidebar
		{
			SizeGroup tmp = new SizeGroup(GtkSizeGroupMode.HORIZONTAL);
			tmp.addWidget(this.sideHeaderBar);
			tmp.addWidget(this.sideBar);
		}

		// Generate new tab
		this.tab = new Tab(this.drawThread);
		this.main.packStart(this.tab.drawElement, true, true, 0);
		this.showAll();
		this.sidebarInvisible();
	}

	public void sidebarInvisible()
	{
		this.sideBarContainer.setVisible(false);
		this.sideHeaderBar.setVisible(false);
	}

	public void sidebarShow(string title, Widget data, Widget[] headerFront = [], Widget[] headerBack = [])
	{
		// Insert
		this.sideHeaderBar.setTitle(title);
		this.sideHeaderBar.removeAll();
		foreach(Widget i; headerFront)
		{
			this.sideHeaderBar.packStart(i);
		}
		foreach(Widget i; headerBack)
		{
			this.sideHeaderBar.packEnd(i);
		}

		this.sideBar.removeAll();
		this.sideBar.add(data);

		// Show
		this.sideHeaderBar.setVisible(true);
		this.sideBarContainer.setVisible(true);
	}

	public void stop()
	{
		this.drawThread.stop = true;
	}
}
