#!/bin/bash

##########################################################################
##
## If running in local FG network, return exit status 0.
## If running in FG VPN, return exit status 1.
## If running elsewhere, return exit status 2.
##
## Options:
##      -e <path>   Check if <path> exists. Return exit status 3 if not.
##                  Can be used to check for samba mount existence.
##
##########################################################################

IP_PUBLIC="193.85.35.106"
CURL_TIMEOUT=5

TUN_DEV="tun0"
TUN_IP_OVPN="172.24.4."
TUN_IP_GTS="172.20."

function ex {
    echo "Exit with status $1"
    exit "$1"
}
function isNumber {
    [ -z "${1##*[!0-9]*}" ] && { echo "ERROR - number expected"; ex 99; } || return 0
}
function msg {
    echo "    $2"
    [ "$1" != "0" ] && ex "$1" || return 0
}

## check public IP
echo "Check if public IP is $IP_PUBLIC"
CNT=`curl -s -f -m $CURL_TIMEOUT "http://www.mojeip.cz/" 2>&1 | grep -c "$IP_PUBLIC"`; isNumber "$CNT"
[ "$CNT" = "0" ] && msg 2 "FG network not detected" || msg 0 "FG network detected"

## check for tunnel device IP address
echo "Check if FG VPN is active"
CNT=`ip a l "$TUN_DEV" 2>&1 | grep "inet " | grep -c " $TUN_IP_OVPN"`; isNumber "$CNT"
[ "$CNT" != "0" ] && msg 1 "FG OpenVPN detected" || msg 0 "FG OpenVPN not detected"
CNT=`ip a l "$TUN_DEV" 2>&1 | grep "inet " | grep -c " $TUN_IP_GTS"`; isNumber "$CNT"
[ "$CNT" != "0" ] && msg 1 "FG GTS VPN detected" || msg 0 "FG GTS VPN not detected"

## optionaly check for pathname existence
if [ "$1" = "-e" ]; then
    pth="$2"
    echo "Check if pathname exists: $pth"
    [ -e "$pth" ] && msg 0 "Found" || msg 3 "Not found"
fi

ex 0
