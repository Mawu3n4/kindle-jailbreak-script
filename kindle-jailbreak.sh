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
MNT=""
KVERSION=""

while test $# -gt 0; do
    case "$1" in
	-h | --help)
	    echo "Usage: ./kindle-jailbreak"
	    echo "options:"
	    echo "	-h, --help		Display this help and exit"
	    echo "	-k [VERSION]		Specify Kindle version"
	    echo "	-d [DEVICE]		Specify device to mount"
	    echo "	-m [MNT]		Specify mount point"
	    echo "	--screensaver		Install screensaver hack"
	    exit 0
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
	    DEVICE="$1"
	    print_ok "Device: $DEVICE"
	    shift
	    ;;

	-m)
	    shift
	    MNT="$1"
	    echo "Mount point: $MNT"
	    shift
	    ;;

	--screensaver)
	    SCREENSAVER=1
	    echo "Screensaver hack"
	    shift
	    ;;

	*)
	    break
	    ;;
    esac
done


