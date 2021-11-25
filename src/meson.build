src = [
	'constants.vala',
	'gui.vala',
	'gui/panel.vala',
	'gui/right/accountInfo.vala',
	'gui/right/editWidget.vala',
	'gui/right/expenseList.vala',
	'gui/right/expenseWidget.vala',
	'gui/right/overview.vala',
	'main.vala',
	'model/account.vala',
	'model/expense.vala',
	'model/location.vala',
	'model/model.vala',
	'model/modelBuilder/modelBuilderFactory.vala',
	'model/modelBuilder/V1Builder.vala',
	'model/modelBuilder/V2Builder.vala',
	'model/shared.vala',
	'model/tag.vala'
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
