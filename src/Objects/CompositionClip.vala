public class Emphasis.CompositionClip : GES.SourceClip, GES.Extractable, GES.MetaContainer {
    public static Emphasis.CompositionClip create (string _name) throws GLib.Error {
        var asset = new CompositionClipAsset (_name);
        Emphasis.CompositionClip res = null;
        try {
            res = (Emphasis.CompositionClip) asset.extract ();
        } catch (Error e) {
            throw e;
        }

        return res;
    }

    construct {
        warning ("");
    }

    public override GES.TrackElement create_track_element (GES.TrackType type) {
        warning ("");
        var res = new CompositionSource ();
        res.set_track_type (type);
        return res;
    }

    /*public override GLib.List<GES.TrackElement> create_track_elements (GES.TrackType type) {
        warning ("");
        var res = new GLib.List<GES.TrackElement> ();
        return res;
    }*/
}
