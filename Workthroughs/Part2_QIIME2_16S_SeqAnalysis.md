<!-- TOC -->

- [Main](#main)
	- [Requirements](#requirements)
	- [Install QIIME2](#install-qiime2)
		- [Load miniconda module](#load-miniconda-module)
		- [Install QIIME2.](#install-qiime2)
	- [While we wait for Qiime2 installing:](#while-we-wait-for-qiime2-installing)
		- [Why QIIME2?](#why-qiime2)
			- [Installing QIIME2 in a conda environment (finishing up the install)](#installing-qiime2-in-a-conda-environment-finishing-up-the-install)
	- [Documentation, Project Directories and Atom](#documentation-project-directories-and-atom)
		- [Atom](#atom)
		- [Putting it all together. How to build a simple pipeline](#putting-it-all-together-how-to-build-a-simple-pipeline)
		- [A batch script (using bash) for 16S seq processing](#a-batch-script-using-bash-for-16s-seq-processing)
	- [Our First Bioinformatics Project](#our-first-bioinformatics-project)
		- [Step 0: Draw out your methods and project goals](#step-0-draw-out-your-methods-and-project-goals)
		- [Step 1: Setup a Project Directory](#step-1-setup-a-project-directory)
			- [(aside) Find / show project on SRA](#aside-find--show-project-on-sra)
		- [Step 2: Pull sequences with SRA](#step-2-pull-sequences-with-sra)
		- [Step 3: Import sequences into a QIIME2 artifact](#step-3-import-sequences-into-a-qiime2-artifact)
		    - [(optional) Loading the CHPC Qiime2 module](#(optional)-loading-the-chpc-qiime2-module)
		- [Step 4: Trim primers and join sequences](#step-4-trim-primers-and-join-sequences)
		- [Step 5: Denoise with Deblur and create a table](#step-5-denoise-with-deblur-and-create-a-table)
			- [OTUs versus ASVs/ESVs](#otus-versus-asvsesvs)
		- [Step 6: Build phylogeny](#step-6-build-phylogeny)
		- [Step 7: Call Taxonomies](#step-7-call-taxonomies)
		- [Step 8: Cleanup!](#step-8-cleanup)
		- [Final Step: Finish the batch script and submit.](#final-step-finish-the-batch-script-and-submit)
			- [Change the sra-toolkit command to pull all the 16S sequences.](#change-the-sra-toolkit-command-to-pull-all-the-16s-sequences)
			- [Add sbatch/slurm directives](#add-sbatchslurm-directives)
				- [Note on partition, processes and time](#note-on-partition-processes-and-time)
	- [Submit Your Batch Script on CHPC](#submit-your-batch-script-on-chpc)
- [Practice / With Your Own Data](#practice--with-your-own-data)
- [Links/Cheatsheets/Today's Commands](#linkscheatsheetstodays-commands)

<!-- /TOC -->

# Main
Today's Objectives:
1. Finish install of QIIME2 virtual environment
2. Pull sequences from SRA
3. Process sequences through QIIME2 to create table, repseqs, phylogeny and taxonomy.

**NOTE**: The in class session for this markdown only got to importing sequences into QIIME2. We will go very quickly through the remaining portion in next class, mostly I'll just have you copy some result files to move along more quickly. So, if you'd like more practice and a better understanding of 16S seq processing steps go through it more carefully here. Build up the batch script and submitting it for full dataset 16S processsing is a great goal.

## Requirements
- CHPC account and *bash* shell session through preferred connection method (prefer OnDemand)
- Plain text editor installed on local computer (NOT Word!).
	- **Atom**: Cross-platform, nicer interface, more community plugins, a bit slower
		- Managed Software (Pathology Machines) AKA "Github Atom"
	- **BBEdit** (TextWrangler): Mac Only, fast/lightweight
		- Managed Software (Pathology machines) or Mac App Store
	- **Notepad++**: Windows
- Conda Install
	- Miniconda3 (installed on CHPC last time)
	- Anaconda

## Install QIIME2
On CHPC we will first need to load our newly installed miniconda3 module. You'll need to do this, *INSTEAD of using CHPC's module*, everytime you use your own conda virtual. environment.
#### Load miniconda module
```bash
$ module use ~/MyModules
$ module load miniconda3/latest
```
#### Install QIIME2.
Instructions for installing in a conda environment are provided on [QIIME's install page](https://docs.qiime2.org/2020.2/install/)
1.  Make sure conda is updated. Note: may need to activate conda first.
  ```bash
  $ conda update conda
  $ conda install wget
  ```
2. Install QIIME2 with the provided scripts into a virtual environment called "qiime2-2020.2":
  ```bash
  $ wget https://data.qiime2.org/distro/core/qiime2-2020.2-py36-linux-conda.yml
  $ conda env create -n qiime2-2020.2 --file qiime2-2020.2-py36-linux-conda.yml
  ```
This is going to take a bit. QIIME2 has a huge amount of dependencies. These should now (or soon) be scrolling by. If you wanted to truly "manually" install QIIME2 you would have to install all of these! Let's move on while this is installing.

## While we wait for Qiime2 installing:
### Why QIIME2?
If you intend to do any 16S sequencing analysis the answer is obvious, but otherwise might be unclear. Truthfully, mainly I think it is a pretty easy to use program on the Linux CLI so I think it's a good opportunity to practice our skills and build a batch script for, and learn some other things about methods in bioinformatics (like the conda environment we are setting up for it).

QIIME stands for "Quantitative Insights Into Microbial Ecology" so you can guess it's main intent. However, if we take a step back and consider what it's doing, you may notice that it actually could be quite useful for many non-microbial ecology questions as well. Broadly, I break QIIME (and other microbial ecology packages) into 2 groups of functions:
1. Processing of marker genes sequences.
2. Analysis of feature tables.

While QIIME is built around analysis of 16S rRNA gene sequences any single gene sequence could benefit from some of it's tools, in particular those resulting from PCR amplification/detection methods. This could include ITS, 18S or other functional marker genes. It could even extend to things like TCR and BCR sequences, though likely with advent of single cell seq technologies this won't be the case. It also has methods to facilitate phylogenetic tree construction and classification. Most have absolutely nothing to do with microbial ecology specifically, and you'll see that a huge chunk of QIIME2 actually calls functions that wrap around other programs not made for microbial ecological analyses.

Next, a feature table is just a general term for features counts (microbial taxa, genes, traits) by samples. In fact, until recently, we called these OTU tables which was specific to microbial ecology, but it was not lost on many that most of the functions and metrics don't really care what the features are. Many (most?) microbial ecology metrics actually are not ecology specific at all, and often were never developed with this in mind, or even with biology in mind (a lot are from economics originally!). Alpha diversity measures are just counts of features (species) that are normalized or transformed in different ways to reveal different aspects of diversity. The simplest, species richness is just a count of features. You could see gene richness if it was a transcriptome for example. I have used, and often see, Shannon index used for describing repertoire of TCRs or BCRs. Beta diversity metrics are just measures of dissimilarity or distances between samples. Thus, any feature table can benefit from some of the analyses in QIIME2 or other ecological focused software. Whether microbial ecology dataset or not, the user needs to know if the metric/index is appropriate.

We'll talk about some of the other neat features in QIIME2 as we use them as well. For now, let's return to the install if it's done, or find some sequences on SRA if it is not still.

#### Installing QIIME2 in a conda environment (finishing up the install)
  3. (continued) After the install is done, activate your new virtual environment with QIIME2 and test that the installation worked.

    ```bash
    $ source activate qiime2-2020.2
    $ qiime --version
    $ conda deactivate
    ```

Notice how your prompt changed after running the `source activate` command. This shows that you are inside of a separate virtual environment now. Changes you make to your files will still show up and be present, and you are still the same user, but a separate virtual environment sits on top of (kind of) your CHPC environment. No irritating file share folder setup and movement of files between them as in Virtual Box, VMware, etc.

**! If you could not install your miniconda virtual environment and/or qiime2-2020.2 you can follow along with the older module installed on CHPC. It's a little odd right now b/c the message is misleading when tryig to load it (I've contacted CHPC). See how to load this, when qiime needs to be loaded in the later section.**


## Documentation, Project Directories and Atom
I certainly don't intend to lecture other scientists on the importance of documentation here at all. Rather, I want to try to highlight the importance, ease and differences of documentaton while coding. The methods I describe here are one way of doing it, and you will likely find your own eventually. Whatever you do, don't think you can get away with not documenting your code. The cool thing about documentation for bioinformatics is that the method you are performing is being typed anyways, so you are sort of creating your lab notebook at the same time you perform the task. How nice would that be at the lab bench! It doesn't leave much excuse for poor documentation. Though bad organization and references can destroy even the best documentation. You may be able to guess that it's really easy to create A LOT of files fast in bioinformatics. You've probably had a lab project that ballooned and had so many files in it's project directory it became difficult to find a specific file. This problem will be magnified several fold in bioinformatics. So:
- **Make extensive use of directories for organization**
- Start with a "project-centric" organization.

I decided to leave *git* to the end of this course, if we have time. Hard decision because it really would go at this point, naturally, as a great documentation tool. However, I wanted to focus on ensuring we have time to work through some real data and get comfortable in the command line and R. Also, for some reason, it seems tricky for new users and I feel like I may be introducing too much already. If you're at all serious about any coding or bioinformatics, you should get to know git soon. You can use it to publish your own code to a private or public repository (like this!) or just use it locally to keep track of changes (as I mainly do).

Many of you may already have (or attempt) organization by projects in your computer files. This is a great way to organize, and is how you will always see software projects organized. In reality, science is quite different than software engineering and projects more frequently split or merge in unexpected ways, but this should still be your goal and you'll see that a lot of the software we will use expect this type of organization to some degree. Also, if you start out this way, you can copy or move directories to maintain a project centric structure when these splits and merges do happen. Let's introduce Atom as our text editor which also shows how project directory mentality can make it easier to use Atom.

There's 2 easy ways to document your code that we will go over.
1. Comments in your submitted job scripts. This is easiest because you're typing the commands already and the script is your documentation. However, it needs comments to make it useful as a "notebook" others can make sense of.
2. Markdown. This looks nicer and easier to browse if used properly. We'll use it in R and show it for Linux commands when we are working interactively for analysis.

### Atom
Really any plain text editor can be used to facilitate your documentation. I have recently come to like Atom for it's easy add-in/package manager and pleasing format. I really just want make sure we are all using the same editor for simplicity though and Atom is cross-platform. Frankly, I actually prefer BBEdit, but it's only available on Mac currently. Atom has many possible add-in/extension/packages provided by the community which makes it super useful. We'll add a couple packages shortly.
- Open Atom and open a folder on your computer (`File -> Open Folder...`). Let's say just your Documents folder at first. This shows again the Project directory centric mentality as the sidebar lists all the files in this folder, and even labels this sidebar "Project"! You can easily open other files in your project directory with a click. They should open in new tabs in Atom by default. Nice, but this is just to illustrate Atom's behavior.

We will return to atom frequently, and use it to build our scripts and to document our code. Keep it open.

### Putting it all together. How to build a simple pipeline
Now that we understand differences between interactive and batch/non-interactive jobs and have learned more about CHPC, you may start to see how you might put together a pipeline that could be run through batch submission. A common process goes like this:
1. Work with a small subset of data in an interactive session to test out commands.
2. As you get each command working, copy the working commands to a new file in the order they will run. This will be your batch script.
3. Add the required SBATCH directives and submit the job to the slurm scheduler on CHPC.

Let's follow this process, and start with a file to copy the commands to.

### A batch script (using bash) for 16S seq processing
Remember, "bash" is the shell we are using. So, in order to have these commands interpreted when submitted as we are doing interactively, we need to specify in our script we want "bash" to do the interpreting. This is accomplished in the first line of our batch script.
1. Open a new file in Atom and save it with the .sh extension to a project folder on your local computer. The .sh extension will let atom know it is a shell script, letting Atom highlight syntax in a relevant manner.
   - Let's call it "PreProcess_16S.sh"
2. Add this text to the very first line to indicate it should be read by bash
```bash
#!/bin/bash
```
Notice how this is the same as we use in the `srun` command, but it has the 2 characters `#!`. This is called a **shebang** and directs what program should interpret it. If this was a python script, for example, you would add the path to python after the `#!` for example. We are working in bash for this course.

3. As we build up commands in succession in the following interactive session, copy your commands to this file. This will then serve as your template for your batch job submission. As it's really a bash script, it could be run on any computer with the required programs. We just add SBATCH specific options (aka "directives") to it later to make it work on CHPC with the slurm scheduler.
4. As you add commands, add comments about what the commands do, expected inputs or anything else you like. To do this, just preface the comment with a `#`. These lines won't be interpreted by the program. Every language has such a comment character. Thankfully, for both bash and R it is the `#`.

Now, for submitted bash scripts you have documentation and the script in the same place. Make useful comments for good documentation! For interactive work (no submitted script) we'll use another method to document what we are doing.

You may ask why we use Atom locally and not the built-in text editor Nano. Well, this is actually a good idea. I'm just having you use Atom because it's easier to keep a different window open in another program and may be an easier setup to document while working on command line too.

## Our First Bioinformatics Project
Now that we've finally learned a whole bunch of Linux commands and created a nice bash shell environment, we will work through a dataset to get practice and reinforce some of these commands, as well as learn a really useful software package for microbiologists (and others really). We will work for the rest of this part on a 16S sequence dataset within QIIME2.

### Step 0: Draw out your methods and project goals
Of course, this step is technically optional, but it is always a good idea to ensure you know where you are heading, what tools you are using and are focusing your analysis. There's so many bioinformatics tools and methods to analyze sequences that you can really just find yourself floundering around creating potentially neat outputs that just aren't moving towards your project goal. Since this may be your first 16S microbial community analysis it is also helpful for me to show what we are trying to accomplish:
![Sequence_Preprocess_Overview](https://drive.google.com/uc?export=view&id=1S5wm0LPxPYwbLyuDWnoBktmA6fSH0e9e)

### Step 1: Setup a Project Directory

**IMPORTANT: From here until we move to interactive analysis (except where noted), copy all working commands to your "PreProcess_16S.sh" script**. This will help you build a submittable batch job script.

Besides just being a good idea to set out your method, your outline can help you make a good directory structure upfront. It is helpful to avoid moving directories and results around in a project because if you do, you're job scripts or markdowns will no longer work or refer to the proper files. So, starting out with a good directory tree is helpful to keep any directory from beginning too unwieldy and tempting you to move things around.

- Create your project directory
```bash
$ mkdir -p ~/BioinfWorkshop2020/Part2_Qiime_16S
```
- Make a `jobs` directory within that where we will eventually put our job submission script. I like having this separate because I'll save the outputs there as well, which can sometimes build up if a lot of troubleshooting is required.
```bash
$ mkdir -p ~/BioinfWorkshop2020/Part2_Qiime_16S/jobs
```
- Make a `metadata` directory as well to hold metadata and lists.
```bash
$ mkdir -p ~/BioinfWorkshop2020/Part2_Qiime_16S/metadata
```

- Make a scratch space and set variables for your scratch and working directory.

It's easy enough to refer to these directories all the time when working interactively, but setting them as variables will make your script a little more readable and easier to use later as templates if you wish. Also, good variable practice and makes it easier for me to refer to them across the class which may have them in different locations. Make sure to add your uNID (or other name) for your scratch directory.
```bash
$ SCRATCH=/scratch/general/lustre/<YOUR_UNID>/Part2_Qiime_16S
$ mkdir -p ${SCRATCH}
$ WRKDIR=~/BioinfWorkshop2020/Part2_Qiime_16S
$ ls ${WRKDIR}
```
It's worth noting that it is generally safer to instead use absolute paths when setting directories and file names as variables. The `~` in this case should work, but as you start passing these to different environments (virtual env) it may lead to unexpected behavior. Similarly if relative to your current directory, the variable won't behave as expected as you move around. Also, we built this up interactively so made the directories first. This will work so long as we are exact in our typing, but if you flip it around and instead define the directory as a variable first, then `mkdir` it, this will ensure that directory exists and commands that need it will run, even if you mistyped.

#### (aside) Find / show project on SRA
I'll go through this because I'm often asked how to pull SRA datasets. It's incredibly easy now, but the sra-toolkit has some historical terminology that makes it seem more confusing than it is. I'm not trying to spend time showing you how to browse some website's interface, as this type of thing is always changing, but still will walk through this to show *one way* of pulling an SRA-hosted dataset and make sure we are all on the same page.

NCBI, The National Center for Biotechnology Information, includes everything from PubMed to chemical and sequence repositories. Many of you have probably already published a paper in which the authors were required to deposit sequences at the NCBI or some other public repository. This was likely also accomplished with the SRA-toolkit, though you still may never need to do it yourself. It used to be a bit of catch-all for raw sequecnes, and was more difficult to make use of anything there becasue of a frequent lack of associated metadata. Now, sequences are required to be associated with BioSamples and BioProjects, making them much more easy to both search and tie metadata to in common formats across NCBI. The structure looks something like this:

- **BioProject** (sometimes an "umbrella" BioProject can encopass >1 BioProjects):
  - *BioSample 1* [with sample metatdata]
  - *...*
  - *BioSample N*
    - SRA deposited Illumina NovaSeq RNAseq reads (for example)
    - SRA deposited Illumina MiSeq 16S reads (for example)

First, let's find a SRA deposited dataset of interest. The SRA has a neat new interface that makes this much easier, called run selector. I've already found one that is a neat example for this class because it has paired 16S and RNAseq. It is BioProject [PRJNA434133](https://www.ncbi.nlm.nih.gov//bioproject/PRJNA434133). If you follow this link and click on the number next to "SRA experiments" it takes you to the list of all SRA entries for the project. Click on the link at the top that says "Send results to Run selector". You can see this is a more useful interface allowing clearer filter of samples. For now we just want to get a couple of this project's 16S sequence files to develop our pipeline. You can explore the website to understand it's use better, but since this isn't the point of this course I'll leave this up to you and just provide the accessions list for you later when we get to the whole dataset. To show the example though follow this procedure to get the accessions and their associated data.
1. Click the checkbox next to 2 entries with the assay type "AMPLICON". These are 16S amplicons for this project. Doesn't matter which 2 as these are tests, but number 2 and 3 are a bit smaller than the first so I grabbed those.
2. Click the switch above the selected entries that says "Selected". The links under download are updated in the "Selected" row to only download data for those 2 entries.
3. Click on the "Metadata" button under "Downloads" on the "Selected" row. This downloads the metadata locally. Save the file as it's named, but add `_test` to give the filename `SraRunTable_test.txt`.
4. Do the same for "Accessions List", to give the filename `SRR_Acc_List_test.txt`.
5. Upload both these files from your local computer to the metadata directory we created (`~/BioinfWorkshop2020/Part2_Qiime_16S/metadata/`). Use OnDemand's file explorer (you can just drag them into that folder) if possible.
   -  If you are having trouble uploading them you can just copy them from my workshop space on CHPC:
   ```bash
   $ cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part2_Qiime_16S/metadata/*_test.txt ~/BioinfWorkshop2020/Part2_Qiime_16S/metadata/
   ```

Now we can use these with SRA toolkit and qiime to pull the sequences from the SRA and analyze them in qiime with the associated metadata.

### Step 2: Pull sequences with SRA
Now, we are ready to pull our sequences. We will use the newer command from SRA-toolkit called `fasterq-dump`, which really simplifies the whole process. I encourage you to look at the help file for it to examine these options. We are setting the output and temporary locations to $SCRATCH because they can be big files. Here, it's only 2 smaller ones, but we are trying to build up a submittable script with bigger and more files. Here, you could just enter the command twice for each accession number we pulled, but let's use it as an opportunity to practice the for loops. Note, this is actually better suited for a while loop to read form the file, but currently I leave that for an exercise to understand while loops. Move to SCRATCH first since the files pulled can be large.

```bash
$ module load sra-toolkit
$ cd ${SCRATCH}
```

```bash
$ for accession in SRR10501757 SRR10501758
$ do
$ fasterq-dump ${accession} -e 2 -t ${SCRATCH} -O ${SCRATCH} -p
$ done
```

### Step 3: Import sequences into a QIIME2 artifact

First, we will need to load our modules on CHPC and load QIIME2. This is repeated here from above just so that you make sure to work it into your bash script "PreProcess_16S.sh". You should have deactivated your QIIME2 envrironment after the install. If not, it may interfere with the fasterq-dump command. Reactivate the environment and make sure to add the commands to your bash script.

```bash
$ module use ~/MyModules
$ module load miniconda3/latest
$ source activate qiime2-2020.2
```

#### (optional) Loading the CHPC Qiime2 module
**! If you could not install your miniconda virtual environment and/or qiime2-2020.2 you can follow along with the older module installed on CHPC. It's a little odd right now b/c the message is misleading when tryig to load it (I've contacted CHPC), but it should load properly like this. Only use the following command if you are using this older module!**
```bash
module load anaconda3/2019.03
source activate qiime2-2019.4
```

### Step 3: Import sequences into a QIIME2 artifact (continued)

Qiime2 uses it's own unique format of files, which they call **artifacts**. They are a pain to just view files because they are binaries, but they are really a neat solution to the build up and difficulty of file tracking. They allow so-called "provenance" tracking, or tracking the origin and functions performed on each file. This is really great for documentation, and really pushed me to loving QIIME. They even provide a reference for the functions you used! Cool. We'll look at this later but, for now, just know you can't operate directly on raw fastq files in QIIME and instead need to import them as QIIME2 artifact files. Make sure your QIIME2 environment loaded. If not, or you had unresolvable problem with the install, use CHPC's module instead (`module load qiime2/2019.1`).

Qiime2 has a few different ways to import files and I'll leave it up to you to look at their documentation. We will use the "**manifest**" file format, which takes an input manifest file that lists the location and orientation of the input fastq files. It's pretty easy to create in a spreadsheet program, along with commands you have learned like `pwd` to get file paths. Let's practice some of our newfound linux skills to make this table "on the fly".

- First, create the header line for the file. It is a comma-separated value file. Save the output to metadata folder where manifest file should probably reside

```bash
$ echo "sample-id,absolute-filepath,direction" > ${WRKDIR}/metadata/manifest.txt
```

Now that you see the columns expected, let's create an entry for each file using a for loop. It's a good idea to use `echo` command without directing the output to your file at fist, in order to check the output is as expected first. In class we will build this up piece-by-piece.

The `%` after a variable name, when inside `{}`, says to strip the characters after the `%` from the variable. Theirs a bunch of really useful little tricks  like this for string variables in Unix. Here's a great page explaining a few simple ones with sequence file usage examples: [http://www.metagenomics.wiki/tools/ubuntu-linux/shell-loop/string-split](http://www.metagenomics.wiki/tools/ubuntu-linux/shell-loop/string-split).

```bash
$ for read1 in *_1.fastq
$ do echo "${read1%_1.fastq},${SCRATCH}/${read1},forward" >> ${WRKDIR}/metadata/manifest.txt
$ done
```

Now, do the same for read2:

```bash
$ for read2 in *_2.fastq
$ do echo "${read2%_2.fastq},${SCRATCH}/${read2},reverse" >> ${WRKDIR}/metadata/manifest.txt
$ done
```

We'll save it for an exercise to figure out how you could do this all in one loop instead of 2.

Checkout the manifest file format with head, or import it into excel to see how you just made a nice table. If you couldn't get this working, it's okay, you can copy the output of this section from me later so that you can move forward with the rest of the course. I can't give you a manifest file though because the filepaths refer to your specific filespace.

Now, use the qiime command to import these sequences. This first import tends to go pretty slowly unfortunately. Also, remember I'm going to use the backslash `\` when writing long commands so they can be shown over multiple lines, but the last line won't have it so that the final `enter` finalizes the command. First move to your SCRATCH space just to make the file listing shorter for me.

- First, bring up the qiime help file (don't put this in your bash script): `qiime tools import --help`. Also, note your autocomplete should work with qiime options, but only if they are all entered on the same line. This is very handy, but know that it is a feature qiime2 devs added in, so don't expect it for other software necessarily.

```bash
$ cd ${SCRATCH}
```
```bash
$ qiime tools import \
 --type 'SampleData[PairedEndSequencesWithQuality]' \
 --input-path ~/BioinfWorkshop2020/Part2_Qiime_16S/metadata/manifest.txt \
 --output-path seqs_import.qza \
 --input-format PairedEndFastqManifestPhred33
```

After that is done, you now have a QIIME2 artifact file that contains your sequences. We'll keep your sequences for now, but don't forget to clean up if needed later.

If you couldn't get the manifest file going (or just don't want to wait for import to finish), copy this output from my group directory to your scratch space so we can move forward (**Don't put this in your bash script**): `cp  /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part2_Qiime_16S/seqs_import.qza ${SCRATCH}`

Let's create our first visualizer in QIIME2. We will use the `demux` plugin for this:

```bash
$ qiime demux summarize \
  --i-data seqs_import.qza \
  --o-visualization seqs_import.qzv
```

Copy it back to your working directory. These visualizers are generally pretty small and create a graph of various outputs, so are worth keeping anyways, but also you probably don't have scratchspace through OnDemand file explorer or mounted.

```bash
$ cp seqs_import.qzv ${WRKDIR}/seqs_import.qzv
```

Now, download that file from CHPC to your local computer, then drag and drop it to qiime's visualziation page: [https://view.qiime2.org/](https://view.qiime2.org/). Click on the tab for "Interactive Quality Plot" near the top left of page. You can see these are paired-end 150 nucleotide sequences. The quality is quite nice for 16S sequences. You always see a pretty good drop in quality near ends, especially of read 2. Let's do some trimming.

### Step 4: Trim primers and join sequences
These parts differ if you are using DADA2 for denoising. We are going to use Deblur here mainly because it's fast. Some folks feel strongly about one or the other. I think they both have advantages and drawbacks. You'll have to do your own research or buy me a coffee/beer and we can talk more.

Because these are amplicon sequences they have primers at the front. As these were put their by PCR, they represent a technical artifact and we don't want these parts of the sequence to influence phylogenies or taxonomies. Here QIIME2 uses cutadapt to trim the primers. Cutadapt is a commonly used program for removing adapters/primers and is notably also installed as  a module on CHPC and has a number of useful options.

I've provided the primer sequences in the command here, but notice that these are part of the metadata that we downloaded from the SRA. Note the `-p-cores` option sets the number of processes to start. We only have 2, but on a full job submission on a single node you can run many more and go much faster. It's a good idea to put a variable for this for each script so you don't need to change it for each command.

```bash
$ qiime cutadapt trim-paired \
  --i-demultiplexed-sequences seqs_import.qza \
  --o-trimmed-sequences seqs_trim.qza \
  --p-front-f GTGCCAGCMGCCGCGGTAA \
  --p-front-r GGACTACHVGGGTWTCTAAT \
  --p-cores 2
```

Now, we will join the paired end sequences with vsearch. Note, If using DADA2 you wouldn't join the sequences first. `vsearch` again, is a separate program that QIIME2 is wrapping. I like to keep the verbose option here because it prints useful data to screen that is helpful for troubleshooting and explains why my reads may or may not be merging. I tend to take a somewhat permissive approach at this stage with the options and let the deblur denoising do the main "denoising"/filtering. Most options from this section are specific to your sequencing strategy and sequencing run quality.

```bash
$ qiime vsearch join-pairs \
  --i-demultiplexed-seqs seqs_trim.qza \
  --o-joined-sequences seqs_trim_join.qza \
  --p-minmergelen 150 \
  --p-maxdiffs 10 \
  --p-allowmergestagger \
  --verbose
```


Let's again also get a visualizer and summarize the output:
```bash
$ qiime demux summarize \
  --i-data seqs_trim_join.qza \
  --o-visualization seqs_trim_join.qzv
```
```bash
$ cp seqs_trim_join.qzv ${WRKDIR}/
```

Notice in the visualizer how some of the sequences drop out after 214 (mouse over the graph). So, of the 10k seqs randomly subsampled for this graph, some are not that long. This is usually the safest place to trim your sequences in the next section, but partly just represents real variation which you may not want to remove. We actually only loose 2 sequences out to 250, so trimming that full 36 bases would be a waste of a lot of sequence info. However, also note that at the very end there are only 1 or 2 seqs that are longer. This part always requires inspection for your sequencing project to determine the appropriate trim length to pass to denoising algorithm. With DADA2 the process is a bit different, but still requires inspection of sequence quality plots at one point, so generally 16S seq preprocessing should not be fully automated.

### Step 5: Denoise with Deblur and create a table

After inspecting the sequence plot, let's move forward with denoising in Deblur. I often use a second filter here (`quality-filter q-score-joined`), especially if seqs are of lesser quality, but these look good and frankly this method is really slow and not totally necessary so I'm going to move forward with denoising.

This is the core of what I call the "sequence preprocessing" part, and it can take quite a bit of time, so let's get it going while we talk about it. You really just need to pass the `p-trim-length` option you determined from inspecting the joined sequence quality plots.

```bash
$ qiime deblur denoise-16S \
  --i-demultiplexed-seqs seqs_trim_join.qza \
  --p-trim-length 250 \
  --p-jobs-to-start 2 \
  --o-table table.qza \
  --o-representative-sequences repseq.qza \
  --o-stats table_stats.qza
```

It's worth spending some time to look at the help file for this command and think about your own particular experiment. The defaults may not be appropriate for each option, so be careful here. You can certainly imagine how some of these absolute read number counts could have a very different impact depending on depth of sequencing of an experiment. In general though, they aren't too bad. For most of us, that rare variant that is only present in one sample is going to be too hard to work with anyway, even if it was real. However, removing rare species can have a HUGE impact on some alpha diversity metrics, so ecologists, in particular, should be aware of what's going on here.

#### OTUs versus ASVs/ESVs
You may have heard the term OTU before for microbiota work. Until recently we would be creating an "OTU" table at this step. Now we create an ASV/ESV table. I'll use the term ASV as I think it is slightly more appropriate.

- **OTU**: Operational Taxonomic Unit. Clusters of seqs at some % similarity.
- **ASV**: Amplified Sequence Variant (or ESV - Exact Sequence Variant)

To boil this change down simply, OTUs lost a lot of information because they are clustered at some % similarity (usually 97%) and a representative sequence is then chosen. There are a number of different ways to create clusters though, and then a number of different ways to choose the representative (most abundant? best quality? most representative?). None of the methods is "perfect" in representing the underlying species. By their very nature clusters are an approximation. However, the justification for a long time was (at least) 2-fold. First, 97% similarity of 16S was sort of agreed on as a decent approximation of species across the bacterial phylogeny; 99% as strains 93-ish% as genus and so on with increasingly worse approximations. Remember **phylogeny IS NOT EQUAL TO taxonomy**. Unfortunately, it's closer to reality in some places of the phylogeny and much worse in others, and this varies depending on the 16S region you are looking at. Second, the justification was that these sequences were necessarily very noisy, so clustering them could get rid of some of this, preventing a single nucleotide difference from being a different species, and at the same time reducing size of the table and compute time. Eventually people started arguing that we could get strain-level resolution if we clustered at 99% instead. This is just "kicking the can down the road" because it still ignores the real biology of life and the fact that the difference between a species or strains (or any other taxa difference really) are artificial constructs anyways. But, it does beg the question, why throw away potentially discriminating information? And that's exactly why ASVs have become the general method of choice now. We acknowledge deficiencies in taxonomic definitions and retain as much information as possible, while still employing sequence-level denoising. This is all still a bit of an oversimplification, again due to the nature of this as a workshop not a course, but it's worth noting and thinking about because it is critical that you understand that **the features in this table DO NOT REPRESENT SPECIES**. They never did with OTUs either, but now we just call these "feature tables" instead of OTU tables to further solidify and also because they could hold any type of "feature". Many microbial ecologists especially had thought about this for a long time before this, but here's a nice paper discussing the change if you are interested in further reading: [ESVs should replace OTUs](https://www.nature.com/articles/ismej2017119)

```bash
$ qiime feature-table summarize \
 --i-table table.qza \
 --o-visualization table.qzv
```

And make handy representative sequence file that will send each sequence into BLAST as well. This is simple but I think pretty neat and could be VERY useful for other projects outside of 16S. :

```bash
$ qiime feature-table tabulate-seqs \
--i-data repseq.qza \
--o-visualization repseq.qzv
```

Make sure to copy the table and representative sequences to your working directory when done. These are key outputs:

```bash
$ cp table.qz[av] ${WRKDIR}
$ cp repseq.qz[av] ${WRKDIR}
```
Did you see what I did with the table files there? Remember regex?

### Step 6: Build phylogeny
Again, QIIME2 is not the actual code building the phylogeny here. It is, instead, wrapping other functions to do this and, in this case, making a pipeline for making a phylogeny from sequences. There are a number of methods once could use to do an alignment and then build a phylogeny. In this command QIIME2 will align sequences, apply a mask to some of those aligned positions (highly conserved bits, especially all gaps) and then build a phylogenetic tree. So, this is great to do this all in one command instead.

We build phylogenies in 16S seq analysis because they allow a unique type of measure of diversity between communities ("beta diversity"). The measure that has really taken over is called UniFrac, and measures the unique fraction of phylogeny between communities. So, instead of each species (ASV really) contributing equally to a measure of difference between samples, different species found in different samples that are more distantly related will contribute more. A sort of weighting by relatedness. It's a cool concept that stems from the notion that things more closely related are more likely to share similar functions. As a pretty extreme example, consider *E. coli* and *Salmonella enterica*. Sure, they are fairly different functionally in the world of immunology and pathology, but not nearly as differnt as are *E. coli* and the Archaeal species *Methanobrevibacter smithii*. So, the contribution to the differences between 2 communities (beta-diversity) should probably be greater in the case where one community has *M. smithii* and one does not, than when one community has *S. enterica* and one does not. Since we need to know these relationships we need to calculate a phylogenetic tree. At least currently, this is still usually done *de novo* each time.

```bash
$ qiime phylogeny align-to-tree-mafft-fasttree \
--i-sequences repseq.qza \
--o-alignment aligned_repseq.qza \
--o-masked-alignment masked_aligned_repseq.qza \
--o-tree tree_unroot.qza \
--o-rooted-tree tree_root.qza
```

I just create a rooted and unrooted tree upfront because some functions require a rooted tree, but really we don't have a known outgroup in our phylogeny so the rooted trees have an arbitrary root.

```bash
$ cp tree*.qza ${WRKDIR}
```

### Step 7: Call Taxonomies
The last step before we start to use more community-level analytical tools to examine differences between samples, is to call phylogenies. The choice of taxonomy reference and method has a tremendous impact on the named species in your community. This is a circular statement, so should be obvious (i.e. species names are a taxa). However, a lot of people look at the inconsistent taxonomic calls and throw their hands in the air and say none of this stuff works and there's nothing useful here. The problem isn't the methods, or even really the taxonomies. The problem is that taxonomies aren't real! We can always improve on them to get better relationships, but they continue to be categoricals we put species into and this will never properly reflect evolution over long time scales (never say never...?). I love this subject so will end here, but suffice it to say your choice of taxonomic classifier and reference makes a big difference. While everyone wants a taxonomy to talk about, this is (in my opinion) where these methods are actually the least useful. You don't have to use taxonomies at all to describe communities though.

For taxonomic calls in QIIME2 we need a trained classifier. This can be done in just a couple steps, but can take awhile and only needs be done once. It's also been shown classifiers work better if the input is trimmed to the region of the query (what you amplified). I've already done this for you and provide the classsifier. Just make a variable reference to it for simplicity. This one is trained on the Greengenes taxonomy and reference set.

```bash
$ CLASSIFIER=/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part2_Qiime_16S/gg_13_8_515F806R_classifier_sk0.22.1.qza
```
Now, run the classifier. Here we will use sci kit learn. Interestingly, because machine learning is so concerned with the problem of classification, classifiers are getting better and better and really this doesn't matter much that these are biological sequences. Computer scientists have been working hard on classifiers for quite awhile now and continue to do so. Biologists are benefiting in many ways including improved taxonomic classification of sequences.

```bash
$ qiime feature-classifier classify-sklearn \
--i-classifier ${CLASSIFIER} \
--i-reads repseq.qza \
--o-classification taxonomy.qza \
--p-n-jobs 2
```

```bash
cp taxonomy.qza ${SCRATCH}
```

### Step 8: Cleanup!
While scratch space is cleaned regular, it's still not limitless and the entire campus+ is using it with massive datasets. Make sure you clean it when you are done. I'd also note, usually it makes more sense to actually copy all your files you want to return at this step. I only did it after each step because I don't know how fare we will get in class.

```bash
$ rm *.fastq
$ rm *.qz[av]
```

**IMPORTANT: Stop copying commands to your bash script, unless noted**

### Final Step: Finish the batch script and submit.
At this stage, you should have a full pipeline that takes input seqs and outputs a feature table, representative sequences, phylogeny and taxonomy. Nice! You know it works because you tested it out, so you can now extend it to the full 16S sequence dataset. But this will take a bit longer to run (mostly just the pulling of the sequences actually), so we will submit it as a batch job script as CHPC is intended. If you've been adding your commands as you were supposed to you are mostly ready for submission. 2 tasks remain.

#### Change the sra-toolkit command to pull all the 16S sequences.
I'm going to provide you with a `while` loop for this and leave it to as an exercise to understand it further. Normally, you are going to have your own sequences in a single directory already. You'll also need the full accessions number list so copy this over and place in your metadata folder:

```bash
$ cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part2_Qiime_16S/metadata/SRR_Acc_List_full.txt ~/BioinfWorkshop2020/Part2_Qiime_16S/metadata/
```

Replace the for loop with this while loop. I leave it for exercise to look up and understand while loops, but they are similar to for loops. Instead of giving a discrete list, `while` operates while a condition is true. This condition could just be the presence of items in a list, as here.

```bash
while read line
do fasterq-dump ${line} -e 2 -t ${SCRATCH}
done < ~/BioinfWorkshop2020/Part2_Qiime_16S/metadata/SRR_Acc_List_full.txt
```

#### Add sbatch/slurm directives
Normally, any line that starts with a # in a bash script would be a comment, but for slurm processed bash scripts if the lines at the beginning start with a `#SBATCH` (sbatch directives) they will be interpreted by slurm to provide the options required to schedule your job. These are the same options (plus some) that you used for `srun`! One of the other cool bits about OnDemand is that they have some of these templates for you already and you should check them out. For this first sbatch submission, I'll just provide those you should add and tell you about them. Add the following lines at the beginning of your script, after the first line containing the shebang (shown for clarity, don't enter it twice)().

```bash
#!/bin/bash

#SBATCH --account=MIB2020
#SBATCH --partition=lonepeak-shared
#SBATCH -n 2
#SBATCH -J Q2_PreProcess16S
#SBATCH --time=10:00:00
#SBATCH -o <YOUR_ABSOLUTE_PATH_TO_HOME_HERE>/BioinfWorkshop2020/Part2_Qiime_16S/jobs/PreProcess_16S.outerror

# your commands begin here..
```
- The `-o` option specifies a file to save the standard output to. By default sbatch actually combines standard eror and standard output, hence the extension I like to add, but you can add any extension you want as well. It usually makes sense to name this at least with the same name as script it came from
- `-J` is the jobname that it will be under when you view the queue.

##### Note on partition, processes and time
Unless you go back and change everytime you referred to number of processes (or better yet use a variable for it), there's no sense in taking more than 2 processes. Be nice! Your job will take awhile with only 2 processes, but will finish. Feel free to change this though if you like. Notice we did not include the `--reservation` option this time. Our reservation is only Tues-Thurs. In regards to time, standard limit on CHPC is 72 hours, but there are ways to run longer. If you request really long you may wait longer in queue though. CHPC has a formula that determines your job priority. Generally, the less resources/time you request the sooner you will run.

## Submit Your Batch Script on CHPC

**Note to Windows Users**: If you used a text editor in Windows to make your sbatch script, you probably have Windows line endings and need to make sure you have Unix line endings before submitting to slurm scheduler. In Atom, at the bottom-right there is a "CRLF". If you click this you can then choose to change to "LF" then save the file and it wil have Unix line-endings. In BBEdit, there is a similar functionality in one of the small arrow dropdowns along the top or bottom (though I forget exactly where it is).

```bash
$ sbatch ~/BioinfWorkshop2020/Part2_Qiime_16S/jobs/PreProcess_16S.sh
```

If that submits properly (your sbatch directives are correct) you will receive a number telling you your job number. Use the `squeue` command to see the status.

```bash
$ squeue -u <YOUR_uNID>
```

- If your job fails, open the `~/BioinfWorkshop2020/Part2_Qiime_16S/jobs/PreProcess_16S.outerror` to figure out why, fix issue and repeat.
  - **DEBUGGING**: Start with first error!!

# Practice / With Your Own Data
- Your main objective should be to get the sbatch job submitted and running on the full SRA 16S dataset.
- Use string split commands to make a manifest file in one single for loop instead of 2 loops like we did here for read 1 and read 2. Hint: see the other string split commands on the linked page. There's several ways to accomplish this.
- Research the `while` loop method yourself and play with it to better understand it's function.

# Links/Cheatsheets/Today's Commands
- A cool little refernce page on variable back references / string splits: [http://www.metagenomics.wiki/tools/ubuntu-linux/shell-loop/string-split](http://www.metagenomics.wiki/tools/ubuntu-linux/shell-loop/string-split)
- Why ASVs: [https://www.nature.com/articles/ismej2017119](https://www.nature.com/articles/ismej2017119)
- Qiime2 Plugins Documenation: [https://docs.qiime2.org/2020.2/plugins/available/](https://docs.qiime2.org/2020.2/plugins/available/)
- Today's New Commands:
  - `while`: A loop that performs commands "while" some condition is true.
