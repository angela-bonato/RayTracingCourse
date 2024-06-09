#!/bin/bash

if [ "$1" == "" ]; then
    echo "Usage: $(basename $0) ANGLE"
    exit 1
fi

readonly angle="$1"
readonly angleNNN=$(printf "%03d" $angle)
readonly pfmfile=image$angleNNN.pfm
readonly pngfile=image$angleNNN.png

time ./../project demo --angle=$angle --antial_rays=0 $pfmfile $pngfile
>>>>>>> 37cc356435cc7912d019ea06acc5493e914936e8
