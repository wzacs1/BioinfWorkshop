
# Main

## Objectives
##### I. Workthrough a test RNAseq dataset to QC and align reads, adding to batch script as we go.
##### II. Submit full batch script.
	- The template for this is here: [PreProcess_RNAseq.sh](https://github.com/wzacs1/BioinfWorkshop/blob/master/batch_job_templates/PreProcess_RNAseq.sh)

## Requirements / Inputs
1. A CHPC account and interactive session on compute node (obtained as in previous classes with `salloc` command)
2. A plain text editor installed locally for your job submission script. Prefer Atom.
3. All inputs can be found *within* (i.e. directories within this directory):
`/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq`
- Probably a good idea to make a soft link (`ln -s`) to this location in your BioinfWorkshop2021/Part3_R_RNAseq directory. Let's call the link "class_space"
```bash
mkdir -p ~/BioinfWorkshop2021/Part3_R_RNAseq/
cd ~/BioinfWorkshop2021/Part3_R_RNAseq/
ln -s /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/ class_space
```

## Plan Overall Method
- For this workthrough, as before, we will first workthrough a test dataset to ensure our code works, then try to run the full dataset as a batch script.
  - Copy the code to your bash script as you go along (once you've verified they are working of course).
  - Full dataset commands are given at the same time now that you know how it all fits together.
    - As you copy working commands to your batch script, alter them to run on the full dataset. This way, we can have the batch script commands for the full dataset right away.
- Open a new file (on your local computer in Atom or whatever text editor you like) and call it "PreProcess_RNAseq.sh". This will be your batch script.
![Preprocess_RNASeq_Image](https://drive.google.com/uc?export=view&id=1lo0z6rmlXHK5PCviu8UwAXVut9gd5x9l)

## RNAseq QC/trim and alignments with Salmon
### Step 0: Setup directory structure
There was a bit of confusion as to directories structures I had you setup for 16S analysis and the assigning of variables to directories. The confusion is partly because as you were still learning commands we did things in slightly different order than we might normally in order to illustrate commands better. Also, because the concept of scratch space still seems a bit foreign and since I name the directories in both home and scratch locations the same. This time, I will go through them more like would make sense in a submitted batch script and go through the setup outside a bit to illustrate how we are aiming to create a similar structure in our scratch and home (or working directory) locations.

- If you didn't already do this (when we made the link in previous section), setup your working directory (in our home space) first. We could actually do this just in the script, but it's not a bad idea to set this up manually then just define it in the script to ensure your job runs at first.

```bash
cd ~/BioinfWorkshop2021/
mkdir -p Part3_R_RNAseq/
pwd -P
```
- Copy the output from the `pwd -P` command and assign it to your working directory variable.
**Add to batch script**

```bash
WRKDIR=${HOME}/BioinfWorkshop2021/Part3_R_RNAseq/
```

With our scratch space, let's just define it and create it within our batch script. You can again `cd` into your scratch space just to get the full directory. If you followed the previous days pages, you should have a softlink to your lustre (the CHPC drive space) space where your scratch directory is and you could just run `cd ~/scratch_lustre`, or whatever your link name is to get there. If not, you may need to create a scratch space still. In order to make sure it is there, I'll show you how to remake it. This won't overwrite your current directory if it is already there. Remember, to replace the <> and everythign in them with your values.

```bash
mkdir -p /scratch/general/lustre/${USER}/
```
- Usually, you will have the correct value set for `${USER}` (your uNID) on CHPC, but sometimes we encounter some environment setup differences that cause this to not be correctly set. If not, add your specific uNID here.

Now, in your batch script. Define your scratch space. Notice how we give it the same terminal folder/directory name.

- Copy the output from the `pwd -P` command and assign it to your working directory variable.
**Add to batch script** (change $USER if your scratch directory was not made by your uNID.
```bash
SCRATCH=/scratch/general/lustre/${USER}/Part3_R_RNAseq/
mkdir -p $SCRATCH
```
- By adding the `mkdir -p` command after defining the directory we ensure the directory is there even (making sure the rest of the script can run) if we defined it slightly wrong, but also this makes your scripts a bit more easy to rerun. You didn't have to create the directories before running the script, just change values for the scratch directory variable in the future and rerun.

In order to help solidify how the naming we used and that scratch and home/working directory are in different places, move to them and list the full path and notice how your prompt looks similar in both places.

```bash
cd ~/BioinfWorkshop2021/Part3_R_RNAseq/
# Above should be the same as 'cd ${SCRATCH}' at this point.
pwd -P
cd /scratch/general/lustre/${USER}/Part3_R_RNAseq/
# Above should be the same as 'cd ${WRKDIR}' at this point.
pwd -P
```

- If your prompt displays the directory before the `$`, notice how the direcory name was the same in both places. This naming of the directories the same in both places (scratch and working directory) to some confusion, and is not at all required. It's just a conventional way I name the different directories in order to make it easy to copy the full scratch directory over when I'm done and maintain the same naming if desired.

Finally, create `code` and `metadata` directories in your working directory. You'll save your batch script in your `code` directory as before.

```bash
cd ~/BioinfWorkshop2021/Part3_R_RNAseq/
mkdir -p code; mkdir -p metadata
```

### Step 1: Obtain sequences
- The 16S sequences were relatively small for each sample and so did not take too long or give us much trouble in pulling them from the SRA. However, RNAseq raw read files are typically much larger, especially with everyone tending to run paired-end 150 nucleotides reads on the NovaSeq now whether they need that much or not (typically, single end 50 nucleotides is sufficient for understanding broad expression patterns).
-  I'll provide the code I used to pull the RNAseq from the SRA, but instead of you running it as well, I'll just recommend you copy the files I already pulled. This took about 12 hours to download them all, and exposes one major issue with sra-toolkit.

- This SRA dataset actually has RNAseq from BAL and from tissue biopsies. For now, we will just look at the tissue biopsy samples, but might come back to the BAL samples at the end of class if we have time.

- *NOTE*: Use only option 1 (for interactive testing) or option 2 (for full batch job). The "(optional)" part is shown only if you want to see how the whole dataset was downloaded from the SRA.

### Step 1 - test dataset: Copy the raw fastq sequences to your scratch directory.
- Throughout this class, I will give the test dataset commands and then the full dataset commands. Mostly, they will be the same.
  - Use the "test dataset" to run interactively today and test our commands are working
  - Use the "full dataset" commands to add to your batch script. Keep in mind that the "full dataset" only contains the **Biopsy** samples.

- Before (with the 16S data) I didn't specifiy a "test" directory but just maintained the same naming as for the full dataset. This is really preferred because all you need to do is change one input and the full dataset overwrites and runs just like the test dataset. However, this led to a lot of confusion so I'll specifically set aside the test dataset this time, which means I'll need to list commands for both test and full dataset at almost every command.

```bash
cd $SCRATCH
mkdir TestSet
cd TestSet
cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/TestSet/*.fastq.gz \
 ./
```

### Step 1 - full dataset: Copy the raw fastq sequences to your scratch directory.
Below we copy the full biopsy dataset to your scratch directory.
**Add to batch script**.
```bash
cd $SCRATCH
mkdir -p BiopsyOnly
cd BiopsyOnly
cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/BiopsyOnly/*.fastq.gz \
 ./
```

### (optional) Step 1 - full dataset: Pull the full dataset from SRA
- **We won't go through this in class**, and newer sra-toolkit that actually works well as expected with `fasterq-dump` makes this easier, but I keep it here for now as documentation if you need to fall back to the previous version using `prefetch` and `fastq-dump` commands.

If you want to work on pulling the full dataset from SRA I'll also show you this command, but otherwise it is easier and faster to just copy the full raw seq dataset over from what I have already downloaded (above). This also shows that there is an issue with SRA-toolkit assigning the temporary cache space to your home normally, and then running out of space because you only have 50 Gb there. First, create a directory which sra-toolkit already knows to look in and place a single line definition there to refer it to your scratch space for temporary cache instead of your home space. You could add this to your batch script as well. As before, make sure to add your values for your scratch space. It doesn't really matter where in your scratch space as these are temporary files. I just point it to my main scratch space.
```bash
mkdir -p ~/.ncbi
echo '/repository/user/main/public/root = "/scratch/general/lustre/<Your_uNID>"' > ~/.ncbi/user-settings.mkfg
```
Copy over the accession list (or pull from SRA site yourself), and use it to pull the sequences.
```bash
cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/metadata/SRR_Acc_List_RNASeq_BiopsyOnly.txt \
 ~/BioinfWorkshop2021/Part3_R_RNAseq/metadata
```
Instead of fasterq-dump we used before I'm doing the same thing but in two commands because it is a little more fault tolerant.
```bash
cd $SCRATCH
mkdir BiopsyOnly
cd BiopsyOnly
module load sra-toolkit
while read line
 do
 prefetch -O ./ -X 90G ${line}
 fastq-dump --split-3 ${line}.sra
 rm ${line}.sra
done < ~/BioinfWorkshop2021/Part3_R_RNAseq/metadata/SRR_Acc_List_RNASeq_BiopsyOnly.txt
for fastq in *.fastq
 do
 pigz ${fastq}
done
cd ../
module unload sra-toolkit
```
If you do this, also keep in mind that I gzipped the files for the input for the rest of the class to save space. fastq-dump like this outputs the files uncompressed, so I added a compression (`pigz`; a multiprocess compression utility) command as well.

### Step 2: Trim adapters, low quality sequences and create quality plots
- It is always a good idea to perform this step to filter out adapter reads in particular. As with 16S, we are going to use cutadapt program that is great for this. For our 16S seqs we were trimming primers as adapter sequences mainly and using QIIME2 which wrapped the cutadapt program.
  - Here, we are trimming actual Illumina adapters (not those that were put on the sequences by PCR) which will be auto-recognized by cutadapt (there's not that many different adapter seqs), and we are using the "trim_galore" tool to wrap cutadapt, which gives us a bunch of useful options. First, we load trim_galore which is installed as a CHPC module.

**Add to batch script**.
```bash
module purge
module load trim_galore/0.6.6
module list
```
- Notice how the trim_galore module loaded cutadapt and fastqc modules as well. These are required and must be in your path for this module to function properly.
  - Open the trim_galore help page (`trim_galore --help`) notice the "--path-to-cutadapt" option. It says cutadapt must be in your path. This is an example of how the chpc module system adds things to your path and why it is good to understand what your path is. You can specify a different path to cutadapt still with this command option.

- Trim_galore will do the quality trimming and create a quality plot for you with fastqc as well. Nice!.
- We will largley leave the default options because they are pretty good and it recognizes the Illumina adapters well.
  - By default, no "unpaired" sequences will be retained. These are sequences with one of the pair that did not pass QC. There's often situations where you would want to retain these, but generally having unpaired seqs will cause problems in other applications and unpaired seqs have a strong tendency to be of lower quality as well, so typically I would just not retain them unless you are particulalry concerned with getting every little bit of increased coverage (more for genome assembly projects).

- Trim_galore will recompress the outputs with gzip if given input gzipped files (as we did here).
  - Most programs will happily take in gzipped files like this and unzip and rezip them before and after (respectively) operating on them.
  - **.gz** files are "gzipped". Use the `pigz` command with the `-p` option to specify number of processors and parallel / quickly zip files. Unzipping is not parallelizable. Use `gunzip` for this.

### Step 2: test dataset
```bash
cd ${SCRATCH}/TestSet
for read1 in *_1.fastq.gz
  do
  trim_galore --paired --fastqc --dont_gzip --length 20 -q 20 -o ./ ${read1} ${read1%_1.fastq.gz}_2.fastq.gz
done
```

- Again, it is a good idea to work through this for loop to understand what it is doing. Notice we keep seeing these. This is a very common type of loop that is quite useful for working with sequences. It is very similar to what we did with 16S seqs, but with a different program invoked.
  - A good way to work through understanding it is to replace with "trim_galore" command and all of it's options with just the `ls` command (or `echo` depending on what you are doing), to see how the loop is iterating over these files.
    - Each time it takes an input the `%` within the variable references is stripping everything after the `%` from the variable in order to remove the "_1.fastq" and replace it with "_2.fastq"; thus passing both read1 and read2 files. In this way, we referred to the read pairs by just inputting the read1.

### Step 2: full dataset
**Add to batch script**.
```bash
cd ${SCRATCH}/BiopsyOnly
for read1 in *_1.fastq.gz
  do
  trim_galore --paired --fastqc --length 20 -q 20 -o ./ --cores 4 ${read1} ${read1%_1.fastq.gz}_2.fastq.gz
done
```

- The above command works but does run one sample at a time making, albeit with 4 cores with the newer version of trime_galore. See the note on the `--cores` option for trim galore for more explanation and that specifying 4 cores is a sweet spot and may take up to 15 processes in reality for paired-end data.
- A method called GNU parallel that can help facilitate processing this much faster. It's a bit much for beginners so I won't get into it, but if you are interested in looking into the syntax more, here's an example command that will start multiple (in this case 4) processes at a time (using 4 cores each), one for each file pair. The first part of it (before `parallel`) just gets the basename of each pair of files which gets passed into the brackets in the `parallel` command, and there are many ways to do this. You could replace this code block with the one above to run much faster, IF you have at least 16 (prob want more like 32) cores available (i.e. `#SBATCH -n 32`).

```bash
cd ${SCRATCH}/BiopsyOnly
ls -1 *.fastq | cut -f 1 -d _ | sort | uniq | parallel -j 4 'trim_galore --paired --fastqc --length 20 -q 20 -o ./ --cores 4 {}_1.fastq {}_2.fastq'
```

### Step 3: Run alignments
We will use the Salmon for our alignments. Salmon is one of a few newer "pseudoalignment" methods that came out fairly recently and are common now. Another is Kallisto. These methods are many many times faster than other short-read alignments methods that were themselves relatively fast initially (eg. Bowtie2, STAR, etc.), and you could run them on your laptop easily. We'll keep it all on CHPC for simplicity, and because you may in the future have good reason to run other aligners that would take considerably longer.

Generally with alignment methods you will need to build an index from the references sequences first in the program. The indices tend to have specific formats for the alignment program you are using. I've made the human transcriptome index for Salmon already to save some time, so just make a variable reference for it, but I also provide the code below if you'd like to see how it works.

**Add to batch script**.
```bash
SALMONINDEX=/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/Homo_sapiens.GRCh38.cdna.all_1.3
```

- **Notice that we map reads to the transcriptome** (the `.cdna` in file name). You can map to genome and this used to be common just a couple years ago. However, as with not clustering 16S seqs to OTUs and now using ASVs instead, we don't want to map reads to a gene with multiple isoforms as a first step, because then we loose that transcript info. It is better to count transcripts then summarize to genes later.
  - "Premature summarization is the root of all evil" - Susan Holmes (I think)

- You may notice this reference index is actually a directory. This is common for these reference indexes.

#### Step 3a (optional): Build the reference index
Building the Salmon reference mapping index (**optional**, already built above). This is only provided if you want to rebuild the reference index yourself. We pull the ENSEMBL human cDNA reference here.

```bash
module load salmon
wget ftp://ftp.ensembl.org/pub/release-100/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz
salmon index -t Homo_sapiens.GRCh38.cdna.all.fa.gz -i Homo_sapiens.GRCh38.cdna.all_1.3 -p 6
rm Homo_sapiens.GRCh38.cdna.all.fa.gz
```

- Make sure to create a variable to refer to your index if you created it yourself.
- **NOTE** Salmon now recommends you build a decoy aware transcriptome for mapping mode. Several premade references are available to facilitate this on [http://refgenomes.databio.org/index](http://refgenomes.databio.org/index).

#### Step 3b - test dataset
- Now, let's run the pseudoaligner to get counts of reads by transcript.
- Notice that we added in an option for Gibbs resampling (similar to bootstrapping) and to correct for GC bias (some options are just on/off so simply specifying turns them on or off).

```bash
module purge
module load salmon
cd ${SCRATCH}/TestSet
for read1 in *_1_val_1.fq.gz
 do
 salmon quant -i ${SALMONINDEX} --numGibbsSamples 20 --gcBias -l ISR -p 4 -1 ${read1} -2 ${read1%_1_val_1.fq.gz}_2_val_2.fq.gz --validateMappings -o ${read1%_1_val_1.fq.gz}_salm_quant
done
```

- Observe the warnings and some of the messages as well.
  - The `-l` option specify the library type. According to the submitters this is a stranded library prepared with Illumina TruSeq. This option allows different types of libraries to be read and can be set to auto (`A`) for which it usually does a pretty good job usually, but not always on smaller test sets. See this page for more details on the library types:
      -  [https://salmon.readthedocs.io/en/latest/library_type.html#fraglibtype](https://salmon.readthedocs.io/en/latest/library_type.html#fraglibtype)

#### Step 3b - full dataset
Now, the command for the full dataset, where we really just replaced the direcotry here, but just to be clear. Here, I'll also add a couple statement to just print the time of start and end. These are often useful when running something expected to take a long time so you can compare later and make faster as needed. Not super helpful in an interactive session, but with the submitted job script these will be recorded to your output and you can `grep` for them to quickly build reports, for example. Also note that the number of processes is changed to 12 because I'll assume you run this with 12 processes requested in your SBATCH -n directive.

**Add to batch script**.
```bash
module purge
module load salmon
cd ${SCRATCH}/BiopsyOnly
echo "TIME:Start Salmon Biopsy Alignment: `date`"
for read1 in *_1_val_1.fq
 do
 salmon quant -i ${SALMONINDEX} --numGibbsSamples 20 --gcBias -l A -p 12 -1 ${read1} -2 ${read1%_1_val_1.fq}_2_val_2.fq --validateMappings -o ${read1%_1_val_1.fq}_salm_quant
done
echo "TIME:End Salmon Biopsy Alignment: `date`"
```
Hopefully you can see that because I started the echo statements for recording time with "TIME", I could quickly parse the standard out/error file for the "TIME" with `grep` to get the printed times. Also note how using the backticks ()\`) within another command allows that command (in this case `date`) to be evaluated.
- Notice that you can use the backticks (on your tilde key) to run a command within another command (in this example, `date` within the `echo` command).

### Step 4: Summarize your sequences and alignments with MultiQC
MultiQC is such a neat tool that is so easy to run I would be remiss if I left it out. It's usually a good idea to look at your sequence quality before spending time mapping/aligning. However, since the pseudoaligner is so fast and multiqc is more useful if there are already alignments I do it last now.
  - MultiQC will traverse directories of wherever you tell it to look and look for files from various programs that are commonly used. You'll want to check out it's doc page for more details (see links at bottom), but for now just run it so we can see the reports.

#### Step 4 - test dataset
```bash
module purge
module load multiqc
cd ${SCRATCH}/TestSet
multiqc ./
```
Copy the multiqc result.html file back to your working directory so you can download them with OnDemand file explorer and view them (you may or may not be able to access your scratch space directly in OnDemand)
```bash
cp multiqc_report.html ${WRKDIR}
```
- Check out the report file. Note that its not a good representation of the actual data because it's just the first 50,000 or so sequences and the top sequences are always poorer quality, but it does let us talk a bit about the results.
- On the left, you can see how multiqc broke them down into the program that created them. Most of our results are actually from fastqc. You could run multiple alignment methods quickly and multiqc could summarize the results for you nicely. A very useful but easy to run tool!


#### Step 4 - full dataset
To run on the full dataset, in your batch script:
**Add to batch script**.
```bash
module purge
module load multiqc
cd ${SCRATCH}/BiopsyOnly
multiqc ./
```

### Step 5: Cleanup
As always, we want to clean the scratch space to be responsible CHPC users and also copy the needed outputs back to your working directory. Here I'll just provide the commands for the full dataset to add to your batch script. For the test dataset, you can just remove the full `TestSet` directory. Let's just retain the Salmon outputs and the reports from multiQC:
**Add to batch script**.
```bash
cd ${SCRATCH}/BiopsyOnly/
mkdir -p ${WRKDIR}/BiopsyOnly/
mv *_salm_quant ${WRKDIR}/BiopsyOnly/
mv multiqc_data/ ${WRKDIR}/BiopsyOnly/
mv multiqc_report.html ${WRKDIR}/BiopsyOnly/
rm ${SCRATCH}/BiopsyOnly/*.txt
rm ${SCRATCH}/BiopsyOnly/*.html
rm ${SCRATCH}/BiopsyOnly/*.zip
# rm ${SCRATCH}/BiopsyOnly/*.gz
```
In practice, it's often helpful to comment out (add a `#` at beginning) the rm commands of the largest input files at first so you don't have to start from scratch if something fails (downloading the files is the longest part).

## Step 6: Submit batch script
Just as we did before with the 16S data, we have built up a full batch script to submit and run on the full dataset. We just need to add SBATCH directives as appropriate. I encourage you to do this for the practice, but will also provide the outputs in the next day. Submit this script requesting 12 processes to speed it up.

- Add the following sbatch directives and "shebang" at the top of your batch script, above all the commands.

```
#!/bin/bash

#SBATCH --account=mib2021
#SBATCH --partition=lonepeak-shared
#SBATCH -n 12
#SBATCH -J PreProcessRNAseq
#SBATCH --time=16:00:00
#SBATCH -o <Full_Path_To_Your_Home>/BioinfWorkshop2021/Part3_R_RNAseq/code/PreProcess_RNAseq.outerror
```
Upload your batch script to the code directory as "PreProcess_RNAseq.sh". You can of course call it whatever you like and put it wherever you like. This is just for consistency within the class.

Submit the job, remembering that you have to be on lonepeak to submit a job on a lonepeak partition and notchpeak on notchpeak partition, etc. If you saved o
```bash
sbatch <Full_Path_To_Your_Home>/BioinfWorkshop2021/Part3_R_RNAseq/code/PreProcess_RNAseq.sh
```

## Git and GitHub
- We will now go through Git and GitHub to sync up your project directory on CHPC (`~/BioinfWorkshop2021`) and your local files you hopefully created in last class with an online repository to keep it all in one place.

- **Git** is a version control software that can track changes and facilitate merging of those changes on *a whole project directory*.
  - The terminology can be a bit confusing at first. Don't worry too much if you feel a bit lost. You will get more comfortable with practice and this is meant to just introduce it as with most parts of this workshop.
  - It is mainly geared towards software engineers that are working as part of team to develop software. However, many bioinformatics-focused groups also use it and it is also quite useful even if you only use it with yourself.
  - Useful just by itself on one computer, but most useful when used in conjuction with a "remote" repository, for example hosted on GitHub.

- **GitHub** is one of several sites that hosts Git repositories. Along with Git, really can help you collaborate with others, yourself and share your code.
    - Facilitates documentation and reproducibility.
      - Markdown formatted files can display as a webpage (like this class) to write and describe in natural language and for basic formatting.
    - Host your code for your publication.
    - Sync between multiple remote computers or servers.
    - 100MB repository size max
      - Not for large files. Only the code used or possibly metadata.
    - Repositories can be private at first, then made public later.
    - Can make group or lab pages and transfer repos to them or share with lab.

**Process Overview Image**

**Branches**

### Step 0: First time setup on CHPC
- It is very helpful (and some required) to do a bit of first time setup on CHPC.
- Git is available without a module, but the version is somewhat old. Generally, useful to load the module first (usually fine to do this all on head node, very minimal computation is done).
```bash
module load git
```


### Step 1: Create a new, empty repository on GitHub
- Many different orders to go about this because the whole point is that Git can merge and keep track of changes. However, it is often easiest (and I think easiest to illustrate Git) if we start by making a remote repository on GitHub, and start with it empty.
1. Navigate to GitHub.com and sign in.
2. On top right there is a **+** sign. Click on the +, and "New Repository"
3. Fill in the name. Let's call it "Bioinf2021". The name includes your username so should be available.
4. For now, choose "Private".
5. Leave everything else empty to create a completely new repository.
   - This is mainly for illustrative purposes with your first repo. It is often handy to initializewith the license, .gitignore and README files.
6. Click "Create Repository"
7. Keep the resulting window open for now. It contains useful code chunks, but they may not make yet since we haven't used Git and Github before so we will work through them.

### Step 2: Initialize your repository on the command line and associate it with the remote repository on GitHub
- Git commands take a similar form to what we have seen. `git` is the initial command and then other commands and functions down from there are added. Overall structure looks like:

```bash
git <A_GIT_COMMAND> <OPTIONAL_SUB_FUNCTIONS>  -<OPTIONS>
```

1. Move into the directory of the project you want to create a repository for. For us, this is the parent direcotry of the BioinfWorskhop2021 class.
```bash
cd ~/BioinfWorkshop2021
```
2. Initialize the repository. This creates some Git-specific files within the directory in a hidden `.git` folder. Note, that it is totally fine to have the parent/project directory be named different things in your repo and in different computers. After it is initalized, check the status of your repository. It should show that there are "untracked" files. We haven't added anything to be tracked yet.
```bash
git init
git status
```
3. We first need to add some files to track in the repo. Let's start with a `.gitignore` file and a very sparse readme file. We already have some directories, but let's just use some small files you'd usually include anyways first to illustrate.
   1. The `.gitignore` file specifies (you guesssed it) which files to ignore. It uses regular expressions or you can specify files individually. Everything is relative to the parent / project directory where you initialized your git repo above.
      - Create this file with nano and add the `*.fastq`, `*.fq`, `*.gz`, `*.qza`, `.outerror` to ignore these large files which we don't want to track and upload to GitHub, at least for now.
      - I also usually remove `.outerror` files from my batch scripts to keep the repo clean, but they may contain useful info you want to keep.
   ```bash
   nano .gitignore
   ```
      - Add `*.fastq`, `*.fq`, and `*.gz`, `*.qza`, `*.outerror` on each line and save and close nano (Ctrl+X --> "Yes" to save changes --> Enter)
   2. A file called README.md if present in a folder will attempt to be displayed on the corresponding page on GitHub. Generally, it is in markdown format which we will more easily show in R in an upcoming class. Similarly, create this in nano and add just a title of the repo for now with a pound sign in front (`# Intro to Bioinformatics Tools Workshop 2021`)
    ```bash
    nano README.md
    ```
4. Check the status to see your files are still untracked, then add them to tracking (use autocomplete, Git is really good at using autocomplet in context):
```bash
git status
git add README.md
git add .gitignore
git status
```

5. Set the branch of the repository to be named "main" branch. Branches are mostly used when multiple people or versions are working on the same thing simultaneously. Notice "on branch master" changed to "on branch main". This is a recent change made by git to change from using the "master" terminology, but the installed Git version is still a bit behind so we need to change the name here so it is the same name as the branch on our remote repository on GitHub.
```bash
git branch -M main
git status
```

6. Add the location of the remote repository (on GitHub) so this local repo knows where to send it to. Copy the `<https://<YOUR_REPO_INFO.git>` from the GitHub page
```bash
git remote add origin <https://YOUR_REPO_LOCATION.git>
```
7. Finally, push your committed changes to your remote repository and check them on your GitHub page.
```bash
git push -u origin main
```
- The terminology can be confusing at first and what is upstream/downstream etc. See the helpfiles (`git push --help` for example) for explanantions, but mainly you will find you only use 4 or 5 commands and they will nearly always take the same options (such as `-u` here)
- Check your GitHub page to see that the .gitignore and the README.md file are there. Notice how your title displays on that page which contains the README.md
  - For now, partly to show that you can edit these online but also to illustrate conflicts, open the README.md file by clicking on it and then the pencil icon to edit it.
    1. On the second line, Let's begin a listing of the sections. Add this text (you can just copy-paste it):
    ```
    **Sections of this course:**

    Part 1: Linux

    Part 2: Qiime and 16S Seq

    Part 3: R and RNAseq
    ```
    2. To save it, scroll down to the "Commit changes" section. You must add a brief statement and it is autofilled for you with "Update README.md". Just keep that and hit the "Commit Changes" button.

- You've now made changes to your online/remote repository that are NOT found on your local repository on CHPC. A conflict has emerged.

### Step 3: Continue adding files to track and address conflicts

- Let's add our Part 1 and Part 2 directories and important results to the repository.
1. Add part 1 to be tracked:
```bash
git status
git add Part1_Linux/
git status
```
- Notice how:
  - a) Git ignored the .fastq files because we made a .gitignore file that told it to.
  - b) Git traversed the directory and added any files that aren't supposed to be ignored.
2. Do the same for Part 2:
```bash
git add Part2_Qiime_16S/
git status
```
- We purposefully, did not add the `.qza` files here because they could take up our whole repo. In practice, you may want to add some of them that are particualarly useful such as the table.qza file, but the visualizers (the .qzv) files are *mostly* small.

3. Now stage your changes for commit and add a message:
```bash
git commit -m "Part1 and Part2 initial"
```
4. And, push to the remote repository as before.
```bash
git push -u origin main
```
- **Oh no! Error!** Well that's actually good, as you can see by the message. There are changes we made to our README.md online that's not in our local one on CHPC. We need to address this conflict and update our local first with these changes.

#### Step 3b: Address issuses and incorporate changes from remote repo to local (`pull`)

- In order to incorporated changes we need to "fetch" the remote repo changes, then "merge" them with the local changes.
  - `git pull` is a quick way to fetch and merge because this is so common.
  - Note that if you merge changes git will not delete things that are present in one location and not the other.

5. Pull the remote repo and merge the changes you made to your README.md file:
```bash
git pull
```
- We didn't need to specify the remote origin because we previously set it, but you may need to do this if you had not.
- This wil bring up your command line text editor and require you to input a message similar to when you do a commit to explain the merging.

6. Now rerun the push command. You already committed your changes and these commits are not lost, they just haven't been published or "pushed" to your remote yet. You can check you have this commit as well as the one you did by merging with the status.
```bash
git status
git push -u origin main
```

7. Check your GitHub repo now. For example, look in the folder `Part2_Qiime_16S/results` which is only there if you correctly pushed your files. If you click on, for example, the `table.qzv` file GitHub says it cannot display it. This file is a binary so it won't know how and it is also too large. However, you can download it from there and upload to the qiime viewer site to view.
   - Use this to share smaller results files with collaborators, PIs, etc. or just to include your results in your repo that might not otherwise be suitable for a journals supplement.

- At this point, you have all you need to work well with Git and GitHub. However, using GitHub desktop can also be very useful and helps solidify some of this visually.

### Use GitHub Desktop application to collaborate with yourself and/or easily edit scripts and push to CHPC

- The desktop application can now get a 3rd location (your local laptop/desktop computer) in the mix. I find this most useful just for more easily editing files in Atom and not having to worry about upload/download manually and checking what is where. However, it's graphic interface also helps highlight changes more easily.
- Here, we will also see how well this integrates with Atom.

1. Open GitHub Desktop on your computer and sign in to it with your GitHub credentials
   - Should ask at first setup, or you can go to File --> Options
2.


# Practice / With Your Own Data
- Understand the while loop and commands I used in the optional section shown how to pull the full dataset from the SRA. You don't need to actually pull them all, but load the sra-toolkit and examine options. This can help understand the SRA format.
- Submit and work through any errors that come up with your batch script.
- Upload your own RNAseq data and work through the day's commands. You may need to modify settings depending on your organism and sequencing setup. This is an excellent opportunity to ensure you know each command well.

# Links / Cheatsheets
- Node sharing page on CHPC: [https://www.chpc.utah.edu/documentation/software/node-sharing.php](https://www.chpc.utah.edu/documentation/software/node-sharing.php)
- Salmon page: [https://salmon.readthedocs.io/en/latest/salmon.html](https://salmon.readthedocs.io/en/latest/salmon.html)
- MultiQC tutorial video: [https://www.youtube.com/watch?v=qPbIlO_KWN0](https://www.youtube.com/watch?v=qPbIlO_KWN0)
