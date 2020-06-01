<!-- TOC -->

- [Main](#main)
  - [Requirements / Inputs](#requirements--inputs)
  - [Plan Overall Method](#plan-overall-method)
  - [Step 0: Setup directory structure](#step-0-setup-directory-structure)
  - [Step 1: Obtain sequences](#step-1-obtain-sequences)
    - [Step 1 - test dataset: Copy the raw fastq sequences to your scratch directory.](#step-1---test-dataset-copy-the-raw-fastq-sequences-to-your-scratch-directory)
    - [Step 1 - full dataset: Copy the raw fastq sequences to your scratch directory.](#step-1---full-dataset-copy-the-raw-fastq-sequences-to-your-scratch-directory)
    - [(optional) Step 1 - full dataset: Pull the full dataset from SRA](#optional-step-1---full-dataset-pull-the-full-dataset-from-sra)
  - [Step 2: Trim adapters, low quality sequences and create quality plots](#step-2-trim-adapters-low-quality-sequences-and-create-quality-plots)
    - [Step 2: test dataset](#step-2-test-dataset)
    - [Step 2: full dataset](#step-2-full-dataset)
  - [Step 3: Run alignments](#step-3-run-alignments)
    - [Step 3 - test dataset](#step-3---test-dataset)
    - [Step 3 - full dataset](#step-3---full-dataset)
  - [Step 4: Summarize your sequences and alignments with MultiQC](#step-4-summarize-your-sequences-and-alignments-with-multiqc)
    - [Step 4 - test dataset](#step-4---test-dataset)
    - [Step 4 - full dataset](#step-4---full-dataset)
  - [Step 5: Cleanup](#step-5-cleanup)
  - [Step 6: Submit batch script](#step-6-submit-batch-script)
- [Practice / With Your Own Data](#practice--with-your-own-data)
- [Links / Cheatsheets](#links--cheatsheets)

<!-- /TOC -->

# Main
**Objectives**
1. Workthrough a test RNAseq dataset to QC and align reads, adding to batch script as we go.
2. Submit full batch script.

## Requirements / Inputs
1. A CHPC account and interactive session on compute node (obtained as in previous classes with `srun` command)
2. A plain text editor installed locally for your markdown and job submission script. Prefer Atom or BBedit.
   1. Alternatively, OnDemand has a built-in text editor as well, though it is minimal. Just open a file to edit through it's interface. (also lacks the cheatsheet for markdown in Atom markdown-writer package)
3. All inputs can be found *within* (i.e. directories within this directory):
`/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq`
- Probably a good idea to make a soft link (`ln -s`) to this location in your BioinfWorkshop2020 directory as before.

## Plan Overall Method
- For this workthrough, I will specifically highlight code chunks that should add to your bash script (once you've verified they are working of course).
- Open a new file (Atom or whatever text editor you like) and call it "PreProcess_RNAseq.sh". This will be your batch script.

## Step 0: Setup directory structure
There was a bit of confusion as to directories structures I had you setup for 16S analysis and the assigning of variables to directories. The confusion is partly because as you were still learning commands we did things in slightly different order than we might normally in order to illustrate commands better. Also, because the concept of scratch space still seems a bit foreign and since I name the directories in both home and scratch locations the same. This time, I will go through them more like would make sense in a submitted batch script and go through the setup outside a bit to illustrate how we are aiming to create a similar structure in our scratch and home (or working directory) locations.

Let's setup our working direcotry (in our home space) first. We could actually do this just in the script, but it's not a bad idea to set this up manually then just define it in the script to ensure your job runs at first.

```bash
$ cd ~/BioinfWorkshop2020/
$ mkdir -p Part3_R_RNAseq/
$ pwd -P
```
- Copy the output from the `pwd -P` command and assign it to your working directory variable.
**Add to batch script** (the part enclosed in "<>", including the "<>", should be replaced by your values).

```bash
$ WRKDIR=<Full_Path_To_Your_Home>/BioinfWorkshop2020/Part3_R_RNAseq/
```
I will note that you can generally get away with just usign the "~" for your home when assigning to variables, but it is safer to use the full path as when you start moving in and out of virtual environments or containers this `~` can be misinterpreted depending on how/if your filesystems are mounted or env variables are passed to new environment.

With our scratch space, let's just define it and create it within our batch script. You can again `cd` into your scratch space just to get the full directory. If you followed the previous days pages, you should have a softlink to your lustre (the CHPC drive space) space where your scratch directory is and you could just run `cd ~/scratch_lustre`, or whatever your link name is to get there. If not, you may need to create a scratch space still. In order to make sure it is there, I'll show you how to remake it. This won't overwrite your current directory if it is already there. Remember, to replace the <> and everythign in them with your values.

```bash
$ mkdir -p /scratch/general/lustre/<Your_uNID>/
```

Now, in your batch script. Define your scratch space. Notice how we give it the same terminal folder/directory name.

- Copy the output from the `pwd -P` command and assign it to your working directory variable.
**Add to batch script** (the part enclosed in "<>", including the "<>", should be replaced by your values).
```bash
$ SCRATCH=/scratch/general/lustre/<Your_uNID>/Part3_R_RNAseq/
$ mkdir -p $SCRATCH
```
By adding the `mkdir -p` command after defining the directory we ensure the directory is there even (making sure the rest of the script can run) if we defined it slightly wrong, but alos this makes your scripts a bit more automated. You didn't have to create the directories before running the script, just change values for directory in the future and rerun.

In order to help solidify how the naming we used and that scratch and home/working directory are in different places, move to them and list the full path and notice how your prompt looks similar in both places (probably, prompt display can be changed, but CHPC's default list the directory you are in before the `$`).

```bash
$ cd ~/BioinfWorkshop2020/Part3_R_RNAseq/
$ pwd -P
$ cd /scratch/general/lustre/<Your_uNID>/Part3_R_RNAseq/
$ pwd -P
```

If your prompt displays the directory before the `$`, notice how the direcory name was the same in both places. This led to some confusion, and is not at all required. It's just a conventional way I name the different directories in order to make it easy to copy the full scratch directory over when I'm done and maintain the same naming.

Finally, create jobs and metadata directories in your working directory. You'll save your batch script in your jobs directory as before.

```bash
$ cd ~/BioinfWorkshop2020/Part3_R_RNAseq/
$ mkdir -p jobs; mkdir -p metadata
```

## Step 1: Obtain sequences
The 16S sequences were relatively small for each sample and so did not take too long or give us much trouble in pulling them from the SRA. However, RNAseq raw read files are typically much larger, especially with everyone tending to run paired-end 150 nucleotides reads on the NovaSeq now whether they need that much or not (typically, single end 50 nucleotides is sufficient for understanding broad expression patterns). I'll provide the code I used to pull the RNAseq from the SRA, but instead of you running it as well, I'll just recommend you copy the files I already pulled. This took about 12 hours to download them all, and exposes one major issue with sra-toolkit.

This SRA dataset actually has RNAseq from BAL and from tissue biopsies. For now, we will just look at the tissue biopsy samples, but will come back to the BAL samples at the end of class if we have time.

- *NOTE*: Use only option 1 (for interactive testing) or option 2 (for full batch job). The "(optional)" part is shown only if you want to see how the whole dataset was downloaded from the SRA.

### Step 1 - test dataset: Copy the raw fastq sequences to your scratch directory.
As this is just for the test dataset, you won't add this to your batch script. See the "full dataset" option below for the commands to replace this to add to your batch script. First, make a directory within scratch for this test dataset. Before (with the 16S data) I didn't specifiy a "test" directory but just maintained the same naming as for the full dataset. This is really preferred because all you need to do is change one input and the full dataset overwrites and runs just like the test dataset. However, this led to a lot of confusion so I'll specifically set aside the test dataset this time, which means I'll need to list commands for both test and full dataset at almost every command.

```bash
$ cd $SCRATCH
$ mkdir TestSet
$ cd TestSet
$ cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/TestSet/*.fastq \
 ./
```

### Step 1 - full dataset: Copy the raw fastq sequences to your scratch directory.
Below we copy the full biopsy dataset to your scratch directory.
**Add to batch script**.
```bash
$ cd $SCRATCH
$ mkdir -p BiopsyOnly
$ cd BiopsyOnly
$ cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/BiopsyOnly/*.fastq \
 ./
```

### (optional) Step 1 - full dataset: Pull the full dataset from SRA
If you want to work on pulling the full dataset from SRA I'll also show you this command, but otherwise it is easier and faster to just copy the full raw seq dataset over from what I have already downloaded (above). This also shows that there is an issue with SRA-toolkit assigning the temporary cache space to your home normally, and then running out of space because you only have 50 Gb there. First, create a directory which sra-toolkit already knows to look in and place a single line definition there to refer it to your scratch space for temporary cache instead of your home space. You could add this to your batch script as well. As before, make sure to add your values for your scratch space. It doesn't really matter where in your scratch space as these are temporary files. I just point it to my main scratch space.
```bash
$ mkdir -p ~/.ncbi
$ echo '/repository/user/main/public/root = "/scratch/general/lustre/<Your_uNID>"' > ~/.ncbi/user-settings.mkfg
```
Copy over the accession list (or pull from SRA site yourself), and use it to pull the sequences.
```bash
$ cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/metadata/SRR_Acc_List_RNASeq_BiopsyOnly.txt \
 ~/BioinfWorkshop2020/Part3_R_RNAseq/metadata
```
Instead of fasterq-dump we used before I'm doing the same thing but in two commands because it is a little more fault tolerant.
```bash
$ cd $SCRATCH
$ mkdir BiopsyOnly
$ cd BiopsyOnly
$ module load sra-toolkit
$ while read line
$  do
$  prefetch -O ./ -X 90G ${line}
$  fastq-dump --split-3 ${line}.sra
$  rm ${line}.sra
$ done < ~/BioinfWorkshop2020/Part3_R_RNAseq/metadata/SRR_Acc_List_RNASeq_BiopsyOnly.txt
$ cd ../
$ module unload sra-toolkit
```

## Step 2: Trim adapters, low quality sequences and create quality plots
It is always a good idea to perform this step to filter out adapter reads in particular. As with 16S, we are going to use cutadapt program that is great for this. For our 16S seqs we were trimming primers as adapter sequences mainly and using QIIME2 which wrapped the cutadapt program. Here, we are trimming actual Illumina adapters which will be auto-recognized by cutadapt, and we are using the "trim_galore" tool to wrap cutadapt. First, we load trim_galore which is installed as a CHPC module.

**Add to batch script**.
```bash
$ module purge
$ module load cutadapt/1.14
$ module load fastqc/0.11.4
$ module load trim_galore/0.4.4
```
Note that the order here matter. In fact, module system will error if you try to load trim_galore first because trim_galore wraps cutadapt and fastqc. Open the trim_galore help page and notice the "--path-to-cutadapt" option. It says cutadapt must be in your path. This is an example of how the chpc module system adds things to your path and why it is good to understand what your path is.

Trim_galore will do the quality trimming and create a quality plot for you with fastqc. We will largley leave the default options because they are pretty good and it recognizes the Illumina adapters well. By default, no "unpaired" sequences will be retained. These are sequences with a pair that did not pass QC. There's often situations where you would want to retain these, but generally having unpaired seqs will cause problems in other applications and unpaired seqs tend to be of lower quality so we do not usually retain them.

### Step 2: test dataset
```bash
$ cd ${SCRATCH}/TestSet
$ for read1 in *_1.fastq
$   do
$   trim_galore --paired --fastqc --length 20 -q 20 -o ./ ${read1} ${read1%_1.fastq}_2.fastq
$ done
```

As I've mentioned before, it is a good idea to work through this for loop to understand what it is doing. This is a very common type of loop that is quite useful for working with sequences. It is very similar to what we did with 16S seqs, but with a different program invoked. A good way to work through understanding it is to replace with "trim_galore" command and all of it's options with just the `ls` command (or `echo` depending on what you are doing), to see how the loop is iterating over these files and how the `%` within the variable refernces is stripping the text string after the % from the variable in order to remove the "_1.fastq" and replace it with "_2.fastq"; thus passing both read1 and read2 files.

### Step 2: full dataset
**Add to batch script**.
```bash
$ cd ${SCRATCH}/BiopsyOnly
$ for read1 in *_1.fastq
$   do
$   trim_galore --paired --fastqc --length 20 -q 20 -o ./ ${read1} ${read1%_1.fastq}_2.fastq
$ done
```

Note: The above command works but does run one sample at a time making it fairly slow. There's no built-in way to have trim_galore run mulitple processes unfortunatley, but there is a method called GNU parallel that can help facilitate it. It's a bit much for beginners so I won't get into it, but if you are interested in looking into the syntax more, here's an example command that will start multiple (in this case 16) processes at a time, one for each file pair. The first part of it (before `parallel`) just gets the basename of each pair of files which gets passed into the brackets in the `parallel` command, and there are many ways to do this. You could replace this code block with the one above to run much faster, IF you have 12 processes available (i.e. `#SBATCH -n 12`).

```bash
$ cd ${SCRATCH}/BiopsyOnly
$ ls -1 *.fastq | cut -f 1 -d _ | sort | uniq | parallel -j 12 'trim_galore --paired --fastqc --length 20 -q 20 -o ./ {}_1.fastq {}_2.fastq'
```

## Step 3: Run alignments
We are going to use Salmon today. Salmon is one of a couple "pseudoalignment" methods that came out a few years ago and are frequently used now. Another is Kallisto, which I actually like a bit more. These methods are many many times faster than other short-read alignments methods that were themselves relatively fast initially (eg. Bowtie2, STAR, etc.), and you could run them on your laptop easily. We'll keep it all on CHPC for simplicity, and because you may in the future have good reason to run other aligners that would take considerably longer.

Generally with alignment methods you will need to build an index from the references sequences first in the program. The indices tend to have specific formats for the alignment program you are using. I've made the human transcriptome index for Salmon already to save some time, so just make a variable reference for it, but I also provide the code below if you'd like to see how it works.

**Add to batch script**.
```bash
SALMONINDEX=/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/Hs.GRCh38.cdna.all_salmon_0.11
```

You may notice this refernce index is actually a directory. This is common for these refernce indexes.


Building the Salmon reference mapping index (**optional**, already built above). This is only provided if you want to rebuild the reference index yourself. We pull the ENSEMBL human cDNA reference here. Generally, you won't want to map RNAseq reads to the genome.
```bash
$ module load salmon
$ wget ftp://ftp.ensembl.org/pub/release-100/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz
$ salmon index -t Homo_sapiens.GRCh38.cdna.all.fa.gz -i Hs.GRCh38.cdna.all_salmon_0.11
$ rm Homo_sapiens.GRCh38.cdna.all.fa.gz
```
- Make sure to create a variable to refer to your index if you creted it yourself.

### Step 3 - test dataset
Now, let's run the pseudoaligner to get counts of reads by transcript.

```bash
$ module purge
$ module load salmon
$ cd ${SCRATCH}/TestSet
$ for read1 in *_1_val_1.fq
$  do
$  salmon quant -i ${SALMONINDEX} -l A -p 2 -1 ${read1} -2 ${read1%_1_val_1.fq}_2_val_2.fq --validateMappings -o ${read1%_1_val_1.fq}_salm_quant
$ done
```

### Step 3 - full dataset
Now, the command for the full dataset, where we really just replaced the direcotry here, but just to be clear. Here, I'll also add a couple statement to just print the time of start and end. These are often useful when running something expected to take a long time so you can compare later and make faster as needed. Not super helpful in an interactive session, but with the submitted job script these will be recorded to your output and you can `grep` for them to quickly build reports, for example. Also note that the number of processes is changed to 12 because I'll assume you run this with 12 processes requested in your SBATCH -n directive.

**Add to batch script**.
```bash
$ module purge
$ module load salmon
$ cd ${SCRATCH}/BiopsyOnly
$ echo "TIME:Start Salmon Biopsy Alignment: `date`"
$ for read1 in *_1_val_1.fq
$  do
$  salmon quant -i ${SALMONINDEX} -l A -p 12 -1 ${read1} -2 ${read1%_1_val_1.fq}_2_val_2.fq --validateMappings -o ${read1%_1_val_1.fq}_salm_quant
$ done
$ echo "TIME:End Salmon Biopsy Alignment: `date`"
```
Hopefully you can see that because I started the echo statements for recording time with "TIME", I could quickly parse the standard out/error file for the "TIME" with `grep` to get the printed times. Also note how using the backticks ()\`) within another command allows that command (in this case `date`) to be evaluated.


## Step 4: Summarize your sequences and alignments with MultiQC
MultiQC is such a neat tool that is so easy to run I would be remiss if I left it out. It's usually a good idea to look at your sequence quality before spending time mapping/aligning. However, since the pseudoaligner is so fast and multiqc is more useful if there are already alignments I do it last now. MultiQC will traverse directories of wherever you tell it to look and look for files from various programs that are commonly used. You'll want to check out it's doc page for more details (see links at bottom), but for now just run it so we can see the reports.

### Step 4 - test dataset
```bash
$ module purge
$ module load multiqc
$ cd ${SCRATCH}/TestSet
$ multiqc ./
```
Copy the multiqc result.html file back to your working directory so you can download them with OnDemand file explorer and view them (you can't access scratch space from it currrently it seems)
```bash
$ cp multiqc_report.html ${WRKDIR}
```
Check out the report file. Note that its not a good representation of the actual data because it's just the first 50,000 or so sequences and the top sequences are always poorer quality, but it does let us talk a bit about the results. On the left, you can see how multiqc broked them down into the program that created them. Most of our results are actually from fastqc. You could run multiple alignment methods quickly and multiqc could summarize the results for you nicely. Very useful but simple tool!


### Step 4 - full dataset
To run on the full dataset, in your batch script:
**Add to batch script**.
```bash
$ module purge
$ module load multiqc
$ cd ${SCRATCH}/BiopsyOnly
$ multiqc ./
```

## Step 5: Cleanup
As always, we want to clean the scratch space to be responsible CHPC users and also copy the needed outputs back to your working directory. Here I'll just provide the commands for the full dataset to add to your batch script. For the test dataset, you can just remove the full `TestSet` directory. Let's just retain the Salmon outputs and the reports from multiQC:
**Add to batch script**.
```bash
$ cd ${SCRATCH}/BiopsyOnly/
$ mkdir -p ${WRKDIR}/BiopsyOnly/
$ mv *_salm_quant ${WRKDIR}/BiopsyOnly/
$ mv multiqc_data/ ${WRKDIR}/BiopsyOnly/
$ mv multiqc_report.html ${WRKDIR}/BiopsyOnly/
$ rm ${SCRATCH}/BiopsyOnly/*.txt
$ rm ${SCRATCH}/BiopsyOnly/*.html
$ rm ${SCRATCH}/BiopsyOnly/*.zip
$ rm ${SCRATCH}/BiopsyOnly/*.fq
$ rm ${SCRATCH}/BiopsyOnly/*.fastq
```
In practice, it's often helpful to comment out (add a `#` at beginning) the rm commands at first so you don't have to start from scratch if something fails.

## Step 6: Submit batch script
Just as we did before with the 16S data, we have built up a full batch script to submit and run on the full dataset. We just need to add SBATCH directives as appropriate. I encourage you to do this for the practice, but will also provide the outputs in the next day. Submit this script requesting 12 processes to speed it up.

**Remember that we only have the reservation between Tuesday and Thursday class**. So, don't include the reservation option if submitting outside those times. Add the following sbatch directives and "shebang" at the top of your batch script, above all the commands.

```
#!/bin/bash

#SBATCH --account=MIB2020
#SBATCH --partition=lonepeak-shared
#SBATCH -n 12
#SBATCH -J PreProcessRNAseq
#SBATCH --time=16:00:00
#SBATCH -o <Full_Path_To_Your_Home>/BioinfWorkshop2020/Part3_R_RNAseq/jobs/PreProcess_RNAseq.outerror
```
Upload your batch script to the jobs directory as "PreProcess_RNAseq.sh". You can of course call it whatever you like and put it wherever you like. This is just for consistency within the class.

Submit the job, remembering that you have to be on lonepeak to submit a job on a lonepeak partition and notchpeak on notchpeak partition, etc. If you saved o
```bash
$ sbatch <Full_Path_To_Your_Home>/BioinfWorkshop2020/Part3_R_RNAseq/jobs/PreProcess_RNAseq.sh
```

# Practice / With Your Own Data
- Understand the while loop and commands I used in the optional section shown how to pull the full dataset from the SRA. You don't need to actually pull them all, but load the sra-toolkit and examine options. This can help understand the SRA format.
- Submit and work through any errors that come up with your batch script.
- Upload your own RNAseq data and work through the day's commands. You may need to modify settings depending on your organism and sequencing setup. This is an excellent opportunity to ensure you know each command well.

# Links / Cheatsheets
- Salmon page: [https://salmon.readthedocs.io/en/latest/salmon.html](https://salmon.readthedocs.io/en/latest/salmon.html)
- MultiQC tutorial video: [https://www.youtube.com/watch?v=qPbIlO_KWN0](https://www.youtube.com/watch?v=qPbIlO_KWN0)
