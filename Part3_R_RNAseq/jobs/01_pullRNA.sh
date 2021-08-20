#!/bin/bash

#SBATCH -J fqtx
#SBATCH -o /uufs/chpc.utah.edu/common/home/u0210816/Teaching/BioinfWorkshop/Part3_R_RNAseq/jobs/transfer_all_BAL.outerror
#SBATCH -A round-np
#SBATCH -p round-shared-np
#SBATCH --time 72:00:00
#SBATCH -n 16


#Starting Dir and Structure:

#- Start with make project directory and jobs and metadata folder

#- SRRAccessionList in metadata folder

# Note the editor on OnDemand instead of for Atom



### Vars
SCRATCH=/scratch/general/lustre/u0210816/Part3_R_RNAseq
WRKDIR=/uufs/chpc.utah.edu/common/home/u0210816/Teaching/BioinfWorkshop/Part3_R_RNAseq

mkdir -p ${SCRATCH}
mkdir -p ${WRKDIR}
mkdir -p ${WRKDIR}/metadata

### Module loading
module purge
module load sra-toolkit/2.10.0

echo '/repository/user/main/public/root = "/scratch/general/lustre/u0210816"' > ~/.ncbi/user-settings.mkfg

cd $SCRATCH

echo "TIME:START: `date`"

# 2.10.0 is buggy and  has common segmentation fault noted on several posts. Could install newer binary and config, instead just use older methods in sra toolkit.
# while read line
# do  fasterq-dump ${line} -e 6 -t ${SCRATCH} -O ${SCRATCH} -m 1200MB 
# done < ${WRKDIR}/metadata/SRR_Acc_List_BALOnly.txt

# Note still need to change cache dir to scratch or run out of room.

#mkdir BALOnly
mkdir BiopsyOnly

#cd BALOnly
#while read line
#do prefetch -O ./ -X 50G ${line}
#fastq-dump --split-3 ${line}.sra
#rm ${line}.sra
#done < ${WRKDIR}/metadata/SRR_Acc_List_BALOnly.txt
#cd ../

cd BiopsyOnly
while read line
do prefetch -O ./ -X 50G ${line}
fastq-dump --split-3 ${line}.sra
rm ${line}.sra
done < ${WRKDIR}/metadata/SRR_Acc_List_RNASeq_BiopsyOnly.txt
cd ../

echo "TIME:END sra pull: `date`"

cd ${SCRATCH}/BiopsyOnly
for f in *.fastq
do
pigz -p 16 $f
done

cd /scratch/general/lustre/u0210816/Part3_R_RNAseq/Biopsy1Only
mv *.gz /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/BiopsyOnly/
