#!/bin/bash

#SBATCH -J TrimAlign
#SBATCH -o /uufs/chpc.utah.edu/common/home/u0210816/Teaching/BioinfWorkshop2020/Part3_R_RNAseq/jobs/02_trimQCalign.outerror
#SBATCH -A round-np
#SBATCH -p round-shared-np
#SBATCH --time 70:00:00
#SBATCH -n 18


#Starting Dir and Structure:
# We copy and paste from previous job to maintaint the same directory structure


### Vars
SCRATCH=/scratch/general/lustre/u0210816/Part3_R_RNAseq
WRKDIR=/uufs/chpc.utah.edu/common/home/u0210816/Teaching/BioinfWorkshop2020/Part3_R_RNAseq

mkdir -p ${SCRATCH}
mkdir -p ${WRKDIR}
mkdir -p ${WKRDIR}/metadata

# Module loading
## Note that trim_galore just wraps cutadapt and fastqc and provides a nice interface to them. Look at trim_galore help page to reiterate why you need to have things in your path (for cutadapt)
module load cutadapt/1.14
module load fastqc/0.11.4
module load trim_galore/0.4.4

cd $SCRATCH

# Here's code for trim_galore loop. In practice, I passed it to gnu parallel to speed it up, but this is beyond class for now so providing original code:


# cd BALOnly
# for read1 in *_1.fastq
# do trim_galore --paired --retain_unpaired --fastqc --length 20 -q 20 -o ./ ${read1} ${read1%_1.fastq}_2.fastq
# done
# cd ../

# cd Biopsy1Only
# for read1 in *_1.fastq
# do trim_galore --paired --retain_unpaired --fastqc --length 20 -q 20 -o ./ ${read1} ${read1%_1.fastq}_2.fastq
# done
# cd ../


# Similar to above, but passed to gnu parallel.
cd BALOnly
ls -1 *.fastq | cut -f 1 -d _ | sort | uniq | parallel -j 16 'trim_galore --paired --fastqc --length 20 -q 20 -o ./ {}_1.fastq {}_2.fastq'
cd ../

cd Biopsy1Only
ls -1 *.fastq | cut -f 1 -d _ | sort | uniq | parallel -j 16 'trim_galore --paired --fastqc --length 20 -q 20 -o ./ {}_1.fastq {}_2.fastq'
cd ../



# Alignments with Salmon
# Awesome to see install page notes conda vnv and docker. We'll use outdated CHPC installed versions: https://combine-lab.github.io/salmon/getting_started/, but note 1.2.0 version to install as miniconda3 (note on page and what is needed before running commands)

module load salmon

# First, need to build a reference index compatibile with Salmon (only once, quite fast)
# cd /uufs/chpc.utah.edu/common/home/round-group1/reference_seq_dbs/salmon_indices/
# wget ftp://ftp.ensembl.org/pub/release-100/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz
# salmon index -t Homo_sapiens.GRCh38.cdna.all.fa.gz -i Hs.GRCh38.cdna.all_salmon_0.11

SALMONINDEX=/uufs/chpc.utah.edu/common/home/round-group1/reference_seq_dbs/salmon_indices/Hs.GRCh38.cdna.all_salmon_0.11

echo "TIME:Start Salmon BAL Alignment: `date`"
cd $SCRATCH

cd BALOnly
for read1 in *_1_val_1.fq
do
salmon quant -i ${SALMONINDEX} -l A -p 12 -1 ${read1} -2 ${read1%_1_val_1.fq}_2_val_2.fq --validateMappings -o ${read1%_1_val_1.fq}_salm_quant
done
cd ../
echo "TIME:End Salmon BAL Alignment: `date`"

echo "TIME:Start Salmon Biopsy Alignment: `date`"
cd Biopsy1Only
for read1 in *_1_val_1.fq
do
salmon quant -i ${SALMONINDEX} -l A -p 12 -1 ${read1} -2 ${read1%_1_val_1.fq}_2_val_2.fq --validateMappings -o ${read1%_1_val_1.fq}_salm_quant
done
cd ../
echo "TIME:End Salmon Biopsy Alignment: `date`"


# MutliQC
module load multiqc
cd ${SCRATCH}
multiqc ./


mv multiqc_report.html ${WRKDIR}
mv multiqc_data/ ${WRKDIR}
mv BALOnly/*_salm_quant ${WRKDIR}
mv Biopsy1Only/*_salm_quant ${WRKDIR}
