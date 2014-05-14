#!/bin/bash

##
## Create profile symlink in duply configuration directory.
##
## Options:
##      -f  Force removal of existing profile directory or symlink.
##

SRC=~/.duply
DST=`readlink -f $0`; DST=`dirname $DST`
PROFILE=`basename $DST`

echo "Profile directory: $DST"
echo "Profile name: $PROFILE"
echo

test -d "$SRC" \
    && { echo "Duply configuration directory exists: $SRC"; } \
    || { echo "Create duply configuration directory: $SRC"; mkdir "$SRC" || exit 1; }

if [ "$1" = "-f" ]; then
    test -e "$SRC/$PROFILE" \
        && { echo "Delete existing duply profile: $SRC/$PROFILE"; rm -rf "$SRC/$PROFILE" || exit 1; }
fi

test -e "$SRC/$PROFILE" \
    && { echo "Duply profile exists: $SRC/$PROFILE"; } \
    || { echo "Create duply profile symlink: $SRC/$PROFILE"; ln -s "$DST" "$SRC/$PROFILE" || exit 1; }
