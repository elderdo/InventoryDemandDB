#!/usr/bin/ksh

function cap {
    typeset -u f
    f=${1:0:1}
    printf "%s%s\n" "$f" "${1:1}"
}

S=usersDiff
echo S=$S
S2=$(cap $S)
echo S2=$S2
S3=$(echo $S2 | sed 's/....$//')
echo S3=$S3
