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

#### II. Build and Submit a Batch Job Script to CHPC

### Requirements and Expected Inputs
- CHPC connection and interactive shell session
- QIIME2 install in Conda virtual environment or CHPC QIIME2 module
  - Note that some commands may differ slightly if you use the older CHPC module.
- Atom or other plain text editor.
- **Expected Inputs**:
	- Working Directory: `~/BioinfWorkshop2021/Part2_Qiime_16S/`
	- Scratch Directory: `/scratch/general/lustre/<YOUR_uNID>/Part2_Qiime_16S/`
	- Test sequences pulled from the SRA as a QIIME2 artifact: `seqs_import.qza`
	- Copy from shared dir to your scratch space if you didn't import last time. Make sure to change this command to add in you uNID:
  	```bash
		cp \
		/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/test_set/seqs_import.qz[av] \
		/scratch/general/lustre/<YOUR_uNID>/Part2_Qiime_16S/
		```

## Review

- When a command doesn't work for you, please give the error or output received. It's hard to troubleshoot "it didn't work".
  - Use up and down arrow to get your command history and tab-autocomplet to check you didn't just spell a directory or command wrong (most common error).

- CHPC's OnDemand File Explorer review.

We are working interactively with a smaller dataset first to test out our commands, but ultimately we are trying to build a batch script that can be submitted and run non-interactively for the full dataset. The overall structure of a batch script will usually look something like this (will add number 1 at the end):
![General Batch Script Process](https://drive.google.com/uc?export=view&id=1OmDxGQeS2wpe6I6B6Dtoin0xxqCvBqGw)

- We went fast through the for loops that setup the "manifest" file. The manifest file is just a comma-separated file with the sample-id, location of the sequence files and the direction. I'm sure you could set this up without much bioinformatics in Excel (though that approach is error prone), but it was a great excercise to test what you have learned. If you can understand the whole loop you will be very well set on Linux, but it's not a big deal at this stage if you don't. It's intended as an excercise. Let's just talk briefly about the different components of it:
```bash
for read1 in *_1.fastq
do
  echo "${read1%_1.fastq},${SCRATCH}/${read1},forward" >> ${WRKDIR}/metadata/manifest_test.txt
done
```

## 16S rRNA Gene Amplicon Sequencing Background

### Sequencing Strategy
It may be helpful to understand how these sequencing libraries are prepared so you get the preprocessing that is happening here today. This is a pretty typical strategy, but many variants exist.
![16S Seq Strategy](https://drive.google.com/uc?export=view&id=17lkN-vVCJwENVdmHgYfSljE3N5JTPBeU)
- The impottant part to note is that the primers used to amplify the product are often sequenced as the first part of Read1 and Read2. These should ALWAYS be removed first.

### 16S sequence process workflow
![Sequence_Preprocess_Overview](https://drive.google.com/uc?export=view&id=1S5wm0LPxPYwbLyuDWnoBktmA6fSH0e9e)

## Setup our Previous Environment
- Because we stopped part way through the sequencing processing and now have a fresh shell environment, we need to setup the variables again and load QIIME2.
  - Directories previously created will remain permanently until you delete them.
    - Scratch space is the exception. Shared and regularly cleaned.
  - Variables you create each session are NOT maintained.
  	- Unless you put them in a file that is sourced at startup such as `.bashrc` or `.bash_profile`. Usually not desired.
- Use the commands we saved to our batch script in Atom to quickly copy over your commands, recreate the variables, load QIIME2 and change to the scratch direcotry.
  - **Replace `<YOUR_uNID>` where needed!**

```bash
SCRATCH=/scratch/general/lustre/<YOUR_uNID/Part2_Qiime_16S/
# mkdir -p ${SCRATCH}
WRKDIR=~/BioinfWorkshop2021/Part2_Qiime_16S/
```
Remember that we installed a separate miniconda3 module so we must load this first then QIIME2. We will use this set of commands frequently:
```bash
module use ~/MyModules
module load miniconda3/latest
source activate qiime2-2020.2
```
**ONLY IF you didn't get the conda environment setup previously, use the CHPC installed module** (only use the above command OR the below command)
```bash
module load anaconda3/2019.03
source activate qiime2-2019.4
```

## Continue our First Bioinformatics Project

- Remember to copy over working commands to your batch job script.
  - Remember to add comments frequently with the `#` character.

- To continue from last step, let's first look at the sequences that we imported using the QIIME2 visualizer file that we made from them (the file that ends in .qzv).
  - In your OnDemand File Explorer window (or Finder if you mounted CHPC)
    1. Find the `seqs_import.qzv` file in your scratch space and download it to your local computer.
       - If you created a scratch space link in your home directory in an earlier class you should be able to go to scratch space directly, using that link.
			 - You may also see your scratch space come up when you click on "Files" in OnDemand.
			 - If you can't get to scratch from OnDemand File explorer or use your mounted CHPC space in Finder, you'll need to copy it from scratch to your home space and download it from there.
    2. Go to https://view.qiime2.org/ and drag the `.qzv` file to the box to upload it and visualize the sequences imported.

### Step 4: Trim primers and join sequences
- These parts differ if you are using DADA2 for denoising. We are going to use Deblur here mainly because it's fast. Some folks feel strongly about one or the other. I think they both have advantages and drawbacks. You'll have to do your own research or buy me a coffee/beer and we can talk more.
  - Very different stategies but ultimately both result in amplicon sequence variants or ASVs (aka ESVs)

- Because these are amplicon sequences they have primers at the front (typical, but not always). These were put there by PCR and as such they represent a technical artifact and we don't want these parts of the sequence to influence phylogenies or taxonomies of the sequences. Here QIIME2 uses cutadapt to trim the primers.
	- Cutadapt is a commonly used program for removing adapters/primers and is notably also installed as  a module on CHPC and has a number of useful options.

- I've provided the primer sequences in the command here, but notice that these are part of the metadata that we downloaded from the SRA (or I provided. In table `SraRunTable_test.txt`).
- Note the `-p-cores` option sets the number of processes to start. We only have 2, but on a full job submission on a single node you can run many more and go much faster. It's a good idea to put a variable for this for each script so you don't need to change it for each command, but let's show the regular command first.

```bash
qiime cutadapt trim-paired \
  --i-demultiplexed-sequences seqs_import.qza \
  --o-trimmed-sequences seqs_trim.qza \
  --p-front-f GTGCCAGCMGCCGCGGTAA \
  --p-front-r GGACTACHVGGGTWTCTAAT \
  --p-cores 2
```

Here, we show how to **instead of the above command** set these primers as variables earlier in our script, as well as the number of processors. This would facilitate using this as a template later on.
```bash
FPrimer="GTGCCAGCMGCCGCGGTAA"
RPrimer="GGACTACHVGGGTWTCTAAT"
NumProc=2
```
Then, we would **instead** use this command referring to the variables, making our script a better template in the future

```bash
qiime cutadapt trim-paired \
  --i-demultiplexed-sequences seqs_import.qza \
  --o-trimmed-sequences seqs_trim.qza \
  --p-front-f ${FPrimer} \
  --p-front-r ${RPrimer} \
  --p-cores ${NumProc}
```

(it actually won't hurt here to do both of these commands, but you should probably do just one)

- Now, we will join the paired end sequences with vsearch.
  - Note, If using DADA2 you wouldn't join the sequences first.

- `vsearch` again, is a separate program that QIIME2 is wrapping, or calling. I like to keep the verbose option here because it prints useful data to screen that is helpful for troubleshooting and explains why my reads may or may not be merging.
  - I tend to take a somewhat permissive approach at this stage with the options (such as minimum merge length) and let the deblur denoising do the main "denoising"/filtering. Most options from this section are specific to your sequencing strategy and sequencing run quality.
  - Notice that, again, we could set these options as variables if we expected to change them often. I leave as an excercise in a for loop to examine behavior with different option values.

```bash
qiime vsearch join-pairs \
  --i-demultiplexed-seqs seqs_trim.qza \
  --o-joined-sequences seqs_trim_join.qza \
  --p-minmergelen 150 \
  --p-maxdiffs 10 \
  --p-allowmergestagger \
  --verbose
```


Let's again also get a visualizer and summarize the output:
```bash
qiime demux summarize \
  --i-data seqs_trim_join.qza \
  --o-visualization seqs_trim_join.qzv
```

- Copy the visualizer back to your results directory. Let's open that directory in your OnDemand file explorer and keep it open throughout.
```bash
cp seqs_trim_join.qzv ${WRKDIR}/results/
```

- Notice in the visualizer how some of the sequences drop out after 214 (mouse over the graph). So, of the 10k seqs randomly subsampled for this graph, some are not that long. This is usually the safest place to trim your sequences in the next section, but partly just represents real variation which you may not want to remove.
  - We only loose 2 sequences out to 250, so trimming that full 36 bases would be a waste of a lot of sequence info. However, also note that at the very end there are only 1 or 2 seqs that are longer. This part always requires inspection for your sequencing project to determine the appropriate trim length to pass to denoising algorithm.
- With DADA2 the process is a bit different, but still requires inspection of sequence quality plots at one point, so generally 16S seq preprocessing should not be fully automated.

### Step 5: Denoise with Deblur and create a table

After inspecting the sequence plot, let's move forward with denoising in Deblur. I often use a second filter here (`quality-filter q-score-joined`), especially if seqs are of lesser quality, but these look good and frankly this method is really slow and not totally necessary so I'm going to move forward with denoising.

This is the core of what I call the "sequence preprocessing" part, and it can take quite a bit of time, so let's get it going while we talk about it. You really just need to pass the `p-trim-length` option you determined from inspecting the joined sequence quality plots.

```bash
qiime deblur denoise-16S \
  --i-demultiplexed-seqs seqs_trim_join.qza \
  --p-trim-length 250 \
  --p-jobs-to-start 2 \
  --o-table table.qza \
  --o-representative-sequences repseq.qza \
  --o-stats table_stats.qza
```

- It's worth spending some time to look at the help file for this command and think about your own particular experiment.
  - The defaults may not be appropriate for each option, so be careful here. You can certainly imagine how some of these absolute read number counts could have a very different impact depending on depth of sequencing of an experiment. In general though, they aren't too bad. For most of us, that rare variant that is only present in one sample is going to be too hard to work with anyway, even if it was real.
	- However, removing rare species can have a HUGE impact on some alpha diversity metrics, so ecologists, in particular, should be aware of what's going on here.
  	- The size here is intended more as a QC of "if I don't see a sequence N times it isn't real".

#### OTUs versus ASVs/ESVs
You may have heard the term OTU before for microbiota work. Until recently we would be creating an "OTU" table at this step. Now we create an ASV/ESV table. I'll use the term ASV as this is what we are doing with "denoising" algorithms.

- **OTU**: Operational Taxonomic Unit. Clusters of seqs at some % similarity.
- **ASV**: Amplified Sequence Variant (or ESV - Exact Sequence Variant)

To boil this change down simply, OTUs lost a lot of information because they are clustered at some % similarity (usually 97%) and a representative sequence is then chosen. There are a number of different ways to create clusters though, and then a number of different ways to choose the representative (most abundant? best quality? most representative?). None of the methods is "perfect" in representing the underlying species. By their very nature clusters are an approximation. However, the justification for a long time was (at least) 2-fold:
- First, 97% similarity of 16S was sort of agreed on as a decent approximation of species across the bacterial phylogeny; 99% as strains 93-ish% as genus and so on with increasingly worse approximations. Remember though **phylogeny IS NOT EQUAL TO taxonomy**. Unfortunately, it's closer to reality in some places of the phylogeny and much worse in others, and this varies depending on the 16S region you are looking at.
- Second, the justification was that these sequences were necessarily very noisy. When you amplify and sequence some target, nucleotide variants will occur due to error in polymerase and sequencing. So clustering them could get rid of some of this, preventing a single nucleotide difference from being a different species, and at the same time reducing size of the table and compute time. Eventually people started arguing that we could get strain-level resolution if we clustered at 99% instead. This is just "kicking the can down the road" because it still ignores the real biology of life and the fact that the difference between a species or strains (or any other taxa difference really) are artificial constructs unevenly applied across the phylogeny. But, it does beg the question, why throw away potentially discriminating information?
- And that's exactly why ASVs have become the general method of choice now. We acknowledge deficiencies in taxonomic definitions and retain as much information as possible, while still employing sequence-level denoising.
- This is all still a bit of an oversimplification, again due to the nature of this as a workshop not a course, but it's worth noting and thinking about because it is critical that you understand that **the features in this table DO NOT REPRESENT SPECIES**. They never did with OTUs either, but now we just call these "**feature tables**" instead of OTU tables to further solidify and also because they could hold any type of "feature".
- Many microbial ecologists especially had thought about this for a long time before this, but it took awhile to implement and become common. Here's a nice paper discussing the change if you are interested in further reading: [ESVs should replace OTUs](https://www.nature.com/articles/ismej2017119)

Let's summarize our table to create a useful visualizer of it with some stats:
```bash
qiime feature-table summarize \
 --i-table table.qza \
 --o-visualization table.qzv
```

And make handy representative sequence file that will send each sequence into BLAST as well. This is simple but I think pretty neat and could be VERY useful for other projects outside of 16S. :

```bash
qiime feature-table tabulate-seqs \
--i-data repseq.qza \
--o-visualization repseq.qzv
```

Make sure to copy the table and representative sequences to your working directory when done. These are key outputs:

```bash
cp table.qz[av] ${WRKDIR}/results/
cp repseq.qz[av] ${WRKDIR}/results/
```
Did you see what I did with the table and repse files there? Remember regex?

### Step 6: Build phylogeny
Again, QIIME2 is not the actual code building the phylogeny here. It is, instead, wrapping other functions to do this and, in this case, making a pipeline for making a phylogeny from sequences. There are a number of methods once could use to do an alignment and then build a phylogeny.
	- In this command QIIME2 will align sequences, apply a mask to some of those aligned positions (highly conserved bits, especially all gaps) and then build a phylogenetic tree. So, this is great to do this all in one command instead and shows the usefulness of wrappers and script made by QIIME.

We build phylogenies in 16S seq analysis because they allow a unique type of measure of diversity between communities (phylogenetic beta diversity metrics). The measure that has really taken over is called UniFrac, and measures the unique fraction of phylogeny between communities. Several variants and other phylogenetic beta diveristy metrics exist, but I'll focus here on this one.
 - Instead of each species (ASV really) contributing equally to a measure of difference between samples, different species found in different samples that are more distantly related will contribute more. A sort of weighting by relatedness. It's a cool concept that stems from the notion that things more closely related are more likely to share similar functions. As a pretty extreme example, consider *E. coli* and *Salmonella enterica*. Sure, they are fairly different functionally in the world of immunology and pathology, but not nearly as differnt as are *E. coli* and the Archaeal species *Methanobrevibacter smithii*. So, the contribution to the differences between 2 communities (beta-diversity) that both contain *E. coli* should probably be greater in the case where one community also has *M. smithii* and one does not, than when one community has *S. enterica* and one does not. Since we need to know these relationships we need to calculate a phylogenetic tree. At least currently, this is still usually done *de novo* each time for a dataset.

```bash
qiime phylogeny align-to-tree-mafft-fasttree \
--i-sequences repseq.qza \
--o-alignment aligned_repseq.qza \
--o-masked-alignment masked_aligned_repseq.qza \
--o-tree tree_unroot.qza \
--o-rooted-tree tree_root.qza
```

I just create a rooted and unrooted tree upfront because some functions require a rooted tree, but really we don't have a known outgroup in our phylogeny so the rooted trees have an arbitrary root.

```bash
cp tree*.qza ${WRKDIR}/results/
```

### Step 7: Call Taxonomies
The last step before we start to use more community-level analytical tools to examine differences between samples, is to call phylogenies.
- The choice of taxonomy reference and method has a tremendous impact on the named species in your community. Frequently, people look at the inconsistent taxonomic calls and throw their hands in the air and say none of this stuff works and there's nothing useful here. The problem isn't the methods, or even really the taxonomies.
- The problem is that taxonomies aren't real! We can always improve on them to get better relationships, but they continue to be categoricals we put species into to *approximate* phylogenetic relationships and this will never properly reflect evolution over long time scales (never say never...?). I love this subject so will end here, but suffice it to say your choice of taxonomic classifier and reference makes a big difference.
- While everyone wants a taxonomy to talk about, this is (in my opinion) where these methods are actually the least useful.
- You don't have to use taxonomies at all to describe communities though.

For taxonomic calls in QIIME2 we need a trained classifier. This can be done in just a couple steps, but can take awhile and only needs be done once.
- It's been shown that classifiers work better if the input is trimmed to the region of the query (what you amplified). I've already done this for you and provide the classsifier. Just make a variable reference to it for simplicity. This one is trained on the Greengenes taxonomy and reference set.
- **NOTE**: I would argue the most useful bacterial taxonomy was just released a couple years ago. It is called the GTDB or [Genome Taxonomy Database](https://gtdb.ecogenomic.org/). It uses relationships based almost entirly on genome relatedness (believe it or not, this is not primary info for other taxonomies - they have lots of historical baggage).
  - We won't use GTDB here for ease, but in the future I would not use this Greengenes taxonomy and instead use the GTDB (or SILVA). The Greengenes was most commonly employed, but is no longer maintained and was always recognized as somewhat more inclusive but lower quality.
  - The names in the GTDB are not what many folks expect so I understand why many may not like it. But, it had to make new taxonomic names as genomes reveal the high amount of innaccuracies and misplacements (relative to genome relatedness) within current taxonomies.

```bash
CLASSIFIER=/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/gg_13_8_515F806R_classifier_sk0.24.1.qza
```
Now, run the classifier. Here we will use sci kit learn. Interestingly, because machine learning is so concerned with the problem of classification, classifiers are getting better and better and really this doesn't matter much that these are biological sequences. Computer scientists have been working hard on classifiers for quite awhile now and continue to do so. Biologists are benefiting in many ways including improved taxonomic classification of sequences.

```bash
qiime feature-classifier classify-sklearn \
--i-classifier ${CLASSIFIER} \
--i-reads repseq.qza \
--o-classification taxonomy.qza \
--p-n-jobs 2
```

Let's again make a visualize for the taxonomy. It is actually metadata so the command is a little idfferent:

```bash
qiime metadata tabulate \
--m-input-file taxonomy.qza \
--o-visualization taxonomy.qzv
```

```bash
cp taxonomy.qz[av] ${WRKDIR}/results/
```

### Step 8: Cleanup!
While scratch space is cleaned regular, it's still not limitless and the entire campus+ is using it with massive datasets. Make sure you clean it when you are done. I'd also note, usually it makes more sense to actually copy all your files you want to return at this step. I only did it after each step because I don't know how fare we will get in class.

```bash
rm *.fastq
rm *.qz[av]
```

**IMPORTANT: Stop copying commands to your bash script, unless noted**

### Final Step: Finish the batch script and submit.
At this stage, you should have a full pipeline that takes input seqs and outputs a **feature table, representative sequences, phylogeny and taxonomy**. Nice! You know it works because you tested it out, so you can now extend it to the full 16S sequence dataset. But this will take a bit longer to run (mostly just the pulling and importing of the sequences), so we will submit it as a batch job script as CHPC is intended. If you've been adding your commands as you were supposed to you are mostly ready for submission. 2 tasks remain.

#### Change the sra-toolkit command to pull all the 16S sequences.
I'm going to provide you with a `while` loop for this and leave it to as an exercise to understand it further. Normally, you are going to have your own sequences in a single directory already. You'll also need the full accessions number list so copy this over and place in your metadata folder:

```bash
cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/metadata/SRR_Acc_List_full.txt ~/BioinfWorkshop2021/Part2_Qiime_16S/metadata/
```

Make sure to change the value of the $ACCESSIONS variable to refer to this "full" accessions list instead of the "test" list of 2 that we used while testing our commands.
```bash
ACCESSIONS=~/BioinfWorkshop2021/Part2_Qiime_16S/metadata/SRR_Acc_List_full.txt
```

Replace the for loop with this while loop. I leave it for exercise to look up and understand while loops, but they are similar to for loops. Instead of giving a discrete list, `while` operates while a condition is true. This condition could just be the presence of items in a list, as here.

```bash
while read line
do
  fasterq-dump ${line} -e 2 -t ${SCRATCH}
done < ${ACCESSIONS}
```

#### Add SBATCH/Slurm directives
Normally, any line that starts with a # in a bash script would be a comment, but for slurm processed bash scripts if the lines at the beginning start with a `#SBATCH` (sbatch directives) they will be interpreted by slurm to provide the options required to schedule your job. These are the same options (plus some) that you used for `salloc`! One of the other cool bits about OnDemand is that they have some of these templates for you already and you should check them out. For this first sbatch submission, I'll just provide those directives you should add and tell you about them. Add the following lines at the beginning of your script, after the first line containing the shebang (shown for clarity, don't enter it twice)().

```bash
#!/bin/bash

#SBATCH --account=mib2020
#SBATCH --partition=lonepeak-shared
#SBATCH -n 2
#SBATCH -J Q2_PreProcess16S
#SBATCH --time=10:00:00
#SBATCH -o <YOUR_ABSOLUTE_PATH_TO_HOME_HERE>/BioinfWorkshop2021/Part2_Qiime_16S/code/PreProcess_16S.outerror

# your commands begin here..
```
- The `-o` option specifies a file to save the standard output to. By default sbatch actually combines standard eror and standard output, hence the extension I like to add, but you can add any extension you want as well. It usually makes sense to name this at least with the same name as script it came from.
- `-J` is the jobname that it will be under when you view the queue.

##### Note on partition, processes and time
Unless you go back and change everytime you referred to number of processes (or better yet use a variable for it), there's no sense in taking more than 2 processes. Be nice! Your job will take awhile with only 2 processes, but will finish. Feel free to change this though if you like.
- In regards to time, standard limit on CHPC is 72 hours, but there are ways to run longer. If you request really long you may wait longer in queue though. CHPC has a formula that determines your job priority. Generally, the less resources/time you request the sooner you will run.

## Submit Your Batch Script on CHPC

**Note to Windows Users**: If you used a text editor in Windows to make your sbatch script, you probably have Windows line endings and need to make sure you have Unix line endings before submitting to slurm scheduler. In Atom, at the bottom-right there is a "CRLF". If you click this you can then choose to change to "LF" then save the file and it will have Unix line-endings. In BBEdit, there is a similar functionality in one of the small arrow dropdowns along the top or bottom (though I forget exactly where it is).

```bash
sbatch ~/BioinfWorkshop2021/Part2_Qiime_16S/code/PreProcess_16S.sh
```

If that submits properly (your sbatch directives are correct) you will receive a number telling you your job number. Use the `squeue` command to see the status.

```bash
squeue -u <YOUR_uNID>
```

- If your job fails, open the `~/BioinfWorkshop2021/Part2_Qiime_16S/code/PreProcess_16S.outerror` to figure out why, fix issue and repeat.
  - **DEBUGGING**: Start with first error!!

# Practice / With Your Own Data
- Most importantly, try submitting your job script with full seqeunces input and working through any errors that occur.
- Use your for loops knowledge and variable expansion knowledge to loop over a seqeucne process command (such as `qiime vsearch join-pairs`) and see the effect on the outputs of using differnet parameters.
  - Hint1: Start with `for PARAMETER in <INTEGER_LIST_SEP_BY_SPACES`
  - Hint2: You'll need to use different output file names in each loop iteration or you'll just overwrite the same one each loop.

# Links, Cheatsheets and Today's Commands
- Why ASVs: [https://www.nature.com/articles/ismej2017119](https://www.nature.com/articles/ismej2017119)
- Qiime2 Plugins Documenation: [https://docs.qiime2.org/2020.2/plugins/available/](https://docs.qiime2.org/2021.4/plugins/available/)
- Today's New Commands:
  - `while`: A loop that performs commands "while" some condition is true.
