public class LayerWidget : Gtk.EventBox {
    public const string CLIP_CSS = """
        .clip {
          background: #3498db;
          background-image: linear-gradient(to bottom, #3498db, #2980b9);
          border-radius: 1px;
          color: #ffffff;
          font-size: 20px;
          border: solid #1f628d 1px;
          text-decoration: none;
        }

        .clip:hover {
          background: #3cb0fd;
          background-image: linear-gradient(to bottom, #3cb0fd, #3498db);
          text-decoration: none;
        }
    """;

    public uint64 time_view { get; set; default=Gst.MSECOND; }
    private GES.Clip? hovered = null;
    private GES.Layer layer;

    private const int HEIGHT = 30;

    public LayerWidget (GES.Layer layer) {
        expand = true;
        this.layer = layer;
        events |= Gdk.EventMask.POINTER_MOTION_MASK;
        set_size_request (100, 100);
        layer.timeline.notify["duration"].connect (() => {
            queue_resize_no_redraw ();
        });
        layer.clip_added.connect (() => {
            queue_resize ();
        });
        layer.clip_removed.connect (() => {
            queue_resize ();
        });
    }

    construct {
        var provider = Gtk.CssProvider.get_default ();
        try {
            provider.load_from_data (CLIP_CSS);
            get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        } catch (Error e) {
            critical (e.message);
        }
    }

    public override bool draw (Cairo.Context cr) {
        int width = get_allocated_width ();
        var style_context = get_style_context ();
        style_context.save ();
        style_context.add_class ("clip");
        layer.get_clips ().foreach ((clip) => {
            if (clip == hovered) {
                style_context.save ();
                style_context.set_state (style_context.get_state () | Gtk.StateFlags.PRELIGHT);
            }
            double x = ((double)clip.get_start ())/((double)time_view);
            double clip_width = ((double)clip.get_duration ())/((double)time_view);
            style_context.render_background (cr, x, 0, clip_width, HEIGHT - 1);
            style_context.render_frame (cr, x, 0, clip_width, HEIGHT - 1);
            style_context.render_focus (cr, x, 0, clip_width, HEIGHT - 1);
            if (clip == hovered) {
                double handle_size = double.min (5, clip_width/2);
                style_context.render_handle (cr, x, 0, handle_size, HEIGHT - 1);
                style_context.render_handle (cr, x + clip_width - handle_size, 0, handle_size, HEIGHT - 1);
                style_context.restore ();
            }
        });
        style_context.restore ();

        return GLib.Source.CONTINUE;
    }

    public override void get_preferred_height (out int minimum_height, out int natural_height) {
        minimum_height = HEIGHT;
        natural_height = minimum_height;
    }

    public override void get_preferred_width (out int minimum_width, out int natural_width) {
        minimum_width = (int) (layer.get_duration () / time_view);
        natural_width = minimum_width;
    }

    public override bool button_press_event (Gdk.EventButton event) {
        return GLib.Source.CONTINUE;
    }

    public override bool button_release_event (Gdk.EventButton event) {
        return GLib.Source.CONTINUE;
    }

    public override bool leave_notify_event (Gdk.EventCrossing event) {
        get_window ().set_cursor (null);
        return GLib.Source.CONTINUE;
    }

    public override bool motion_notify_event (Gdk.EventMotion event) {
        var old_hovered = hovered;
        hovered = null;
        if (event.y >= 0 && event.y < HEIGHT) {
            layer.get_clips ().foreach ((clip) => {
                double x = ((double)clip.get_start ())/((double)time_view);
                double clip_width = ((double)clip.get_duration ())/((double)time_view);
                if (event.x >= x && event.x < x + clip_width) {
                    double handle_size = double.min (5, clip_width/2);
                    hovered = clip;
                    if (event.x > x && event.x < x + handle_size || event.x > x + clip_width - handle_size && event.x < x + clip_width) {
                        get_window ().set_cursor (new Gdk.Cursor.for_display (get_display (), Gdk.CursorType.SB_H_DOUBLE_ARROW));
                    } else {
                        get_window ().set_cursor (null);
                    }
                }
            });
        } else {
            get_window ().set_cursor (null);
        }

        if (old_hovered != hovered) {
            queue_draw ();
        }

        return GLib.Source.CONTINUE;
    }
}
