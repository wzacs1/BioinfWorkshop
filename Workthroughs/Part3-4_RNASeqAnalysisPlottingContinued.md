<!-- TOC -->

- [Main](#main)
	- [Requirements / Inputs](#requirements--inputs)
	- [Objectives](#objectives)
	- [Start RStudio Server Interactive App on OnDemand](#start-rstudio-server-interactive-app-on-ondemand)
	- [Load Project](#load-project)
	- [Continue with DTE/DGE from last class](#continue-with-dtedge-from-last-class)
		- [Step 6 (optional): DGE analysis with swish](#step-6-optional-dge-analysis-with-swish)
		- [Step 7 (optional): Examine differential transcript isoform usage](#step-7-optional-examine-differential-transcript-isoform-usage)
		- [Step 8: Built-in plots with fishpond](#step-8-built-in-plots-with-fishpond)
		- [Step 9: Extract the table of results](#step-9-extract-the-table-of-results)
			- [Install the genome wide annotation database for humans.](#install-the-genome-wide-annotation-database-for-humans)
	- [Term enrichment, GSEA, etc. with ClusterProfiler package](#term-enrichment-gsea-etc-with-clusterprofiler-package)
		- [Create a named, sorted vector of genes significantly different](#create-a-named-sorted-vector-of-genes-significantly-different)
		- [General Term Enrichment in `clusterProfiler`](#general-term-enrichment-in-clusterprofiler)
		- [Specific database functions for enrichment in `clusterProfiler`](#specific-database-functions-for-enrichment-in-clusterprofiler)
	- [Volcano plots with `EnhancedVolcano` package](#volcano-plots-with-enhancedvolcano-package)
	- [`ggplot2`: powerful graphics in R](#ggplot2-powerful-graphics-in-r)
	- [Moving forward in bioinformatics:](#moving-forward-in-bioinformatics)
- [Links](#links)

<!-- /TOC -->
# Main

## Requirements / Inputs
1. A CHPC account and OnDemand login
2. RStudio Server session from ondemand-class.chpc.utah.edu.
   1. [Reminder] Classes menu and MIB2020. 2 cores and 3 hours.
3. (optional) RStudio installed on desktop/laptop
4. `tidyverse`, `tximeta`, `fishpond` packages (and dependencies) installed in R. For install in RStudio Server OnDemand:
```r
install.packages('rlang', lib = .libPaths()[1], version = '0.4.11', INSTALL_opts = "--no-lock")

install.packages('Rcpp', lib = .libPaths()[1])

BiocManager::install( c('DESeq2', 'fishpond', 'tximeta', 'tidyverse', 'clusterProfiler', 'DOSE'), lib = .libPaths()[1], ask = FALSE )
```
5. Project and workspace from last class with objects:
	1. metadata_singleSamp (must have "names" and "files" columns)
	2. sS_se
 **OR**
- Load these 2 objects from shared space into a Project "Part3_R_RNAseq":
```r
readRDS(file = "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/metadata_singleSamp_fix.rds" )
readRDS(file = "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/sS_se_singleSamp.rds" )
```

## Objectives
##### I. Finish differential expression analysis on transcripts and genes.
##### II. Introduce a few useful/example plotting and analysis packages for DTE/DGE results.
##### III. Intro the structure of ggplots2 commands.
##### IV. Gain more R experience.

## Start RStudio Server Interactive App on OnDemand
- If not already done.

## Load Project
**Load Project from last class**:
- In the upper right hand corner of RStudio underneath power button, or with `File -> Open Project..`, browse to and open the project file that should be named the same as the Folder "Part3_R_RNAseq.Rproj".
  - This project should have save object `sS_se` in it at least. If not, you should read it in from the shared space (in class to save time), or recreate it with the commands from last session.
  - If you didn't save your project from last time, you may need to create a new project and import the shared sS_se object as detailed above.

## Continue with DTE/DGE from last class

Last class, we just got through the differential test with swish on the transcripts. We will continue with this part before moving onto some useful plotting packages and gaining more experience in R.

### Step 6 (optional): DGE analysis with swish

- We can still perform gene-level differential expression (DGE) analysis because transcripts can be grouped by the genes they come from. The reverse is not necessarily true (i.e. if we did gene level counting/alignments we couldn’t necessarily back out to transcript-level). The testing of differences is basically the same, but we first need to regroup them to genes. `tximeta` provides a function for this, and because we linked all the reference information to the index, all the information required to do this is already together.

``` r
sS_se_gene <- summarizeToGene(sS_se)
```

Notice the object is still a summarized experiment object, but is ~ 4.5X smaller. Clearly we have lost a LOT of information by doing gene-level analysis. That is not to say that this is inappropriate or not what we are looking for. As before, we scale filter/mask genes with low counts. If we started with gene level grouping we would need to do `scaleInfReps()` as well first, but since these reps are at the level of transcript and we already scaled them we don’t need to do it again.

``` r
sS_se_gene <- labelKeep(sS_se_gene, minCount = 100, minN = 5)
```

Let’s run swish again to test for differences at the gene-level. Because this is much smaller we can run a lot more permutations quickly than we did with the transcript-level data set.

``` r
set.seed(1)
sS_se_gene <- swish(sS_se_gene, x = "smoking_status", nperms = 50)
```

Then, let’s just retrieve the number of genes with a q < 0.05 as before. (again, I'm putting specific pacakge names for functions to be clear (PackageName::FunctionName) )

``` r
SummarizedExperiment::mcols(sS_se_gene) %>% as_tibble() %>% dplyr::filter( qvalue < 0.05 ) %>% nrow()
```

We do have some differences between smokers and non-smokers. Outside of class, take a look at the other factors as well.
	- Notice that you can use add in a covariate or sample pairings. See the swish() command for more documentation.
	- Anything more than 2 factors does not currently run well in swish function. Use original DESeq2 instead which can build (or at least deal with) much more complicated models.

### Step 7 (optional): Examine differential transcript isoform usage

- In the interest of time in class, we will skip this section, but be aware it is possible. Here, briefly how this can be performed (requires fishpond > 1.4):

``` r
sS_se_iso <- isoformProportions(sS_se)
sS_se_iso <- swish(sS_se_iso, x="smoking_status", nperms=50)
```

### Step 8: Built-in plots with fishpond

- The `fishpond` package, as with most good packages, provides a few simple graphing functions to help you get a sense of your data as you move along. However, most of your graphing will be done with graphing-specific packages (such as `ggplots`) or other downstream analysis packages. We’ll just look at an MA plot and a plot of inferential replicates for a gene to see how they look.

-   First, the MA plot.

It’s always good to inspect your data with significant differences highlighted with an MA plot to see if there is any obvious systematic bias. These should *usually* look pretty evenly centered around 0 log2FC. If you have a strong detection bias you might see only significant differences towards the right or only major fold changes at one end of these plots. Because one of Salmon and swish’s main goals is to model and correct for known biases these plots look really good.

``` r
plotMASwish(sS_se)
```

-   Plot the range of counts from inferential replicates for a given gene amongst all samples.

``` r
plotInfReps(sS_se, idx = "ENST00000380859", x = "smoking_status", legend = TRUE)
```

- Here, just notice some of the options to the plotInfReps() command for plotting. Many of these are common because they call base R plotting functions so it's worth noting some and being familiar with the frequent shorthand used in R:
  - "xlab": x axis labels. You can pass your own text here to relabel it.
  - "main": main title. Again, can relabel as desired.
  - "ylim": y axis limits. Pass a range of values in a vector c().


- This transcript actually has one of the lowest q-values. You can see it is different amongst smokers (orange) and non-smokers (blue), but many smokers it is still quite low. While this difference may not look very impressive, it is reflective of how actual human data often looks, and I think serves as a better example than data often attached to packages and worked through in vignettes because it is more reflective of how human data tends to look, while vignettes usually grab some highly controlled cell culture data.

### Step 9: Extract the table of results

Before we extract the results let’s add NCBI Entrez Gene IDs to the data. These common numeric IDs are frequently used to access genes and their associated annotations and are supposed to be resistant to gene name changes. We currently have ENSEMBL IDs that serve a similar purpose.

#### Install the genome wide annotation database for humans.

These genome wide annotations are available precompiled for many model organisms and you can create your own as well quite easilty from NCBI’s repository for an organism with the annotation forge package. These are very useful packages because they contain just about all the info for an organism you can think of in a single place (genes, transcripts, functions, ontological annotations/terms, alternative gene names/IDs, etc.). These greatly facilitate the downstream analysis and regrouping functions and we will use it extensively in the following section for graphing and regrouping.

- Install the annotation database for human. In class, if asked to update other packages select 'n' for time.

``` r
BiocManager::install('org.Hs.eg.db')
```

Load the library:

``` r
library(org.Hs.eg.db)
```

- Now add the ENTREZIDs for each gene. Notice that we use gene = TRUE flag for the transcrtipts because ENTREZIDs are for genes.

``` r
sS_se <- addIds(sS_se, column = "ENTREZID", gene = TRUE)
```

- And for the genes set.

``` r
sS_se_gene <- addIds(sS_se_gene, column = "ENTREZID", gene = TRUE)
```


- Now, let’s create a tibble with the results for ALL transcripts and one for ALL genes using commands we have learned before. We’ll just maintain all that were tested for now, but this is often a good time to do some extra filtering as well (maybe log fold changles, or only those which were q < 0.05):

``` r
txps <- mcols(sS_se) %>% as_tibble() %>% filter(keep == TRUE)
genes <- mcols(sS_se_gene) %>% as_tibble() %>% filter(keep == TRUE)
```

- One thing to note in the genes table is that there is a column called "tx_ids" that lists the transcripts that were summarized to get the gene info.

- This is often a time we want to export these tables for saving/sharing with other programs or collaborators. See the `write_`csv/csv2/excel_csv family of functions in the `readr` package.

- Here, if you haven't been able to keep up or create these tables the same (there were some issues in class with different environments and linked transcritpomes) please go ahead and import the objects that I exported already so we can continue to follow along:

``` r
genes <- readRDS(file = "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/genes.RDS")
txps <- readRDS(file = "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/txps.RDS")
```

## Term enrichment, GSEA, etc. with ClusterProfiler package

-   `clusterProfiler` should have already been installed earlier in the week. It has a lot of dependencies so can take awhile.
	- I expected that `enrichplot` was installed with it, but check if it can be loaded (`library('enrichplot')`) and if not install it (`BiocManager::install('enrichplot')` )

  - Please note that I will quickly run throuhg a few examples in class. However, I had you do the testing and import both the the txps set for the metadata_singleSamp test and also create the table for the metadata_repsOnly so that you have other datasets to explore and get more familiar in R. Hopefully, you will use these as an opportunity to practice and gain familiarity.

- Load packages

``` r
library(tidyverse)
library(clusterProfiler)
library(DOSE)
library(org.Hs.eg.db)
library(enrichplot)
```

-   We will use the results table from DE based on “smoking_status” from lung biopsy samples.
-   Make sure we have the same results file.
-   Read them in from objects and check number of differential features

``` r
genes <- readRDS(file = "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/genes.RDS")
txps <- readRDS(file = "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/txps.RDS")
genes %>% filter(qvalue < 0.05) %>% nrow()
```

- The `clusterProfiler` package


-   `clusterProfiler` brings in an impressive number of functions and relies on many other packages.
    -   It goes hand-in-hand with `DOSE` package by same author.
    -   Several other similar packages are out there, but I like this b/c it brings so many functions together in one place (even if docs could be better!)
    -   GO, KEGG term and enrichment, Reactome, MSigDB, MeSH. (wraps `fgsea` with some extra plotting functions too)
-   Generally, need a **named, sorted vector** of genes.

### Create a named, sorted vector of genes significantly different

-   Let’s get just the significant genes. We will build it up a few pieces at at time, but could be done at once. How could you do this for transcripts (hint: you need unique gene names!)

``` r
geneList <- genes %>% filter(ENTREZID != "NA", qvalue < 0.05) %>% dplyr::select(ENTREZID, log2FC)
gL <- as.vector(geneList$log2FC)
str(gL)
```

- Notice how I specified `dplyr::select` (dply is part of tidyverse) because the select function was being masked by another function from other package.
- Now add ENTREZID as names for each entry, but ensure they stored as characters.
  - `names`, like many functions in R, can “get” or “set” names.

``` r
names(gL) <- as.character(geneList$ENTREZID)
str(gL)
```
- Notice how these vector now has each entry named by the ENTREZID.
-   Now, we can just extract the names when we only need the list of genes, but also have the fold changes for functions that require them.
-   Finally, let’s sort our vector by log2FC values

``` r
gL <- sort(gL, decreasing = TRUE)
```

### General Term Enrichment in `clusterProfiler`

-   Many functions in `clusterProfiler` for working with established set specifically (GO, KEGG, DisGeNet, DO). Let’s just focus on generic function withs MSigDB reference sets.
-   Read in the “Hallmarks” gene set from MSigDB. This relates the ENTREZIDs to each Hallmark set (download these from :
    [https://www.gsea-msigdb.org/gsea/msigdb/](https://www.gsea-msigdb.org/gsea/msigdb/)

``` r
hall.gmtFilePath <- "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/h.all.v7.1.entrez.gmt"
hall <- read.gmt(hall.gmtFilePath)
```

- Be aware that the read.gmt function is specific to clusterProfiler. The .gmt files are pretty normal looking R lists, but clusterProfler turns them into a data frame. Other packages (like fgsea) will want them in a different format.


-   Term enrichment just takes the list of genes to test if they are enriched for a category (`enricher` function)
-   Gene set enrichment (GSEA) requires ranked (usually by fold-change) list. (`GSEA` function)
		- I think the fgsea package works a bit better for this. I would use it directly instead. In interest of a short class we will skip the GSEA in clusterProfiler.

``` r
gL_enrich <- enricher(names(gL), TERM2GENE = hall)
```
-   A number of built in plotting functions. Let’s just look at this via the barchart for now:

``` r
barplot(gL_enrich, title = "Hallmark Gene Sets Enriched in Smokers")
```

-   Some of the coolest plots in this package though allow us to see the actual genes and how they relate to these sets. We have ENTREZIDs though, so first convert them to standard names, using the genomic database object and `setReadable` function:

``` r
gL_enrich_symbol <- setReadable(gL_enrich, OrgDb = 'org.Hs.eg.db', 'ENTREZID')
heatplot(gL_enrich_symbol, foldChange = gL)
```

### Specific database functions for enrichment in `clusterProfiler`

-   As a single example of one of the database-specific functions, look at the genes enriched in sets in the DisGeNET database, convert their IDs and plot them again.

``` r
gL_DGN <- enrichDGN(names(gL))
gL_DGN <- setReadable(gL_DGN, OrgDb = 'org.Hs.eg.db', 'ENTREZID')
heatplot(gL_DGN, foldChange = gL)
```

-   It’s nice to show how these gene sets overlap. Often people are confused why, for example, “contact dermatitis” would be in a lung biopsy dataset. Of course, there’s no reason genes wouldn’t be involved in >1 process, but this helps visualize this.
-   For GO term annotations, you should generally specify the specific ontology.

``` r
gL_GO_BP <- enrichGO(names(gL), OrgDb = org.Hs.eg.db, ont = "BP")
gL_GO_BP <- setReadable(gL_GO_BP, OrgDb = 'org.Hs.eg.db', 'ENTREZID')
heatplot(gL_GO_BP, foldChange = gL)
```

- Still not actually the most useful. A bit big and redundant. There is more control over this available, but I leave it to you to examine the docs and come up with plots you like. GO terms are a bit limited in their inferences anyways in my opinion.

-   (NOTE: If you are having trouble viewing the squished plot, run this
    in the regular console (not markdown) and hit the “Zoom” button )

## Volcano plots with `EnhancedVolcano` package

-   Volcano plots are just a dot plot, so terribly easy to plot just the points. Annotating them basically is not too hard either (as we will see), but getting them just right can be surprisingly tedious.
-   Recently I found the `EnhancedVolcano` package which is just amazing in its ability to facilitate what should be a simple task and make much nicer volcano plots:

``` r
BiocManager::install('EnhancedVolcano')
library(EnhancedVolcano)
```

-   We just need a table or tibble or dataframe so we are all set with
    our input tibble.

``` r
EnhancedVolcano(genes , lab = genes$symbol, x = 'log2FC', y = 'pvalue')
```

-   Check out all the options (`?EnhancedVolcano`)! Gives you a sense of why these seemingly easy dotplots can get pretty tricky to do well.
-   Let’s add a few options in to customize (and as a seque):

``` r
EnhancedVolcano(genes , lab = genes$symbol, x = 'log2FC', y = 'pvalue',
                drawConnectors = TRUE, boxedLabels = TRUE,
                ylim = c(0,7), colAlpha = 1, shape = c(1, 12, 4, 5))
```

-   A few nice just aesthetic options like boxes and connectors. But also a few common point and formatting options that control the underlying ggplot2 functions.
    -   `shape`: Actually from base graphics. See `?pch` to find which # for which shape.
    -   `colAlpha`: “alpha” (or some variant) is used to controlling transparency. Import with a lot of overlappiong points.
    -   `ylim`: Common format to specify axes limits. Note how we pass a vector of 2 values for the range.
-   Much more to do with EnhancedVolcano, but really just wanted to introduce it and use to seque to ggplots which this package and `enrichplots` use, as do most R plotting functions.

## `ggplot2`: powerful graphics in R

-   ggplot2 has been around quite awhile and is now part of the tidyverse. Most plotting you will encounter in R uses or wraps ggplot2 functions.
-   Tidyverse functions can really facilitate getting things set up for ggplot2 because they need to be in “tidy” format.
    -   I highly recommend reading further in the ModernDive tidyverse walkthrough (see links). It’s very succinct and explains this better than I probably will.
    -   This will be a very brief intro to ggplots and I encourage you to look into "tidy" data more on your own. I don't think I've done a good job explaining it in class and think it is one of those things it is better to read and sit and think about for a bit. Just be aware ggplot2 generally expects data in long/tidy format.
      - A useful function to convert "wide" tables (what you probably normally think of) to long/tidy ones is the `pivot_longer()` in tidyverse.

-   Graphs (in any program) are built layer upon layer. You may have noticed this if you’ve brought a pdf graph from Prism into a vector graphics editor like Illustrator or Inkscape. With ggplots this becomes more obvious.
-   ggplots have 3 parts:
    1.  Data: Obvious, but can be tibble, data frame, data.table. Some 2D object.
    2.  Aesthetics (“aes”): The color, size, shape of X and Y variables.
    3.  Geometry (“geom”): The type of graph (dotplot/scatter,
        histogram, etc.)
-   Let’s build a basic volcano plot like the EnhancedVolcano package just did in order to illustrate.
-   You will frequently see 2 slight variants on ways to construct graphs, but the 3 parts to a ggplot are always required and these 2 methods produce the same result.
    1.  The definitions for the graph are created as an object with *data* and *aesthetics* first, then *geometry* specified later. (I prefer this b/c it’s easier to change the graph type)
    2.  All three parts are specified at once.

``` r
library(ggplot2)
plot <- ggplot(data = genes, aes(x = log2FC, y = pvalue))
plot + geom_point()
```
-   This (below) is the same in just one command:

``` r
ggplot(data = genes, aes(x = log2FC, y = pvalue)) + geom_point()
```

-   Now we have the basic plot, but not much of a volcano shape yet since we don’t have the log10 pvalues.

``` r
ggplot(data = genes, aes(x = log2FC, y = -log(pvalue))) + geom_point()
```

-   That’s pretty much a standard volcano plot with a very simple command. Of course, we are missing a lot of formatting and highlighting.
-   We can do a lot within the ggplot function (like we did with log fxn), but it gets both very long to read and harder to replot. Instead, add a variable to color by.
    -   For simplicity’s sake, let’s add a variable to our table that specifies groups to color. This might look a litte complex, but it’s just a couple nested “ifelse” statement to describe the 4 types of categories we have for the EnhancedVolcano plots.

``` r
genes <- genes %>% mutate(highlight = if_else(
  pvalue < 0.00001 & abs(log2FC) >= 1, true = "p-value and log2FC",
  false = if_else(pvalue < 0.00001 & abs(log2FC) < 1, true = "p-value",
  false = if_else(pvalue >= 0.00001 & abs(log2FC) >=1, true = "log2FC",
  false = "NS"))))
```

-   We build formatting layer by layer. Which specific color is a formatting choice, but how we assign variables to color groups is an aesthetic definition.

``` r
ggplot(data = genes, aes(x = log2FC, y = -log10(pvalue))) +
  geom_point(aes(color=highlight))
```

-   Nice. Except I don’t really like the bright color for non-significant values. Let’s specify the colors explicitly, again we are building up our plot.

``` r
ggplot(data = genes, aes(x = log2FC, y = -log10(pvalue))) +
  geom_point(aes(color=highlight)) +
  scale_color_manual(values = c("seagreen2", "grey", "blue", "red"))
```

-   Colors can be specified with Hex codes (in quotes) or their natural names. There are a ton of named colors (see link).

-   “Themes” are built in combinations of background color and grid spacing. Change to minimal:

``` r
ggplot(data = genes, aes(x = log2FC, y = -log10(pvalue))) +
  geom_point(aes(color=highlight)) +
  scale_color_manual(values = c("seagreen2", "grey", "blue", "red")) +
  theme_minimal()
```
-   Last, add lines for visual effect:

``` r
ggplot(data = genes, aes(x = log2FC, y = -log10(pvalue))) +
  geom_point(aes(color=highlight)) +
  scale_color_manual(values = c("seagreen2", "grey", "blue", "red")) +
  theme_minimal() +
  geom_vline(xintercept = 1, linetype = "dashed") +
  geom_vline(xintercept = -1, linetype = "dashed") +
  geom_hline(yintercept = 5, linetype = "dashed")
```

-   Let’s change the shape of the groups as we did before, and the alpha values for transparency.
    -   Notice that we need to specify the shape as an aesthetic.

``` r
ggplot(data = genes, aes(x = log2FC, y = -log10(pvalue))) +
  geom_point(aes(color=highlight, shape = highlight), alpha = 0.9) +
  scale_color_manual(values = c("seagreen2", "grey", "blue", "red")) +
  theme_minimal() +
  geom_vline(xintercept = 1, linetype = "dashed") +
  geom_vline(xintercept = -1, linetype = "dashed") +
  geom_hline(yintercept = 5, linetype = "dashed") +
  scale_shape_manual(values = c(1, 12, 4, 5))
```
-   Finally, remove the legend title:

``` r
ggplot(data = genes, aes(x = log2FC, y = -log10(pvalue))) +
  geom_point(aes(color=highlight, shape = highlight), alpha = 0.9) +
  scale_color_manual(values = c("seagreen2", "grey", "blue", "red")) +
  theme_minimal() +
  geom_vline(xintercept = 1, linetype = "dashed") +
  geom_vline(xintercept = -1, linetype = "dashed") +
  geom_hline(yintercept = 5, linetype = "dashed") +
  scale_shape_manual(values = c(1, 12, 4, 5)) +
  theme(legend.title = element_blank())
```

-   Easy, right!?

-   Graphing with ggplots is not exactly easy, but it is practically limitless and we just scratched the surface to get a sense of how it
    works and, *hopefully*, demystify it a little bit so it's easier for you to jump into when you start with your own data.
    -   The link I provided at the bottom (“be awesome in ggplots”) is a particularly outstanding resource for ggplots.
-   Many other plot types (geometries) are availabe: `geom_box`, `geom_violin`, `geom_contour`, etc. If it was plotted in an R function, it was likely plotted with ggplots.

## Moving forward in bioinformatics:

-   Thank you for participating and putting time into learning something new and not biology!
-   “Just do it”!! Free experimentation with immediate results. Bioinformatics can be frustrating at times, but quite satisfying to see your work so quickly and without expensive raagents, animals, etc.
    -   Google, Stackexchange, Stackedit, Coursera
    -   Talk to each other, talk to me!
-   CHPC training series
- Just do it! Seriously. While it is starting to change a bit now, it is very common among folks doing bioinformatics to have started as a biologist with a question (just like you) and not have any comp sci background.

# Links

-   [clusterProfiler Book
    page](https://yulab-smu.github.io/clusterProfiler-book/chapter1.html)
-   Be awesome in ggplots page: [Awesome
    ggplots](http://www.sthda.com/english/wiki/be-awesome-in-ggplot2-a-practical-guide-to-be-highly-effective-r-software-and-data-visualization)
-   Modern Dive into tidyverse:
    [ModernDive](https://moderndive.com/4-tidy.html)
-   R built-in colors cheatsheet: [R
    colors](https://www.nceas.ucsb.edu/sites/default/files/2020-04/colorPaletteCheatsheet.pdf)
