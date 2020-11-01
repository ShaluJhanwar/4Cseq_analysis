#!/bin/bash

#When: Aug 9 2018
#Who: Shalu Jhanwar
#What: generate UCSC bedgraph files

INPUTPATH=$1 #normCounts containing folder
PARENTDIR=$2
CHRSZ=$3
RGB=$4
ALTCODE=$5
FILENAME=$6


if [ ! -d "$PARENTDIR/uploadUCSC" ]; then
        mkdir "$PARENTDIR/uploadUCSC"
fi

DATE_TIME_STAMP=`date "+%Y%m%d_%H"`
OUTPUT_PATH="$PARENTDIR/uploadUCSC/${DATE_TIME_STAMP}_uploadUCSC"

mkdir -pv "$OUTPUT_PATH"
echo "output folder created $OUTPUT_PATH"

module purge BEDTools
module purge kentUtils
ml BEDTools/2.26.0-goolf-1.7.20
ml kentUtils/v351-goolf-1.7.20
#
RGBCODE=$(echo "$RGB" | sed 's/ /,/g')
cd $INPUTPATH
#
# #For substraction profiles
sample=$(ls $FILENAME | sed 's/log2ratio_//' | sed 's/.bdg//')
subsBDG="logratio_${sample}.bdg"
echo "sample folder created ${OUTPUT_PATH}/${subsBDG}"
echo "browser position chr2:113326224-113894862" > "${OUTPUT_PATH}/${subsBDG}"
echo "track type=bedGraph name=logratio_${sample} description=logratio_${sample} visibility=full color=$RGBCODE altColor=$ALTCODE maxHeightPixels=64 autoScale=off viewLimits=-35:35" >> "${OUTPUT_PATH}/${subsBDG}"
cat "log2ratio_${sample}.bdg" >> "${OUTPUT_PATH}/${subsBDG}"
gzip -c "${OUTPUT_PATH}/${subsBDG}" > "${OUTPUT_PATH}/${subsBDG}.gz"
