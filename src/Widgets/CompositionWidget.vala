public class CompositionWidget : Gtk.EventBox {
    List<GraphicalElement> element_list;
    private const double WIDTH = 1920;
    private const double HEIGHT = 1080;
    bool pressed = false;
    double latest_x = 0;
    double latest_y = 0;
    public CompositionWidget () {
        expand = true;
        element_list = new List<GraphicalElement> ();
        /*var element = new GraphicalElement ();
        element.load_file ("bg.jpg");
        element_list.append (element);
        element = new GraphicalElement ();
        element.depth = 1;
        element.x = 10;
        element.y = 10;
        element.load_file ("image.png");
        element_list.append (element);*/
        events |= Gdk.EventMask.POINTER_MOTION_MASK;
        set_size_request (100, 100);
    }

    public override bool draw (Cairo.Context cr) {
        int width = get_allocated_width ();
        int height = get_allocated_height ();

        double ratio = double.min (width/WIDTH, height/HEIGHT);

        double start_x = (width-WIDTH*ratio)/2;
        double start_y = (height-HEIGHT*ratio)/2;

        cr.set_source_rgb (0.5, 0.5, 0.5);
        cr.rectangle (0, 0, start_x, height);
        cr.fill ();
        cr.set_source_rgb (0.5, 0.5, 0.5);
        cr.rectangle (WIDTH*ratio+start_x, 0, width - WIDTH*ratio+start_x, height);
        cr.fill ();

        cr.set_source_rgb (0.5, 0.5, 0.5);
        cr.rectangle (0, 0, width, start_y);
        cr.fill ();
        cr.set_source_rgb (0.5, 0.5, 0.5);
        cr.rectangle (0, HEIGHT*ratio+start_y, width, height - HEIGHT*ratio+start_y);
        cr.fill ();

        var style_context = get_style_context ();
        var scale = style_context.get_scale ();
        cr.save ();
        cr.scale (1.0/scale, 1.0/scale);
        element_list.foreach ((element) => {
            double x = element.x * ratio + start_x;
            double y = element.y * ratio + start_y;
            var scaled = element.pixbuf.scale_simple ((int)(element.pixbuf.width * ratio * scale), (int)(element.pixbuf.height * ratio * scale), Gdk.InterpType.BILINEAR);
            style_context.render_icon (cr, scaled, x * scale, y * scale);
            if (element.hovered) {
                cr.set_source_rgb (1, 1, 1);
                cr.set_line_width (scale);
                cr.move_to (x * scale, y * scale);
                cr.line_to ((x+10) * scale, y * scale);
                cr.move_to (x * scale, y * scale);
                cr.line_to (x * scale, (y+10) * scale);
                cr.move_to (x * scale, y * scale);
                cr.stroke();
            }
        });

        cr.restore ();
        return true;
    }

    public override bool button_press_event (Gdk.EventButton event) {
        latest_x = event.x;
        latest_y = event.y;
        pressed = true;
        return GLib.Source.CONTINUE;
    }

    public override bool button_release_event (Gdk.EventButton event) {
        pressed = false;
        return GLib.Source.CONTINUE;
    }
    
    public override bool motion_notify_event (Gdk.EventMotion event) {
        int width = get_allocated_width ();
        int height = get_allocated_height ();

        double ratio = double.min (width/WIDTH, height/HEIGHT);
        double start_x = (width-WIDTH*ratio)/2;
        double start_y = (height-HEIGHT*ratio)/2;
        if (pressed) {
            GraphicalElement hovered_element = null;
            element_list.foreach ((element) => {
                if (element.hovered == true) {
                    hovered_element = element;
                }
            });

            if (hovered_element != null) {
                hovered_element.x += (int) ((event.x - latest_x) / ratio);
                hovered_element.y += (int) ((event.y - latest_y) / ratio);
                latest_x = event.x;
                latest_y = event.y;
                queue_draw ();
                return GLib.Source.CONTINUE;
            }
        }

        GraphicalElement hovered_element = null;
        element_list.foreach ((element) => {
            element.hovered = false;
            if (hovered_element == null || hovered_element.depth < element.depth) {
                if (event.x > (element.x * ratio) + start_x && event.x < ((element.x + element.width) * ratio) + start_x) {
                if (event.y > (element.y * ratio) + start_y && event.y < ((element.y + element.height) * ratio) + start_y) {
                    hovered_element = element;
                }
                }
            }
        });
        
        if (hovered_element != null) {
            hovered_element.hovered = true;
        }
        
        queue_draw ();
        return GLib.Source.CONTINUE;
    }
    
    public class GraphicalElement : GLib.Object {
        public int x = 0;
        public int y = 0;
        public int width = 0;
        public int height = 0;
        public Gdk.Pixbuf pixbuf;
        public bool hovered = false;
        public int depth = 0;

        public GraphicalElement () {
            
        }

        public void load_file (string file) {
            pixbuf = new Gdk.Pixbuf.from_file (file);
            width = pixbuf.width;
            height = pixbuf.height;
        }
    }
}
