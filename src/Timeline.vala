public class Emphasis.Timeline : Gtk.Grid {
    public GES.Timeline timeline { get; private set; }
    private Gtk.Grid layers_grid;
    private Ruler ruler;
    public Timeline () {
        var zoom = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 1, 50, 1);
        zoom.set_size_request (100, -1);
        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.expand = true;
        layers_grid = new Gtk.Grid ();
        layers_grid.orientation = Gtk.Orientation.VERTICAL;
        scrolled.add_with_viewport (layers_grid);
        ruler = new Ruler (scrolled.hadjustment);
        attach (zoom, 0, 0, 1, 1);
        attach (ruler,    1, 0, 1, 1);
        attach (scrolled, 1, 1, 1, 1);
        set_size_request (100, 100);
        zoom.value_changed.connect (() => {
            ruler.time_view = (uint64)(zoom.get_value () * Gst.MSECOND);
            ruler.queue_resize ();
            layers_grid.get_children ().foreach ((child) => child.queue_resize ());
        });
    }

    public void put_timeline (GES.Timeline timeline) {
        this.timeline = timeline;
        timeline.get_layers ().foreach ((layer) => {
            var layer_widget = new LayerWidget (layer);
            layer_widget.show_all ();
            ruler.bind_property ("time-view", layer_widget, "time-view");
            layers_grid.add (layer_widget);
        });

        timeline.layer_added.connect ((layer) => {
            warning ("");
            var layer_widget = new LayerWidget (layer);
            layer_widget.show_all ();
            ruler.bind_property ("time-view", layer_widget, "time-view");
            layers_grid.add (layer_widget);
        });
    }
}
