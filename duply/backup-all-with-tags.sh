#!/bin/bash

##
## Run backup-cron.sh scripts in profile directories
##

WD=`readlink -f $0`; WD=`dirname $WD`
LD="$WD/../log"
LOG="$LD/backup.all-with-tags.`date '+%Y%m%d-%H%M%S'`.log"

function lg {
    if [ "$*" != "" ]; then
        echo "`date '+%Y-%m-%d %H:%M:%S'` $$ $@" | tee -a $LOG
    else
        echo | tee -a $LOG
    fi
}

## print usage if no tags specified
if [ "$*" = "" ]; then
    echo "Usage: $0 <tag> [tag2] [tag3] ..."
    exit 0
fi

lg "STARTED - $0 $@"

lg "Backup profiles with matching tags"
## for each profile directory
for PD in `find "$WD/profile" -maxdepth 1 -mindepth 1 -type d`; do #lg "PD: $PD"
    P=`basename $PD`

    ## for each tag on commandline
    for T1 in "$@"; do #lg "T1: $T1"
        ## for each tag in profile tags
        for T2 in `cat "$PD/tags" | grep -v '^#' | grep -Ev '^[[:space:]]*$'`; do #lg "T2: $T2"
            if [ "$T1" = "$T2" ]; then
                lg "    $P - backup (tag $T1)"
                LOG2="$LD/backup.$P.`date '+%Y%m%d-%H%M%S'`.log"
                $PD/backup.sh >$LOG2 2>&1; RC="$?"
                if [ "$RC" != "0" ]; then
                    lg "    $P - backup FAILED with status $RC";
                fi
                continue 3 ## next profile
            fi
        done
    done
    lg "    $P - skip"
done

lg "Remove old logs"
find "$LD" -type f -name "*.log" -mtime +30 -print -delete | tee -a "$LOG"

lg "FINISHED - $0 $@"
