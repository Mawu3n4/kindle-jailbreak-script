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
	    DEVICE=$(ls -d1 /dev/* | grep $1)

	    in_array DEVICES "$DEVICE" > /dev/null && {
		print_ok "Device: $DEVICE: found" 1
	    } || {
		print_ko "Device: $DEVICE: not found" 1
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


if [ ! -d "$MNT" ]; then
    CHECK=$(ls -d1 /media/* | grep -i "Kindle")

    if [ ! `echo -n $CHECK | wc -c` -eq 0 ]; then
	print_ok "Mount point: $CHECK: found, use it ?: [Y/n].." 0
	read YN
	case "$YN" in
	    n)
		MNT=""
		;;
	    *)
		MNT="$CHECK"
		;;
	esac
    fi
fi

while [ ! -d "$MNT" ]; do
    MNT=$(print_help "mount")
    [ ! -d "$MNT" ] && {
	print_ko "Mount point: $MNT: not found. Try specifyin full path" 1
    }
done

print_ok "Mount point: $MNT" 1

if [ `mountpoint $MNT | grep "not" | wc -l` -eq 1 ]; then
    while [ "$DEVICE" == "" ] || [ $EXIST -eq 1 ] ; do
	INPUT=$(print_help "device")
	DEVICE=$(ls -d1 /dev/* | grep $INPUT)
	EXIST=$(in_array DEVICES "$DEVICE")

	echo $DEVICE
	echo $EXIST
	([ "$DEVICE" == "" ] || [ $EXIST -eq 1 ]) && {
	    print_ko "Device not specified or not found: $DEVICE" 1
	}
    done

    print_ok "Device: $DEVICE: found" 1
else
    print_ok "Mount point: $MNT: mounted" 1
    MOUNTED=1
fi

EXIST=1
while [ "$KVERSION" == "" ] || [ $EXIST -eq 1 ] ; do
    KVERSION=$(print_help "version")
    KVERSION_F=$(echo "$KVERSION" | tr ' ' '-')

    EXIST=$(in_array SUPPORTED_VERSIONS "$KVERSION_F")

    ([ "$KVERSION" == "" ] || [ $EXIST -eq 1 ]) && {
	print_ko "Unrecognized or unsupported version" 1
	print_ko "Supported version are :" 1
	KVERSION=""
	print_array SUPPORTED_VERSIONS
    }
done

print_ok "Version: $KVERSION" 1

if [ $MOUNTED -eq 0 ]; then
    mount $DEVICE $MNT
fi


umount $MNT