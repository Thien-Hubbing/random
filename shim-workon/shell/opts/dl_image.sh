#!/bin/bash
# Set variables
rma=false
verbose=false
board=""
list=false
help=false
prefix="/opt/custom-tools/sdk/shim-workon"

# now enjoy the options in order and nicely split until we see --
for option in "$@"; do
    case "${option}" in
        --verbose)
            verbose=true
            shift
            ;;
        --board)
            board="$2"
            shift
            ;;
        --rma)
            rma=true
            shift
            ;;
        --list)
            list=true
            shift
            ;;
        --help|--usage)
            help=true
            shift
            ;;
        --*)
            ;;
        -*)
            [[ ${option} == "*r*" ]] && rma=true
            [[ ${option} == "*l*" ]] && list=true
            [[ ${option} == "*b*" ]] && board=$2
            [[ ${option} == "*v*" ]] && verbose=true
            [[ ${option} == "*h*" ]] && help=true
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "ERROR: we have no idea what happened."
            exit 3
            ;;
    esac
done

# Define functions
source ${prefix}/opts/echos.sh
function echo_debug() {
    if [[ $verbose == "true" ]]; then
        echo_blue "$@"
    fi
}
function help() {
    echo "Usage: shim-workon download -b \"board\" [--rma|-r]"
    echo "shim-workon download: ChromeOS recovery/factory image downloader."
    echo -e "Arguments:"
    echo -e "   -b|--board\n        The image board you want to download (Example: -b octopus)"
    echo -e "   -r|--rma\n        Download a RMA image instead of a normal recovery image."
    echo -e "   -l|--list\n        List the boards currently available."
    echo -e "   -v|--verbose\n        Use verbose logging details."
    echo -e "   -h|--help\n        Show this help menu."
    exit "$@"
}
function echo_debug() {
    if [[ $verbose == "true" ]]; then
        echo_blue "$@"
    fi
}
function fetching() {
    wget_param="-dFc -O - -t 3 -T 12 --no-cache --no-check-certificate"
    curl_param="-fvSkL"
    if [[ $FETCH_APP == "curl" ]]; then
        curl $curl_param "$@"
    elif [[ $FETCH_APP == "wget" ]]; then
        wget $wget_param "$@"
    fi
}
function get_url() {
    if [[ "$rma" == "true" ]]; then
        get_url_rma
    fi
    echo "INFO: Fetching url for board $board"
    echo_debug "DEBUG: Downloading recovery.conf from dl.google.com..."
    fetching "https://dl.google.com/dl/edgedl/chromeos/recovery/recovery.conf" > cros_recovery.conf
    echo_debug "DEBUG: Using grep to cut segments..."
    a="$(cat cros_recovery.conf | grep -A 7 -B 4 $board | grep -- "url=" | cut -f2 -d"=")"
    got_url="$(echo $a | cut -f2 -d" ")"
    bin="$(echo ${got_url#"https://dl.google.com/dl/edgedl/chromeos/recovery/"*})"
    dl_image $got_url $bin
}
function get_url_rma() {
    echo "INFO: Fetching RMA board $board from https://dl.sh1mmer.me/..."
    got_url="https://dl.sh1mmer.me/raw%20shims/${board}.bin"
    bin="chromeos_rma-${board}-latest-sh1mmer.bin"
    dl_image $got_url $bin
}
function dl_image() {
    recovery_url=$1
    bin_file=$2
    echo "INFO: Downloading $bin_file from $recovery_url..."
    fetching $recovery_url > $bin_file
    echo "INFO: File $bin_file was successfully downloaded."
}
function list_boards() {
    echo "Usually almost all chromeOS boards are available for download at \"https://dl.google.com/edgedl/chromeos/recovery/\""
    echo "If you want RMA boards, these are available:\nbrask, brya, clapper, coral, dedede, enguarde, glimmer, grunt, hana, jacuzzi, kukui, nami, octopus, orco, pyro, reks, sentry, stout, strongbad, tidus, ultima, volteer, zork."
    echo "NOTE: These boards are downloaded from https://dl.sh1mmer.me/ As such, only Chromebook/box RMA boards hosted by the sh1mmer team are available.\nWE ARE NOT RESPONSIBLE FOR YOU GETTING INTO TROUBLE WITH YOUR OEM, SCHOOL, OR ENTERPRISE WORKPLACE."
    exit $1
}

# Main
if [[ "$help" == "true" ]]; then
    help 0
fi
if [[ "$list" == "true" ]]; then
    list_boards
fi
if [ -z "$board" ]; then
    exit_red "ERROR: You need to specify a board to download."
fi
which wget || echo_yellow "WARNING: wget not found. Falling back to curl."
if [[ ${PIPESTATUS[0]} == 0 ]]; then
    FETCH_APP="wget"
else
    which curl
    if [[ ${PIPESTATUS[0]} != 0 ]]; then
        exit_red "ERROR: No download utility was available."
    fi
    FETCH_APP="curl"
fi
get_url