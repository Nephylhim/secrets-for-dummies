#!/bin/bash

# working directory
wd="$(pwd)"

cd $HASHCAT_DIR
#pwd
#echo "$hashes_dir"

./hashcat.exe -m 0 -a 0 -o $wd/cracked.txt --outfile-format 1,2$wd/md5.hash $wd/../example.dict

echo "Output will be saved to: $wd/cracked.txt"
