public class Emphasis.ProjectView : Gtk.Grid {
    public signal void add_asset_to_timeline (GES.Asset asset);

    GES.Project project;
    Gee.LinkedList<GES.Asset> assets;
    Gtk.ListBox assets_listbox;
    Gtk.Toolbar toolbar;
    public ProjectView () {
    
    }

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        assets = new Gee.LinkedList<GES.Asset> ();
        assets_listbox = new Gtk.ListBox ();
        assets_listbox.expand = true;

        toolbar = new Gtk.Toolbar ();
        toolbar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        toolbar.icon_size = Gtk.IconSize.SMALL_TOOLBAR;
        var add_button = new Gtk.ToggleToolButton ();
        add_button.icon_name = "list-add-symbolic";
        var remove_button = new Gtk.ToolButton (null, null);
        remove_button.icon_name = "list-remove-symbolic";
        toolbar.add (add_button);
        toolbar.add (remove_button);

        var add_menu = new Gtk.Menu ();
        var new_composition_item = new Gtk.MenuItem.with_label (_("New composition…"));
        var import_item = new Gtk.MenuItem.with_label (_("Import file…"));
        add_menu.add (new_composition_item);
        add_menu.add (import_item);
        add_menu.bind_property("visible", add_button, "active");
        add_menu.show_all ();
        add_button.toggled.connect (() => {
            if (add_button.active == true) {
                add_menu.popup (null, null, null, 0, Gtk.get_current_event_time ());
            }
        });
        new_composition_item.activate.connect (() => {
            project.create_asset (null, typeof (CompositionClip));
        });

        import_item.activate.connect (() => {
            var chooser = new Gtk.FileChooserDialog ("Select your favorite file", this.get_toplevel () as Gtk.Window, Gtk.FileChooserAction.OPEN,
                                                     "_Cancel", Gtk.ResponseType.CANCEL, "_Open", Gtk.ResponseType.ACCEPT);
            if (chooser.run () == Gtk.ResponseType.ACCEPT) {
                project.create_asset (chooser.get_uri (), typeof (GES.UriClipAsset));
            }

            // Close the FileChooserDialog:
            chooser.close ();
        });

        assets_listbox.row_activated.connect ((row) => {
            add_asset_to_timeline (((AssetRow) row).asset);
        });

        add (assets_listbox);
        add (toolbar);
    }

    public void set_project (GES.Project project) {
        this.project = project;
        project.list_assets (typeof(GES.Extractable)).foreach (add_asset);
        project.asset_added.connect (add_asset);
        project.asset_removed.connect ((asset) => {});
        project.error_loading_asset.connect ((error, id, type) => {critical (error.message);});
    }

    private void add_asset (GES.Asset asset) {
        assets.add (asset);
        var row = new AssetRow (asset);
        assets_listbox.add (row);
        row.show_all ();
    }
    
    public class AssetRow : Gtk.ListBoxRow {
        public GES.Asset asset;
        Gtk.Label asset_label;
        public AssetRow (GES.Asset asset) {
            this.asset = asset;
            if (asset is GES.UriClipAsset) {
                asset_label.label = Filename.display_basename (Filename.from_uri (asset.id));
            } else {
                asset_label.label = asset.id;
            }
        }
        
        construct {
            asset_label = new Gtk.Label (null);
            asset_label.halign = Gtk.Align.START;
            add (asset_label);
        }
    }
}
