#!/usr/bin/env python3
#* - Important information
#! - Errors/Known bugs
#? - Questions
#TODO - Fix "x"
# Imports

import sys
import argparse
import os
print(os.__file__)
sys.exit(0)

# Classes to make

class bcolors:
    header = '\033[95m'
    debug = '\033[94m'
    info = '\033[96m'
    success = '\033[92m'
    warning = '\033[93m'
    error = '\033[91m'
    endnorm = '\033[0m'
    notice = '\033[1m'

# Function of echos
# TODO: Fuse the echos into one big function.

def echo_error(text):
    print(f"{bcolors.error}{sys.argv[0]}: ERROR: " + text + f"{bcolors.endnorm}")

def echo_warn(text):
    print(f"{bcolors.warning}{sys.argv[0]}: WARNING: " + text + f"{bcolors.endnorm}")

def echo_success(text):
    print(f"{bcolors.success}{sys.argv[0]}: SUCCESS: " + text + f"{bcolors.endnorm}")

def echo_notice(text):
    print(f"{bcolors.notice}{sys.argv[0]}: NOTICE: " + text + f"{bcolors.endnorm}")

def echo_info(text):
    print(f"{bcolors.info}{sys.argv[0]}: INFO: " + text + f"{bcolors.endnorm}")

def echo_debug(text):
    print(f"{bcolors.debug}{sys.argv[0]}: DEBUG: " + text + f"{bcolors.endnorm}")

def echo_head(text):
    print(f"{bcolors.header}===> " + text + f" <==={bcolors.endnorm}")

def die(err_text,err_code):
    echo_error(err_text)
    sys.exit(err_code)

# Parsing code
#! Will never work by v1

parser = argparse.ArgumentParser(
    prog="shim-workon",
    usage='--c{mod|add|del|fetch}',
    description="ChromeOS recovery/factory shim image modification tool.\nNow rewritten in python!",
    epilog="Version 1.0.0",
    argument_default=argparse.SUPPRESS
)
parse_args=parser.add_argument_group("Arguments")
parse_commands=parser.add_argument_group("Sub-Commands")
parse_commands.add_argument("--cmod", help="Use the sub-command modify.")
parse_args.add_argument('-v', '--version', help='Show the current version')

try:
    args = parser.parse_args()
except (ArgumentError, ArgumentTypeError, SystemExit, SystemError):
    die("Unrecognized arguments:",2)
print(args)
echo_success("yay it works!")