#!/bin/bash

rm hashes.txt

while IFS= read -r line; do 
  echo -n "$line" | md5sum | awk '{print $1}' >> "hashes.txt"
done < "../passwords.txt"

