src = [
	'account_exporters/factory.vala',
	'account_exporters/md.vala',
	'account_exporters/pdf.vala',
	'constants.vala',
	'crypto/decryption.vala',
	'crypto/derive.vala',
	'crypto/encryption.vala',
	'crypto/encryptedFileWriter.vala',
	'exporters/pdf.vala',
	'exporters/stats.vala',
	'gui/left/accountActionHandler.vala',
	'gui/left/actionHandler.vala',
	'gui/left/addPanel.vala',
	'gui/left/bigList.vala',
	'gui/left/dialogs/addAccountDialog.vala',
	'gui/left/dialogs/addLocationDialog.vala',
	'gui/left/dialogs/addTagDialog.vala',
	'gui/left/dialogs/coloredRadioButton.vala',
	'gui/left/dialogs/customColorButton.vala',
	'gui/left/dialogs/exportAccount.vala',
	'gui/left/dialogs/exportModel.vala',
	'gui/left/dialogs/locationEditDialog.vala',
	'gui/left/dialogs/recommendedColorButton.vala',
	'gui/left/dialogs/tagEditDialog.vala',
	'gui/left/expander.vala',
	'gui/left/locationActionHandler.vala',
	'gui/left/tagActionHandler.vala',
	'gui/left/treeViewWithAction.vala',
	'gui/panel.vala',
	'gui/right/accountInfo.vala',
	'gui/right/createExpense.vala',
	'gui/right/createExpenseWidget.vala',
	'gui/right/dialogs/addTagDialog.vala',
	'gui/right/editWidget.vala',
	'gui/right/expenseList.vala',
	'gui/right/expenseWidget.vala',
	'gui/right/extendedTagButton.vala',
	'gui/right/locationButton.vala',
	'gui/right/overview.vala',
	'gui/right/tagButton.vala',
	'gui/shared/scrollBox.vala',
	'gui/shared/selectAccountFunc.vala',
	'main.vala',
	'model/account.vala',
	'model/expense.vala',
	'model/location.vala',
	'model/modelBuilder/modelBuilderFactory.vala',
	'model/modelBuilder/V1Builder.vala',
	'model/modelBuilder/V2Builder.vala',
	'model/model.vala',
	'model/shared.vala',
	'model/tag.vala'
]
deps = [
	dependency('glib-2.0'),
	dependency('gobject-2.0'),
	dependency('gee-0.8'),
	dependency('json-glib-1.0'),
	dependency('gtk+-3.0'),
	meson.get_compiler('vala').find_library('posix'),
	project_config_dep,
	dependency('libgcrypt')
]
executable('lfinance', sources: src, dependencies: deps, install: true)
test_deps = [
	dependency('glib-2.0'),
	dependency('gobject-2.0'),
	dependency('gee-0.8'),
	dependency('json-glib-1.0'),
	dependency('libgcrypt')
]
test_sources = [
	'test/testUtils.vala',
	'crypto/decryption.vala',
	'crypto/derive.vala',
	'crypto/encryption.vala',
	'model/account.vala',
	'model/expense.vala',
	'model/location.vala',
	'model/modelBuilder/modelBuilderFactory.vala',
	'model/modelBuilder/V1Builder.vala',
	'model/modelBuilder/V2Builder.vala',
	'model/model.vala',
	'model/shared.vala',
	'model/tag.vala'
]
model_builder_test = executable('model_builder_test', sources: test_sources + ['test/modelBuilderTest.vala'], dependencies : test_deps)
test('model_builder_test', model_builder_test)
v1_test = executable('v1_test', sources: test_sources + ['test/v1Test.vala'], dependencies : test_deps)
test('v1_test', v1_test)
v2_test = executable('v2_test', sources: test_sources + ['test/v2Test.vala'], dependencies : test_deps)
test('v2_test', v2_test)
crypto_test = executable('crypto_test', sources: test_sources + ['test/cryptoTest.vala'], dependencies : test_deps)
test('crypto_test', crypto_test)
