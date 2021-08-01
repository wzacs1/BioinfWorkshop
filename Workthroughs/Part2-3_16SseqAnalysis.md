
# Main

## Setup and Background
- Obtain an interactive shell session:
1. Log in to CHPC via your preferred method (OnDemand, ssh from Terminal, or FastX Web server).
- https://ondemand-class.chpc.utah.edu
2. Obtain an interactive session with 2 processors.
```bash
 salloc -A mib2020 -p lonepeak-shared -n 2 --time 3:00:00
 # OR
 salloc -A notchpeak-shared-short -p notchpeak-shared-short -n 2 --time 3:00:00
```
3. (optional)(for next week): Sign up for a GitHub account: [https://github.com](https://github.com)

### Today's Objectives:

#### I. Analyze 16S Sequences with QIIME2 on the Linux CLI
- Understand an amplicon sequencing process workflow.
- Gaining more command line practice.


### Requirements and Expected Inputs
- CHPC connection and interactive shell session
- QIIME2 install in Conda virtual environment or CHPC QIIME2 module
  - Note that some commands may differ slightly if you use the older CHPC module. Look at the help file of commands to see if options are different.
- Atom or other plain text editor.
- **Expected Inputs**:
	- Working Directory: `~/BioinfWorkshop2021/Part2_Qiime_16S/`
	- Scratch Directory: `/scratch/general/lustre/<YOUR_uNID>/Part2_Qiime_16S/`
```

- In previous session, we used 2 samples to first workup our sequence processing pipeline and get to a feature table with taxonomy calls, representative sequences and a phylogeny. Then, we worked up a submitted batch script to run the full dataset. The full dataset, including the metadata table, is the input for our analysis. If you were able to generate these yourself, continue to use them. If not, copy the inputs to your Project directory for the day (`~/BioinfWorkshop2021/Part2_Qiime_16S/` if you named it as I suggested). Each path is given below:

1. The feature table: `table_full.qza`
```bash
/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/table_full.qza
```
2. The rooted phylogeny: `tree_root_full.qza`
```bash
/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/tree_root_full.qza
```
3. The taxonomy calls `taxonomy_full.qza`
```bash
/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/taxonomy_full.qza
```
4. The metadata table `SraRunTable_full.txt`
```bash
/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/metadata/SraRunTable_full.txt
```

**NOTE if using Qiime 2019 CHPC module**: There may be some version incompatibilities. Mostly, looks to not be a problem, so you just use the same as above if possible, but if  there are issues use the 2019 files of the same name I created in the folder:

```bash
/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/Qiime2_2019_outs/
```



## Review

We are working interactively with a smaller dataset first to test out our commands, but ultimately we are trying to build a batch script that can be submitted and run non-interactively for the full dataset. The overall structure of a batch script will usually look something like this (will add number 1 at the end):
![General Batch Script Process](https://drive.google.com/uc?export=view&id=1OmDxGQeS2wpe6I6B6Dtoin0xxqCvBqGw)

```bash
SCRATCH=/scratch/general/lustre/<YOUR_uNID/Part2_Qiime_16S/
# mkdir -p ${SCRATCH}
WRKDIR=~/BioinfWorkshop2021/Part2_Qiime_16S/
```
Remember that we installed a separate miniconda3 module so we must load this first then QIIME2. We will use this set of commands frequently:
```bash
module use ~/MyModules
module load miniconda3/latest
source activate qiime2-2021.4
```
We also ended up in our scratch directory space, so we need to make sure to change directories to that location or many of our file references would be off.
```bash
cd ${SCRATCH}
```

**ONLY IF you didn't get the conda environment setup previously, use the CHPC installed module** (only use the above command OR the below command)
```bash
module load anaconda3/2019.03
source activate qiime2-2019.4
```

##### My batch job script created during class.
If you want to check what a working job script should look like (based off how we created it in class), mine can be copied from the shared directory. Just remember, to replace the value in the `SBATCH -o` option with your home directory path (use `echo $HOME` to get it).

```bash
cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/code/PreProcess_16S.sh ~/BioinfWorkshop2021/Part2_Qiime_16S/code/PreProcess_16S.sh
```

# Practice / With Your Own Data

# Links, Cheatsheets and Today's Commands
- Qiime2 Plugins Documenation: [https://docs.qiime2.org/2021.4/plugins/available/](https://docs.qiime2.org/2021.4/plugins/available/)
- Today's New Commands:
