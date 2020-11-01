#!/bin/bash

#When: Aug 9 2018
#Who: Shalu Jhanwar
#What: perform window normalization to generate the 4C profiles

#################
#Load library
#################
library(GenomicRanges)
library(bit64)

#################
#Inputs and set paths
#################
rm(list=ls())
args = commandArgs(trailingOnly=TRUE)
BDGFILE = args[1]
BAITFRAGBED=args[2] #bed file of viewpoint fragment
MAPPEDREADFILE=args[3] #tab-delimited file with samplename and reads mapped
DELETIONBED=args[4] #tab-delimited file with deletion coordinates and prefix
PARENTDIR=args[5]
FILEPREFIX=args[6]

curentDate = Sys.time()
curentDateTime = gsub("-","",strsplit(as.character(curentDate), " ")[[1]][[1]])
projectPATH=paste0(curentDateTime,"_normCounts")
cat(projectPATH, "projectPATH",'\n')

dir.create(file.path(PARENTDIR, "normCounts"), showWarnings = TRUE)
dir.create(file.path(PARENTDIR, paste0("normCounts/",projectPATH)), showWarnings = TRUE)
dir.create(file.path(PARENTDIR, paste0("normCounts/",projectPATH,"/",FILEPREFIX)), showWarnings = TRUE)
outPath=file.path(PARENTDIR, paste0("normCounts/",projectPATH,"/",FILEPREFIX))
cat(outPath, "outPath",'\n')

tmp_bdgFile=basename(BDGFILE)
outFile=file.path(outPath, paste0(FILEPREFIX,"_", gsub("_mm10_grem1viewpoint_coverage.bdg", "_remDelReadsSmooth.bdg", tmp_bdgFile)))
cat(outFile, "outFile",'\n')

bait_df = read.table(BAITFRAGBED, sep='\t', header=F)
BAITCHR = as.character(bait_df$V1)
BAITSTART = as.integer(bait_df$V2)
BAITEND = as.integer(bait_df$V3)
if(length(BAITCHR)==0 | length(BAITSTART)==0 | length(BAITEND)==0){
  cat("No bait fragment coordinates found, pls provide fragment bed and run again \n")
  stop()
}
mappedreads_df = read.table(MAPPEDREADFILE, sep='\t', header=F)
sampleName = gsub("_mm10_grem1viewpoint_coverage.bdg","", tmp_bdgFile)
MAPPEDREADS = as.integer(mappedreads_df[grep(paste("^",sampleName,"$",sep=""), mappedreads_df$V1),"V2"])

if(length(MAPPEDREADS)==0){
  cat("No mapped reads is found, pls provide mapped reads and run again \n")
  stop()
}
deletion_df = read.table(DELETIONBED, sep='\t', header=T)
DELCHR = as.character(deletion_df[grep(paste("^", FILEPREFIX, "$",sep=""), deletion_df$prefix), "chr"])
DELSTART = as.integer(deletion_df[grep(paste("^", FILEPREFIX, "$",sep=""), deletion_df$prefix), "start"])
DELEND = as.integer(deletion_df[grep(paste("^", FILEPREFIX, "$",sep=""), deletion_df$prefix), "end"])
if(length(DELCHR)==0 | length(DELSTART)==0 | length(DELEND)==0){
  cat("No deletion coordinates found, pls chk prefix and run again \n")
  stop()
}

cat("DELSTART", DELSTART, '\n')
cat("DELEND", DELEND, '\n')
cat("BAITSTART", BAITSTART, '\n')
cat("BAITEND", BAITEND, '\n')
cat("MAPPEDREADS", MAPPEDREADS, '\n')

