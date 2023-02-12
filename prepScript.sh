#!/usr/bin/env bash
# shellcheck disable=SC2129
set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi


###SOF###
# Use this script to combine multiple scripts into one script for deploying to a remote machine or management system like Workspace ONE UEM

# Directions:
# create an array of files to combine
# example: files=("bashLibrary.sh" "prepScript.sh")
# decide on a destination file name
# example: destination="fullScript.sh"
# run the script
# example: ./prepScript.sh "${files[@]}" "$destination"

# take lines from the sfiles starting at ###SOF### and ending at ###EOF### and add them to the dfile
# if the dfile does not exist it will be created

# $1 - source files array
# $2 - destination file

sfiles=("$@")
dfile=${sfiles[${#sfiles[@]}-1]}
rm -f "$dfile"
copyLines() {
    # get the lines from the source file
    lines=$(sed -n '/###SOF###/,/###EOF###/p' "$1")
    # if the destination file does not exist create it
    if [ ! -f "$2" ]; then
        echo '#!/bin/bash' > "$2"
        echo 'set -o errexit' >> "$2"
        echo 'set -o nounset' >> "$2"
        echo 'set -o pipefail' >> "$2"
        echo 'if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi' >> "$2"
        echo "$lines" >> "$2"
    else # the destination file does exist and copy the lines at the end of the file
        echo "" >> "$2"
        echo "$lines" >> "$2"
    fi
}

for ifile in "${sfiles[@]}"; do
    echo "copying lines from $ifile to $dfile"
    if [ "$ifile" == "$dfile" ]; then
        continue
    else
        copyLines "$ifile" "$dfile"
    fi
done

