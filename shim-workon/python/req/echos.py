# Have the echos available at a different area

import sys

class bcolors:
    header = '\033[95m===>'
    debug = '\033[94mDEBUG: '
    info = '\033[96mINFO: '
    success = '\033[92mSUCCESS: '
    warning = '\033[93mWARNING: '
    error = '\033[91mERROR:'
    endnorm = '\033[0m'
    notice = '\033[1mNOTICE: '

# Echo functions
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