#################
#Define functions
#################
readsMappedDeletion <- function(bedFile_gr, BAITCHR, DELCHR, DELSTART, DELEND){
  for(chr in sort(unique(seqnames(bedFile_gr)))){
    select1 <- seqnames(bedFile_gr)==chr
    gr1.select <- bedFile_gr[select1,]
    if(chr == BAITCHR){
      str_col = start(gr1.select)
      end_col = end(gr1.select)
      indRemove = which(((str_col > DELSTART) & (end_col < DELEND)) | ((str_col < DELSTART) & (end_col > DELSTART) & (end_col < DELEND)) | ((str_col > DELSTART) & (str_col < DELEND) & (end_col > DELEND)))
      delReg_gr = gr1.select[indRemove,]
      delMappedReads = sum(delReg_gr$score)
    }
  }
  return(delMappedReads)
}

remove10kbUpDownBait <- function(bedFile_gr, BAITSTART, BAITEND){
  bait_up_10kb = BAITSTART - 5000
  bait_down_10kb = BAITEND + 5000
  without10Kb_bedFile = data.frame()
  for(chr in sort(unique(seqnames(bedFile_gr)))){
    select1 <- seqnames(bedFile_gr)==chr
    gr1.select <- bedFile_gr[select1,]
  if(chr == BAITCHR){
    str_col = start(gr1.select)
    end_col = end(gr1.select)
    indRemove = which(((str_col >= bait_up_10kb) & (end_col<= bait_down_10kb)) | ((str_col <= bait_up_10kb) & (end_col > bait_up_10kb) & (end_col <=bait_down_10kb)) | ((str_col >= bait_up_10kb) & (str_col < bait_down_10kb) & (end_col >= bait_down_10kb)))
    no10kb_gr = gr1.select[-indRemove,]
    without10Kb_bedFile = rbind(without10Kb_bedFile, as.data.frame(no10kb_gr))
  }
  else{
    cat("chr", chr)
    without10Kb_bedFile = rbind(without10Kb_bedFile, as.data.frame(gr1.select))
    }
  }
  return(without10Kb_bedFile)
}

normProfile <- function(without10Kb_bedFile, MAPPEDREADS){
  ma <- function(x, n = 5){filter(x, rep(1, n), sides = 2)}
  without10Kb_bedFile$smoothScore = round(ma(without10Kb_bedFile$score, n=5))
  without10Kb_bedFile$smoothScore[which(is.na(without10Kb_bedFile$smoothScore))] = without10Kb_bedFile$score[which(is.na(without10Kb_bedFile$smoothScore))]
  without10Kb_bedFile$normSmoothScore = round(((without10Kb_bedFile$smoothScore * 1000000)/MAPPEDREADS), digits = 5)
  normSmoothcounts = without10Kb_bedFile[,c('seqnames', 'start', 'end', 'normSmoothScore')]
  return(normSmoothcounts)
}

setwd(outPath)

#################
#Start processing
#################
#Create GR object for input signals
cols <- c('character', 'integer', 'integer', 'integer')
bedFile = read.table(BDGFILE,colClasses = cols)
bedFile_gr = GRanges(IRanges(start = bedFile$V2, end = bedFile$V3), seqnames = bedFile$V1, score = bedFile$V4)
bedFile_gr <- sortSeqlevels(bedFile_gr)
bedFile_gr <- sort(bedFile_gr)

#COUNT READS per fragments from WT or mutant samples, matching with deletion - required to remove reads for deleted region to normalize them
delMappedReads = readsMappedDeletion(bedFile_gr, BAITCHR, DELCHR, DELSTART, DELEND)
MAPPEDREADS = MAPPEDREADS - delMappedReads

#REMOVE 10kb up and down stream of the region
without10Kb_bedFile = remove10kbUpDownBait(bedFile_gr, BAITSTART, BAITEND)
without10Kb_bedFile = without10Kb_bedFile[,c(1,2,3,6)]

normSmoothcounts = normProfile(without10Kb_bedFile, MAPPEDREADS)
cat("Output file is saved as:", outFile, '\n')
write.table(normSmoothcounts,outFile, quote=FALSE, col.names=FALSE, row.names=FALSE, sep = "\t")
