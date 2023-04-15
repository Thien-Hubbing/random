#!/bin/bash

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
    echo_red "ERROR: $@"
    read -ep "Press [Enter] to return to the main menu."
    main_menu
}
function exit_green() {
    echo_green "SUCCESS: $@"
    read -ep "Press [Enter] to return to the main menu."
    main_menu
}
function debug() {
    if [[ $verbose == "true" ]]; then
        echo_blue "DEBUG: $@"
    fi
}
function info() {
    echo "INFO: $@"
}
function warn() {
    echo_yellow "WARNING: $@"
}
function die() {
    echo_red "FATAL: $@"
    exit 1
}
# Fetch recovery url for chromebook
function cros_fetch_recovery_url() {
    local recovery_file
    recovery_file="$1"
    a=$(cat $recovery_file | grep -A 7 -B 4 ${hwid_simple} | grep -- "url=")
    a=$(echo "$a" | cut -f2 -d"=")
    recovery_url=$(echo $a | uniq -d | cut -f1 -d" ")
    cros_bin_package="$(echo ${recovery_url#"https://dl.google.com/dl/edgedl/chromeos/recovery/"*})"
}
# Restore a Chromebook or Chromebox or Chromewhatever to stock settings
function cros_restore() {
    local use_cross
    which crossystem vpd "/usr/sbin/chromeos-*" "/usr/share/chromeos-assets/*"
    if [[ $? != 0 ]]; then
        echo_yellow "Warning: Some chromeOS assets does not exist (Have you modded chromeOS?)."
        use_cross=false
    else
        use_cross=true
    fi
    echo_blue "You have selected option $menuOption."
    read -ep "Do you want to restore your chromeOS device to stock? [Y/N]"
    if [[ $REPLY != "y" || $REPLY != "Y" ]]; then
        exit_red "ChromeOS restore cancelled."
    fi
    echo_blue "Beginning phase 1: Downloading recovery image for chromeOS recovery..."
    which curl && FETCH_URL="curl"
    which wget && FETCH_URL="wget"
    if [[ "$use_cross" == "true" ]]; then
        sudo crossystem clear_tpm_owner_request=1
        sudo crossystem wipeout_request=1
        use_cross=""
    fi
    if [[ "$FETCH_URL" == "curl" ]]; then
        $FETCH_URL -fvkSL "https://dl.google.com/dl/edgedl/chromeos/recovery/recovery.conf" > ${tmp_dir}/cros_recovery.conf
        cros_fetch_recovery_url ${tmp_dir}/cros_recovery.conf
        $FETCH_URL -fvkSL "${recovery_url}" > "${tmp_dir}/$cros_bin_package"
    elif [[ "$FETCH_URL" == "wget" ]]; then
        $FETCH_URL -Fc -t 3 -T 12 -O - --no-cache --no-check-certificate "https://dl.google.com/dl/edgedl/chromeos/recovery/recovery.conf" > ${tmp_dir}/cros_recovery.conf
        cros_fetch_recovery_url ${tmp_dir}/cros_recovery.conf
        $FETCH_URL -Fc -t 3 -T 12 -O - --no-cache --no-check-certificate "${recovery_url}" > "${tmp_dir}/$cros_bin_package"
    else
        exit_red "ERROR: Curl or wget was not found on this device."
    fi
    if [[ $? != 0 ]]; then
        exit_red "ERROR: Attempting to download recovery bin failed."
    fi
    echo_blue "Phase 2: Flashing recovery image to USB"
    which fdisk
    if [[ $? != 0 ]]; then
        which lsblk
        if [[ $? != 0 ]]; then
            echo_yellow "WARNING: Cannot list external drives. You will have to do it yourself."
        fi
        lsblk
    else
        fdisk -l 
        if [[ $? != 0 || grep "illegal option" ]]; then
            echo_yellow "Caution: fdisk utility cannot list block devices."
            lsblk
        fi
        read -p "Which device do you want to use? " disk
        echo_blue "Flashing drive to USB device..."
        dd if="${tmp_dir}/$cros_bin_package" of=$disk bs=$(($(stat -c %s ${tmp_dir}/$cros_bin_package) / 3)) conv=sync status=progress
        if [[ $? == 0 ]]; then
            if [[ $extend_ft == "true" ]]
            exit_green "The flash was successful. You now need to reset your chromebook\ninto recovery mode and plug the flash drive into the computer and do the recovery."
        fi
    fi
}
function cros_powerwash() {
    wpsw_cur=$(crossystem --all | grep wpsw_cur | cut -f2 -d"=" | cut -f1 -d"   " | cut -f2 -d"= ")
    if [[ $wpsw_cur == 0 ]]; then
        info "Resetting software AP write-protection..."
        debug "Running command: sudo flashrom -p host --wp-enable --wp-range 0x000000,0x200000"
        sudo flashrom -V -p host --wp-enable --wp-range 0x000000,0x200000
        info "Software write-protection enabled. You need to manaully enable hardware WP by putting back in your battery or screw."
    fi
    info "Setting arguments for powerwashing..."
    debug "Using crossystem to set powerwash state..."
    sudo crossystem clear_tpm_owner_done=0
    sudo crossystem clear_tpm_owner_request=1
    sudo crossystem wipeout_request=1
    debug "Passing arguments to file for powerwashing state..."
    echo "quick safe" > /mnt/stateful_partition/factory_install_reset
    info "Done. Restarting in 15 seconds..."
    sleep 15
    info "Rebooting device..."
    sudo /sbin/reboot
}