namespace MoneyWatch {
	internal class BigList : ScrollBox {
		Model model;
		Expander accounts;
		Expander locations;
		Expander tags;
		AddPanel addButtons;

		internal BigList(Model model) {
			Object(orientation: Gtk.Orientation.VERTICAL, spacing: 2);
			this.model = model;
		}
		internal void rebuild(SelectAccountFunc func) {
			bool expanded_accounts = accounts == null ? false : accounts.get_expanded();
			bool expanded_locations = locations == null ? false : locations.get_expanded();
			bool expanded_tags = tags == null ? false : tags.get_expanded();
			this.box.get_children().@foreach(a => {this.box.remove(a);});
			this.accounts = new Expander(_("Accounts"), new AccountActionHandler(func, this.model), "text", false);
			foreach(var account in model._accounts) {
				this.accounts.append_string(account._name);
			}
			this.accounts.set_expanded(expanded_accounts);
			this.pack_start(this.accounts, false, false, 2);
			this.locations = new Expander(_("Locations"), new LocationActionHandler(this.model), "text", false);
			foreach(var location in model._locations) {
				this.locations.append_string(location.id_string(), location.id_string());
			}
			this.locations.set_expanded(expanded_locations);
			this.pack_start(this.locations, false, false, 2);
			this.tags = new Expander(_("Tags"), new TagActionHandler(this.model), "markup");
			foreach(var tag in model._tags) {
				var colors = tag._rgba;
				this.tags.append_string(
					"<b><span foreground=\"#%02x%02x%02x%02x\" >".printf(colors[0], colors[1], colors[2], colors[3]) + tag._name + "</span></b>");
			}
			this.tags.set_expanded(expanded_tags);
			this.pack_start(this.tags, false, false, 2);
			this.addButtons = new AddPanel(this.model);
			this.pack_start(this.addButtons, false, false, 2);
		}
	}
}
