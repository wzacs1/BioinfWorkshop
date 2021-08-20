#!/bin/bash

#SBATCH -J TrimAlign
#SBATCH -o /uufs/chpc.utah.edu/common/home/u0210816/Teaching/BioinfWorkshop2020/Part3_R_RNAseq/jobs/realign_w_gibb.outerror
#SBATCH -A round-np
#SBATCH -p round-shared-np
#SBATCH --time 24:00:00
#SBATCH -n 18


SCRATCH=/scratch/general/lustre/u0210816/Part3_R_RNAseq/Biopsy1Only
cd $SCRATCH

SALMONINDEX=/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/Hs.GRCh38.cdna.all_salmon_0.11

module purge
module load salmon

for read1 in *_1_val_1.fq; do salmon quant -i ${SALMONINDEX} --numGibbsSamples 20 --gcBias -l A -p 16 -1 ${read1} -2 ${read1%_1_val_1.fq}_2_val_2.fq --validateMappings -o ${read1%_1_val_1.fq}_salm_quant2; done
