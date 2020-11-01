#!/bin/bash

#When: Aug 9 2018
#Who: Shalu Jhanwar
#What: map reads for primer sequences

INPUTPATH=$1 #mapped file containing folder
genomeIndwithPrefix=$2

one_up=$(dirname $INPUTPATH)
parentFolder=$(dirname $one_up)
echo "parentFolder $parentFolder"

if [ ! -d "$parentFolder/aln" ]; then
        mkdir "$parentFolder/aln"
fi

DATE_TIME_STAMP=`date "+%Y%m%d_%H%M%S"`
OUTPUT_PATH="$parentFolder/aln/${DATE_TIME_STAMP}_aln"
mkdir -pv "$OUTPUT_PATH"
echo "output folder created $OUTPUT_PATH"

LOG_PATH="${PWD}/logs"
mkdir -pv $LOG_PATH

SCRIPT_PATH="${PWD}/scripts"
mkdir -pv "$SCRIPT_PATH"

cd $INPUTPATH

for sample in $(ls *_grem1viewpoint.fastq.gz | sed 's/.fastq.gz//');
do
  echo "$sample sample"
  echo "#!/bin/bash" > "$SCRIPT_PATH/map_${sample}.sh"
  echo -e "\n" >> "$SCRIPT_PATH/map_${sample}.sh"
  echo "#SBATCH --job-name=$sample" >> "$SCRIPT_PATH/map_${sample}.sh"
  echo "#SBATCH --cpus-per-task=4" >> "$SCRIPT_PATH/map_${sample}.sh"
  echo "#SBATCH --mem-per-cpu=8G" >> "$SCRIPT_PATH/map_${sample}.sh"
  echo "#SBATCH --output=${LOG_PATH}/map_${sample}.o%j" >> "$SCRIPT_PATH/map_${sample}.sh"
  echo "#SBATCH --error=${LOG_PATH}/map_${sample}.e%j" >> "$SCRIPT_PATH/map_${sample}.sh"
  echo "#SBATCH --qos=6hours" >> "$SCRIPT_PATH/map_${sample}.sh"
  echo -e "\n" >> "$SCRIPT_PATH/map_${sample}.sh"
  echo "module purge" >> "$SCRIPT_PATH/map_${sample}.sh"
  echo "ml Bowtie2/2.2.9-goolf-1.7.20" >> "$SCRIPT_PATH/map_${sample}.sh"
  echo "echo \"Starting mapping...\"" >> "$SCRIPT_PATH/map_${sample}.sh"
  echo "time bowtie2 -p 6 --un $OUTPUT_PATH/${sample}_unaligned.sam -x $genomeIndwithPrefix -U $INPUTPATH/${sample}.fastq.gz -S $OUTPUT_PATH/${sample}_aligned.sam" >> "$SCRIPT_PATH/map_${sample}.sh"
  echo "echo \"Finished mapping....\"" >> "$SCRIPT_PATH/map_${sample}.sh"
done
