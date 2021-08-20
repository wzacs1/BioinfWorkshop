#!/bin/bash

#SBATCH -J fqtx_full
#SBATCH -o /uufs/chpc.utah.edu/common/home/u0210816/Teaching/BioinfWorkshop/Part3_R_RNAseq/jobs/01_pullRNA_full.outerror
#SBATCH -A round-np
#SBATCH -p round-shared-np
#SBATCH --time 72:00:00
#SBATCH -n 12


#Starting Dir and Structure:

#- Start with make project directory and jobs and metadata folder

#- SRRAccessionList in metadata folder

# Note the editor on OnDemand instead of for Atom



### Vars
SCRATCH=/scratch/general/lustre/u0210816/Part3_R_RNAseq
WRKDIR=/uufs/chpc.utah.edu/common/home/u0210816/Teaching/BioinfWorkshop/Part3_R_RNAseq

NumProc=10

mkdir -p ${SCRATCH}
mkdir -p ${WRKDIR}/metadata

### Module loading
module purge


cd $SCRATCH
mkdir -p BiopsyOnly

echo "TIME:START: `date`"

module load sra-toolkit/2.10.9

echo "TIME:START sra pull at `date`"
cd ${SCRATCH}/BiopsyOnly
while read line
do
 fasterq-dump $line -e $NumProc -t ${SCRATCH} -O ${SCRATCH}/TestSet
done < ${WRKDIR}/metadata/SRR_Acc_List_RNASeq_BiopsyOnly.txt


echo "TIME:END sra pull: `date`"

cd ${SCRATCH}/BiopsyOnly
for f in *.fastq
do
pigz -p 10 $f
done

cd /scratch/general/lustre/u0210816/Part3_R_RNAseq/BiopsyOnly
mkdir -p /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/BiopsyOnly/
mv *.gz /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/BiopsyOnly/
