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
LONGOPTS=add,inject,mod,modify,remove,delete,help
OPTIONS=amrh

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
operation="none"

# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        add|inject)
            operation="add"
            shift
            ;;
        mod|modify)
            operation="modify"
            shift
            ;;
        rm|remove|delete)
            operation="remove"
            shift
            ;;
        help)
            operation="help"
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

# handle non-option arguments
# none so far

# Make some functions
function help_cli() {
    echo "Usage: $0 [sub-commands]"
    echo "$0: ChromeOS recovery/factory shim image modification tool."
    echo -e "Commands:"
    echo -e "   add\n        Inject a payload, tools, or files into an image/drive. (Example: add your own testing tools.)"
    echo -e "   remove\n        Delete payloads, tools, files, or functions from a image/drive. (Example: remove the older chromeOS kernel.)"
    echo -e "   modify\n        Modify a payload for custom uses (Example: sh1mmer unenrollment exploit)."
    exit 0
}
function echo_blue() {
    echo -e "\033[1;94m$1"
    echo -e '\e[0m'
}
function echo_green() {
    echo -e "\e[0;32m$1"
    echo -e '\e[0m'
}
function echo_yellow() {
    echo -e "\e[1;33m$1"
    echo -e '\e[0m'
}
function echo_red() {
    echo -e "\e[0;31m$1"
    echo -e '\e[0m'
}
function exit_red() {
    echo_red "$@"
    read -ep "Press [Enter] to exit."
    exit 1
}
function exit_green() {
    echo_green "$@"
    read -ep "Press [Enter] to exit."
    exit 0
}

# More random stuff

# Call other scripts to do the heavy work
if [[ $operation == "none" || $operation == "help" ]]; then
    help_cli
elif [[ $operation == "add" ]]; then
    exec ./opts/add.sh
elif [[ $operation == "modify" ]]; then
    exec ./opts/mod.sh
elif [[ $operation == "remove" ]]; then
    exec ./opts/del.sh
fi