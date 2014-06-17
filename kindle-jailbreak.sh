#!/bin/bash

SRC_PATH=`pwd`
UTILS_PATH="$SRC_PATH/src/utils"
INSTALL_PATH="$SRC_PATH/src/install"

function load_items () {
    local PATTERN="$1"
    local L_PATH="$2"

    ITEMS=`ls -1 $L_PATH | grep $PATTERN`

    for ITEM in $ITEMS; do
	. /$L_PATH/$ITEM
    done
}


load_items ".utils$" $UTILS_PATH
check_root

SCREENSAVER=0
SUPPORTED_VERSIONS=(`cat files/config/versions | cut -d'|' -f2 | tr ' ' '-' | tr '\n' ' '`)
DEVICE=""
DEVICES=(`ls -1 /dev/sd*`)
MNT=""
KVERSION=""

while test $# -gt 0; do
    case "$1" in
	-h | --help)
	    print_help "usage"
	    ;;

	-k)
	    shift
	    KVERSION="$1"
	    KVERSION_F=$(echo "$KVERSION" | tr ' ' '-')

	    in_array SUPPORTED_VERSIONS "$KVERSION_F" && {
		print_ok "Version: $kversion"
	    } || {
		print_ko "Unrecognized or unsupported version."
		print_ko "Supported version are :"
		print_array SUPPORTED_VERSIONS
	    }
	    shift
	    ;;

	-d)
	    shift
	    DEVICE=$(locate $1 2>/dev/null | head -1)

	    in_array DEVICES "$DEVICE" > /dev/null && {
		print_ok "Device: $DEVICE: found."
	    } || {
		print_ko "Device: $DEVICE: not found."
		DEVICE=""
		EXIST=1
	    }

	    shift
	    ;;

	-m)
	    shift
	    MNT="$1"
	    print_ok "Mount point: $MNT."
	    shift
	    ;;

	--screensaver)
	    SCREENSAVER=1
	    print_ok "Screensaver hack will be installed."
	    shift
	    ;;

	*)
	    break
	    ;;
    esac
done

while [ "$DEVICE" == "" ] || [ $EXIST -eq 1 ] ; do
    DEVICE=$(print_help "device")
    EXIST=$(in_array DEVICES "$DEVICE")

    ([ "$DEVICE" == "" ] || [ $EXIST -eq 1 ]) && {
	print_ko "Device not specified or not found: $DEVICE."
    }
done

if [ "$MNT" == "" ]; then
    MNT=$(print_help "mount")
fi