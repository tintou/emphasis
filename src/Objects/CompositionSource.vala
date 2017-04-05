public class Emphasis.CompositionSource : GES.VideoSource, GES.Extractable, GES.MetaContainer {
    public CompositionSource () {
        
    }

    construct {
        track_type = GES.TrackType.VIDEO;
    }

    public override Gst.Element create_source (GES.TrackElement object) {
        warning ("");
        var topbin = new Gst.Bin ("titlesrc-bin");
        var background = Gst.ElementFactory.make ("videotestsrc", "titlesrc-bg");

        var capsfilter = Gst.ElementFactory.make ("capsfilter", null);
        var alphacaps = Gst.Caps.from_string ("video/x-raw, format={AYUV, AYUV64, ARGB, ARGB64}");
        capsfilter.set ("caps", alphacaps);

        background.set ("pattern", GES.VideoTestPattern.SOLID_COLOR);
        background.set ("foreground-color", 100);

        topbin.add_many (background, capsfilter, null);
        background.link_pads ("src", capsfilter, "sink", Gst.PadLinkCheck.NOTHING);
        add_children_props (background, null, null, { "pattern", "foreground-color", null });
        return topbin;
    }
}
