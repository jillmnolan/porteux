#!/bin/bash

MODULENAME=003-lxde-0.10.1

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$PWD/../builder-utils/cachefiles.sh"
source "$PWD/../builder-utils/downloadfromslackware.sh"
source "$PWD/../builder-utils/genericstrip.sh"
source "$PWD/../builder-utils/helper.sh"
source "$PWD/../builder-utils/latestfromgithub.sh"

if ! isRoot; then
	echo "Please enter admin's password below:"
	su -c "$0 $1"
	exit
fi

### create module folder

mkdir -p $MODULEPATH/packages > /dev/null 2>&1

### download packages from slackware repositories

DownloadFromSlackware

### packages outside Slackware repository

currentPackage=xcape
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/misc/${currentPackage}/ -A * || exit 1
info=$(DownloadLatestFromGithub "alols" ${currentPackage})
version=${info#* }
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sed -i "s|-O2.*|$GCCFLAGS -flto=auto\"|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=gpicview
version="0.2.6"
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget https://github.com/lxde/${currentPackage}/archive/refs/heads/master.tar.gz -O ${currentPackage}.tar.gz
tar xfv ${currentPackage}.tar.gz
cd ${currentPackage}-master
./autogen.sh && CFLAGS="$GCCFLAGS -flto=auto" ./configure --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc --disable-static --disable-debug --enable-gtk3
make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lightdm
SESSIONTEMPLATE=lxde sh $SCRIPTPATH/../extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lightdm-gtk-greeter
sh $SCRIPTPATH/../extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=atril
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

# required from now on
installpkg $MODULEPATH/packages/libcanberra*.txz || exit 1

currentPackage=pavucontrol
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=l3afpad
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/stevenhoneyman/${currentPackage}
cd ${currentPackage}
version=`git log -1 --date=format:"%Y%m%d" --format="%ad"`
sh autogen.sh
CFLAGS="$GCCFLAGS -flto=auto" ./configure --prefix=/usr --libdir=/usr/lib${SYSTEMBITS} --sysconfdir=/etc --disable-static --disable-debug || exit 1
make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious
sh $SCRIPTPATH/../extras/audacious/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
sh $SCRIPTPATH/../extras/audacious/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

# temporary just to build engrampa and mate-search-tool
currentPackage=mate-common
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "mate-desktop" ${currentPackage})
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
sh autogen.sh --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc
make -j${NUMBERTHREADS} install || exit 1
rm -fr $MODULEPATH/${currentPackage}

# temporary to build yelp-tools
installpkg $MODULEPATH/packages/python-pip*.txz || exit 1
rm $MODULEPATH/packages/python-pip*.txz
cd $MODULEPATH
pip install lxml || exit 1

# temporary to build yelp-tools
currentPackage=yelp-xsl
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "GNOME" ${currentPackage})
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
sh autogen.sh --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc
make -j${NUMBERTHREADS} install || exit 1
rm -fr $MODULEPATH/${currentPackage}

