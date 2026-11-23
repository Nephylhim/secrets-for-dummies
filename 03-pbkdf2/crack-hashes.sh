#!/bin/bash

# working directory
wd="$(pwd)"

hashcat -m 12100 -a 0 -o "$wd/cracked.txt" --outfile-format 1,2 "$wd/hashes.txt" "$wd/../example.dict"

echo "Output will be saved to: $wd/cracked.txt"
