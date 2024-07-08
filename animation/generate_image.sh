#!/bin/bash

if [ "$1" == "" ]; then
    echo "Usage: $(basename $0) ANGLE FILENAME"
    exit 1
fi

readonly angle="$1"
readonly txtfile="$2"
readonly angleNNN=$(printf "%03d" $angle)

time ./../project demo --angle=$angle $txtfile

