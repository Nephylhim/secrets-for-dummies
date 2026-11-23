#!/bin/bash

rm hashes.txt

while IFS= read -r line; do
  python3 -c "
import sys, hashlib, base64
pw = sys.argv[1].encode()
h = hashlib.pbkdf2_hmac('sha512', pw, b'', 220000, dklen=64)
print('sha512:220000::' + base64.b64encode(h).decode())
" "$line" >> "hashes.txt"
done < "../passwords.txt"
