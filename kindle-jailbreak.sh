#!/bin/bash

screensaver=0
supported_versions=(`cat files/config/versions | cut -d'|' -f2 | tr ' ' '-' | tr '\n' ' '`)
device=""
mnt=""
kversion=""

print_array() {
    local array="$1[@]"

    for element in "${!array}"; do
	echo "     "$element | tr '-' ' '
    done
}

in_array () {
    local array="$1[@]"
    local seeking=$2
    local in=1

    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

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
	    kversion="$1"
	    kversion_f=$(echo "$kversion" | tr ' ' '-')
	    in_array supported_versions "$kversion_f" && {
		echo "[+] Version: $kversion"
	    } || {
		echo "[-] Unrecognized or unsupported version."
		echo "[-] Supported version are :"
		print_array supported_versions
	    }
	    shift
	    ;;

	-d)
	    shift
	    device="$1"
	    echo "Device: $device"
	    shift
	    ;;

	-m)
	    shift
	    mnt="$1"
	    echo "Mount point: $mnt"
	    shift
	    ;;

	--screensaver)
	    echo "Screensaver hack"
	    shift
	    ;;

	*)
	    break
	    ;;
    esac
done