#!/bin/bash
# Version 1.0.3

# Set variables
operation="none"
prefix="/opt/custom-tools/sdk/shim-workon"

case "$1" in
    add|inject)
        operation="add"
        shift
        ;;
    mod|modify)
        operation="modify"
        shift
        ;;
    remove|delete)
        operation="remove"
        shift
        ;;
    fetch|download)
        operation="download"
        shift
        ;;
    -v|--version)
        echo "Current version: v1.0.3"
        shift
        exit 0
        ;;
    -h|--help)
        operation="help"
        shift
        ;;
    -*|--*)
        echo "ERROR: Unrecognized options chosion."
        exit 1
        ;;
esac

# handle non-option arguments
# none so far

# Make some functions
source ${prefix}/opts/echos.sh
function help_cli() {
    echo "Usage: shim-workon [sub-commands]"
    echo "shim-workon: ChromeOS recovery/factory shim image modification tool."
    echo -e "Commands:"
    echo -e "   add\n        Inject a payload, tools, or files into an image/drive. (Example: add your own testing tools.)"
    echo -e "   remove\n        Delete payloads, tools, files, or functions from a image/drive. (Example: remove the older chromeOS kernel.)"
    echo -e "   modify\n        Modify a payload for custom uses (Example: sh1mmer unenrollment exploit)."
    echo -e "   download\n        Download the image for modification (Example: shim-workon dl -r -b octopus)."
    exit 0
}

# Call other scripts to do the heavy work
if [[ $operation == "none" || $operation == "help" ]]; then
    help_cli
elif [[ $operation == "add" ]]; then
    # exec ./opts/add.sh
    exit_green "INFO: Function not implemented yet. Wait for v1.1.0"
elif [[ $operation == "modify" ]]; then
    echo_yellow "WARNING: Function not properly implemented yet. Wait for v1.1.0 for full funtionality.\nDon't say I didn't warn ya."
    $prefix/opts/mod.sh
elif [[ $operation == "remove" ]]; then
    # exec ./opts/del.sh
    exit_green "INFO: Function not implemented yet. Wait for v1.1.0"
elif [[ $operation == "download" ]]; then
    echo_yellow "WARNING: Function not properly implemented yet. Wait for v1.1.0 for full funtionality.\nDon't say I didn't warn ya."
    ${prefix}/opts/dl_image.sh
else
    help_cli
fi