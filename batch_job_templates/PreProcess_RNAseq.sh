#!/bin/bash

#SBATCH --account=mib2020
#SBATCH --partition=lonepeak-shared
#SBATCH -n 12
#SBATCH -J PreProcessRNAseq
#SBATCH --time=36:00:00
#SBATCH -o <YOUR_ABSOLUTE_PATH_TO_HOME>/BioinfWorkshop2021/Part3_R_RNAseq/code/PreProcess_RNAseq.outerror

WRKDIR=${HOME}/BioinfWorkshop2021/Part3_R_RNAseq/
SCRATCH=/scratch/general/lustre/${USER}/Part3_R_RNAseq/
mkdir -p $SCRATCH

# Here, we just copy over the input files from my shared space
cd $SCRATCH
mkdir -p BiopsyOnly
cd BiopsyOnly
cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/BiopsyOnly/*.gz ./

module purge
module load trim_galore/0.6.6

for read1 in *_1.fastq.gz
  do
  trim_galore --paired --fastqc --length 20 -q 20 -o ./ --cores 4 ${read1} ${read1%_1.fastq.gz}_2.fastq.gz
done

module purge
module load multiqc
cd ${SCRATCH}/BiopsyOnly
multiqc ./

SALMONINDEX=/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/Homo_sapiens.GRCh38.cdna.all_1.3

module purge
module load salmon/1.3.0

for read1 in *_1_val_1.fq.gz
  do
  salmon quant -i ${SALMONINDEX} --numGibbsSamples 20 --gcBias -l ISR -p 12 -1 ${read1} -2 ${read1%_1_val_1.fq.gz}_2_val_2.fq.gz --validateMappings -o ${read1%_1_val_1.fq.gz}_salm_quant
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
