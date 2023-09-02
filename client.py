#!/usr/bin/env python3

import os
import sys
import requests
from cryptography.fernet import *

got_files = []

url_key = "https://drive.usercontent.google.com/download?id=1d0Pff-ySxLNo2yFHCssOfCBrQJuSDTNB&export=download&authuser=0&confirm=t&uuid=4cdc2dd6-2749-4ff0-bcdb-fb066b265c52&at=APZUnTXN-a69W-HECmV5gsU0nvNV:1693684635168"

for file in os.listdir():
    if file == "server.py" or file == "access_key.key" or file == "client.py":
            continue
    if os.path.isfile(file):
          got_files.append(file)

phrase = 'QVVSTFNhZmVFbmNvZGluZw'

print("These are the files found: " + str(got_files))

user_phrase = input("Please enter the password: ")

if user_phrase == phrase:
    print("Downloading key file...")
    
    download = requests.get(url_key, allow_redirects=True, timeout=12)
    open('access_key.key', "wb").write(download.content)

    with open("access_key.key", "rb") as key_file:
        decrypting_key = key_file.read()

    for file in got_files:
        with open(file, "rb") as rdfile:
            contents = rdfile.read()
        contents_dec = Fernet(decrypting_key).decrypt(contents)
        with open(file, "wb") as wtfile:
            wtfile.write(contents_dec)

