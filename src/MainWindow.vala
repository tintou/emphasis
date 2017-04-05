public class Emphasis.MainWindow : Gtk.Window {
    ProjectView project_view;
    Timeline timeline;
    CompositionView composition_view;
    GES.Project project;
    public MainWindow () {
        set_default_size (800, 600);
    }

    construct {
        var vpaned = new Gtk.Paned (Gtk.Orientation.VERTICAL);
        var hpaned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        project_view = new ProjectView ();
        composition_view = new CompositionView ();
        timeline = new Timeline ();
        add (vpaned);
        vpaned.pack1 (hpaned, true, false);
        vpaned.pack2 (timeline, true, false);
        hpaned.pack1 (project_view, true, false);
        hpaned.pack2 (composition_view, true, false);

        var header_bar = new Gtk.HeaderBar ();
        header_bar.show_close_button = true;
        header_bar.title = "Emphasis";

        var open_button = new Gtk.Button.from_icon_name ("document-open", Gtk.IconSize.LARGE_TOOLBAR);

        var save_button = new Gtk.Button.from_icon_name ("document-save", Gtk.IconSize.LARGE_TOOLBAR);

        header_bar.pack_start (open_button);
        header_bar.pack_start (save_button);
        set_titlebar (header_bar);
        
        project_view.add_asset_to_timeline.connect ((asset) => {
            var layer = timeline.timeline.get_layers ().first ().data;
            layer.add_asset (asset, Gst.CLOCK_TIME_NONE, 0, Gst.SECOND, GES.TrackType.VIDEO);
        });

        open_button.clicked.connect (() => {
            var chooser = new Gtk.FileChooserDialog ("Select your favorite file", this.get_toplevel () as Gtk.Window, Gtk.FileChooserAction.OPEN,
                                                     "_Cancel", Gtk.ResponseType.CANCEL, "_Open", Gtk.ResponseType.ACCEPT);
            if (chooser.run () == Gtk.ResponseType.ACCEPT) {
                project = new GES.Project (chooser.get_uri ());
                timeline.put_timeline ((GES.Timeline) project.extract ());
                composition_view.set_timeline (timeline.timeline);
                project_view.set_project (project);
            }

            // Close the FileChooserDialog:
            chooser.close ();
        });

        save_button.clicked.connect (() => {
            try {
                var val = project.save (timeline.timeline, "file:///home/tintou/test2.xges", null, true);
            } catch (Error e) {
                critical (e.message);
            }
        });

        destroy.connect (Gtk.main_quit);
    }
}
