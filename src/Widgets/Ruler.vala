public class Emphasis.Ruler : Gtk.EventBox {
    // The maximum number of pixels
    private const int MAX_STEP = 150;
    public uint64 time_view { get; set; default=Gst.MSECOND; }
    public Gtk.Adjustment hadjustment;
    private double step = 1;
    public Ruler (Gtk.Adjustment hadjustment) {
        this.hadjustment = hadjustment;
        calculate_step ();
        hadjustment.value_changed.connect (() => {
            queue_draw ();
            calculate_step ();
        });
    }

    public override bool draw (Cairo.Context cr) {
        int width = get_allocated_width ();
        int height = get_allocated_height ();
        var hadjust_value = hadjustment.value;
        var style_context = get_style_context ();

        double time_step = step*time_view;
        for (uint i = 0; i * step < hadjustment.upper; i++) {
            double x = i * step - hadjust_value;
            if (x + step <= 0 || x > hadjustment.page_size) {
                continue;
            }

            style_context.render_line (cr, x, 0, x, height);
            var layout = create_pango_layout ("");
            layout.set_markup (get_pretty_time (i * time_step), -1);
            style_context.render_layout (cr, x + 2, 0, layout);
        }

        return true;
    }

    private string get_pretty_time (double time) {
        uint second_part = (uint)(time/Gst.SECOND);
        uint milisecond_part = (uint)((time%Gst.SECOND)/Gst.MSECOND);
        uint microsecond_part = (uint)((time%Gst.MSECOND)/Gst.USECOND);
        return "00:%02u.<small>%02u</small>".printf (second_part, milisecond_part);
    }
    
    private void calculate_step () {
        double time_step = Gst.USECOND;
        while (time_step/time_view < MAX_STEP) {
            time_step = time_step*2;
        }
        time_step = Gst.SECOND/ Math.round (Gst.SECOND/time_step);
        step = time_step/time_view;
    }
}
