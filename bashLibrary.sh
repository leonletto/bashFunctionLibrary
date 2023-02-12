#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi

###SOF###
##################################
#
# bash function library
# Developed by: Leon Letto
# December 2022
#
# revision 1 (Dec 6, 2022)
#
#
# This is a collection of functions that I use in my bash scripts
#
#
##################################

# my definition of valid characters for passwords
#validCharacters='[\~\!\@\#\$\%\^\*\_\+\-\=\{\}\[\]\:\,\.\/]' # bigger set of characters which I am not using
validCharacters='[\~\!\@\#\$\%\^\*\_\+]'
invalidCharacters='[\`\&\(\)\|\\\"\;\<\>\?]'


source_env() {
    # retrieve variables from the environment file containing name=value pairs
    # and escaping any special characters which may cause problems
    # shellcheck disable=SC2002 # the cat is not a file, it is a stream
    if isFile "$1"; then
        while read -r line; do
            read -r k v <<<"$line"
            test="$k=$v"
            varLength=${#test}
            varLengthMinusOne=$((varLength - 1))
            varMinusLastChar=${test:0:varLengthMinusOne}
            test2=$(echo "${varMinusLastChar}" | sed -e 's/[]\/$\&*^|[]/\\&/g')
            eval export "$test2"
        done <<<"$(cat "$1" | grep -v '^#' | grep '=')"
    fi
}

headers_import() {
    # Read response headers produced when you dump headers to a file in curl
    # and escaping any special characters which may cause problems
    # shellcheck disable=SC2002 # the cat is not a file, it is a stream
    if isFile "$1"; then
        while read -r line; do
            if [[ "$line" =~ ^HTTP/ ]]; then
                read -r httpVersion httpStatus httpStatusText <<<"$line"
                export httpVersion
                export httpStatus
                export httpStatusText
            else
                read -r k <<<"$line"
                input="$k"
                separator=":"
                prefix=${k%%$separator*}
                index=${#prefix}
                varLength=${#input}
                varName=${input:0:index}
                varValue=${input:index+1:varLength}
                # Just doing cookie so far unless I need other stuff from the response headers
                if [[ "$varName" == "Set-Cookie" ]]; then
                    cookie=$(echo "${varValue}" | cut -d' ' -f2 | cut -d';' -f1)
                    eval export "$cookie"
                fi
                # remove teh space after the colon
#                varValue=${varValue#* }
                 #escape the variable value
#                varValue=$(echo "${varValue}" | sed -e 's/[]\/$\&;*^|[]/\\&/g')
#                echo "$varName=$varValue"
#                eval export "$varName=$varValue"
#                eval export "$varName"="$varValue"
            fi
        done <<<"$(cat "$1")"
    fi
}


sedCmd() {
    # check which OS you are running on and choose the proper sed variation
    local script="$1"
    local file="$2"
    case "$(uname -sr)" in
    Darwin*)
        sed -i .bak "$script" "$file"
        ;;
    Linux*)
        sed -i.bak -e "$script" "$file"
        ;;
    *)
        sed -i.bak -e "$script" "$file"
        ;;
    esac
}


checkPassword() {
    # check if a password uses valid characters - see validCharacters and invalidCharacters above
    if [[ -z "${1}" ]]; then
        echo "Password is empty."
        exit 1
    fi
    if [[ "${1}" =~ ${invalidCharacters} ]]; then
#        echo "Password contains invalid characters."
        return 1
    fi
    return 0
}


fileDate() {
    # returns the date of the last modification of a file
    stat "$@" | awk '{print $10}'
}


fileSize() {
    # Returns the file size in bytes even if it is on a mapped smb drive
    optChar='f'
    fmtString='%z'
    stat -$optChar "$fmtString" "$@"
}


fileType() {
    # returns the file type of a file or directory even if it is on a mapped smb drive or a symlink
    test="$(stat "${*}")" || true
    if [[ $test ]]; then
        myStr="$(stat "$*" | awk '{print $3}')" # get the file type string
        if [[ "${myStr:0:1}" = 'd' ]]; then
            echo "directory"
        elif [[ "${myStr:0:1}" = '-' ]]; then
            echo "file"
        elif [[ "${myStr:0:1}" = 'l' ]]; then
            str="$(readlink -f "$@")"
            t="${str// /\\ }"
            x="fileType ${t}"
            eval "$x"
        fi # end if
    else
        echo "unknown"
    fi # end if
}


isLocalFS() {
    # returns true if the file or folder is on a local file system
    myStr="$(df -P "$*" | tail -n +2 | awk '{print $1}')" # get the file type string
    if [[ "${myStr:0:4}" = '/dev' ]]; then
        return 0
    else
        return 1
    fi # end if
}

isDir() {
    # returns true if path passed is a directory
    dir=$(fileType "$@")
    if [[ "$dir" = "directory" ]]; then
        return 0
    else
        return 1
    fi
}

isFile() {
    # returns true if path passed is a file
    file=$(fileType "$@")
    if [[ "$file" = "file" ]]; then
        return 0
    else
        return 1
    fi
}

compareFiles() {
    # compares two files and returns true if they are the same
    # based on size and date modified
    # used for checking files on remote drives where you don't want to use md5/sha/diff of the file
    # because it is too slow
    local file1="$1"
    local file2="$2"
    local size1
    local size2
    local date1
    local date2

    test1="$(stat "$file1" 2>/dev/null)" || true
    test2="$(stat "$file2" 2>/dev/null)" || true
    if [[ $test1 && $test2 ]]; then
        size1="$(fileSize "$file1")"
        size2="$(fileSize "$file2")"
        date1="$(fileDate "$file1")"
        date2="$(fileDate "$file2")"
        if [[ $size1 -eq $size2 && $date1 -eq $date2 ]]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

urlencode() {
    # urlencodes a string
    local string="${1}"
    local strlen=${#string}
    local encoded=""
    local pos c o

    for ((pos = 0; pos < strlen; pos++)); do
        c=${string:$pos:1}
        case "$c" in
        [-_.~a-zA-Z0-9]) o="${c}" ;;
        *) printf -v o '%%%02x' "'$c" ;;
        esac
        encoded+="${o}"
    done
    echo "${encoded}"  # You can either set a return variable (FASTER)
    REPLY="${encoded}" #+or echo the result (EASIER)... or both... :p
}

###EOF###