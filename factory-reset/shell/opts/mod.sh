#!/bin/bash
# More safety, by turning some bugs into errors.
# Without `errexit` you don’t need ! and can replace
# ${PIPESTATUS[0]} with a simple $?, but I prefer safety.
set -o errexit -o pipefail -o noclobber -o nounset

# -allow a command to fail with !’s side effect on errexit
# -use return value from ${PIPESTATUS[0]}, because ! hosed $?
! getopt --test > /dev/null 
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo 'I’m sorry, `getopt --test` failed in this environment.'
    exit 1
fi

# option --output/-o requires 1 argument
LONGOPTS=verbose,payload:,image:,help,drive:
OPTIONS=vp:i:hd:

# -regarding ! and PIPESTATUS see above
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

# Set variables
verbose=false
drive=""
payload="none"

# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -v|--verbose)
            verbose=true
            shift
            ;;
        -p|--payload)
            payload=$2
            shift
            ;;
        -i|--image)
            image="$2"
            shift
            ;;
        -h|--help)
            help_cli 0
            shift
            ;;
        -d|--drive)
            image="$2"
            shift
            ;;
        -l|--list|--list-payloads)
            list_payload 0
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

# Handle non-option arguments
if [[ $# -ne 1 ]]; then
    echo "$0: A input file is required."
    exit 1
fi

##### Actually start running the script #####

# Make some functions
function echo_debug() {
    if [[ $verbose == "true" ]]; then
        echo_blue "$@"
    fi
}
function help_cli() {
    echo "Usage: $0 mod -i \"image\" or -d \"drive\" -p \"payload\""
    echo "$0: ChromeOS recovery/factory shim image modification tool."
    echo -e "Arguments:"
    echo -e "   -i|--image\n        The image you want to modify (Example: -i chromeos_octopus_v111.bin)"
    echo -e "   -d|--drive\n        The USB drive you want to modify (Example: -d /dev/sda)"
    echo -e "   -p|--payload\n        The payload you want to use (Example: -p new_kern)"
    echo -e "   -l|--list|--list-payloads\n        List the payloads currently available."
    echo -e "   -v|--verbose\n        Use verbose logging details."
    echo -e "   -h|--help\n        Show this help menu."
    exit "$@"
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
function get_payload() {
    echo_debug "DEBUG: Finding payload option..."
    PAYLOAD_URL=$(cat urls.txt | grep -A 3 "name=$1" | grep -- "url=" | cut -f2 -d"=")
    echo "INFO: Fetching payload..."
    if [[ $FETCH_APP == "curl" ]]; then
        fetching "$PAYLOAD_URL" > payload
    else
        fetching "$PAYLOAD_URL" > payload
    fi
    echo "INFO: The payload $payload has now been downloads."
}
function list_payload() {
    echo -e "The following payloads are available:"
    echo "sh1mmer-norm, sh1mmer-dev, fakemurk, rma, mini."
    exit $1
}

# Main part
if [ -z $image ]; then
    exit_red "ERROR: You need to specify an image or drive to modify."
    help_cli 1
fi
which dd || exit_red "ERROR: dd flashing utility not found."
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
if [[ $payload != "" ]]; then
    get_payload $payload
else
    echo_red "ERROR: You need to provide a payload for your image."
    list_payload 1
fi
if [ -e $image ] || [ -b $image ] then
    exit_red "ERROR: The file or drive $image does not exist or is not readable."
else
    [ -w $image ]
    if [[ ${PIPESTATUS[0]} != 0 ]]
        exit_red "ERROR: The file or drive $image is not writable by any means."
    fi
fi
if [ -e payload ]; then
    echo "INFO: Mounting $image..."
    echo_debug "DEBUG: Running command: mkdir -p /tmp/cros_image_mnt/root"
    mkdir -p /tmp/cros_image_mnt/root
    echo_debug "DEBUG: Running command: sudo mount -v -o nodev,noexec,rw,loop,errors=remount-ro $image /tmp/cros_image_mnt/root"
    read -p "Please enter your password to continue: " passwd
    sudo -S $passwd mount -v -o nodev,noexec,rw,loop,errors=remount-ro $image /tmp/cros_image_mnt/root
fi