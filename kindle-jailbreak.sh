#!/bin/bash

SRC_PATH=$(pwd)
UTILS_PATH="$SRC_PATH/src/utils"
INSTALL_PATH="$SRC_PATH/src/install"
TMP_="$SRC_PATH/tmp"
KINDLE4="$SRC_PATH/files/archives/kindle-k4-jailbreak-1.7.N.tar.gz"
KINDLE_="$SRC_PATH/files/archives/kindle-jailbreak-0.12.N.tar.gz"

function load_items () {
    local PATTERN="$1"
    local L_PATH="$2"

    ITEMS=$(ls -1 $L_PATH | grep $PATTERN)

    for ITEM in $ITEMS; do
	. /$L_PATH/$ITEM
    done
}


load_items ".utils$" $UTILS_PATH
load_items ".install$" $INSTALL_PATH
check_root

CUSTOM_FONTS=0
JAILBREAK=1
SCREENSAVER=0
SUPPORTED_VERSIONS=($(cat files/config/versions | cut -d'|' -f2 | tr ' ' '-' | tr '\n' ' ')
DEVICE=""
DEVICES=($(ls -1 /dev/sd*))
MNT=""
MOUNTED=0
KVERSION=""
INSTALL="_install.bin"

while test $# -gt 0; do
    case "$1" in
	-h | --help)
	    print_help "usage"
	    ;;

	--no)
	    shift
	    JAILBREAK=0
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

	--fonts)
	    CUSTOM_FONTS=1
	    print_ok "Custom fonts hack will be installed" 1
	    shift
	    ;;

	--uninstall)
	    INSTALL="_uninstall.bin"
	    print_ok "Jailbreak will be uninstalled" 1
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

############################################
### Make variables available in install/ ###
############################################
export KVERSION=$KVERSION
export MNT=$MNT
export DEVICE=$DEVICE
export SRC_PATH=$SRC_PATH
export INSTALL=$INSTALL
export MOUNTED=$MOUNTED

if [ $JAILBREAK -eq 1 ]; then
    if [ "$KVERSION" == "Kindle 4" ]; then install_hack "$TMP_" "$SRC_PATH/files/archives/kindle-k4-jailbreak-1.7.N.tar.gz" jailbreak_install
    else; install_hack "$TMP_" "$SRC_PATH/files/archives/kindle-jailbreak-0.12.N.tar.gz" jailbreak_install
    fi
fi

[ $SCREENSAVER -eq 1 ] && install_hack "$TMP_" "$SRC_PATH/files/archives/kindle-ss-0.44.N.tar.gz" screensaver_install
[ $CUSTOM_FONTS -eq 1 ] && install_hack "$TMP_" "" custom_fonts_install

print_help "end"
