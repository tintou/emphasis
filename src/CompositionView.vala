public class CompositionView : Gtk.Grid {
    GES.Pipeline pipeline;

    public CompositionView () {
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        pipeline = new GES.Pipeline ();
        var gtksink = Gst.ElementFactory.make ("gtksink", "sink");
        Gtk.Widget video_area;
        gtksink.get ("widget", out video_area);
        pipeline["video-sink"] = gtksink;
        add (video_area);
        //add (new CompositionWidget ());
    }

    public void set_timeline (GES.Timeline timeline) {
        pipeline.set_state (Gst.State.NULL);
        pipeline.set_timeline (timeline);
        pipeline.set_mode (GES.PipelineFlags.FULL_PREVIEW);
        pipeline.set_state (Gst.State.PLAYING);
        
    }
}
