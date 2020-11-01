#!/bin/bash

#When: Aug 9 2018
#Who: Shalu Jhanwar
#What: get counts per fragment

INPUTPATH=$1 #bam file containing folder
VALID_RE_FILE=$2 #saf format file with valid RE fragments

one_up=$(dirname $INPUTPATH)
parentFolder=$(dirname $one_up)
echo "parentFolder $parentFolder"

if [ ! -d "$parentFolder/featureCount" ]; then
        mkdir "$parentFolder/featureCount"
fi

DATE_TIME_STAMP=`date "+%Y%m%d_%H%M%S"`
OUTPUT_PATH="$parentFolder/featureCount/${DATE_TIME_STAMP}_featureCount"
mkdir -pv "$OUTPUT_PATH"
echo "output folder created $OUTPUT_PATH"

LOG_PATH="${PWD}/logs"
mkdir -pv $LOG_PATH

SCRIPT_PATH="${PWD}/scripts"
mkdir -pv "$SCRIPT_PATH"

module purge Subread/1.6.0-goolf-1.7.20
ml Subread/1.6.0-goolf-1.7.20

cd $INPUTPATH
for sample in $(ls *_aligned.bam | sed 's/_aligned.bam//');
do
  echo "$sample sample"
  OUTFILE="${sample}_feaCount.bedGraph"
  echo "#!/bin/bash" > "$SCRIPT_PATH/feaCount_${sample}.sh"
  echo -e "\n" >> "$SCRIPT_PATH/feaCount_${sample}.sh"
  echo "#SBATCH --job-name=$sample" >> "$SCRIPT_PATH/feaCount_${sample}.sh"
  echo "#SBATCH --cpus-per-task=2" >> "$SCRIPT_PATH/feaCount_${sample}.sh"
  echo "#SBATCH --mem-per-cpu=8G" >> "$SCRIPT_PATH/feaCount_${sample}.sh"
  echo "#SBATCH --output=${LOG_PATH}/feaCount_${sample}.o%j" >> "$SCRIPT_PATH/feaCount_${sample}.sh"
  echo "#SBATCH --error=${LOG_PATH}/feaCount_${sample}.e%j" >> "$SCRIPT_PATH/feaCount_${sample}.sh"
  echo "#SBATCH --qos=30min" >> "$SCRIPT_PATH/feaCount_${sample}.sh"
  echo -e "\n" >> "$SCRIPT_PATH/feaCount_${sample}.sh"
  echo "module purge Subread/1.6.0-goolf-1.7.20" >> "$SCRIPT_PATH/feaCount_${sample}.sh"
  echo "ml Subread/1.6.0-goolf-1.7.20" >> "$SCRIPT_PATH/feaCount_${sample}.sh"
  echo "echo \"Starting featureCounts...\"" >> "$SCRIPT_PATH/feaCount_${sample}.sh"
  echo "time featureCounts -a \"$VALID_RE_FILE\" -F SAF -o \"$OUTPUT_PATH/$OUTFILE\" --largestOverlap \"$INPUTPATH/${sample}_aligned.bam\" " >> "$SCRIPT_PATH/feaCount_${sample}.sh"
  echo "echo \"Finished featureCounts....\" " >> "$SCRIPT_PATH/feaCount_${sample}.sh"
done
