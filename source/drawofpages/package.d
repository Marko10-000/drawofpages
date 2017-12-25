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
module drawofpages;

private import drawofpages.elements;
private import drawofpages.gui.drawArea;
private import drawofpages.draw;
private import gtk.MainWindow;
private import gtk.Main;


void main(string[] args)
{
	Main.init(args);
	MainWindow win = new MainWindow("Hello World");
	win.setDefaultSize(800, 600);
	DrawElement de = new DrawElement();
	de.getDrawHanlder().drawLine(Point2D([50, 50]), Point2D([100, 100]), 5, Color.RED);
	de.getGuiInteraction() = new Interaction(de.getDrawHanlder());
	win.add(de);
	de.queueDraw();
	win.showAll();
	Main.run();
}
