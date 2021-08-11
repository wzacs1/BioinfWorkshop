#!/bin/bash

#SBATCH --account=mib2020
#SBATCH --partition=lonepeak-shared
#SBATCH -n 12
#SBATCH -J PreProcessRNAseq
#SBATCH --time=36:00:00
#SBATCH -o <YOUR_ABSOLUTE_PATH_TO_HOME>/BioinfWorkshop2021/Part2_Qiime_16S/jobs/PreProcess_16S_QIIME2019_2020Classifier.outerror

WRKDIR=~/BioinfWorkshop2021/Part3_R_RNAseq/
SCRATCH=/scratch/general/lustre/u0210816/Part3_R_RNAseq/
mkdir -p $SCRATCH

cd $SCRATCH
mkdir -p TestSet
cd TestSet
cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/TestSet/*.fastq ./

# the path to full BiopsyOnly dataset is here: /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/BiopsyOnly/

module purge
module load cutadapt/1.14
module load fastqc/0.11.4
module load trim_galore/0.4.4

cd ${SCRATCH}/TestSet
for read1 in *_1.fastq
  do
  trim_galore --paired --fastqc --length 20 -q 20 -o ./ ${read1} ${read1%_1.fastq}_2.fastq
done

SALMONINDEX=/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/Hs.GRCh38.cdna.all_salmon_0.11

module purge
module load salmon

cd ${SCRATCH}/TestSet
for read1 in *_1_val_1.fq
  do
  salmon quant -i ${SALMONINDEX} -l A -p 2 -1 ${read1} -2 ${read1%_1_val_1.fq}_2_val_2.fq --validateMappings -o ${read1%_1_val_1.fq}_salm_quant
done

cd ${SCRATCH}/BiopsyOnly/
mkdir -p ${WRKDIR}/BiopsyOnly/
mv *_salm_quant ${WRKDIR}/BiopsyOnly/
mv multiqc_data/ ${WRKDIR}/BiopsyOnly/
mv multiqc_report.html ${WRKDIR}/BiopsyOnly/
rm ${SCRATCH}/BiopsyOnly/*.txt
rm ${SCRATCH}/BiopsyOnly/*.html
rm ${SCRATCH}/BiopsyOnly/*.zip
rm ${SCRATCH}/BiopsyOnly/*.fq
rm ${SCRATCH}/BiopsyOnly/*.fastq
