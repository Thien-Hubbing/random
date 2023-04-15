#!/bin/bash
# Set variables
verbose=false
image=""
payload=""
help=false
use_drive=false
force_operation=false
prefix="/opt/custom-tools/sdk/shim-workon"

# now enjoy the options in order and nicely split until we see --
for option in "$@"; do
    case "${option}" in
        --verbose)
            verbose=true
            shift
            ;;
        --payload)
            payload=$2
            shift
            ;;
        --image)
            image="$2"
            shift
            ;;
        --help|--Usage)
            help=true
            shift
            ;;
        --drive)
            use_drive=true
            image="$2"
            shift
            ;;
        --list)
            list=true
            shift
            ;;
        --force)
            force_operation=true
            shift
            ;;
        --*)
            ;;
        -*)
            [[ ${option} == "*i*" ]] && image=$2
            [[ ${option} == "*d*" ]] && use_drive=true; image=$2
            [[ ${option} == "*f*" ]] && force_operation=true
            [[ ${option} == "*l*" ]] && list=true
            [[ ${option} == "*p*" ]] && payload=$2
            [[ ${option} == "*v*" ]] && verbose=true
            [[ ${option} == "*h*" ]] && help=true
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "ERROR: Unrecogized option: ${option}"
            exit 3
            ;;
    esac
done

##### Actually start running the script #####

# Make some functions
source ${prefix}/opts/echos.sh
function echo_debug() {
    if [[ $verbose == "true" ]]; then
        echo_blue "$@"
    fi
}
function help() {
    echo "Usage: shim-workon mod -i \"image\" or -d \"drive\" -p \"payload\""
    echo "shim-workon: ChromeOS recovery/factory shim image modification tool."
    echo -e "Arguments:"
    echo -e "   -i|--image\n        The image you want to modify (Example: -i chromeos_octopus_v111.bin)"
    echo -e "   -d|--drive\n        The USB drive you want to modify (Example: -d /dev/sda)"
    echo -e "   -p|--payload\n        The payload you want to use (Example: -p new_kern)"
    echo -e "   -l|--list\n        List the payloads currently available."
    echo -e "   -v|--verbose\n        Use verbose logging details."
    echo -e "   -h|--help\n        Show this help menu."
    echo -e "   -f|--force\n        Force the modification despite rootfs verification and user permissions."
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
    PAYLOAD_URL=$(cat ${prefix}/etc/urls.txt | grep -A 3 "name=$1" | grep -- "url=" | cut -f2 -d"=")
    echo "INFO: Fetching payload..."
    if [[ $FETCH_APP == "curl" ]]; then
        fetching "$PAYLOAD_URL" > payload
    else
        fetching "$PAYLOAD_URL" > payload
    fi
    local_load="$(cat urls.txt | grep "name=$1" | cut -f2 -d"=")"
    echo "INFO: The payload $payload has now has been downloaded."
}
function list_payload() {
    echo -e "The following payloads are available:"
    echo "sh1mmer-norm, sh1mmer-dev, fakemurk, rma, quick-rma, and mini."
    exit $1
}

# Main part
if [[ $help == true ]]; then
    help 0
fi
if [[ $list == true ]]; then
    list_payload
fi
if [ -z $image ]; then
    echo "$image"
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
    echo "INFO: Starting payload operation $local_load"
    sleep 3
    echo "INFO: Grabbing user password for sudo..."
    read passwd
    if [[ $local_load == "sh1mmer-norm" ]]; then
        echo "INFO: Extracting sh1mmer payload..."
        mv payload payload.zip
        unzip payload.zip -d payload_extract
        echo_green "INFO: Extraction success. Running payload..."
        mv $image payload_extract/wax/
        cd payload_extract/wax/
        echo_debug "DEBUG: Downloading chromebrew.tar.gz, required for sh1mmer."
        fetching https://dl.sh1mmer.me/build-tools/chromebrew/chromebrew.tar.gz > chromebrew.tar.gz
        sudo -S $passwd bash wax.sh $image
        if [[ ${PIPESTATUS[0]} != 0 ]]; then
            exit_red "ERROR: sh1mmer waxing failed. Try again."
        else
            exit_green "SUCCESS: Your image, $image, was modded successfully."
        fi
    elif [[ $local_load == "sh1mmer-dev" ]]; then
        echo "INFO: Extracting sh1mmer payload..."
        mv payload payload.zip
        unzip payload.zip -d payload_extract
        echo_green "INFO: Extraction success. Running payload..."
        mv $image payload_extract/wax/
        cd payload_extract/wax/
        echo_debug "DEBUG: Downloading chromebrew-dev.tar.gz, required for sh1mmer (dev)."
        fetching https://dl.sh1mmer.me/build-tools/chromebrew/chromebrew-dev.tar.gz > chromebrew-dev.tar.gz
        sudo -S $passwd bash wax.sh $image --dev
        if [[ ${PIPESTATUS[0]} != 0 ]]; then
            exit_red "ERROR: sh1mmer waxing failed. Try again."
        else
            exit_green "SUCCESS: Your image, $image, was modded successfully."
        fi
    elif [[ $local_load == "rma" ]]; then
        echo "INFO: Extracting RMA payload..."
        mv payload payload.tar.gz
        tar xvf payload.tar.gz --strip-components=1
        echo_debug "DEBUG: Fetching WiFi compatible firmware..."
        fetching "https://github.com/Netronome/linux-firmware/raw/master/iwlwifi-9000-pu-b0-jf-b0-41.ucode" > iwlwifi.ucode
        echo "INFO: Installing git for cloning repo..."; sudo -S $passwd apt install git || exit_red "ERROR: git utility was not able to be installed."
        echo "INFO: Done. Running supporting script..."
        exec local/rma.sh
        if [[ ${PIPESTATUS[0]} != 0 ]]; then
            exit_red "ERROR: RMA image modification failed.\nUsually the most common reason is because your don't have access to CFPE, GoldenEye, or you can't install docker.\nNOTE: This functionality still isn't working yet. Expect this to be fixed in v1.2.0"
        else
            exit_green "SUCCESS: Your image, $image, was modded with RMA functionality successfully."
        fi
    elif [[ $local_load == "rma-quick" ]]; then
        echo "INFO: Running payload..."
        read -ep "What board model do you have? [eg. octopus] "
        echo_debug "DEBUG: Downloading RMA shim image $REPLY from Lenovo..."
        
    elif [[ $local_load == "mini" ]]; then
        echo "INFO: Mounting loop device for disk modification..."
        echo "INFO: Fetching make_dev_ssd.sh..."
        echo_debug "DEBUG: Fetching a version of make_dev_ssd.sh from MercuryWorkshop that doesn't require resigning."
        fetching "https://github.com/MercuryWorkshop/sh1mmer/raw/beautifulworld/wax/make_dev_ssd_no_resign.sh" > make_dev_ssd_no_resign.sh
    fi
fi