Name: lfinance
Version: 0.1
Release: 1%{?dist}
Summary: An application to easily manage your finances
License: AGPL-3.0

Source0: %{name}-%{version}.tar.xz

BuildRequires: meson
BuildRequires: gcc
BuildRequires: vala
BuildRequires: pkgconfig(glib-2.0)
BuildRequires: pkgconfig(gobject-2.0)
BuildRequires: pkgconfig(gee-0.8)
BuildRequires: pkgconfig(json-glib-1.0)
BuildRequires: pkgconfig(gtk+-3.0)

%description

%prep
%autosetup

%build
%meson
%meson_build

%install
%meson_install

%check
%meson_test

%files
%{_bindir}/lfinance
%{_datadir}/applications/jcwasmx86.lfinance.desktop
%{_datadir}/icons/hicolor/scalable/apps/jcwasmx86.lfinance.svg
%{_datadir}/locale/de/LC_MESSAGES/lfinance.mo

%post
gtk-update-icon-cache --quiet --force --ignore-theme-index %{_datadir}/icons/hicolor

%changelog
* Sat Nov 27 2021 JCWasmx86 <JCWasmx86@t-online.de> - 
- Initial beta release
