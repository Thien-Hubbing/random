
import sys
import os
import argparse
import subprocess

class bcolors:
    header = '\033[95m===>'
    debug = '\033[94mDEBUG: '
    info = '\033[96mINFO: '
    success = '\033[92mSUCCESS: '
    warning = '\033[93mWARNING: '
    error = '\033[91mERROR:'
    endnorm = '\033[0m'
    notice = '\033[1mNOTICE: '

# Function of echos
# TODO: Fuse the echos into one big function.

def echo_error(text):
    print(f"{bcolors.error}" + text + f"{bcolors.endnorm}")

def echo_warn(text):
    print(f"{bcolors.warning}" + text + f"{bcolors.endnorm}")

def echo_success(text):
    print(f"{bcolors.success}" + text + f"{bcolors.endnorm}")

def echo_notice(text):
    print(f"{bcolors.notice}" + text + f"{bcolors.endnorm}")

def echo_info(text):
    print(f"{bcolors.info}" + text + f"{bcolors.endnorm}")

def echo_debug(text):
    print(f"{bcolors.debug}" + text + f"{bcolors.endnorm}")

def echo_head(text):
    print(f"{bcolors.header}" + text + f" <==={bcolors.endnorm}")

def die(err_text,err_code):
    echo_error(err_text)
    sys.exit(err_code)

# Parse arguments

parser = argparse.ArgumentParser(
    prog="shim-workon",
    usage='--c{mod|add|del|fetch}',
    description="ChromeOS recovery/factory shim image modification tool.\nNow rewritten in python! (TEST/DEBUG VERSION)",
    epilog="Version 1.0.0",
    argument_default=argparse.SUPPRESS
)
parse_args=parser.add_argument_group("Arguments")
parse_commands=parser.add_argument_group("Sub-Commands")
parse_commands.add_argument("--cmod", help="Use the sub-command modify.", action="store_true")
parse_args.add_argument('-v', '--version', help='Show the current version')
args = parser.parse_args()

print(args.cmod)

# Call other scripts to do the heavy work

if args.cmod == True:
    echo_info("The function hasn't been made yet.")
elif args.cadd == True:
    echo_info("The function hasn't been made yet.")
elif args.cdel == True:
    echo_info("The function hasn't been made yet.")
elif args.cfetch == True:
    echo_info("The function hasn't been made yet.")