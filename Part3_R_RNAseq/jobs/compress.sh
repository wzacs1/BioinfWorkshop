#!/bin/bash

#SBATCH -J gzi
#SBATCH -o /uufs/chpc.utah.edu/common/home/u0210816/Teaching/BioinfWorkshop2020/Part3_R_RNAseq/jobs/compress.outerror
#SBATCH -A round-np
#SBATCH -p round-shared-np
#SBATCH --time 12:00:00
#SBATCH -n 18

cd /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/BiopsyOnly
for f in *.fastq
do
pigz -p 16 $f
done

cd /scratch/general/lustre/u0210816/Part3_R_RNAseq/Biopsy1Only
mv *.gz /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/BiopsyOnly/

