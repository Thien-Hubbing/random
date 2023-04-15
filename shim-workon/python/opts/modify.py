#!/usr/bin/env python3
# The python script is called as shim-workon --cmod.
# This file should not be called from anything else other than the above.

# Import libraries and modules
import sys
import os
import argparse
import regex
import pathlib
sys.path.append(os.path.abspath("/opt/custom-tools/shim-workon/python/req"))
from echos import *

# Defined classes

class payloadsAvailable:
    shimmer = {
        "download": "https://www.github.com/MercuryWorkshop/sh1mmer/archive/heads/beautifulworld.zip",
        "param": "--antiskid",
        "chromebrew": "http://dl.sh1mmer.me/build-tools/chromebrew/chromebrew.tar.gz"
    }
    shimmer_dev = {
        "download": "https://www.github.com/MercuryWorkshop/sh1mmer/archive/heads/beautifulworld.zip",
        "param": "--dev",
        "chromebrew": "http://dl.sh1mmer.me/build-tools/chromebrew/chromebrew-dev.tar.gz"
    }
    fakemurk = "https://www.github.com/MercuryWorkshop/fakemurk/releases/latest/download/fakemurk.sh"
    unenroll = "https://www.github.com/Thien-Hubbing/random/unenroll_v2.1.sh"
    mini_cros = "https://www.github.com/Thien-Hubbing/random/mini_recovery.sh"

# Define functions
def get_file(url):
    os.system("curl -fvkSL" + url)

# Parse arguments
parser = argparse.ArgumentParser(
    prog="shim-workon mod",
    usage='--image|-i \"IMAGE\" --payload|-p \"PAYLOAD\" [--drive|-d][-l|--list][-v|--verbose][-d|--drive]',
    description="ChromeOS recovery/factory shim image modification tool.\nNow rewritten in python!",
    epilog="Version 1.0.0",
    argument_default=argparse.SUPPRESS
)
parser.add_argument("-i", "--image",
                    help="Modify an image to have a payload in it.",
                    nargs=1,
                    type=pathlib.Path)
parser.add_argument("-v", "--verbose",
                    help="Use verbose logging details.",
                    action="store_true")
parser.add_argument("-D", "--debug",
                    help="Use debug-level logging details.",
                    action="store_true")
parser.add_argument("-p", "--payload",
                    help="Select the payload to be injected.",
                    nargs=1)
parser.add_argument("-l", "--list",
                    help="List the available payloads.",
                    action="store_true")
parser.add_argument("-d", "--drive",
                    help="Modify a drive instead of a image.",
                    action="store_true")
args = parser.parse_args()

warn("E")
sys.exit(0)