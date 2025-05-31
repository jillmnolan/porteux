#!/bin/bash

CURRENTPACKAGE=nvidia-driver
PORTEUXFULLVERSION=$(cat /etc/porteux-version)
PORTEUXVERSION=${PORTEUXFULLVERSION//*-}

systemFullVersion=$(cat /etc/slackware-version)
SLACKWAREVERSION=${systemFullVersion//* }

if [[ "$SLACKWAREVERSION" == *"+" ]]; then
    SLACKWAREVERSION=current
else
    SLACKWAREVERSION=stable
fi

APPLICATIONURL="https://github.com/porteux/porteux/releases/download/$PORTEUXVERSION/$CURRENTPACKAGE-$SLACKWAREVERSION.zip"
OUTPUTDIR="$PORTDIR/modules/"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
MODULEDIR="$BUILDDIR/$CURRENTPACKAGE-module"

rm -fr "$BUILDDIR" &>/dev/null
mkdir "$BUILDDIR" &>/dev/null

wget -T 15 "$APPLICATIONURL" -P "$BUILDDIR" || exit 1
MODULEFILENAME=$(unzip -Z1 $BUILDDIR/$CURRENTPACKAGE-$SLACKWAREVERSION.zip | rev | cut -d "/" -f 1 | rev) || exit 1
echo "$MODULEFILENAME"
unzip $BUILDDIR/$CURRENTPACKAGE-$SLACKWAREVERSION.zip -d "$BUILDDIR" &>/dev/null

if [ ! -w "$OUTPUTDIR" ]; then
    mv "$BUILDDIR"/"$MODULEFILENAME" /tmp &>/dev/null
    echo "Destination $OUTPUTDIR is not writable. New module placed in /tmp and not activated."
elif [ ! -f "$OUTPUTDIR"/"$MODULEFILENAME" ]; then
    mv "$BUILDDIR"/"$MODULEFILENAME" "$OUTPUTDIR" &>/dev/null
    echo "Module placed in $OUTPUTDIR"
    if [[ "$@" == *"--activate-module"* ]] && [ ! -d "/mnt/live/memory/images/$MODULEFILENAME" ]; then
        activate "$OUTPUTDIR"/"$MODULEFILENAME" -q &>/dev/null
    fi
else
    mv "$BUILDDIR"/"$MODULEFILENAME" /tmp &>/dev/null
    echo "Module $MODULEFILENAME was already in $OUTPUTDIR. New module placed in /tmp and not activated."
fi

# cleanup
rm -fr "$BUILDDIR" 2> /dev/null
