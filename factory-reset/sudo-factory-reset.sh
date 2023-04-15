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
        -t|--type)
            reset_type=$2
            shift
            ;;
        -q|--quick)
            quick=true
            shift
            ;;
        -q|--)
            quick=true
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

# Make a temporary directory
export tmp_dir="/tmp/freset_$(date +%Y-%m-%d_$RANDOM)"
mkdir $tmp_dir

# Do things to see what's required
mkdir -p ${tmp_dir}/tools
mkdir -p ${tmp_dir}/libraries
mkdir -p ${tmp_dir}/logs
mkdir -p ${tmp_dir}/req
cp -R "/Volumes/USB/factory-reset/bin/" "${tmp_dir}/tools"
cp -R "/Volumes/USB/factory-reset/lib/" "${tmp_dir}/libraries"
cp -R "/Volumes/USB/factory-reset/sbin/" "${tmp_dir}/req"

# Source some scripts
source "${tmp_dir}/req/sources.sh"
source "${tmp_dir}/req/functions.sh"

# Sets a bunch of random stuff
which "brew"
if [[ $? = 0 ]]; then
    homebrewExist=true
fi
for i in "${tmp_dir}/tools/*.sh" "${tmp_dir}/libraries/*"; do
    which $i
    if [[ $? != 0 ]]; then
        die "ERROR: One or more required scripts was not found."
    fi
done

# Check if you are running as root
if [[ $EUID != 0 ]]; then
    die "The following script requires you to run as root using sudo.\nPlease run the script again as root."
fi

# Go to main menu
main_menu
echo -e "A full reset was request on $(date) using option ${reset_option}." > ${tmp_dir}/reset_on.txt