#!/usr/bin/env sh
# Based on https://gitlab.gnome.org/GNOME/gnome-2048/-/blob/master/meson_post_install.py
if [[ $(id -u) -ne 0 ]] ; then echo "No root - Probably in RPM-Build or install, I will just exit"; exit 0; fi
gtk-update-icon-cache --quiet --force --ignore-theme-index $1
