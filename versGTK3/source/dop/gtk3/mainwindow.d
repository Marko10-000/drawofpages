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
module dop.gtk3.mainwindow;

private
{
    import cairo.Context;

    import dop.authorship;
    import dop.processing.mainsystem;
    import dop.structures.base;

    import gdk.RGBA;

    import gtk.AboutDialog;
    import gtk.Application;
    import gtk.ApplicationWindow;
    import gtk.Builder;
    import gtk.ColorChooserIF;
    import gtk.ColorChooserWidget;
    import gtk.DrawingArea;
    import gtk.Image;
    import gtk.Label;
    import gtk.MenuButton;
    import gtk.MenuItem;
    import gtk.Range;
    import gtk.Scale;
    import gtk.SpinButton;
    import gtk.ToggleButton;
    import gtk.Widget;

    import gobject.ObjectG;
    import gobject.ParamSpec;

    import std.algorithm : min;
    import std.format;
    import std.math : PI;
}

public
{
    /++
     + Main window of draw of pages
     +/
    class DOP_MainWindow
    {
        private
        {
            Builder __builder;
            shared MainSystem __mainSystem;
            
            ApplicationWindow __aw;

            Image __colorInfoSizeInfo;
            DrawingArea __colorInfo;
            ColorChooserWidget __colorChooser;
            MenuButton __colorHelper;

            Scale __sizeChooser1;
            SpinButton __sizeChooser2;
            Label __sizeInfo;
            MenuButton __sizeHelper;

            AboutDialog __menuAboutDialog;
            MenuItem __menuAbout;
            MenuItem __menuQuit;

            //
            // Colors
            //
            void __updateColor(Context context)
            {
                // Center position
                double posX;
                double posY;
                double size;
                GtkAllocation alloc;
                {
                    int requestWidth;
                    int requestHeight;
                    int baseLine;

                    this.__colorInfo.getSizeRequest(requestWidth, requestHeight);
                    this.__colorInfo.getAllocatedSize(alloc, baseLine);
                    size = min(requestHeight, requestWidth) * 0.4;
                    posX = alloc.width / 2.;
                    posY = alloc.height / 2.;
                }

                ColorRGBA currentColor;
                if(this.__mainSystem !is null)
                {
                    currentColor = this.__mainSystem.currentColor;
                }
                { // Draw outer circle
                    context.save();
                    context.arc(posX, posY, size, 0, 2 * PI);
                    if(currentColor.getLuma() >= 0.5)
                    {
                        context.setSourceRgba(0, 0, 0, 1);
                    }
                    else
                    {
                        context.setSourceRgba(1, 1, 1, 1);
                    }
                    context.fill();
                    context.restore();
                }

                { // Draw inner circle
                    context.save();
                    context.arc(posX, posY, size * 0.8, 0, 2 * PI);
                    context.setSourceRgba(currentColor.r, currentColor.g, currentColor.b, currentColor.a);
                    context.fill();
                    context.restore();
                }
            }
            void __updateColorInfoSize(int width, int height)
            {
                int tmpW = 0;
                int tmpH = 0;
                this.__colorInfo.getSizeRequest(tmpW, tmpH);
                if((width != tmpW) || (height != tmpH))
                {
                    this.__colorInfo.setSizeRequest(width, height);
                    this.__colorInfo.queueResize();
                    this.updateColor();
                }
            }
        }

        public
        {
            /++
             + Create main window.
             + Params:
             +     app = The app to use
             +/
            this(Application app)
            {
                // Find and show main window
                this.__builder = new Builder();
                this.__builder.setApplication(app);
                assert(this.__builder.addFromString(import("MainWindow.glade")) != 0);
                this.__aw = cast(ApplicationWindow) this.__builder.getObject("MainApplication");
                assert(this.__aw !is null);
                this.__aw.setApplication(app);
                this.__aw.showAll();

                { // Manage color info
                    this.__colorInfo = cast(DrawingArea) this.__builder.getObject("ColorInfo");
                    assert(this.__colorInfo !is null);
                    this.__colorInfoSizeInfo = cast(Image) this.__builder.getObject("ColorInfoSizeInfo");
                    assert(this.__colorInfoSizeInfo !is null);
                    this.__colorChooser = cast(ColorChooserWidget) this.__builder.getObject("ColorChooser");
                    assert(this.__colorChooser !is null);
                    this.__colorHelper = cast(MenuButton) this.__builder.getObject("ColorHelper");
                    assert(this.__colorHelper !is null);

                    // Color blob size
                    this.__colorInfoSizeInfo.addOnDraw(delegate bool(Context cr, Widget widget) {
                        if(widget == this.__colorInfoSizeInfo)
                        {
                            this.__updateColorInfoSize(this.__colorInfoSizeInfo.getAllocatedWidth(), this.__colorInfoSizeInfo.getAllocatedHeight());
                        }
                        return false;
                    });

                    // Render color blob
                    this.__colorInfo.addOnDraw(delegate bool(Context cr, Widget widget) {
                        if(widget == this.__colorInfo)
                        {
                            this.__updateColor(cr);
                        }
                        return false;
                    });

                    // Chooser color
                    this.__colorChooser.addOnNotify((delegate void(ParamSpec ps, ObjectG go) {
                        RGBA rgba;
                        this.__colorChooser.getRgba(rgba);
                        ColorRGBA newColor = {rgba.red, rgba.green, rgba.blue, rgba.alpha};
                        this.__mainSystem.currentColor = newColor;
                    }), "rgba");
                    this.__colorHelper.addOnToggled(delegate void(ToggleButton button) {
                        if(button == this.__colorHelper && button.getActive())
                        {
                            this.__colorChooser.setProperty("show-editor", false);
                            RGBA rgba = new RGBA;
                            {
                                ColorRGBA current = this.__mainSystem.currentColor;
                                rgba.red = current.r;
                                rgba.green = current.g;
                                rgba.blue = current.b;
                                rgba.alpha = current.a;
                            }
                            this.__colorChooser.setRgba(rgba);
                        }
                    });
                }

                { // Manage point size
                    this.__sizeChooser1 = cast(Scale) this.__builder.getObject("SizeChooser1");
                    assert(this.__sizeChooser1 !is null);
                    this.__sizeChooser2 = cast(SpinButton) this.__builder.getObject("SizeChooser2");
                    assert(this.__sizeChooser2 !is null);
                    this.__sizeInfo = cast(Label) this.__builder.getObject("SizeInfo");
                    assert(this.__sizeInfo !is null);
                    this.__sizeHelper = cast(MenuButton) this.__builder.getObject("SizeHelper");
                    assert(this.__sizeHelper !is null);

                    // Value change callback
                    this.__sizeChooser1.addOnValueChanged(delegate void(Range range) {
                        if(this.__sizeChooser1 == range)
                        {
                            this.__mainSystem.currentSize = this.__sizeChooser1.getValue();
                        }
                    });

                    // When open reset value
                    this.__sizeHelper.addOnToggled(delegate void(ToggleButton button) {
                        if(button == this.__sizeHelper && button.getActive())
                        {
                            this.__sizeChooser1.setValue(this.__mainSystem.currentSize);
                            this.__sizeChooser2.setValue(this.__mainSystem.currentSize);
                        }
                    });
                }

                { // Manage menu entries
                    this.__menuAboutDialog = cast(AboutDialog) this.__builder.getObject("AboutDialog");
                    assert(this.__menuAboutDialog !is null);
                    this.__menuAbout = cast(MenuItem) this.__builder.getObject("MenuInfo");
                    assert(this.__menuAbout !is null);
                    this.__menuQuit = cast(MenuItem) this.__builder.getObject("MenuQuit");
                    assert(this.__menuQuit !is null);

                    // Set infos
                    this.__menuAboutDialog.setArtists(authorship_artists);
                    this.__menuAboutDialog.setAuthors(authorship_authors);
                    this.__menuAboutDialog.setDocumenters(authorship_documenters);
                    {
                        string trans = format!("%(%s\n%)")(authorship_translators);
                        if(trans.length == 0)
                        {
                            this.__menuAboutDialog.setTranslatorCredits(null);
                        }
                        else
                        {
                            this.__menuAboutDialog.setTranslatorCredits(trans[0..$-1]);
                        }
                    }
                    {
                        string copyright = authorship_copyright_infos;
                        if(copyright.length > 0)
                        {
                            copyright ~= "\n\n";
                        }
                        copyright ~= "Used library: GtkD(http://gtkd.org)";
                        this.__menuAboutDialog.setCopyright(copyright);
                    }
                    this.__menuAboutDialog.setVersion(programm_version);

                    // About
                    this.__menuAbout.addOnActivate(delegate void(MenuItem mi) {
                        if(mi == this.__menuAbout)
                        {
                            this.__menuAboutDialog.showAll();
                        }
                    });

                    // Quit
                    this.__menuQuit.addOnActivate(delegate void(MenuItem mi) {
                        if(mi == this.__menuQuit)
                        {
                            this.__mainSystem.quit();
                        }
                    });
                }
            }

            /++
             + Returns the main System
             + Returns: The main system.
             +/
            @property
            shared(MainSystem) mainSystem()
            {
                return this.__mainSystem;
            }
            /++
             + Sets the main system. It have to be not null
             + Params:
             +     ms = The main system to set
             + Returns: The main system
             +/
            @property
            shared(MainSystem) mainSystem(shared MainSystem ms)
            in
            {
                assert(ms !is null);
            }
            do
            {
                this.__mainSystem = ms;
                return ms;
            }

            /++
             + Request to update the color
             +/
            void updateColor()
            {
                this.__colorInfo.queueDraw();
            }

            /++
             + Update size output
             +/
            void updateSize(float size)
            {
                this.__sizeInfo.setLabel(format!("%1.2f")(size));
            }
        }
    }
}