#!/bin/bash

##
## Backup, purge, etc.
##

cd `dirname $0` || exit 99

## only backup if in FG local network
../../../scripts/isInFgNetwork.sh -e "/home/mpe/SHARE/FG/nas2/Petruzelka/duply" \
    || { echo "Not in FG local network, exiting..."; exit 0; }

## delete broken backup archives (e.g. after unfinished run)
./duply.sh cleanup --force  || exit 1

## backup
./duply.sh backup || exit 2

## purge outdated backup archives (older than $MAX_AGE)
./duply.sh purge --force || exit 3

## purge outdated backups (more than $MAX_FULL_BACKUPS full backups and associated incrementals)
./duply.sh purge-full --force || exit 4
