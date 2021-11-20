project('money_watch', ['c', 'vala'], version: '0.1')
# The following is heavily inspired by https://github.com/Fluid-DE/test
add_project_arguments('-DGETTEXT_PACKAGE="' + meson.project_name() + '"', language:'c')
project_version = meson.project_version()
config_h = configuration_data()

package_bugreport = 'http://bugzilla.gnome.org/enter_bug.cgi?product=' + meson.project_name()
set_defines = [
	['PACKAGE', meson.project_name()],
	['PACKAGE_BUGREPORT', package_bugreport],
	['PACKAGE_NAME', meson.project_name()],
	['PACKAGE_STRING', '@0@ @1@'.format(meson.project_name(), project_version)],
	['PACKAGE_TARNAME', meson.project_name()],
	['PACKAGE_URL', 'https://github.com/JCWasmx86/MoneyWatch'],
	['PACKAGE_VERSION', project_version],
	['VERSION', project_version],
	['GETTEXT_PACKAGE', meson.project_name()],
	['APPLICATION_ID', meson.project_name()],
	['APPLICATION_INSTALL_PREFIX', get_option('prefix')]
]

foreach define: set_defines
	config_h.set_quoted(define[0], define[1])
endforeach

# Compiler flags

config_data = configuration_data()
config_data.set('version', meson.project_version())
config_data.set('testdata_dir', join_paths(meson.source_root(), 'data', 'tests'))
config_data.set('app_name', meson.project_name())

config_file = configure_file(
         output: 'config.h',
  configuration: config_h
)

project_config_dep = declare_dependency(
    sources: config_file,
    include_directories: include_directories('.')
)

i18n = import('i18n')
data_dir = join_paths(meson.source_root(), 'data')
po_dir = join_paths(meson.source_root(), 'po')
src_dir = join_paths(meson.source_root(), 'src')

subdir('src')
subdir('po')
