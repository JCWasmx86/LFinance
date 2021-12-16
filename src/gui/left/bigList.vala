namespace LFinance {
	internal class BigList : ScrollBox {
		Model model;

		Expander accounts;
		Expander locations;
		Expander tags;
		AddPanel addButtons;

		internal BigList(Model model) {
			Object (orientation: Gtk.Orientation.VERTICAL, spacing: 2);
			this.model = model;
		}
		internal void rebuild(TriggerType? type, SelectAccountFunc func) {
			if(type == null) {
				this.accounts = new Expander (_("Accounts"),
							      new AccountActionHandler (func,
											this.model),
							      "text",
							      false);
				foreach(var account in this.model._accounts) {
					this.accounts.append_string (account._name);
				}
				this.pack_start (this.accounts, false, false, 2);
				this.locations = new Expander (_("Locations"),
							       new LocationActionHandler (
								       this.model),
							       "text",
							       false);
				foreach(var location in this.model._locations) {
					this.locations.append_string (location.id_string (), location.id_string ());
				}
				this.pack_start (this.locations, false, false, 2);
				this.tags = new Expander (_("Tags"), new TagActionHandler (this.model), "markup");
				foreach(var tag in this.model._tags) {
					var colors = tag._rgba;
					this.tags.append_string (
						"<b><span foreground=\"#%02x%02x%02x%02x\" >%s</span></b>".printf (
							colors[0],
							colors[1],
							colors[2],
							colors[3],
							tag._name));
				}
				this.pack_start (this.tags, false, false, 2);
				this.addButtons = new AddPanel (this.model);
				this.pack_start (this.addButtons, false, false, 2);
			} else if(type == TriggerType.ADD_TAG || type == TriggerType.DELETE_TAG ||
				  type == TriggerType.EDIT_TAG) {
				this.tags.clear ();
				foreach(var tag in this.model._tags) {
					var colors = tag._rgba;
					this.tags.append_string (
						"<b><span foreground=\"#%02x%02x%02x%02x\" >%s</span></b>".printf (
							colors[0],
							colors[1],
							colors[2],
							colors[3],
							tag._name));
				}
				this.tags.queue_draw ();
			} else if(type == TriggerType.ADD_LOCATION || type == TriggerType.DELETE_LOCATION ||
				  type == TriggerType.EDIT_LOCATION) {
				this.locations.clear ();
				foreach(var location in this.model._locations) {
					this.locations.append_string (location.id_string (), location.id_string ());
				}
				this.locations.queue_draw ();
			} else if(type == TriggerType.ADD_ACCOUNT || type == TriggerType.DELETE_ACCOUNT ||
				  type == TriggerType.EDIT_ACCOUNT) {
				this.accounts.clear ();
				foreach(var account in this.model._accounts) {
					this.accounts.append_string (account._name);
				}
				this.accounts.queue_draw ();
			} else {
				info ("Unknown type, ignoring in BigList: %s", type.to_string ());
			}
		}
	}
}