# temporary to build engrampa and mate-search-tool
currentPackage=yelp-tools
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "GNOME" ${currentPackage})
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
mkdir build && cd build
meson setup --prefix /usr ..
ninja -j${NUMBERTHREADS} install || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=engrampa
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "mate-desktop" ${currentPackage})
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
CFLAGS="$GCCFLAGS" sh autogen.sh --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc --disable-static --disable-debug --disable-caja-actions || exit 1
make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=gnome-screenshot
version=3.36.0 # higher than this will require libhandy
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget https://gitlab.gnome.org/GNOME/${currentPackage}/-/archive/$version/${currentPackage}-$version.tar.gz || exit 1
tar xvf ${currentPackage}-$version.tar.?z || exit 1
cd ${currentPackage}-$version
mkdir build && cd build
sed -i "s|i18n.merge_file('desktop',|i18n.merge_file(|g" ../src/meson.build
sed -i "s|i18n.merge_file('appdata',|i18n.merge_file(|g" ../src/meson.build
meson setup -Dcpp_args="$GCCFLAGS -flto=auto" --prefix /usr ..
ninja -j${NUMBERTHREADS} || exit 1
DESTDIR=$MODULEPATH/${currentPackage}/package ninja install
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=libfm-extra
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/libfm ${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
sed -i "s|g_file_info_get_size(inf)|g_file_info_get_attribute_uint64 (inf, G_FILE_ATTRIBUTE_STANDARD_SIZE)|g" src/base/fm-file-info.c || exit 1
sed -i "s|g_file_info_get_size(inf)|g_file_info_get_attribute_uint64 (inf, G_FILE_ATTRIBUTE_STANDARD_SIZE)|g" src/job/fm-deep-count-job.c || exit 1
sed -i "s|g_file_info_get_size(inf)|g_file_info_get_attribute_uint64 (inf, G_FILE_ATTRIBUTE_STANDARD_SIZE)|g" src/job/fm-file-ops-job.c || exit 1
sed -i "s|g_file_info_get_size(info)|g_file_info_get_attribute_uint64 (info, G_FILE_ATTRIBUTE_STANDARD_SIZE)|g" src/modules/vfs-search.c || exit 1
./autogen.sh --prefix=/usr --without-gtk --disable-demo && CFLAGS="$GCCFLAGS" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--localstatedir=/var \
	--enable-static=no \
	--enable-udisks \
	--with-gtk=3 \
	--with-extra-only 

make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=menu-cache
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
sh ./autogen.sh && CFLAGS="$GCCFLAGS" \
./configure \
  --prefix=/usr \
  --libdir=/usr/lib$SYSTEMBITS \
  --localstatedir=/var \
  --sysconfdir=/etc \
  --mandir=/usr/man \
  --enable-static=no \
  --program-prefix= \
  --program-suffix= 

make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=libfm
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh --prefix=/usr --without-gtk --disable-demo && CFLAGS="$GCCFLAGS -Wno-error=incompatible-pointer-types" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--localstatedir=/var \
	--with-gtk=3 \
	--enable-static=no

cp $SCRIPTPATH/lxde/${currentPackage}*.patch .
for i in *.patch; do patch -p0 < $i; done

make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=pcmanfm
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="$GCCFLAGS -flto=auto -Wno-error=incompatible-pointer-types" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--with-gtk=3 \
	--enable-static=no

make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

installpkg $MODULEPATH/packages/vte*.txz || exit 1

currentPackage=lxterminal
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="$GCCFLAGS -flto=auto -Wno-error=incompatible-pointer-types" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-man

make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxtask
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="$GCCFLAGS -flto=auto" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-static=no

cp $SCRIPTPATH/lxde/${currentPackage}*.patch .
for i in *.patch; do patch -p0 < $i; done

make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxrandr
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="$GCCFLAGS -flto=auto" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-man \
	--enable-gtk3

make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxsession
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="$GCCFLAGS -flto=auto -Wno-error=incompatible-pointer-types" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-static=no

make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxmenu-data
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="$GCCFLAGS -flto=auto" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-static=no

make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxlauncher
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="$GCCFLAGS -flto=auto" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-static=no

make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxinput
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="$GCCFLAGS -flto=auto" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-man

make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxhotkey
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="$GCCFLAGS -flto=auto" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-static=no

make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxde-common
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="$GCCFLAGS -flto=auto" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-static=no

make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxappearance
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="$GCCFLAGS -flto=auto" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-dbus \
	--enable-man \
	--enable-static=no

make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxappearance-obconf
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="$GCCFLAGS" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-static=no

make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

# required by lxpanel
installpkg $MODULEPATH/packages/libwnck3-*.txz
installpkg $MODULEPATH/packages/keybinder3*.txz

currentPackage=lxpanel
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="$GCCFLAGS -Wno-error=incompatible-pointer-types" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--with-plugins=all \
	--program-prefix= \
	--disable-silent-rules \
	--enable-static=no

cp $SCRIPTPATH/lxde/${currentPackage}*.patch .
for i in *.patch; do patch -p0 < $i || exit 1; done

make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=kora
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget https://github.com/bikass/${currentPackage}/archive/refs/heads/master.tar.gz || exit 1
tar xvf master.tar.gz && rm master.tar.gz || exit 1
cd ${currentPackage}-master
version=$(date -r . +%Y%m%d)
iconRootFolder=../${currentPackage}-$version-noarch/usr/share/icons/${currentPackage}
lightIconRootFolder=../${currentPackage}-$version-noarch/usr/share/icons/${currentPackage}-light
mkdir -p $iconRootFolder
mkdir -p $lightIconRootFolder
cp -r ${currentPackage}/* $iconRootFolder || exit 1
cp -r ${currentPackage}-light/* $lightIconRootFolder || exit 1
gtk-update-icon-cache -f $iconRootFolder || exit 1
gtk-update-icon-cache -f $lightIconRootFolder || exit 1
cd ../${currentPackage}-$version-noarch
echo "Generating icon package. This may take a while..."
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-icon-theme-$version-noarch-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### fix some .desktop files

sed -i "s|Core;|Utility;|g" $MODULEPATH/packages/usr/share/applications/gpicview.desktop
sed -i "s|image/x-xpixmap|image/x-xpixmap;image/heic;image/jxl|g" $MODULEPATH/packages/usr/share/applications/gpicview.desktop
sed -i "s|;Settings;|;|g" $MODULEPATH/packages/usr/share/applications/pavucontrol.desktop
sed -i "s|System;|Utility;|g" $MODULEPATH/packages/usr/share/applications/pcmanfm.desktop

### add lxde session

sed -i "s|SESSIONTEMPLATE|/usr/bin/lxsession|g" $MODULEPATH/packages/etc/lxdm/lxdm.conf

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### module clean up

cd $MODULEPATH/packages/

rm -R usr/share/engrampa
rm -R usr/share/gdm
rm -R usr/share/gnome
rm -R usr/share/Thunar

rm etc/xdg/autostart/blueman.desktop
rm usr/bin/canberra*
rm usr/bin/vte-*-gtk4
rm usr/lib${SYSTEMBITS}/gtk-2.0/modules/libcanberra-gtk-module.*
rm usr/lib${SYSTEMBITS}/libappindicator.*
rm usr/lib${SYSTEMBITS}/libcanberra-gtk.*
rm usr/lib${SYSTEMBITS}/libdbusmenu-gtk.*
rm usr/lib${SYSTEMBITS}/libindicator.*
rm usr/lib${SYSTEMBITS}/libkeybinder.*
rm usr/lib${SYSTEMBITS}/libvte-*-gtk4*
rm usr/libexec/indicator-loader
rm usr/share/lxde/wallpapers/lxde_green.jpg
rm usr/share/lxde/wallpapers/lxde_red.jpg

[ "$SYSTEMBITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null

mv $MODULEPATH/packages/usr/lib${SYSTEMBITS}/libvte-* $MODULEPATH/
GenericStrip
AggressiveStripAll
mv $MODULEPATH/libvte-* $MODULEPATH/packages/usr/lib${SYSTEMBITS}

### copy cache files

PrepareFilesForCacheDE

### generate cache files

GenerateCachesDE

### finalize

Finalize