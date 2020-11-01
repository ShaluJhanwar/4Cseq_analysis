#!/bin/bash

#When: 2017-10-01
#What: count fastq reads
#Who: Shalu Jhanwar

INPUTPATH=$1 #input the fastq folder containing fq files
cd $INPUTPATH

#create readCount.txt
touch readCount.txt
for f in $(ls | egrep '\.gz$|\.fq$|\.fasta$');
do
        if [[ $f =~ \.gz$ ]]; then
                echo "Processing gz file: $f"
                countF=$(zcat $f | wc -l | awk '{print $1/4}')
        else
                echo "Processing file (no gz): $f"
                countF=$(wc -l "$f" | awk '{print $1/4}')
        fi
        echo -e "$f\t$countF" >> readCount.txt
done
