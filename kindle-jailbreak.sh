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
MOUNTED=0
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

	    in_array SUPPORTED_VERSIONS "$KVERSION_F" > /dev/null && {
		print_ok "Version: $KVERSION" 1
	    } || {
		print_ko "Unrecognized or unsupported version" 1
		print_ko "Supported version are :" 1
		KVERSION=""
		print_array SUPPORTED_VERSIONS
	    }
	    shift
	    ;;

	-d)
	    shift
	    INPUT=$1
	    DEVICE=$(ls -d1 /dev/* | grep $1)

	    in_array DEVICES "$DEVICE" > /dev/null && {
		print_ok "Device: $DEVICE: found" 1
	    } || {
		print_ko "Device: $INPUT: not found" 1
		DEVICE=""
		EXIST=1
	    }

	    shift
	    ;;

	-m)
	    shift
	    MNT="$1"
	    print_ok "Mount point: $MNT" 1
	    shift
	    ;;

	--screensaver)
	    SCREENSAVER=1
	    print_ok "Screensaver hack will be installed" 1
	    shift
	    ;;

	*)
	    break
	    ;;
    esac
done

get_mountpoint
print_ok "Mount point: $MNT" 1

if [ `mountpoint $MNT | grep "not" | wc -l` -eq 1 ]; then
    get_device
    print_ok "Device: $DEVICE: found" 1
else
    print_ok "Mount point: $MNT: mounted" 1
    MOUNTED=1
fi

get_version
print_ok "Version: $KVERSION" 1

if [ $MOUNTED -eq 0 ]; then
    mount $DEVICE $MNT
fi

########################
### Here for testing ###
########################
echo ""
echo "Kindle version: $KVERSION"
echo "Firmware: $(cat files/config/versions | grep "$KVERSION" | cut -d'|' -f1)"
echo "Mountpoint: $MNT"

umount $MNT

