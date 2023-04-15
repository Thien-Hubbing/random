#!/bin/bash
header="\033[95m===>"
debug="\033[94mDEBUG: "
info="\033[96mINFO: "
success="\033[92mSUCCESS: "
warning="\033[93mWARNING: "
error="\033[91mERROR: "
endnorm="\033[0m"
notice="\033[1mNOTICE: "

function exit_red() {
    error "$@"
    read -ep "Press [Enter] to return to the main menu."
    main_menu
}
function exit_green() {
    success "$@"
    read -ep "Press [Enter] to return to the main menu."
    main_menu
}
function info() {
    echo -e "\033[96mINFO: $@"
    echo -e "\033[0m"
}
function error() {
    echo -e "\033[96mERROR: $@"
    echo -e "\033[0m"
}
function notice() {
    echo -e "\033[96mNOTICE: $@"
    echo -e "\033[0m"
}
function header() {
    echo -e "\033[96m===> $@ <==="
    echo -e "\033[0m"
}
function warn() {
    echo -e "\033[96mWARNING: $@"
    echo -e "\033[0m"
}
function die() {
    error "$@"
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
        warn "Some chromeOS assets does not exist (Have you modded chromeOS?)."
        use_cross=false
    else
        use_cross=true
    fi
    info "You have selected option $menuOption."
    read -ep "Do you want to restore your chromeOS device to stock? [Y/N]"
    if [[ $REPLY != "y" || $REPLY != "Y" ]]; then
        exit_red "ChromeOS restore cancelled."
    fi
    read -ep "Do you want to use recovery or powerwash? [P/R]"
    if [[ $REPLY == "p" || $REPLY == "P" ]]; then
        notice "Using powerwash instead of recovery."
        cros_powerwash
    elif [[ $REPLY == "r" || $REPLY == "R" ]]; then
        info "Using recovery."
    else
        exit_red "Not a vaild choice: $REPLY"
    fi
    notice "Beginning phase 1: Downloading recovery image for chromeOS recovery..."
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
        $FETCH_URL -dFc -t 3 -T 12 -O - --no-cache --no-check-certificate "https://dl.google.com/dl/edgedl/chromeos/recovery/recovery.conf" > ${tmp_dir}/cros_recovery.conf
        cros_fetch_recovery_url ${tmp_dir}/cros_recovery.conf
        $FETCH_URL -dFc -t 3 -T 12 -O - --no-cache --no-check-certificate "${recovery_url}" > "${tmp_dir}/$cros_bin_package"
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
        sudo flashrom -V -p host --wp-enable --wp-range 0x000000,0x200000
        info "Resetting software flashrom write-protection..."
        sudo flashrom -V -p internal --wp-enable --wp-range 0x000000,0x200000
        info "Software write-protection enabled. You need to manaully enable hardware WP by putting back in your battery or screw."
    fi
    if [[ "$use_cross" == "true" ]]; then
        sudo crossystem clear_tpm_owner_done=0
        sudo crossystem clear_tpm_owner_request=1
        sudo crossystem wipeout_request=1
        use_cross=""
    fi
    info "Setting arguments for powerwashing..."
    echo "quick safe" > /mnt/stateful_partition/factory_install_reset
    info "Done. Restarting in 15 seconds..."
    sleep 15
    info "Rebooting device..."
    sudo /sbin/reboot
}
function main_menu() {
    
    echo "Welcome to the main menu for reseting a computer.\n"

    if [[ "$unlockMenu" = true || ( "$isFullRom" = false && "$isBootStub" = false && "$isUnsupported" = false && "$isEOL" = false ) ]]; then
        echo -e "${MENU}**${WP_TEXT}     ${NUMBER} 1)${MENU} Install/Update RW_LEGACY Firmware ${NORMAL}"
    else
        echo -e "${GRAY_TEXT}**     ${GRAY_TEXT} 1)${GRAY_TEXT} Install/Update RW_LEGACY Firmware ${NORMAL}"
    fi

    if [[ "$unlockMenu" = true || "$hasUEFIoption" = true || "$hasLegacyOption" = true ]]; then
        echo -e "${MENU}**${WP_TEXT} [WP]${NUMBER} 2)${MENU} Install/Update UEFI (Full ROM) Firmware ${NORMAL}"
    else
        echo -e "${GRAY_TEXT}**     ${GRAY_TEXT} 2)${GRAY_TEXT} Install/Update UEFI (Full ROM) Firmware${NORMAL}"
    fi
    if [[ "${device^^}" = "EVE" ]]; then
        echo -e "${MENU}**${WP_TEXT} [WP]${NUMBER} D)${MENU} Downgrade Touchpad Firmware ${NORMAL}"
    fi
    if [[ "$unlockMenu" = true || ( "$isFullRom" = false && "$isBootStub" = false ) ]]; then
        echo -e "${MENU}**${WP_TEXT} [WP]${NUMBER} 3)${MENU} Set Boot Options (GBB flags) ${NORMAL}"
        echo -e "${MENU}**${WP_TEXT} [WP]${NUMBER} 4)${MENU} Set Hardware ID (HWID) ${NORMAL}"
    else
        echo -e "${GRAY_TEXT}**     ${GRAY_TEXT} 3)${GRAY_TEXT} Set Boot Options (GBB flags)${NORMAL}"
        echo -e "${GRAY_TEXT}**     ${GRAY_TEXT} 4)${GRAY_TEXT} Set Hardware ID (HWID) ${NORMAL}"
    fi
    if [[ "$unlockMenu" = true || ( "$isFullRom" = false && "$isBootStub" = false && \
        ("$isHsw" = true || "$isBdw" = true || "$isByt" = true || "$isBsw" = true )) ]]; then
        echo -e "${MENU}**${WP_TEXT} [WP]${NUMBER} 5)${MENU} Remove ChromeOS Bitmaps ${NORMAL}"
        echo -e "${MENU}**${WP_TEXT} [WP]${NUMBER} 6)${MENU} Restore ChromeOS Bitmaps ${NORMAL}"
    fi
    if [[ "$unlockMenu" = true || ( "$isChromeOS" = false  && "$isFullRom" = true ) ]]; then
        echo -e "${MENU}**${WP_TEXT} [WP]${NUMBER} 7)${MENU} Restore Stock Firmware (full) ${NORMAL}"
    fi
    if [[ "$unlockMenu" = true || ( "$isByt" = true && "$isBootStub" = true && "$isChromeOS" = false ) ]]; then
        echo -e "${MENU}**${WP_TEXT} [WP]${NUMBER} 8)${MENU} Restore Stock BOOT_STUB ${NORMAL}"
    fi
    if [[ "$unlockMenu" = true || "$isUEFI" = true ]]; then
        echo -e "${MENU}**${WP_TEXT}     ${NUMBER} C)${MENU} Clear UEFI NVRAM ${NORMAL}"
    fi
    echo -e "${MENU}*********************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Select a menu option or${NORMAL}"
    echo -e "${nvram}${RED_TEXT}R${NORMAL} to reboot ${NORMAL} ${RED_TEXT}P${NORMAL} to poweroff ${NORMAL} ${RED_TEXT}Q${NORMAL} to quit ${NORMAL}"
    
    read -e opt
    case $opt in

        1)  if [[ "$unlockMenu" = true || "$isEOL" = false && ("$isChromeOS" = true \
                    || "$isFullRom" = false && "$isBootStub" = false && "$isUnsupported" = false) ]]; then
                flash_rwlegacy
            fi
            menu_fwupdate
            ;;

        2)  if [[  "$unlockMenu" = true || "$hasUEFIoption" = true || "$hasLegacyOption" = true ]]; then
                flash_coreboot
            fi
            menu_fwupdate
            ;;

        [dD])  if [[  "${device^^}" = "EVE" ]]; then
                downgrade_touchpad_fw
            fi
            menu_fwupdate
            ;;

        3)  if [[ "$unlockMenu" = true || "$isChromeOS" = true || "$isUnsupported" = false \
                    && "$isFullRom" = false && "$isBootStub" = false ]]; then
                set_boot_options
            fi
            menu_fwupdate
            ;;

        4)  if [[ "$unlockMenu" = true || "$isChromeOS" = true || "$isUnsupported" = false \
                    && "$isFullRom" = false && "$isBootStub" = false ]]; then
                set_hwid
            fi
            menu_fwupdate
            ;;

        5)  if [[ "$unlockMenu" = true || ( "$isFullRom" = false && "$isBootStub" = false && \
                    ( "$isHsw" = true || "$isBdw" = true || "$isByt" = true || "$isBsw" = true ) )  ]]; then
                remove_bitmaps
            fi
            menu_fwupdate
            ;;

        6)  if [[ "$unlockMenu" = true || ( "$isFullRom" = false && "$isBootStub" = false && \
                    ( "$isHsw" = true || "$isBdw" = true || "$isByt" = true || "$isBsw" = true ) )  ]]; then
                restore_bitmaps
            fi
            menu_fwupdate
            ;;

        7)  if [[ "$unlockMenu" = true || "$isChromeOS" = false && "$isUnsupported" = false \
                    && "$isFullRom" = true ]]; then
                restore_stock_firmware
            fi
            menu_fwupdate
            ;;

        8)  if [[ "$unlockMenu" = true || "$isBootStub" = true ]]; then
                restore_boot_stub
            fi
            menu_fwupdate
            ;;

        [rR])  echo -e "\nRebooting...\n";
            cleanup
            reboot
            exit
            ;;

        [pP])  echo -e "\nPowering off...\n";
            cleanup
            poweroff
            exit
            ;;

        [qQ])  cleanup;
            exit;
            ;;

        [U])  if [ "$unlockMenu" = false ]; then
                echo_yellow "\nAre you sure you wish to unlock all menu functions?"
                read -ep "Only do this if you really know what you are doing... [y/N]? "
                [[ "$REPLY" = "y" || "$REPLY" = "Y" ]] && unlockMenu=true
            fi
            menu_fwupdate
            ;;

        [cC]) if [[ "$unlockMenu" = true || "$isUEFI" = true ]]; then
                clear_nvram
            fi
            menu_fwupdate
            ;;

        *)  clear
            menu_fwupdate;
            ;;
    esac
}