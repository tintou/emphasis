namespace Emphasis {

    int main (string[] args) {
        Gtk.init (ref args);
        Gst.init (ref args);
        try {
            GES.init_check (ref args);
        } catch (Error e) {
            error (e.message);
        }

        //Reference the new GStreamer Editing Service types
        typeof(CompositionClipAsset).class_ref ();
        typeof(CompositionClip).class_ref ();
        typeof(CompositionSource).class_ref ();

        var window = new MainWindow ();
        window.show_all ();

        Gtk.main ();
        return 0;
    }

}
