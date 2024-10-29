#!/bin/bash
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "accountsservice" &
DownloadPackage "aspell" &
DownloadPackage "cairomm1" & # required by gnome-system-monitor
DownloadPackage "colord" &
DownloadPackage "dconf" &
DownloadPackage "editorconfig-core-c" &
DownloadPackage "enchant" &
DownloadPackage "ffmpegthumbnailer" &
wait
DownloadPackage "gexiv2" &
DownloadPackage "gjs" &
DownloadPackage "hunspell" &
DownloadPackage "glib-networking" &
DownloadPackage "glibmm2" & # required by gnome-system-monitor
DownloadPackage "gperf" & # required by libadwaita (appstream sub-project)
DownloadPackage "gst-plugins-bad-free" &
DownloadPackage "gst-plugins-good" &
DownloadPackage "gst-plugins-libav" &
wait
DownloadPackage "gtk4" &
DownloadPackage "gtkmm4" & # required by gnome-system-monitor
DownloadPackage "hyphen" &
DownloadPackage "ibus" &
DownloadPackage "libcanberra" &
DownloadPackage "libgtop" &
DownloadPackage "libgusb" &
DownloadPackage "libhandy" &
DownloadPackage "libnma" &
wait
DownloadPackage "libproxy" &
DownloadPackage "libsigc++3" & # required by gnome-system-monitor
DownloadPackage "libxklavier" &
DownloadPackage "libyaml" &
DownloadPackage "mozjs128" &
DownloadPackage "pangomm2" & # required by gnome-system-monitor
DownloadPackage "woff2" &
DownloadPackage "xorg-server-xwayland" &
wait

### only download if not present

[ ! -f /usr/bin/clang ] && DownloadPackage "llvm" # required by glycin

### temporary packages for further building

DownloadPackage "boost" &
DownloadPackage "c-ares" &
DownloadPackage "cups" &
DownloadPackage "dbus-python" &
DownloadPackage "egl-wayland" &
DownloadPackage "hwdata" & # required by libdisplay-info
DownloadPackage "iso-codes" & # required by gnome-desktop
DownloadPackage "krb5" &
wait
DownloadPackage "libsass" & # required by gnome-console
DownloadPackage "libsoup3" &
DownloadPackage "libwnck3" &
DownloadPackage "python-pip" &
DownloadPackage "sassc" & # required by gnome-console
DownloadPackage "vulkan-sdk" & # required by gtksourceview
DownloadPackage "xtrans" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
