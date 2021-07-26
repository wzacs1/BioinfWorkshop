#!/bin/bash

SCRATCH=/scratch/general/lustre/u0210816/Part2_Qiime_16S
mkdir -p ${SCRATCH}
# Set the working directory and create a subdirectory to store results in:
WRKDIR=~/BioinfWorkshop2021/Part2_Qiime_16S/
mkdir -p ${WRKDIR}/results
# Listing the contents is not required, but helps show what is already there in the output if, for example, we need to rerun.
ls ${WRKDIR}

module load sra-toolkit/2.10.9
cd ${SCRATCH}

for accession in SRR10501757 SRR10501758
do
  fasterq-dump ${accession} -e 2 -t ${SCRATCH} -O ${SCRATCH} -p
done

module use ~/MyModules
module load miniconda3/latest
source activate qiime2-2020.2

echo "sample-id,absolute-filepath,direction" > ${WRKDIR}/metadata/manifest_test.txt

for read1 in *_1.fastq
do
  echo "${read1%_1.fastq},${SCRATCH}/${read1},forward" >> ${WRKDIR}/metadata/manifest_test.txt
done

for read2 in *_2.fastq
do
  echo "${read2%_2.fastq},${SCRATCH}/${read2},reverse" >> ${WRKDIR}/metadata/manifest_test.txt
done

MANIFEST=${WRKDIR}/metadata/manifest_test.txt

qiime tools import \
 --type 'SampleData[PairedEndSequencesWithQuality]' \
 --input-path ${MANIFEST} \
 --output-path seqs_import.qza \
 --input-format PairedEndFastqManifestPhred33
