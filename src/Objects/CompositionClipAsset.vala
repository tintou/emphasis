public class Emphasis.CompositionClipAsset : GES.ClipAsset, GES.MetaContainer, GLib.AsyncInitable, GLib.Initable {
    public CompositionClipAsset (string _name) {
        Object (id: _name, extractable_type: typeof(Emphasis.CompositionClip));
    }

    construct {
        warning ("");
    }
}
