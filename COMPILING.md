# Compiling

The at the moment only Fedora and Debian are supported. These instructions may work on Debian-derived distributons like Ubuntu.

## Install packages

### Fedora

```
sudo dnf install git glib2-devel pkgconf-pkg-config meson ninja-build vala libgee-devel json-glib-devel gtk3-devel
```

### Debian

```
sudo apt install git libglib2.0-dev meson ninja-build valac libgee-0.8-dev libjson-glib-dev libgtk-3-dev
```

## Build

```
git clone https://github.com/JCWasmx86/LFinance
cd LFinance
mkdir build && cd build
meson ..
ninja
# To run
./src/lfinance
# To install to /usr/local
sudo ninja install
```
