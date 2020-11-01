#!/bin/bash

#When: Aug 9 2018
#Who: Shalu Jhanwar
#What: create 4 col bedgraph of coverage

INPUTPATH=$1 
DATE_TIME_STAMP=`date "+%Y%m%d_%H%M%S"`
OUTPUT_PATH="$INPUTPATH/${DATE_TIME_STAMP}_bedGraphs"

mkdir -pv "$OUTPUT_PATH"
echo "output folder created $OUTPUT_PATH"

cd $INPUTPATH
for sample in $(ls *_feaCount.bedGraph | sed 's/_feaCount.bedGraph//');
do
  OUTFILE="${sample}_coverage.bdg"
  echo "processing file $sample"
  tail -n+3 "${sample}_feaCount.bedGraph" | cut -f2,3,4,7 > "${OUTPUT_PATH}/${OUTFILE}"
  echo "generated $OUTFILE"
done
