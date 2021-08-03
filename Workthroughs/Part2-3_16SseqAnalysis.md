<!-- TOC -->

- [Main](#main)
  - [Setup and Background](#setup-and-background)
    - [Today's Objectives:](#todays-objectives)
    - [Requirements, Expected Inputs and Review](#requirements-expected-inputs-and-review)
      - [Expected Inputs from Previous Class](#expected-inputs-from-previous-class)
  - [Review](#review)
  - [Core Analyses of 16S rRNA Gene Sequences](#core-analyses-of-16s-rrna-gene-sequences)
    - [Step 0: (optional) A little environment setup makes it easier and more reproducible](#step-0-optional-a-little-environment-setup-makes-it-easier-and-more-reproducible)
    - [Step 1: Remove poorly sequenced samples](#step-1-remove-poorly-sequenced-samples)
      - [1.1 Summarize Table](#11-summarize-table)
      - [1.2 Filter out samples](#12-filter-out-samples)
      - [1.3 (optional) Create a collector's curve](#13-optional-create-a-collectors-curve)
    - [Step 2: Perform core diversity calculations](#step-2-perform-core-diversity-calculations)
    - [Step 3: Examine alpha diversity](#step-3-examine-alpha-diversity)
    - [Step 4: Examine beta diversity](#step-4-examine-beta-diversity)
    - [Step 5 (sort of): Subset the table](#step-5-sort-of-subset-the-table)
    - [Step 6: Rerun core diversity analyses](#step-6-rerun-core-diversity-analyses)
    - [Step 7: Subsetting by taxonomic levels](#step-7-subsetting-by-taxonomic-levels)
    - [Step 8: Differential abundance testing of taxa.](#step-8-differential-abundance-testing-of-taxa)
- [Practice / With Your Own Data](#practice--with-your-own-data)
- [Links, Cheatsheets and Today's Commands](#links-cheatsheets-and-todays-commands)

<!-- /TOC -->
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
3. (optional)(for next class)
   - Sign up for a GitHub account: [https://github.com](https://github.com)
   - Install GitHub Desktop Program on your local computer: [https://desktop.github.com/](https://desktop.github.com/)

### Today's Objectives:

#### I. Analyze 16S Sequences with QIIME2 on the Linux CLI
- Understand the main components of a 16S rRNA gene analysis workflow.
- Gaining more command line practice.

#### II. Introduce Git and GitHub (if time)

### Requirements, Expected Inputs and Review
- CHPC connection and interactive shell session
- QIIME2 install in Conda virtual environment or CHPC QIIME2 module
  - Note that some commands may differ slightly if you use the older CHPC module. Look at the help file of commands to see if options are different.
- Atom or other plain text editor.

#### Expected Inputs from Previous Class

- Working Directory: `~/BioinfWorkshop2021/Part2_Qiime_16S/` with:
  	- `results` directory
  	- `metadata` directory
  	- `code` directory

- In previous session, we used 2 samples to first workup our sequence processing pipeline and get to a feature table with taxonomy calls, representative sequences and a phylogeny. Then, we worked up a submitted batch script to run the full dataset. The full dataset, including the metadata table, is the input for our analysis. If you were able to generate these yourself, continue to use them. If not, copy the inputs to your Project directory for the day (`~/BioinfWorkshop2021/Part2_Qiime_16S/` if you named it as I suggested). Each path is given below in a copy command to copy both the .qza and .qzv (`qz[av]`) files to your directory:

1. The feature table: `table.qza`
```bash
cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/results/table.qz[av] ~/BioinfWorkshop2021/Part2_Qiime_16S/results/
```
2. The rooted phylogeny: `tree_root.qza`
```bash
cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/results/tree_root.qza ~/BioinfWorkshop2021/Part2_Qiime_16S/results/
```
3. The taxonomy calls `taxonomy.qza`
```bash
cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/results/taxonomy.qz[av] ~/BioinfWorkshop2021/Part2_Qiime_16S/results/
```
4. The representative sequence of each ASV `repseq.qza`:
```bash
cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/results/repseq.qz[av] ~/BioinfWorkshop2021/Part2_Qiime_16S/results/
```
5. The metadata table `SraRunTable_full.txt`
```bash
cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/metadata/SraRunTable_full.txt ~/BioinfWorkshop2021/Part2_Qiime_16S/metadata/
```

The last item (`SraRunTable_full.txt`) we didn't use in last session. We downloaded from the SRA run-selector tool, though I've cleaned it up to remove some extraneous columns for clarity and changed the first header line to be compatible with QIIME2's minimal metadata requirements. See that page ([https://docs.qiime2.org/2021.4/tutorials/metadata/](https://docs.qiime2.org/2021.4/tutorials/metadata/)) for more info when you need to create your own, but the original page I pulled these from gives you an idea what the table looked like:

![Run Selector](https://drive.google.com/uc?export=view&id=1p2bZZK8bA_vOirXvclI-pfbQ_oz3_vt-)

- Note that we have used the "Run" as the Sample ID when we made the manifest file to import the samples. The main requirement for the QIIME2 metadata file is that the Sample ID is in the first column and the header is in one of several recognized formats. You can open up our metadata table to see I used the term `sample-id`.

- Scratch directory is not needed for this session. The large input files have been processed and now only smaller files are needed to do analysis.
  - View the size of your input files from before in human-readable format (`-h`) to get a sense of the size reduction due to the dereplication and counting of amplicons to ASVs with a representative sequence. If you only have the 2 test files we downloaded they are each only a couple dozen to hundreds of MB, but the full set contains 277 paired-end sequenced samples and so contains 50 GB (you can summarize the size of a file location with the " **d**isk **u**sage command and summarize option `du -s`).

```bash
ls -lh /scratch/general/lustre/${USER}/Part2_Qiime_16S/
ls -lh ~/BioinfWorkshop2021/Part2_Qiime_16S/results/repseq.qza
du -sh /scratch/general/lustre/<YOUR_uNID>/Part2_Qiime_16S/
```

- 50 GB input of 42 million raw sequences reads were reduced to a couple files that total just a bit more than 2 MB (`repseq.qza` and `table.qza`) and 9,220 sequences.
  - Notably, if we looked at the deblur logs there were initially 53098 sequences, but only 9,220 with >=10 reads/observations. This size filtering can be set in a denoising command's parameters but 10 is typical. There can be good reason to retain ASVs with even less observations but you can probably guess by the high proportion with less than 10 observations that 16S data tends to have a lot of this type of "noise". DADA2 has similar options and tends to retain more ASVs, but it isn't quite an accurate comparison at this stage of denoising because this comes after the main denoising algorithm.

**NOTE if using Qiime 2019 CHPC module**: There may be some version incompatibilities. Mostly, looks to not be a problem, so you just use the same as above if possible, but if  there are issues use the 2019 files of the same name I created in the folder:

```bash
/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/Qiime2_2019_outs/
```
## Review

- Examine your batch job scripts from the previous class and the `/results` directory.
  - `/code/PreProcess_16S.outerror`: Notice timestamp of when it was finished versus when your initial job was submitted.
    - Hint: Make use of the `date` command in your batch scripts for finding time of different steps.
  - I'll quickly review the batch job script we came up with over the course of last couple classes to download and process the sequences. You can bring up your own or mine here to examine it:
  ```bash
  less -S /uufs/chpc.utah.edu/common/home/u0210816/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/code/PreProcess_16S.sh
  ```
    - To solidify the batch job script structure and key points, find:
          1. The shebang
          2. The SBATCH directives at the beginning (NOTE you could give these as options to `sbatch` command when submitting).
          3. Your variables and environment setup. In future, it is best to keep this all up front as a section.
          4. Copy raw files to and copy back results statements.
  - List the artifact files in your results directory and see the key results copied back:
    ```bash
    ls -l ~/BioinfWorkshop2021/Part2_Qiime_16S/results/*.qza
    ```
    - These 4 files (5 if you include both trees) and the metadata file are all you need for further analysis.
    - Share with collaborators, archive, import into R (phyloseq package).

- Remember that we installed a separate miniconda3 module so we must load this first then QIIME2. We will use this set of commands frequently to start up our QIIME2 conda environment. Run it now for today session after you have an interactive shell:
```bash
module use ~/MyModules
module load miniconda3/latest
source activate qiime2-2021.4
```

**ONLY IF you didn't get the conda environment setup previously, use the CHPC installed module** (only use the above command OR the below command). Much prefer the Conda environment. I have not fully tested all commands in the older 2019 environment.
```bash
module load anaconda3/2019.03
source activate qiime2-2019.4
```

## Core Analyses of 16S rRNA Gene Sequences

### Step 0: (optional) A little environment setup makes it easier and more reproducible
- First, let's bring up a new file in Atom to document what we do. We won't actually submit this one as a job script. We could, and should write commands as though it would be, but we do need to document in some way what we are doing.
  - In previous iteration of this workhshop I introduced the Markdown syntax here for documentation. It is a good choice, but because it is easiest to see in action within RStudio, I don't intro it here to avoid redundancy. If you know the syntax a bit, feel free to use it instead.
  - For simplicity, let's just write this as if it was a shell (bash) script again. Let's save it as `Analysis_16S.sh` in the same local directory you previously saved `PreProcess_16S.sh`.
    - Try to document in this file as if it were your lab notebook. Ideally you would have all commands needed to recreate any published figure, but this may not always be possible. Add section headers and comments by prefacing a line with the `#`.

- Hopefully, you can start to see how making use of variables results in not only less typing, but also can help you to make reusable scripts or pipelines, where you just need to change the variables but the commands are the same. Let's set a few early on. Add these to your script and enter them in your shell:
```bash
WRKDIR=${HOME}/BioinfWorkshop2021/Part2_Qiime_16S/
MAP=${HOME}/BioinfWorkshop2021/Part2_Qiime_16S/metadata/SraRunTable_full.txt
```

### Step 1: Remove poorly sequenced samples
- 16S sequence data can be generated quite cheap because one can multiplex quite a few samples and capture the vast majority of diversity with only a few thousand sequences (depending on sample type). However, it's difficult to evenly multiplex 100% of the samples and even with great care, some degree of random sampling at high multiplex numbers will result in some samples that are very poorly sequenced from a given sequencing run. It's always a good idea to remove these from further analysis.
- Very low sequences per sample are indicative of poor sample quality to begin with. Additionally, even if the sequences came from a good quality library, a very low sampling effort will introduce a high level of variance due to random sampling that can obscure your ability to uncover real patterns in your data. The appropriate sequencing depth cutoff is always a bit difficult to determine and experiment specific. This is one of the most important piece of information to document and provide in your methods.
  - **Importantly**, this does NOT refer to even-depth subsampling (often called rarefaction somewhat incorrectly). This is just a sample QC pre-filtering.

#### 1.1 Summarize Table


- Let's first determine the number of *quality* sequences (observations now) in each sample. If you were able to run the full dataset as a batch script you previously generated a summarized table visualization already.
- Either way, let's generate this again, but this time let's add the map file with metadata which will adds some useful breakdown by metadata categories as well. First, make sure you are in the correct directory since I'm using relative paths to refer to the filenames succinctly.
```bash
cd ~/BioinfWorkshop2020/Part2_Qiime_16S/results
```
```bash
qiime feature-table summarize \
 --i-table table.qza \
 --o-visualization table.qzv \
 --m-sample-metadata-file ${MAP}
```

- Download to your local computer then examine the .qzv visualization file as we did before on the qiime2 visualization webpage. [view.qiime2.org](view.qiime2.org). Go to the "Interactive Sample Detail" tab.
- We can see that there is quite a range from almost a million to only 504. I suspect the original authors already filtered some that were lower, which is common for public deposited datasets, and cutoffs of around 500-1000 are frequent.

#### 1.2 Filter out samples
Let's filter out the bottom 2 samples that only have a few hundred observations. I'm mainly doing this just to show those commands and keep this method in your thoughts as an important QC. I suspect the 500 seqs / sample aren't actually bad at all given some of these are lung communities that are relatively low in microbes.
```bash
qiime feature-table filter-samples \
 --i-table table.qza \
 --o-filtered-table table_1k.qza \
 --p-min-frequency 1000
```

#### 1.3 (optional) Create a collector's curve
One way to assess if your level of sequencing is covering the community is to look at "collector's curves". You've probably seen these before in other settings. In ecology, the shape of these curves when shown as a function of diversity metrics is actually a type of alpha diversity analysis itself called rarefaction. The so-called collector's curve with observations/species is the simplest. Often we hear "rarefaction" and "subsampling" used interchangeably, which isn't quite correct. Let's examine *all* our samples with a sequence depth up to 5000 to see the number of observations (ASVs) we continue to gain with increasing depth.

- I'll note that this command and the graph generated is actually much more useful if you provide the metadata table as well, but it's quite slow already due to the repeated subsampling required, so for in class I am not doing this, but it's a good idea if you do are doing this outside of class.
- In fact, this is always a rather slow function so in class I will have you skip it and just show you the result.

```bash
qiime diversity alpha-rarefaction \
 --i-table table.qza \
 --o-visualization collector_curve.qzv \
 --p-metrics observed_features \
 --p-max-depth 5000 \
 --p-steps 20
```

- You can see that most samples level out by around 2500 observations/sequences. That is, we collect most of the ASVs (or more generally "features") by that point. At the same time, most samples continue to increase, albeit very slowly, past that point. These curves never totally flatten. It's interesting to think deeply about why this is and much has been written on it. Suffices to say there is both technical artifacts and potentially real community ecology at play here.
- This rarefaction is actually a type of diversity analysis itself and why referring to a single subsampling of the data at one depth as "rarefaction" is not accurate but common.

- As our aim is to compare the different sample types we included them all. If your aim was mainly to compare one of the metadatum then you would want to be careful to examine this for that subset.  Either way, here's an example where QIIME2 provides a pretty useful function that could be applied to non-microbial ecology data just as well. Check out the metrics one can input in this method besides "observed_features". They can tell you a lot about the distribution of your data.
  - See if you can run the same command to do alpha-rarefaction but use the "faith_pd" as your measure of diversity (you can actually add both metrics in one command). Compare it to your observed features curve. Faith's Phylogenetic Diversity just sums up the total branch length in a community. It's not uncommon that this levels out with number of observations made much more quickly, and this usually reflects that your increasing observations are closely related to already observed observations. Think of reasons why this might be.

### Step 2: Perform core diversity calculations

- If you take one ecology concept from this course I hope it is that there is many ways to describe diversity. You might say that there is no such thing as simply "diversity". A community with many species (what we usually intuitively call diversity) can be very "uneven" and dominated by only a few species. Thus, from a single observational point you may only see a few species which makes the community appear, paradoxically, not very diverse at all. In fact, this is frequently what microbial communities look like: they are often highly uneven.
  - How to measure diversity is a much more complex subject than you might expect, so we won't get heavy into it in this class (in line with our goal of getting practical bioinformatics experience). I encourage further reading and thinking hard about how we assess diversity.

- Because a few diversity metrics are more commonly used than others and together do a pretty good job describing diversity of communities, QIIME2 has made a "core-diversity" method that does these most common calculations. As we like to weight by phylogenetic dissimilarity as well, I'll use the phylogenetic method. These methods within Qiime require a depth for even subsampling (random, without replacement).
  - This has become a fairly contentious method, but has much precedence as well. Some good arguments can be made on both sides in my opinion and I'm not going to get into this either. However, be aware you can still do diversity calculations without it in Qiime2 if you don't use this "core-diversity" method.
- Given that we saw a pretty good amount of species in each sample by 2500 sequences per sample (and, frankly, that I want to speed up some calculations in class time), let's choose that as our sequencing depth. The actual decision is always about sample retention and your real project goals (discovery versus comparison can lead to different emphases).

```bash
qiime diversity core-metrics-phylogenetic \
 --i-table table_1k.qza \
 --i-phylogeny tree_root.qza \
 --output-dir core-div \
 --p-sampling-depth 2500 \
 --m-metadata-file ${MAP} \
 --p-n-jobs-or-threads 2
```

That's pretty cool. It calculated alpha and beta diversity and made visualizations in one step and very fast. We'll look at these as we also calculate some stats on them.

- Check out this [great post on qiime2 forum regarding diversity metrics and their calculations.](https://forum.qiime2.org/t/alpha-and-beta-diversity-explanations-and-commands/2282). You may have seen many of these metrics before outside of the context of "diversity". As I mentioned before, many have nothing to do with community ecology, *per se*, but are used to describe distributions.

### Step 3: Examine alpha diversity
While the alpha diversity metrics are calculated for each sample in the previous command, no visualizer is created until you perform a test. For our dataset we will just examine the differences in within sample diversity among the different sample types. There are methods for standard statistical tests of groups or correlation with a continuous variable. Notably, there are also a few 3rd party plugins that address this. While this may seem simple, how to properly assess alpha diversity is an active area of research and actually very complex.
- Trying to pin absolute numbers to something that is repeatedly subsampled and has many technical artifacts is hard, and not just limited to ecology (think harder about absolute numbers from flow data for example, or immune repertoire diversity), it's just very up front in that field.
  - It's also worth remembering that these ultimately are relative abundance data. We can't tell if the overall number of organisms in these communities has actually increased or decreased. This is a really important caveat to almost all high-throughput sequencing data and is also an active area where improvements have been made, but without lab methods to assess this initially, we will always be rather limited.

As a simple example, let's just examine Shannon diversity among the different sample types:
```bash
qiime diversity alpha-group-significance \
 --i-alpha-diversity core-div/shannon_vector.qza \
 --o-visualization core-div/shannon_SampleType.qzv \
 --m-metadata-file ${MAP}
```

- Download the visualization and check it out. A couple things to notice. First, while qiime calculates for every category within that metadata file, it wouldn't make any sense to use this to examine, for example, asthma status because we have all 4 sample types in there. Be careful!!
  - This is just doing a Kruskal-Wallis test.
- Grab the dropdown menu for column and look at SampleType. Shannon diversity is significantly different among all sample types. Second, I have got to point out that **Shannon diversity does NOT == EVENNESS**. This is *frequently* misinterpreted in the literature. It does indeed account for evenness, but richness (or number of species) as well. Notice how high the fecal samples are, which if this was only evenness would suggest they are highly even communities. Let's use one of a couple different evenness measures to directly ask this. For a proper comparison, we'll use the same subsampled (aka rarefied) table to calculate this, then do the significance tests:

```bash
qiime diversity alpha \
 --i-table core-div/rarefied_table.qza \
 --p-metric mcintosh_e \
 --o-alpha-diversity core-div/mcintosh_vector.qza
```
```bash
qiime diversity alpha-group-significance \
 --i-alpha-diversity core-div/mcintosh_vector.qza \
 --o-visualization core-div/mcintosh_SampleType.qzv \
 --m-metadata-file ${MAP}
```

- Download and examine that result also by sample type. Mcintosh's evenness is an index, so values have a closed range, in this case between 0 and 1. As values approach 1, the community is more even, or more homogeneously distributed. This is not only different than the Shannon result, the pattern is completely opposite! So, if we (as is frequently done) said that our Shannon diversity shows fecal communities are more even, we would have completely misinterpreted the data! Wow. Why? As Shannon is a combination of richness (the number of species) and evenness we need to look at richness to understand. That's easy, just count the species, which was already done for us with the core diversity metric. Do the statistical test to create the visualizer.

```bash
qiime diversity alpha-group-significance \
 --i-alpha-diversity core-div/observed_features_vector.qza \
 --o-visualization core-div/observed_features_SampleType.qzv \
 --m-metadata-file ${MAP}
```

Again, download and view the results. You can see that there are many less features (ASVs) in the nasal samples than in the others.
- The mean of observed features is highest in fecal, but surprisingly not higher. This likely reflects the measure itself and the effect of our relatively low sampling depth, and illustrates the caveats to comparing alpha diversities. It's good to think about how these samples were collected, the biological and laboratory media they were in, and how they are extracted to consider the difficulties normalizing. It's truly a task still best suited to careful qPCR assays. Yea, molecular biology still rules! However, this example nicely illustrates that a similar Shannon metric can result from different combinations of species richness and evenness, and all alpha diversity are highly influenced by sampling effort.
- This is not to say Shannon is not useful, it does still provide what most people find to be the most intuitive measure of diversity I think. But that also doesn't make it the best measure or appropriate for the question being asked. And sometimes, the comparisons we are making were not a good idea in the first place due to uneven sampling effort introduced by lab methods.

### Step 4: Examine beta diversity
Beta diversity describes the differences *between* communities. As such, it is often less sensitive to sampling efforts than alpha diversity, so long as a reasonable depth is chosen. More so with some metrics than others. It is also a great way to examine the dissimilarity of samples and you will frequently see these type of results in a PCoA plot. While the term beta diversity comes from community ecology, as it really is just "dissimilarity" you can apply most of these calculations to lots of different types of data and most of the metrics are not specific to species counts data.
- QIIME2 does a few different functions for you in order to give you a principle coordinates analysis plot right away with the core diversity functions. The core diversity function calculates the distance matrices for 3 of the most common beta diversity metrics, then calculates Eigen vectors and principle components and plots them with a cool visualizer that is pretty easy to format (too easy sometimes, be careful!).
- Before we look at the graphs, let's also calculate significance with permanova so we can discuss what it means with the graph as a visualization. In order to do this, use the "beta-group-significance" command. Add the `--p-pairwise` option to test for differences between all pairs of sample types.

```bash
qiime diversity beta-group-significance \
 --i-distance-matrix core-div/weighted_unifrac_distance_matrix.qza \
 --m-metadata-file ${MAP} \
 --m-metadata-column SampleType \
 --o-visualization core-div/weighted_unifrac_SigTest_SampleType.qzv \
 --p-pairwise
```

- Download the 2 files in the core-div directory: `weighted_unifrac_emperor.qzv` and `weighted_unifrac_SigTest_SampleType.qzv`.

- Bring them both into the QIIME2 visualizer webpage and let's examine them. Examine the `weighted_unifrac_SigTest_SampleType.qzv` file and let's discuss a few items regarding these dissimilarities/beta-diversity results.
  - First, a couple things to note about the test. This is a non-parametric test (PERMANOVA = permutational multivariate ANOVA) where the distribution to test against is created by performing a number of random shuffling of the data. The number of digits of the p-value of a non-parametric test cannot exceed the number of permutations. By default this does 999 permutations, thus the minimum p-value IS p=0.001. **It is NOT p < 0.001**.
  - Second, the pairwise option is off by default because if you have a number of factor levels with many permutations this can take quite a long time to finish.
  - Third, note that a significant value just tells us the communities are significantly different.

- Now, look at the PCoA visualization file (`weighted_unifrac_emperor.qzv`). This emperor plugin is pretty nice and has lots of options for visualizing your data. You can color by any of the variables in your metadata file.
  - Go to the color tab and choose "SampleType". You can really see how the samples are different from one another, and get a qualitative sense that the nasal and BAL sample types are more similar to one another.
  - You can get the actual distances between the types downloaded from the significance visualizer.

A couple points on these PCoA plots.
- First, notice there are 3 axes shown. This is one of the advantages and disadvantages of PCoA as a multidimensional reduction method. Some methods you may be familiar with such as NMDS, tSNE and UMAP reduce the data into a 2D space. These are probably more appropriate for publication (usually a 2D space), but almost inevitably have more stress in them. Basically error, because it's unlikely to find a single 2D solution for high dimensional data. The 2D multidimensional reductions tend to not look as nicely clustered. At least when they work on the original distances.
  - tSNE and UMAP frequently used in scRNAseq are usually operated on the principal components, so are sort of reductions upon reductions and give the impression of nicer clusters than they usually would if operated on the original distances. Nothing wrong with this, just be aware of what you are really looking at.
  - The reason PCoA gives the impression of nice clusters usually is because you are seeing the first 3 (or 2) of many axes of variation and the axes are ordered by decreasing amount of variation.
  - Notice this in the % for each PC (principle component). QIIME2 is only showing the first 5 for some reason (they used to have ability to see all), but most of the variation is captured in the first 3 (~60%). It's important when looking at these graphs to see how much of the variation you are seeing and which axes. There may be much more than the presenter is showing you and it can be evident by the axes.

- Second, the space these points are in (the axes) is created by the input dataset itself (as in other multidimensional reduction methods) - the axes have no absolute meaning. Notice there is a tab for "visibility". It's hard for me to imagine what situation actually warrants this option (at least in publication). As a clearer example:
1. Color by sample type: Color tab and choose "SampleType" dropdown.
2. Get only 2 axes: Click on the axes tab and get axes 1 and axes 4. For the third option, choose "hide axis (make 2D)".
3. Click on the visibility tab and choose "SampleType" in the dropdown, then click the "Fecal" checkbox to remove it's visibility.

- Notice how the points stretch all the way up the top of the y-axis, but without the fecal data the points don't stretch to the end of the x-axis. This shows how the axes are determined by the dataset, and thus hiding data is misleading. You would need to subset the data and recalculate the PCs to do this properly.
- Qualitatively (and we see these statements often in the literature) we might conclude from this graph that Fecal and Oral samples aren't really different, but are much more different than nasal and BAL. But, we are looking at only 2 axes of variation cherry-picked to show this. Change Axes 4 back to Axes 2 to see that Fecal and Oral are not on top of one another if we choose different axes.

- A MUCH better way to state if sample groups are more or less similar to one another is to use the actual distances themselves. Look back at the `weighted_unifrac_SigTest_SampleType.qzv` visualizer.
  - The default plots can be nice to show the distances to every other sample type (in our case). But I think it is often more useful to see the within sample type distances next to them at least.
      - Notice the "Download Raw Data as TSV" link. This is one really useful thing about some of these QIIME2 visualizers. They provide this way to export this reformatted data. In this case, the original data is a diagonal matrix of each sample with the metric as the value. You would have to extract, transpose and line these up with metadata characteristics of each sample without this link. It can be a fairly complicated task to get these into a usable format to plot in other programs.

### Step 5 (sort of): Subset the table
We went through much more of an exploratory analysis of the full data in the above sections. This is not a bad idea with your own dataset either, but ultimately you likely want to test specific hypotheses about some of your data that would probably require you to subset it first. Going through the full dataset also allowed some opportunities for me to discuss some potential pitfalls and poor inference possible with diversity analyses in HTseq. So, although it seems strange to end at subsetting, it was fun to see the full dataset first and the potential differences among body sites.

- Let's subset the data before we look to see if we can detect taxonomic differences among asthmatics. While frequently reported, this does remain a bit unclear and there seems to be little consistency between studies.

- There's a couple different ways to subset your data with the same qiime2 command. The simplest way is probably to provide a list of the sample IDs. A more efficient way to subset is using the statements with the `--p-where` option. These use SQL syntax. This syntax is used all over for working with data tables and we'll see similar methods with some R packages. It's easy when you are only trying to grab one category, but a bit more complicated when trying to pass multiple options. Let's subset to just the BAL samples for further exploration.

```bash
qiime feature-table filter-samples \
 --i-table table.qza \
 --o-filtered-table table_BAL.qza \
  --p-where "[SampleType] = 'BAL'" \
 --m-metadata-file ${MAP}
```

- Refer to the QIIME2 help page for more filtering syntax examples: [https://docs.qiime2.org/2021.4/tutorials/filtering/](https://docs.qiime2.org/2021.4/tutorials/filtering/)

### Step 6: Rerun core diversity analyses

- We will skip this part in class simply due to time and that we have already shown how to run these.
- In your own time, run these core diversity analyses, replacing commands with interesting metadata groupings as you see fit.

### Step 7: Subsetting by taxonomic levels

- First create a taxa directory to hold these taxa results within the results directory (we can create quite a few new files here). Then, run the command to create a stacked barplots visualizer.

```bash
mkdir taxa
qiime taxa barplot \
 --i-table table_BAL.qza \
 --i-taxonomy taxonomy.qza \
 --m-metadata-file ${MAP} \
 --o-visualization taxa/tax_barplot_BAL.qzv
```

- You can download and look at that visualizer and see it can be quite useful for creating these common plots. You can look at different taxonomic levels and reorder by metadata. These will be even more useful often if you do some subsetting or summarizing beforehand, but I leave that to you as an excercise now that I have given you all the commands and skills to do this.
- It is often useful to get a new table for each taxonomic level though. For example if you want to test for differential abundance of the "Family" taxonomic level (Level 5 in the Greengenes taxonomy). Let's just employ our looping skill to do this quickly.

```bash
for Level in 3 4 5 6 7
do
  qiime taxa collapse --i-table table_BAL.qza --p-level ${Level} --i-taxonomy taxonomy.qza --o-collapsed-table taxa/table_BAL_L${Level}.qza
done
```

- Can you see what happened in the loop? Look back at the loops section of earlier classes to remind yourself. Summarize the output tables like we did at the beginning of class to see how the number of "features" (now taxa levels) has changed compared to the number of ASVs in the original `table_BAL.qza` file.

### Step 8: Differential abundance testing of taxa.
- We actually won't go through this in class because it is more about the test type, and the type of choice you make for this can make big differences. It's also an active area and not exactly "cut and dry" how to do this believe it or not (you'd be forgiven for thinking this would be the first thing we would know how to do).
- 2 main approaches to this:
1. Use established differential expression methods (such as DESeq2) and operate on the ASVs. Don't subsample/rarefy your data for these! They expect the variance of count data and stabilize it to find the most likely things different. Often developed for RNAseq data, they don't really care what the counts are. You can actually do this on other taxonomic grouping levels but you loose a lot of the power of this type of method.
2. Use methods that account for the proportional (or relative abundance) nature of the data. These include ANCOM, Aldex2 and Gneiss already available as QIIME2 plugins. Generally, these also don't require a previous single-depth rarefaction/subsampling (and it is not advised to do so), but can take it.

- You can perform these now on your original ASVs in the table, *or on the summarized taxonomic levels* (generally, though you may need to keep them as counts instead of proportions depending on the expected input). However, **once you summarize to a taxonomic level your results are only as good as that taxa grouping**, which we know are notoriously poor in bacterial taxonomies across the entire domain. Though everyone wants a taxa name, these types of analyses on higher taxonomic levels are often the most useless and incorrect (my opinion).
  - This should be more reproducible and accurate if you use the GTDB taxonomy.

# Practice / With Your Own Data
- If you have your own dataset, continue to use it an go through some of these diversity analyses.
- Run the core diversity analyses and examine outputs on the `table_BAL.qza` subset.
- Find a 3rd party plugin that does a function of interest to you (see below link), install it and try to run it using your table.qza and other files (if required) for input.

# Links, Cheatsheets and Today's Commands
- QIIME2 plugins documentation: [https://docs.qiime2.org/2021.4/plugins/available/](https://docs.qiime2.org/2021.4/plugins/available/)
