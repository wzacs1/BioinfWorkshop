#!/bin/bash

#SBATCH --account=MIB2020
#SBATCH --partition=lonepeak-shared
#SBATCH -n 2
#SBATCH -J PreProcess16S
#SBATCH --time=12:00:00
#SBATCH -o <YOUR_ABSOLUTE_PATH_TO_HOME>/BioinfWorkshop2020/Part2_Qiime_16S/jobs/PreProcess_16S_QIIME2019_2020Classifier.outerror

mkdir -p ~/BioinfWorkshop2020/Part2_Qiime_16S
mkdir -p ~/BioinfWorkshop2020/Part2_Qiime_16S/jobs
mkdir -p ~/BioinfWorkshop2020/Part2_Qiime_16S/metadata

SCRATCH=/scratch/general/lustre/u0210816/Part2_Qiime_16S_2019Module
mkdir -p ${SCRATCH}
WRKDIR=~/BioinfWorkshop2020/Part2_Qiime_16S_2019Module
ls ${WRKDIR}

module load sra-toolkit
cd ${SCRATCH}

cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part2_Qiime_16S/metadata/SRR_Acc_List_full.txt \
 ~/BioinfWorkshop2020/Part2_Qiime_16S/metadata/

while read line
do fasterq-dump ${line} -e 2 -t ${SCRATCH}
done < ~/BioinfWorkshop2020/Part2_Qiime_16S/metadata/SRR_Acc_List_full.txt

module unload sra-toolkit
module load qiime2
conda activate qiime2-2019.1

echo "sample-id,absolute-filepath,direction" > ${WRKDIR}/metadata/manifest_full.txt

for read1 in *_1.fastq
do echo "${read1%_1.fastq},${SCRATCH}/${read1},forward" >> ${WRKDIR}/metadata/manifest_full.txt
done

for read2 in *_2.fastq
do echo "${read2%_2.fastq},${SCRATCH}/${read2},reverse" >> ${WRKDIR}/metadata/manifest_full.txt
done

cd ${SCRATCH}

qiime tools import \
 --type 'SampleData[PairedEndSequencesWithQuality]' \
 --input-path ~/BioinfWorkshop2020/Part2_Qiime_16S/metadata/manifest_full.txt \
 --output-path seqs_import.qza \
 --input-format PairedEndFastqManifestPhred33

 qiime demux summarize \
   --i-data seqs_import.qza \
   --o-visualization seqs_import.qzv

cp seqs_import.qzv ${WRKDIR}/seqs_import.qzv

qiime cutadapt trim-paired \
  --i-demultiplexed-sequences seqs_import.qza \
  --o-trimmed-sequences seqs_trim.qza \
  --p-front-f GTGCCAGCMGCCGCGGTAA \
  --p-front-r GGACTACHVGGGTWTCTAAT \
  --p-cores 2

qiime vsearch join-pairs \
    --i-demultiplexed-seqs seqs_trim.qza \
    --o-joined-sequences seqs_trim_join.qza \
    --p-minmergelen 150 \
    --p-maxdiffs 10 \
    --p-allowmergestagger \
    --verbose

qiime demux summarize \
      --i-data seqs_trim_join.qza \
      --o-visualization seqs_trim_join.qzv

cp seqs_trim_join.qzv ${WRKDIR}/

qiime deblur denoise-16S \
  --i-demultiplexed-seqs seqs_trim_join.qzv \
  --p-trim-length 250 \
  --p-jobs-to-start 12 \
  --o-table table_full.qza \
  --o-representative-sequences repseq_full.qza \
  --o-stats table_full_stats.qza

qiime feature-table summarize \
   --i-table table_full.qza \
   --o-visualization table_full.qzv

qiime feature-table tabulate-seqs \
   --i-data repseq_full.qza \
   --o-visualization repseq_full.qzv


cp table_full.qz[av] ${WRKDIR}
cp repseq_full.qz[av] ${WRKDIR}

qiime phylogeny align-to-tree-mafft-fasttree \
--i-sequences repseq_full.qza \
--o-alignment aligned_repseq.qza \
--o-masked-alignment masked_aligned_repseq.qza \
--o-tree tree_unroot_full.qza \
--o-rooted-tree tree_root_full.qza

cp tree*.qza ${WRKDIR}

CLASSIFIER=/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part2_Qiime_16S/gg_13_8_515F806R_classifier_sk0.22.1.qz

qiime feature-classifier classify-sklearn \
--i-classifier ${CLASSIFIER} \
--i-reads repseq_full.qza \
--o-classification taxonomy_full.qza \
--p-n-jobs 2

cp taxonomy_full.qza ${SCRATCH}

rm *.fastq
rm *.qz[av]
