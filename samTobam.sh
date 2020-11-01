#!/bin/bash

#When: Aug 9 2018
#Who: Shalu Jhanwar
#What: map reads for primer sequences

INPUTPATH=$1 #mapped file containing folder
one_up=$(dirname $INPUTPATH)
parentFolder=$(dirname $one_up)
echo "parentFolder $parentFolder"

if [ ! -d "$parentFolder/samTobam" ]; then
        mkdir "$parentFolder/samTobam"
fi

DATE_TIME_STAMP=`date "+%Y%m%d_%H%M%S"`
OUTPUT_PATH="$parentFolder/samTobam/${DATE_TIME_STAMP}_samTobam"
mkdir -pv "$OUTPUT_PATH"
echo "output folder created $OUTPUT_PATH"

LOG_PATH="${PWD}/logs"
mkdir -pv $LOG_PATH

SCRIPT_PATH="${PWD}/scripts"
mkdir -pv "$SCRIPT_PATH"

cd $INPUTPATH

for sample in $(ls *_aligned.sam | sed 's/.sam//');
do
  echo "$sample sample"
  echo "#!/bin/bash" > "$SCRIPT_PATH/samTobam_${sample}.sh"
  echo -e "\n" >> "$SCRIPT_PATH/samTobam_${sample}.sh"
  echo "#SBATCH --job-name=$sample" >> "$SCRIPT_PATH/samTobam_${sample}.sh"
  echo "#SBATCH --cpus-per-task=4" >> "$SCRIPT_PATH/samTobam_${sample}.sh"
  echo "#SBATCH --mem-per-cpu=8G" >> "$SCRIPT_PATH/samTobam_${sample}.sh"
  echo "#SBATCH --output=${LOG_PATH}/samTobam_${sample}.o%j" >> "$SCRIPT_PATH/samTobam_${sample}.sh"
  echo "#SBATCH --error=${LOG_PATH}/samTobam_${sample}.e%j" >> "$SCRIPT_PATH/samTobam_${sample}.sh"
  echo "#SBATCH --qos=6hours" >> "$SCRIPT_PATH/samTobam_${sample}.sh"
  echo -e "\n" >> "$SCRIPT_PATH/samTobam_${sample}.sh"
  echo "module purge" >> "$SCRIPT_PATH/samTobam_${sample}.sh"
  echo "ml SAMtools/1.7-goolf-1.7.20" >> "$SCRIPT_PATH/samTobam_${sample}.sh"
  echo "echo \"Starting mapping...\"" >> "$SCRIPT_PATH/samTobam_${sample}.sh"
  echo "time samtools view -h -F 0x904 "$INPUTPATH/${sample}.sam" | grep -E \"@|NM:\" | grep -v \"XS:\" > $INPUTPATH/tmp_${sample}" >> "$SCRIPT_PATH/samTobam_${sample}.sh"
  echo "time samtools view -Sbh "$INPUTPATH/tmp_${sample}" > $OUTPUT_PATH/${sample}.bam" >> "$SCRIPT_PATH/samTobam_${sample}.sh"
  echo "echo \"Finished mapping....\" " >> "$SCRIPT_PATH/samTobam_${sample}.sh"
done
