/* DrawOfPages: Take notes with touchscreen input.
 * Copyright (C) 2019  Marko Semet
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
import dop.gtk3.mainwindow;
import dop.processing.mainsystem;
import dop.structures.base;

import gdk.Threads;
import gio.Application: GioApplication = Application;
import gtk.Application;
import gtk.Main;

private
{
	class Callbacks : BaseSystemCallbacks
	{
		private
		{
			void delegate(void delegate(DOP_MainWindow, Application)) __runWithMainWindow;
		}

		public
		{
			shared this(void delegate(void delegate(DOP_MainWindow, Application)) func)
			in
			{
				assert(func !is null);
			}
			do
			{
				this.__runWithMainWindow = func;
			}

			shared void setCurrentColor(ColorRGBA color)
			{
				this.__runWithMainWindow(delegate void(DOP_MainWindow mw, Application app) {
					mw.updateColor();
				});
			}
			shared void setCurrentSize(float size)
			{
				this.__runWithMainWindow(delegate void(DOP_MainWindow mw, Application app) {
					mw.updateSize(size);
				});
			}

			shared void quit()
			{
				this.__runWithMainWindow(delegate void(DOP_MainWindow mw, Application app) {
					app.quit();
				});
			}
		}
	}
}


int main(string[] args)
{
	auto app = new Application("de.marko10_000.DrawOfPages", GApplicationFlags.FLAGS_NONE);
	shared MainSystem ms = null;
	shared Callbacks baseCB = null;
	app.addOnActivate(delegate void(GioApplication _) {
		// Create main window
		DOP_MainWindow mainWindow = new DOP_MainWindow(app);

		// Create main system
		baseCB = new shared Callbacks(delegate void(void delegate(DOP_MainWindow, Application) func) {
			threadsEnter();
			func(mainWindow, app);
			threadsLeave();
		});
		ms = new shared MainSystem(baseCB);
		mainWindow.mainSystem = ms;

		// Finalize main system init
		ms.finalizeInit();
	});

	{ // Finalize
		auto result = app.run(args);
		return result;
	}
}
