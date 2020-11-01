#!/bin/bash

#When: Aug 9 2018
#Who: Shalu Jhanwar
#What: trim reads to make the samples of the same length

INPUTPATH=$1 # clipped fastq file containing folder

one_up=$(dirname $INPUTPATH)
parentFolder=$(dirname $one_up)
echo "parentFolder $parentFolder"

if [ ! -d "$parentFolder/trimmedReads" ]; then
        mkdir "$parentFolder/trimmedReads"
fi

DATE_TIME_STAMP=`date "+%Y%m%d_%H%M%S"`
OUTPUT_PATH="$parentFolder/trimmedReads/${DATE_TIME_STAMP}_trimmedReads"
mkdir -pv "$OUTPUT_PATH"
echo "output folder created $OUTPUT_PATH"


LOG_PATH="${PWD}/logs"
mkdir -pv $LOG_PATH

SCRIPT_PATH="${PWD}/scripts"
mkdir -pv "$SCRIPT_PATH"

cd $INPUTPATH
date_match="201901"
for sample in $(cat "trimmedReads_list.txt");
do
  echo "$sample sample"
  filename=$(echo "$sample" | sed 's/.fastq.gz/.fastq/')
  echo "#!/bin/bash" > "$SCRIPT_PATH/trimRead_${filename}.sh"
  echo -e "\n" >> "$SCRIPT_PATH/trimRead_${filename}.sh"
  echo "#SBATCH --job-name=$filename" >> "$SCRIPT_PATH/trimRead_${filename}.sh"
  echo "#SBATCH --cpus-per-task=4" >> "$SCRIPT_PATH/trimRead_${filename}.sh"
  echo "#SBATCH --mem-per-cpu=6G" >> "$SCRIPT_PATH/trimRead_${filename}.sh"
  echo "#SBATCH --output=${LOG_PATH}/trim_${sample}.o%j" >> "$SCRIPT_PATH/trimRead_${filename}.sh"
  echo "#SBATCH --error=${LOG_PATH}/trim_${sample}.e%j" >> "$SCRIPT_PATH/trimRead_${filename}.sh"
  echo "#SBATCH --qos=6hours" >> "$SCRIPT_PATH/trimRead_${filename}.sh"
  echo -e "\n" >> "$SCRIPT_PATH/trimRead_${filename}.sh"
  echo "module purge" >> "$SCRIPT_PATH/trimRead_${filename}.sh"
  echo "ml FASTX-Toolkit/0.0.14-goolf-1.7.20" >> "$SCRIPT_PATH/trimRead_${filename}.sh"
  echo "echo \"unzipping file...\"" >> "$SCRIPT_PATH/trimRead_${filename}.sh"
  echo "gunzip $INPUTPATH/$sample" >> "$SCRIPT_PATH/trimRead_${filename}.sh"
  echo "echo \"unzipping file finished...\"" >> "$SCRIPT_PATH/trimRead_${filename}.sh"
  echo "echo \"Starting trimming $filename...\"" >> "$SCRIPT_PATH/trimRead_${filename}.sh"
    if [[ $sample =~ $date_match ]];
    then
    echo "time fastx_trimmer -t 9  -z -i $INPUTPATH/$filename -o $OUTPUT_PATH/$sample" >> "$SCRIPT_PATH/trimRead_${filename}.sh"
    else
    echo "time fastx_trimmer -t 5 -z -i $INPUTPATH/$filename -o $OUTPUT_PATH/$sample" >> "$SCRIPT_PATH/trimRead_${filename}.sh"
    fi
  echo "echo \"Finished trimming....\"" >> "$SCRIPT_PATH/trimRead_${filename}.sh"
  echo "echo \"zipping file...\"" >> "$SCRIPT_PATH/trimRead_${filename}.sh"
  echo "gzip $INPUTPATH/$filename" >> "$SCRIPT_PATH/trimRead_${filename}.sh"
  echo "echo \"zipping file finished...\"" >> "$SCRIPT_PATH/trimRead_${filename}.sh"

done

