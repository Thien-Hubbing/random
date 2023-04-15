
import sys
import os
import argparse

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

def error(text):
    print(f"{bcolors.error}" + text + f"{bcolors.endnorm}")

def warn(text):
    print(f"{bcolors.warning}" + text + f"{bcolors.endnorm}")

def success(text):
    print(f"{bcolors.success}" + text + f"{bcolors.endnorm}")

def notice(text):
    print(f"{bcolors.notice}" + text + f"{bcolors.endnorm}")

def info(text):
    print(f"{bcolors.info}" + text + f"{bcolors.endnorm}")

def debug(text):
    print(f"{bcolors.debug}" + text + f"{bcolors.endnorm}")

def head(text):
    print(f"{bcolors.header}" + text + f" <==={bcolors.endnorm}")

def die(err_text,err_code):
    error(err_text)
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
parse_commands.add_argument("--cmod", help="Modify an image to have a feature in it.", action="store_true")
parse_commands.add_argument("--cadd", help="Inject a payload into the image.", action="store_true")
parse_commands.add_argument("--cdel", help="Delete modifications or features from the image.", action="store_true")
parse_commands.add_argument("--cfetch", help="Fetch the image required for modification.", action="store_true")
parse_args.add_argument('-v', '--version', help='Show the current version', action="store_true")
args = parser.parse_args()

try:
    if args.version == True:
        print("shim-workon version 1.0.0")
except AttributeError:
    pass

# Call other scripts to do the heavy work
try:
    if args.cmod == True:
        warn("The function hasn't been properly converted yet. Expect a lot of bugs")
        with open("/opt/custom-tools/shim-workon/python/opts/modify.py") as cmod:
            exec(cmod.read())

    elif args.cadd == True:
        info("The function hasn't been made yet.")
    elif args.cdel == True:
        info("The function hasn't been made yet.")
    elif args.cfetch == True:
        info("The function hasn't been made yet.")
except AttributeError:
    pass