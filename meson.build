project('lfinance', ['c', 'vala'], version: '0.1')
# The following is heavily inspired by https://github.com/Fluid-DE/test
add_project_arguments('-DGETTEXT_PACKAGE="' + meson.project_name() + '"', language: 'c')
project_version = meson.project_version()
config_h = configuration_data()

set_defines = [
	['PACKAGE_VERSION', project_version],
	['APPLICATION_ID', meson.project_name()],
	['APPLICATION_INSTALL_PREFIX', get_option('prefix')]
]
foreach define: set_defines
	config_h.set_quoted(define[0], define[1])
endforeach
config_data = configuration_data()
config_data.set('version', meson.project_version())
config_data.set('app_name', meson.project_name())
config_file = configure_file(output: 'config.h', configuration: config_h)

project_config_dep = declare_dependency(sources: config_file, include_directories: include_directories('.'))

i18n = import('i18n')
data_dir = join_paths(meson.source_root(), 'data')
po_dir = join_paths(meson.source_root(), 'po')
vapi_dir = meson.current_source_dir() / 'vapi'
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')
subdir('data')
subdir('src')
subdir('po')
meson.add_install_script('update_cache.sh', icondir)
