src = [
	'constants.vala',
	'gui.vala',
	'main.vala',
	'model.vala',
	'modelBuilder.vala'
]
deps = [
	dependency('glib-2.0'),
	dependency('gobject-2.0'),
	dependency('gee-0.8'),
	dependency('json-glib-1.0'),
	dependency('gtk+-3.0'),
	project_config_dep
]
executable('money_watch', sources: src, dependencies: deps)
