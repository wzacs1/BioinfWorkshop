<!-- TOC -->

- [Main](#main)
  - [Requirements / Inputs](#requirements--inputs)
    - [Requirements:](#requirements)
    - [Inputs:](#inputs)
  - [Following along](#following-along)
  - [Using QIIME2 in a container](#using-qiime2-in-a-container)
  - [Markdown for awesome documentation](#markdown-for-awesome-documentation)
  - [Step 1: Remove poorly sequenced samples](#step-1-remove-poorly-sequenced-samples)
    - [1.1 Summarize Table](#11-summarize-table)
    - [1.2 Filter out samples](#12-filter-out-samples)
    - [1.3 (optional) Create a collector's curve](#13-optional-create-a-collectors-curve)
  - [Step 2: Perform core diversity calculations](#step-2-perform-core-diversity-calculations)
  - [Step 3: Examine alpha diversity](#step-3-examine-alpha-diversity)
  - [Step 4: Examine beta diversity](#step-4-examine-beta-diversity)
  - [Step 5 (sort of): Subset the table](#step-5-sort-of-subset-the-table)
- [Practice / With Your Own Data](#practice--with-your-own-data)
- [Links / Cheatsheets / Today's New Commands](#links--cheatsheets--todays-new-commands)

<!-- /TOC -->

# Main
**Objectives**
1. Introduce markdown for documentation.
2. Analyze 16S seq feature table.

## Requirements / Inputs
### Requirements:
1. A CHPC account and interactive session on compute node (obtained as in previous classes with `srun` command)
2. A plain text editor installed locally. Prefer Atom or BBedit.
   1. Alternatively, OnDemand has a built-in text editor as well, though it is minimal. Just open a file to edit through it's interface.

### Inputs:
In previous session, we used 2 samples to first workup our sequence processing pipeline and get to a feature table with taxonomy calls, representative sequences and a phylogeny. Then, we worked up a submitted batch script to run the full dataset. The full dataset, including the metadata table, is the input for our analysis. If you were able to generate these yourself, continue to use them. If not, copy the inputs to your Project directory for the day (`~/BioinfWorkshop2020/Part2_Qiime_16S/` if you named it as I suggested). Each path is given below:
1. The feature table: `table_full.qza`
```bash
/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part2_Qiime_16S/table_full.qza
```
2. The rooted phylogeny: `tree_root_full.qza`
```bash
/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part2_Qiime_16S/tree_root_full.qza
```
3. The taxonomy calls `taxonomy_full.qza`
```bash
/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part2_Qiime_16S/taxonomy_full.qza
```
4. The metadata table `SraRunTable_full.txt`
```bash
/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part2_Qiime_16S/metadata/SraRunTable_full.txt
```
**NOTE if using Qiime 2019 CHPC module**: There may be some version incompatibilities. Mostly, looks to not be a problem, so you just use the same as above if possible, but if there are issues use the 2019 files of the same name I created in the folder:
```bash
/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part2_Qiime_16S/Qiime2_2019_outs/
```

## Following along
Because today's session is heavier on analysis, I want to ensure you can follow along. If you have trouble creating any of the outputs, feel free to copy them from my space in order to view them or create needed inputs in order to keep up. Remember though, it's ideal to create them yourself as we are trying to get you practice on the command line. The shared direcotry is here:

`/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part2_Qiime_16S/`

It may be easier to make a soft link to it to avoid a lot of typing and keep it available to you.

```bash
$ cd ~/BioinfWorkshop2020/Part2_Qiime_16S/
$ ln -s /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part2_Qiime_16S/ answers_Part2
```

## Using QIIME2 in a container
I would recommend using QIIME2 in a conda virtual environment if you can. If not, another option is to use the Docker-hosted container. I was going to introduce containers at the end of this workshop, but it's looking like we may not make it there so I do want to introduce them. Even if you did get QIIME2 working in conda environment it may be worth it to follow these commands to see how this works.

Containers are similar in concept to virtual machines but are more lightweight and have differences in how they interact with the main system resources. They are really awesome for reproducibility because one can simply provide the definitions of their environment and others can reproduce this environment with all installs in a "contained" environment. However, a lot of folks are using them just to assist people with install because you really don't have to install anything, except some program to manage the container (much like miniconda manages the virtual environment). On CHPC we can use udocker or Singularity, and on your computer you can use Docker, which is the most popular. These container definitions are hosted on various sites and the program managing the container pulls the definition and builds the container for you. You can either shell into an environment or just pass commands to the container manager which acts as a intermediary.

To show how this works, pull the QIIME2 container and just run the info command in QIIME2. The first time you pull it, it will take a while to download, then after that it will be much faster. Don't worry if you get a XDG_RUNTIME_DIR error, or set it (it's an environmental variable):

```bash
$ module load singularity
$ singularity exec docker://qiime2/core:2020.2 qiime info
```

The `exec` command just executes the command after the specifiied container. We specified the qiime2 container and where it is hosted (on docker). The syntax is like this:
- singularity exec HOST://CONTAINER:TAG <YOUR_COMMANDS>

You can also "shell" into this container and work interactively. You need to specify your shell. We are always using bash for this workshop:

```bash
$ singularity shell -s /bin/bash docker://qiime2/core:2020.2
```

Just type exit to get out of your container. One thing to note is that you may not mount your shared or scratch spaces. If you can't access them look at the help file for singularity on how to mount them with each command.

If you can find a container for your program (and more and more this is true) you can run it usually. This technology is new enough there's been a number of bugs in the different managers using different types of definition files, and it felt overly complicated initially getting your environment into them sometimes, but it feels like it's settling out now and more and more you are seeing everything hosted as a container and the defaults set up nicely. It's a very nice method and I expect you will use it quite a bit so wanted to make sure to introduce it. CHPC gives a more thorough lecture on containers and even how to build your own.

## Markdown for awesome documentation
Let's return to Atom to learn about markdown. First we will install a couple packages to make this more useful.
- Install packages with atom. Go to `Packages -> Settings View -> Install packages/themes`. In the text box search for the following packages and install them.
   1. markdown-writer
   2. language-markdown
   3. markdown-preview (This should be installed already)

Markdown is a simple text syntax that makes it easy to document your code with few highlights and with naturally written text around it. This document is entirely written in markdown, and almost all program docs you see these days are in markdown. We will also use it in R, where it really shines with R's flavor of markdown in R studio, but we want to start using it early for documentation. Let's create our first markdown file for our class in a local project directory. (I will note that this makes more sense to just have this in your same project directory on CHPC. However, since we had to move to remote class we are mostly not connected to campus network or VPNs and so most people won't have CHPC directly mounted):

1. Make a local (on your desktop/laptop) project directory on your computer for this class. Naming is up to you.
2. Now use the `File -> Open Folder...` again to change your project directory to the newly created folder. It should open in a new window.
3. Create a new file in your class project directory. When you use `File -> New file` it will create that file in that directory. Let's use this file to document our interactive analysis of the 16S sequences dataset. Let's name it by the BioProject of the dataset. Save it as "PRJNA434133_16S_Analysis.md".
   - The file extension informs Atom as to the syntax used and allows different highlighting of the text. Thus we need to save the file first to see the highlighting.

We'll use this file as we go along to further illustrate markdown by using it. But for now, let's look at the cheatsheet to see the syntax overview.
- Open the markdown cheatsheet in Atom: `Packages -> Markdown Writer -> Open Cheat Sheet`

This syntax may look familiar to some. It's similar to rich text formatting and a number of these conventions have been used for years on blog sites like WordPress. Please do play around with these in your own time, but you can really just know a couple main points to get decent documentation.
- The `#` characters are used for section headers. Increasing number of them for each level gives simple and effective organization. There are packages that will turn these into clickable entries for a table of contents in one click so use them with this in mind and your documentation will be slick and useful.
- The backtick ( \` - on your `~` key) is used to delineate code. It can be `inline` when enclosed in a single backtick, or set aside in blocks (like you've seen throughout these documents) with 3 \`\`\` noting the start and 3 noting the end of the block. This cheatsheet also shows an alternative for code blocks (3 spaces), but let's use the 3 backticks instead because it's consistent with what we will see in R markdown.
  - While you don't *require* it for documentation purposes, you can tell markdown how to highlight (and potentially interpret) your codeblock, by specifying what program is to be used after the first the backticks. You would simply type `bash` directly after the backticks for our purposes today.
- **Bold** and *italics* are very useful to know as well. Use text enclosed in 2 `*` for bold and one `*` for italics.

That's sufficient to provide readable, decent documentation. Get fancier if you like by looking at the cheatsheet or online. Try to use this as much as possible when working interactively to document your working commands. Think about it as a batch script itself, so ultimately each command block could be run in succession automatically and generate your outputs/graphs/stats.

## Step 1: Remove poorly sequenced samples
16S sequence data can be generated quite cheap because one can multiplex quite a few samples and capture the vast majority of diversity with only a few thousand sequences (depending on sample type). However, it's difficult to evenly multiplex 100% of the samples and even with great care, some degree of random sampling at high multiplex numbers will result in some samples that are very poorly sequenced. It's always a good idea to remove these from further analysis. Often very low sequences per sample are indicative of poor sample quality to begin with. Additionally, even if good quality, the very low sampling effort will introduce a high level of error due to random sampling that can obscure your ability to uncover real patterns in your data. The appropriate sequencing depth cutoff is always a bit difficult to determine and experiment specific. This is one of the most important piece of information to document and provide in your methods.

### 1.1 Summarize Table
Let's first determine the number of *quality* sequences (observations now) in each sample. If you were able to run the full dataset as a batch script you previously generated a summarized table visualization already. If not, let's generate this now. First, make sure you are in the correct directory since I'm using relative paths to refer to the filenames succinctly.
```bash
$ cd ~/BioinfWorkshop2020/Part2_Qiime_16S/
```
```bash
$ qiime feature-table summarize \
 --i-table table_full.qza \
 --o-visualization table_full.qzv
```

Examine the .qzv visualization file as we did before on the qiime2 visualization webpage. [view.qiime2.org](view.qiime2.org). We can see that there is quite a range from almost a million to only 504. I suspect the original authors already filtered some that were lower, which is common for public deposited datasets, and cutoffs of around 500-1000 seem frequent.

### 1.2 Filter out samples
Let's filter out the bottom 2 samples that only have a few hundred observations. I'm mainly doing this just to show those commands and keep this method in your thoughts as an important QC. I suspect the 500 seqs / sample aren't actually bad at all given some of these are lung communities that are relatively low in microbes.
```bash
$ qiime feature-table filter-samples \
 --i-table table_full.qza \
 --o-filtered-table table_full1k.qza \
 --p-min-frequency 1000
```

### 1.3 (optional) Create a collector's curve
One way to assess if your level of sequencing is covering the community is to look at "collector's curves". You've probably seen these before in other settings. In ecology, the shape of these curves when shown as a function of diversity metrics is actually a type of alpha diversity analysis itself called rarefaction. The so-called collector's curve with observations/species is the simplest. Often we hear "rarefaction" and "subsampling" used interchangeably, which isn't quite correct. Let's examine *all* our samples with a sequence depth up to 5000 to see the number of observations (ASVs) we continue to gain with increasing depth. You'll notice the metric we provide is still called "observed_otus", a remnant of OTU clustering not so long ago.

(I'll note that this command and the graph generated is actually much more useful if you provide the metadata table as well, but it's quite so slow already due to the repeated subsampling required so for in class I am not doing this, but it's a good idea if you do are doing this outside of class).

```bash
$ qiime diversity alpha-rarefaction \
 --i-table table_full.qza \
 --o-visualization collector_curve.qzv \
 --p-metrics observed_otus \
 --p-max-depth 5000 \
 --p-steps 20
```

You can see that nearly all samples level out by around 2500 observations/sequences. That is, we collect most of the ASVs by that point. At the same time, most samples continue to increase, albeit very slowly, past that point. These curves never totally flatten. It's interesting to think deeply about why this is and much has been written on it. Suffices to say there is both technical artifacts and potentially real community ecology at play here.

As our aim is to compare the different sample types we included them all. If your aim was mainly to compare one of the metadatum then you would want to be careful to examine this for that subset.  Either way, here's an example where QIIME2 provides a pretty useful function that could be applied to non-microbial ecology data just as well. Check out the metrics one can input in this method besides "observed_otus". They can tell you a lot about the distribution of your data.

## Step 2: Perform core diversity calculations
If you take one ecology concept from this course I hope it is that there is many ways to describe diversity. You might say that there is no such thing as simply "diversity". A community with many species (what we usually intuitively call diversity) can be very "uneven" and dominated by only a few species. Thus, from a single observational point you may only see a few species which makes the community appear, paradoxically, not very diverse at all. In fact, this is frequently what microbial communities look like: they are often highly uneven.

Because a few diversity metrics are more commonly used than others and together do a pretty good job describing diversity of communities, qiime2 has made a "core-diversity" method that does this most common calculations. As we like to weight by phylogenetic dissimilarity as well, I'll use the phylogenetic method. These methods within Qiime require a depth for even subsampling (random, without replacement). This has become a fairly contentious method, but has much precedence as well. Some good arguments can be made on both sides in my opinion and I'm not going to get into it. However, be aware you can still do diversity calculations without it in Qiime2 if you don't use this "core-diversity" method. Given that we saw a pretty good amount of species in each sample by 2500 sequences per sample, and that I want to speed up some calculations in class, let's choose that as our sequencing depth.

```bash
$ qiime diversity core-metrics-phylogenetic \
 --i-table table_full1k.qza \
 --i-phylogeny tree_root_full.qza \
 --output-dir core-div \
 --p-sampling-depth 2500 \
 --m-metadata-file metadata/SraRunTable_full.txt \
 --p-n-jobs 2
```

That's pretty cool. It calculated alpha and beta diversity and made visualizations in one step and very fast. We'll look at these as we also calculate some stats on them.

- Check out this [great post on qiime2 forum regarding diversity metrics and their calculations.](https://forum.qiime2.org/t/alpha-and-beta-diversity-explanations-and-commands/2282). You may have seen many of these metrics before outside of the context of "diversity". As I mentioned before, many have nothing to do with community ecology, *per se*, but are used to describe distributions.

## Step 3: Examine alpha diversity
While the alpha diversity metrics are calculated for each sample in the previous command, no visualizer is created until you perform a test. For our dataset we will just examine the differences in within sample diversity among the different sample types. There are methods for standard statistical tests of groups or correlation with a continuous variable. Notably, there are also a few 3rd party plugins that address this. While this may seem simple, how to properly assess alpha diversity is an active area of research and actually very complex. Folks from my lab will expect a lengthy rant from me here, but I will mercifully spare you in the interest of time. Trying to pin absolute numbers to something that is repeatedly subsampled and has many technical artefacts is hard, and not just limited to ecology (think harder about absolute numbers from flow data!!), it's just very up front in that field.

As a simple example, let's just examine Shannon diversity among the different sample types:
```bash
$ qiime diversity alpha-group-significance \
 --i-alpha-diversity core-div/shannon_vector.qza \
 --o-visualization core-div/shannon_SampleType.qzv \
 --m-metadata-file metadata/SraRunTable_full.txt
```

- Download the visualization and check it out. A couple things to notice. First, while qiime calculates for every category within that metadata file, it wouldn't make any sense to use this to examine, for example, asthma status because we have all 4 sample types in there. This is just doing Kruskal-Wallis test. Grab the dropdown menu for column and look at SampleType. Shannon diversity is significantly different among all sample types. Second, I have got to point out that **Shannon diversity does NOT == EVENNESS**. This is *frequently* misinterpreted in the literature. It does indeed account for evenness, but richness (or number of species) as well. Notice how high the fecal samples are, which if this was only evenness would suggest they are highly even communities. Let's use one of a couple different evenness measures to directly ask this. For a proper comparison, we'll use the same subsampled (aka rarefied) table to calculate this, then do the significance tests:

```bash
$ qiime diversity alpha \
 --i-table core-div/rarefied_table.qza \
 --p-metric mcintosh_e \
 --o-alpha-diversity core-div/mcintosh_vector.qza
```
```bash
$ qiime diversity alpha-group-significance \
 --i-alpha-diversity core-div/mcintosh_vector.qza \
 --o-visualization core-div/mcintosh_SampleType.qzv \
 --m-metadata-file metadata/SraRunTable_full.txt
```

- Download and examine that result as well by sample type. Mcintosh's evenness is an index, so values have a closed range, in this case between 0 and 1. As values approach 1, the community is more even, or more homogenously distributed. This is not only different than the Shannon result, the pattern is completely opposite! So, if we (as is frequently done) said that our Shannon diversity shows fecal communities are more even, we would have completely misinterpreted the data! Wow. Why? As Shannon is a combination of richness and evenness we need to look at richness to understand. That's easy, just count the species, which was already done for us with the core diversity metric. Do the statistical test to create the visualizer.

```bash
$ qiime diversity alpha-group-significance \
 --i-alpha-diversity core-div/observed_otus_vector.qza \
 --o-visualization core-div/observed_otus_SampleType.qzv \
 --m-metadata-file metadata/SraRunTable_full.txt
```

Again, download and view the results. You can see that there are many less features (ASVs) in the nasal samples than in the others. The mean of observed features is highest in fecal, but surprisingly not higher. This likely reflects the measure itself and the effect of our relatively low sampling depth, and illustrates the caveats to comparing alpha diversities. It's good to think about how these samples were collected, the biological and laboratory media they were in, and how they are extracted to consider the difficulties normalizing. It's truly a task still best suited to careful qPCR assays. Yea, molecular biology still rules! However, this example nicely illustrates that a similar Shannon metric can result from different combinations of species richness and evenness, and all alpha diversity are highly influenced by sampling effort. This is not to say Shannon is not useful, it does still provide what most people find to be the most intuitive measure of diversity I think. But that also doesn't make it the best measure or appropriate for the question being asked.

## Step 4: Examine beta diversity
Beta diversity describes the differences *between* communities. As such, it is generally less sensitive to sampling effects than alpha diversity. More so with some metrics than others. QIIME2 does a few different functions for you in order to give you a principle coordinates analysis plot right away with the core diversity functions. The core diversity function calculates the distance matrices for 3 of the most common beta diversity metrics, then calculates eigen vectors and principle components and plots them with a cool visualizer that is pretty easy to format (too easy sometimes, be careful!). Before we look at the graphs let's also calculate significance with permanova so we can discuss what it means with the graph as a visualization. In order to do this, use the "beta-group-significance" command. Add the `--p-pairwise` option to test for differences between all pairs of sample types.

```bash
$ qiime diversity beta-group-significance \
 --i-distance-matrix core-div/weighted_unifrac_distance_matrix.qza \
 --m-metadata-file metadata/SraRunTable_full.txt \
 --m-metadata-column sample_type \
 --o-visualization core-div/weighted_unifrac_SigTest_SampleType.qzv \
 --p-pairwise
```

- Download the 2 files in the core-div directory: `weighted_unifrac_emperor.qzv` and `weighted_unifrac_SigTest_SampleType.qzv`.

Bring them both into the qiime2 visualizer and let's examine them. First, a couple things to note about the test. This is a non-parametric test (PERMANOVA = permutational multivariate ANOVA) where the distribution to test against is created by performing a number of random shuffling of the data. The number of digits of the p-value cannot exceed the number of permutations. By default this does 999 permutations, thus the minimum p-value is 0.001. It is NOT p < 0.001. Second, the pairwise option is off by default because if you have a number of factor levels with many permutations this can take quite a long time to finish. Third, note that a significant value just tells us the communities are significantly different.

Look at the PCoA visualization. This emperor plugin is pretty nice and has lots of options for visualizing your data. You can color by any of the variables in your metadata file. Go to the color tab and choose "sample_type". You can really see how the samples are different from one another, and get a qualitative sense that the nasal and BAL sample types are more similar to one another. You can get the actual distances between the types downloaded from the significance visualizer.

A couple points on these PCoA plots though. First, notice there are 3 axes shown. This is one of the advantages and disadvantages of PCoA as a multidimensional reduction method. Some methods you may be familiar with such as NMDS, tSNE and UMAP reduce the data into a 2D space. These are probably more appropriate for publication (usually a 2D space), but almost inevitably have more stress in them. Basically error, because it's usually unlikely to find a single 2D solution for high dimensional data. They tend to not look as nicely clustered. At least when they work on the original distances. tSNE and UMAP in scRNAseq you are probably used to seeing now are usually operated on the principal components, so are sort of reductions upon reductions and give the impression of nicer clusters than they usually would if operated on the original distances. Nothing wrong with this, just be aware of what you are really looking at. The reason PCoA gives the impression of nice clusters usually is because you are seeing the first 3 (or 2) of many axes of variation and the axes are ordered by decreasing amount of variation. Notice this in the % for each PC (principle component). QIIME2 is only showning the first 5 for some reason (they used to have ability to see all), but most of the variation is captured in the first 3 (~60%). It's important when looking at these graphs to see how much of the variation you are seeing and which axes. There may be much more than the presenter is showing you and it can be evident by the axes.

Second, the space these points are in (the axes) is created by the input dataset itself (as in other multidimensional reduction methods) - the axes have no absolute meaning. Notice there is a tab for "visibility". It's hard for me to imagine what situation warrants this option. As a clearer example:
1. Get only 2 axes: Click on the axes tab and get axes 1 and axes 4. For the third option, choose "hide axis".
2. Click on the visibility tab and click on fecal to remove it's visibility

Notice how the points stretch all the way up the top of the y-axis, but without the fecal data the points don't stretch to the end of the x-axis. This shows how the axes are determined by the dataset, and thus hiding data is misleading. You would need to subset the data and recalculate the PCs to do this properly.

## Step 5 (sort of): Subset the table
We went through much more of an exploratory analysis of the full data in the above sections. This is not a bad idea with your own dataset either, but ultimately you likely want to test specific hypotheses about some of your data that would probably require you to subset it first. Going through the full dataset also allowed some opportunities for me to discuss some potential pitfalls and poor inference possible with diversity analyses in HTseq. So, although it seems strange to end at subsetting, it was fun to see the full dataset first and the potential differences among body sites. Let's subset the data before we look to see if we can detect taxonomic differences among asthmatics. While frequently reported, this does remain a bit unclear and it there seems to be little consistency between studies.

There's a couple different ways to subset your data with the same qiime2 command. The simplest way is probably to provide a list of the sample IDs. A more efficient way to subset is using the statements with the `--p-where` option. These use SQL syntax. This syntax is used all over for working with data tables and we'll see similar methods with some R packages. It's easy when you are only trying to grab one category, but a bit more complicated when trying to pass multiple options. Let's subset to just the BAL samples for further exploration.

```bash
$ qiime feature-table filter-samples \
 --i-table table_full.qza \
 --o-filtered-table table_full_BAL.qza \
 --m-metadata-file metadata/SraRunTable_full.txt \
 --p-where "SampleType == 'BAL'"
```

# Practice / With Your Own Data
- Go through analysis with the newly subsetted BAL samples only and explore associations of diversity with asthma and obesity status.
- Use the subsetted BAL (or full if you like) data to create barplots of taxa and use one of the methods described on QIIME2's site to explore associations of taxa with asthma and/or obesity status. Use the `taxonomy_full.qza` file in my shared class folder (not the test taxonomy.qza file). Hint, gneiss and ANCOM are 2 plugins. Gneiss can take a general linear model equation.
- Write a for loop with a list of alpha diveristy metrics of interest to quickly calculate them. Use another for loop to create visualizers of the results with a metadata category. How should you correct for multiple hypothesis testing now?

# Links / Cheatsheets / Today's New Commands
- QIIME2's tutorial's page: [https://docs.qiime2.org/2020.2/tutorials/](https://docs.qiime2.org/2020.2/tutorials/)
- QIIME2's plugin documentation page: [https://docs.qiime2.org/2020.2/plugins/](https://docs.qiime2.org/2020.2/plugins/)
