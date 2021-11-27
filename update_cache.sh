#!/usr/bin/env sh
# Based on https://gitlab.gnome.org/GNOME/gnome-2048/-/blob/master/meson_post_install.py
gtk-update-icon-cache --quiet --force --ignore-theme-index $1
