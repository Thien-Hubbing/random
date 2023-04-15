#!/bin/bash

if [[ "$EUID" != 0 ]]; then
  echo "The following command requires you to run as root."
  exit 1
fi

function deprovision() {
    echo "\nDeprovisioning..."
    vpd -i RW_VPD -s check_enrollment=0
    vpd -i RW_VPD -s block_devmode=0
    echo -e "Checking..."
    dump_vpd_log --force
    dump_vpd_log --full --stdout | grep check_enrollment
    echo "The value should say 0."
    sleep 5
}
function reprovision() {
    echo "\nReprovisioning..."
    vpd -i RW_VPD -s check_enrollment=1
    vpd -i RW_VPD -s block_devmode=1
    echo -e "Checking..."
    dump_vpd_log --force
    dump_vpd_log --full --stdout | grep check_enrollment
    echo "The value should say 1."
    sleep 5
}
function deprovision_full() {
  echo -e "WARNING!\nThe following command will do the following:\n1. Unenroll your computer\n2. Disable block_devmode\nand 3. Remove firmware management parameters."
  read -p "Are you sure you want to do this? [y/n] " input
  if [ "$input" = "y" ]; then
    crossystem dev_boot_usb=1
    sleep 3
    crossystem dev_boot_legacy=1
    sleep 3
    deprovision
    crossystem block_devmode=0
    sleep 3
    cryptohome --action=tpm_take_ownership
    tpm_manager_client take_ownership
    sleep 5
    cryptohome --action=set_firmware_management_parameters --flags=0x00
    if [[ $? != 0 ]]; then
      cryptohome --action=remove_firmware_management_parameters
      if [[ $? != 0 ]]; then
        echo -e "The previous command didn't work. The unenrollment might not fully work."
      fi
    fi
    sleep 5
    echo "\nRebooting computer..."
    reboot
    exit
  else
    echo "Aborting..."
    exit 0
  fi
}
function provision_full() {
  echo -e "WARNING!\nThe following command will re-enroll the Chrome OS device into the\ndomain and allow your administrator to manage your computer again."
  read -p "Are you sure you want to do this? [y/n] " input
  if [ "$input" = "y" ]; then
    crossystem dev_boot_usb=0
    sleep 3
    crossystem dev_boot_legacy=0
    sleep 3
    reprovision
    crossystem block_devmode=1
    sleep 3
    cryptohome --action=tpm_take_ownership
    tpm_manager_client take_ownership
    sleep 5
    cryptohome --action=set_firmware_management_parameters --flags=0x01
    if [[ $? != 0 ]]; then
      echo -e "The previous command didn't work. The renrollment might not fully work."
    fi
    sleep 5
    echo "\nRebooting computer..."
    reboot
    exit
  else
    echo "Aborting..."
    exit 0
  fi
}
function restore_stock() {
  echo -e "WARNING!\nThe following command will unenroll your computer AND, restore the chromebook to factory settings."
  read -p "Are you sure you want to do this? [y/n] " input
  if [ "$input" = "y" ]; then
    crossystem dev_boot_usb=0
    sleep 3
    crossystem dev_boot_legacy=0
    sleep 3
    deprovision
    sleep 3
    cryptohome --action=tpm_take_ownership
    tpm_manager_client take_ownership
    sleep 5
    cryptohome --action=set_firmware_management_parameters --flags=0x00
    if [[ $? != 0 ]]; then
      cryptohome --action=remove_firmware_management_parameters
      if [[ $? != 0 ]]; then
        echo -e "The previous command didn't work. The unenrollment might not fully work."
      fi
    fi
    sleep 5
    echo "\nThis now begins phase two where the computer is reinstalling the operating system."
    echo "Beginning in 10 seconds..."
    sleep 10
    chromeos-recovery /dev/sda --dst /dev/mmcblk0
    sleep 5
    crossystem clear_tpm_owner_done=0
    crossystem clear_tpm_owner_request=1
    crossystem wipeout_request=1
    echo "\nRebooting computer..."
    reboot
    exit
  else
    echo "Aborting..."
    exit 0
  fi
}

function reprov_stock() {
  read -ep "WARNING: The following command will re-enroll the Chrome OS device into the domain.\nBUT, it will completely wipe out all evidence of you using this.\nAre you sure you want to do this?"
  if [[ $REPLY == "N" || $REPLY == "n" ]]; then
    echo "Aborting..."
    exit 1
  fi
  reprovision
  sleep 3
  
  
}

function clear_soft_wp() {
  echo "\nWarning: Disabling software write protection."
  flashrom -p internal --wp-disable --verbose
  if [[ $? != 0 ]]; then
    echo "\nError disabling write protection, exiting..."
    return 1
  else
    flashrom -p internal --wp-range 0,0 --verbose
    if [[ $? != 0 ]]; then
      echo "\nError clearing WP range, exiting..."
      return 1
    fi
    return 0
  fi
}

clear
for i in "$@"; do
  case $i in
    -u|--unenroll)
      deprovision_full
      shift # past argument
      ;;
    -r|--re-enroll)
      provision_full
      shift # past argument
      ;;
    -s|--restore-to-stock)
      restore_stock
      shift # past argument
      ;;
    -c|--chromebox-firmware-util|--fw-util)
      clear_soft_wp
      if [[ $? != 0 ]]; then
        echo "\nWrite protection was unable to be cleared. You can only install RW legacy firmware."
      fi
      exec /usr/bin/firmware-util.sh
      shift # past argument
      ;;
    -e|--enable-dev)
      tmp
      shift # past argument
      ;;
    -*|--*)
      echo "Unknown option $i"
      exit 1
      ;;
    *)
      ;;
  esac
done
