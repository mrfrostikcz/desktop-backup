#!/bin/bash

##
## Duply with profile
##

DIR=`readlink -f $0`; DIR=`dirname $DIR`
PROFILE=`basename $DIR`

echo
echo "### Duply command: $0 $@"
echo "Profile directory: $DIR"
echo "Profile name: $PROFILE"
echo

if [ "$*" = "" ]; then
    duply "$DIR" status
else
    duply "$DIR" "$@"
fi
