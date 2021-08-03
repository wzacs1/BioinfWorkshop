#!/bin/bash

#SBATCH --account=MIB2020
#SBATCH --partition=lonepeak-shared
#SBATCH -n 2
#SBATCH -J PreProcess16S
#SBATCH --time=12:00:00
#SBATCH -o <YOUR_ABSOLUTE_PATH_TO_HOME>/BioinfWorkshop2021/Part2_Qiime_16S/code/PreProcess_16S.outerror

mkdir -p ~/BioinfWorkshop2021/Part2_Qiime_16S
mkdir -p ~/BioinfWorkshop2021/Part2_Qiime_16S/results
mkdir -p ~/BioinfWorkshop2021/Part2_Qiime_16S/metadata

SCRATCH=/scratch/general/lustre/<Your_uNID>/Part2_Qiime_16S
mkdir -p ${SCRATCH}
WRKDIR=~/BioinfWorkshop2021/Part2_Qiime_16S
ls ${WRKDIR}

module load sra-toolkit
cd ${SCRATCH}

cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/metadata/SRR_Acc_List_full.txt \
 ~/BioinfWorkshop2021/Part2_Qiime_16S/metadata/

while read line
do fasterq-dump ${line} -e 2 -t ${SCRATCH}
done < ~/BioinfWorkshop2021/Part2_Qiime_16S/metadata/SRR_Acc_List_full.txt

# If using the CHPC installed module, uncomment (remove the '#') from the lines below, and comment out the 2020.2 commands after this:
# module purge
# module load anaconda3/2019.03
# source activate qiime2-2019.4

# For user installed miniconda and Qiime2 environment (2020.2):
module purge
module use ~/MyModules
module load miniconda3/latest
source activate qiime2-2020.2

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
 --input-path ~/BioinfWorkshop2021/Part2_Qiime_16S/metadata/manifest_full.txt \
 --output-path seqs_import.qza \
 --input-format PairedEndFastqManifestPhred33

 qiime demux summarize \
   --i-data seqs_import.qza \
   --o-visualization seqs_import.qzv

# Don't copy the seqs_import.qza, just the vizualizer. The seqs_import.qza is large and just a different format of the input fastq files, so unnecessary to retain.
cp seqs_import.qzv ${WRKDIR}/results/

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
  --o-table table.qza \
  --o-representative-sequences repseq.qza \
  --o-stats table_stats.qza

qiime feature-table summarize \
   --i-table table.qza \
   --o-visualization table.qzv

qiime feature-table tabulate-seqs \
   --i-data repseq.qza \
   --o-visualization repseq.qzv


cp table.qz[av] ${WRKDIR}
cp repseq.qz[av] ${WRKDIR}

qiime phylogeny align-to-tree-mafft-fasttree \
--i-sequences repseq.qza \
--o-alignment aligned_repseq.qza \
--o-masked-alignment masked_aligned_repseq.qza \
--o-tree tree_unroot.qza \
--o-rooted-tree tree_root.qza

cp tree*.qza ${WRKDIR}

# Use this classifier if using the QIIME2 2020.2 version
CLASSIFIER=/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/gg_13_8_515F806R_classifier_sk0.22.1.qz

# Use this classifier (uncomment) if using the CHPC module 2019 version of qiime2
# CLASSIFIER=/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/gg_13_8_515F806R_classifier_ForQIIME_v2019.4.qza

qiime feature-classifier classify-sklearn \
--i-classifier ${CLASSIFIER} \
--i-reads repseq.qza \
--o-classification taxonomy.qza \
--p-n-jobs 2

cp taxonomy.qza ${SCRATCH}

# Good idea to comment out the remove input fastq until you know it worked. Most of the time of this script is spent downloading the files and imorting them to the QIIME2 artifact file file.
# rm *.fastq
# rm *.qz[av]
