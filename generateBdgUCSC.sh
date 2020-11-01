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

RGBCODE=$(echo "$RGB" | sed 's/ /,/g')
cd $INPUTPATH
sample=$(ls $FILENAME | sed 's/_remDelReadsSmooth.bdg//')
echo "processing sample ${sample}"

  sortBDG="${sample}_sort"
  clipBDG="${sample}_clip"
  outBDG="${sample}.bdg"

  echo "processing sample ${sample}\n RBG $RGBCODE sortBDG $sortBDG"

  bedSort "${sample}_remDelReadsSmooth.bdg" $sortBDG
  bedClip $sortBDG $CHRSZ $clipBDG

  echo "browser position chr2:113326224-113894862" > "${OUTPUT_PATH}/${outBDG}"
  echo "track type=bedGraph name=${sample} description=${sample} visibility=full color=$RGBCODE altColor=$ALTCODE maxHeightPixels=64 autoScale=off viewLimits=0:5000" >> "${OUTPUT_PATH}/${outBDG}"
  cat $clipBDG >> "${OUTPUT_PATH}/${outBDG}"
  gzip -c "${OUTPUT_PATH}/${outBDG}" > "${OUTPUT_PATH}/${outBDG}.gz"
  #rm "${sample}_sort" "${sample}_clip "${OUTPUT_PATH}/${outBDG}" "

#NOTE I am not generating substraction profiles for 201910 4C samples as we just wanted to check if there's reads mapped in the deleted region or not? So i'm making follwoing lines as commented

#For substraction profiles
# for sample in $(ls subtract_*.bdg | sed 's/subtract_//' | sed 's/.bdg//');
# do
#   subsBDG="subs_${sample}.bdg"
#   echo "browser position chr2:113326224-113894862" > "${OUTPUT_PATH}/${subsBDG}"
#   echo "track type=bedGraph name=${sample} description=${sample} visibility=full color=$RGBCODE altColor=252,127,35 maxHeightPixels=64 autoScale=off viewLimits=-3000:3000" >> "${OUTPUT_PATH}/${subsBDG}"
#   cat "subtract_${sample}.bdg" >> "${OUTPUT_PATH}/${subsBDG}"
#   gzip -c "${OUTPUT_PATH}/${subsBDG}" > "${OUTPUT_PATH}/${subsBDG}.gz"
#   #rm ${OUTPUT_PATH}/${subsBDG}
# done
