#!/bin/bash

# working directory
wd="$(pwd)"

hashcat -m 1700 -a 0 --outfile-format 1,2 "$wd/hashes.txt" "$wd/../example.dict"

# Hashcat remembers already-cracked hashes in its potfile and only writes
# newly found ones to -o during the attack above, so re-running this script
# against hashes already seen before would otherwise produce an empty/stale
# cracked.txt. --show dumps every known plaintext (old + new) instead.
rm -f "$wd/cracked.txt"
hashcat -m 1700 --show --outfile-format 1,2 -o "$wd/cracked.txt" "$wd/hashes.txt"

echo "Output will be saved to: $wd/cracked.txt"
