#!/bin/bash

#When: Aug 9 2018
#Who: Shalu Jhanwar
#What: clip reads for primer sequences

INPUTPATH=$1 #fastq file containing folder
PRIMER_FILE=$2 #file with the primer details
DEMULTIPLX_PATH="demultiplex.py"

one_up=$(dirname $INPUTPATH)
parentFolder=$(dirname $one_up)
echo "parentFolder $parentFolder"

if [ ! -d "$parentFolder/clippedReads" ]; then
        mkdir "$parentFolder/clippedReads"
fi

DATE_TIME_STAMP=`date "+%Y%m%d_%H%M%S"`
OUTPUT_PATH="$parentFolder/clippedReads/${DATE_TIME_STAMP}_clippedReads"
mkdir -pv "$OUTPUT_PATH"
echo "output folder created $OUTPUT_PATH"

LOG_PATH="${PWD}/logs"
mkdir -pv $LOG_PATH

SCRIPT_PATH="${PWD}/scripts"
mkdir -pv "$SCRIPT_PATH"

cd $INPUTPATH

for sample in $(ls *fastq.gz | sed 's/.fastq.gz//');
do
        echo "$sample sample"
        echo "#!/bin/bash" > "$SCRIPT_PATH/clip_${sample}.sh"
        echo -e "\n" >> "$SCRIPT_PATH/clip_${sample}.sh"
        echo "#SBATCH --job-name=$sample" >> "$SCRIPT_PATH/clip_${sample}.sh"
        echo "#SBATCH --cpus-per-task=2" >> "$SCRIPT_PATH/clip_${sample}.sh"
        echo "#SBATCH --mem-per-cpu=4G" >> "$SCRIPT_PATH/clip_${sample}.sh"
        echo "#SBATCH --output=${LOG_PATH}/clip_${sample}.o%j" >> "$SCRIPT_PATH/clip_${sample}.sh"
        echo "#SBATCH --error=${LOG_PATH}/clip_${sample}.e%j" >> "$SCRIPT_PATH/clip_${sample}.sh"
        echo "#SBATCH --qos=6hours" >> "$SCRIPT_PATH/clip_${sample}.sh"
        echo -e "\n" >> "$SCRIPT_PATH/clip_${sample}.sh"
        echo "module purge" >> "$SCRIPT_PATH/clip_${sample}.sh"
        echo "ml Python/2.7.11-goolf-1.7.20" >> "$SCRIPT_PATH/clip_${sample}.sh"
        echo "ml HTSeq/0.6.1p1-goolf-1.7.20-Python-2.7.11" >> "$SCRIPT_PATH/clip_${sample}.sh"
        echo "echo \"Starting clipping...\"" >> "$SCRIPT_PATH/clip_${sample}.sh"
        echo "time python $DEMULTIPLX_PATH --fastq "$INPUTPATH/${sample}.fastq.gz" --barcode $PRIMER_FILE --out $OUTPUT_PATH" >> "$SCRIPT_PATH/clip_${sample}.sh"
        echo "echo \"Finished Clipping....\"" >> "$SCRIPT_PATH/clip_${sample}.sh"
done
