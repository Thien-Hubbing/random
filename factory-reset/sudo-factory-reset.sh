#!/bin/bash
# Make a temporary directory
export tmp_dir="/tmp/freset_$(date +%Y-%m-%d_$RANDOM)"
mkdir $tmp_dir

# Do things to see what's required
mkdir -p ${tmp_dir}/tools
mkdir -p ${tmp_dir}/libraries
mkdir -p ${tmp_dir}/logs
mkdir -p ${tmp_dir}/req
cp -R "${prefix}/factory-reset/bin/" "${tmp_dir}/tools"
cp -R "${prefix}/factory-reset/lib/" "${tmp_dir}/libraries"
cp -R "${prefix}/factory-reset/sbin/" "${tmp_dir}/req"

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
if [[ $1 == "-v" || $1 == "--verbose" ]]; then\
    verbose=true
fi

# Check if you are running as root
if [[ $EUID != 0 ]]; then
    die "The following script requires you to run as root using sudo.\nPlease run the script again as root."
fi

# Go to main menu
main_menu
echo -e "A full reset was request on $(date) using option ${reset_option}." > ${tmp_dir}/reset_on.txt