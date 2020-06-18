-   [Main](#main)
    -   [Requirements](#requirements)
    -   [Objectives](#objectives)
    -   [Setup and Input data](#setup-and-input-data)
    -   [The `clusterProfiler` package](#the-clusterprofiler-package)
    -   [Create a named, sorted vector of genes significantly
        different](#create-a-named-sorted-vector-of-genes-significantly-different)
    -   [General Term and Gene set enrichment in
        `clusterProfiler`](#general-term-and-gene-set-enrichment-in-clusterprofiler)
    -   [Specific database functions for enrichment in
        `clusterProfiler`](#specific-database-functions-for-enrichment-in-clusterprofiler)
    -   [Volcano plots with `EnhancedVolcano`
        package](#volcano-plots-with-enhancedvolcano-package)
    -   [`ggplot2`: powerful graphics in
        R](#ggplot2-powerful-graphics-in-r)
        -   [(aside) “Tidy” data](#aside-tidy-data)
    -   [`ggplot2`: powerful graphics in R
        (cont.)](#ggplot2-powerful-graphics-in-r-cont.)
-   [Final Remarks](#final-remarks)
    -   [Feedback:](#feedback)
    -   [Moving forward in
        bioinformatics:](#moving-forward-in-bioinformatics)
-   [Links](#links)

Main
====

Requirements
------------

-   RStudio Server session on lonepeak-shared. 4 cores.
-   Create **NEW** RStudio Project (in new directory, call it whatever
    you like) and import the results from last class (ensure we all work
    with same objects / avoid package conflicts):

``` r
genes <- readRDS(file = "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/genes.RDS")
txps <- readRDS(file = "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/txps.RDS")
```

-   Installed packages: `tidyverse`, `clusterProfiler`,
    `EnhancedVolcano`, `org.Hs.eg.db`. (`ggplot2` will be installed in
    system library)

Objectives
----------

-   Perform GO term and higher level enrichment analysis with
    clusterProfiler package
-   Understand basic structure of ggplot package
-   Introduce easy to use volcano plot package

Setup and Input data
--------------------

-   Load packages

``` r
library(tidyverse)
library(clusterProfiler)
library(DOSE)
library(org.Hs.eg.db)
library(enrichplot)
```

-   We will use the results table from DE based on “smoking\_status”
    from lung biopsy samples.
-   Make sure we have the same results file.
-   Read them in from objects and check number of differential features

``` r
genes <- readRDS(file = "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/genes.RDS")
txps <- readRDS(file = "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/txps.RDS")
genes %>% filter(qvalue < 0.05) %>% nrow()
```

    ## [1] 180

``` r
txps %>% filter(qvalue < 0.05) %>% nrow()
```

    ## [1] 231

The `clusterProfiler` package
-----------------------------

-   `clusterProfiler` brings in an impressive number of functions and
    relies on many other packages.
    -   It goes hand-in-hand with `DOSE` package by same author.
    -   Several other similar packages are out there, but I like this
        b/c it brings so many functions together in one place (even if
        docs could be better)
    -   GO, KEGG term and enrichment, Reactome, MSigDB, MeSH. (wraps
        `fgsea`)  
-   Generally, need a named, sorted vector of genes.

Create a named, sorted vector of genes significantly different
--------------------------------------------------------------

-   Let’s get just the significant genes. We will build it up a few
    pieces at at time, but could be done at once. How could you do this
    for transcripts (hint: you need unique gene names!)

``` r
geneList <- genes %>% filter(ENTREZID != "NA", qvalue < 0.05) %>% dplyr::select(ENTREZID, log2FC)
gL <- as.vector(geneList$log2FC)
str(gL)
```

    ##  num [1:174] 1.021 -1.028 0.649 0.274 0.406 ...

-   Notice how I specified `dplyr::select` (dply is part of tidyverse)
    because the select function was being masked by another function
    from other package.
-   Now add ENTREZID as names for each entry, but ensure they stored as
    characters. `names`, like many functions in R, can “get” or “set”
    names.

``` r
names(gL) <- as.character(geneList$ENTREZID)
str(gL)
```

    ##  Named num [1:174] 1.021 -1.028 0.649 0.274 0.406 ...
    ##  - attr(*, "names")= chr [1:174] "2729" "53616" "4257" "6050" ...

-   Now, we can just extract the names when we only need the list of
    genes, but also have the fold changes for functions that require
    them.
-   Finally, let’s sort our vector by log2FC values

``` r
gL <- sort(gL, decreasing = TRUE)
```

General Term and Gene set enrichment in `clusterProfiler`
---------------------------------------------------------

-   Many functions in `clusterProfiler` for working with established set
    specifically (GO, KEGG, DisGeNet, DO). Let’s just focus on generic
    function withs MSigDB reference sets.
-   Read in the “Hallmarks” gene set from MSigDB. This relates the
    ENTREZIDs to each Hallmark set (download these from :
    <a href="https://www.gsea-msigdb.org/gsea/msigdb/" class="uri">https://www.gsea-msigdb.org/gsea/msigdb/</a>)

``` r
hall.gmtFilePath <- "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/h.all.v7.1.entrez.gmt"
hall <- read.gmt(hall.gmtFilePath)
```

-   Term enrichment just takes the list of genes to test if they are
    enriched for a category (`enricher` function)
-   Gene set enrichment (GSEA) requires ranked (usually by fold-change)
    list. (`GSEA` function)

``` r
gL_enrich <- enricher(names(gL), TERM2GENE = hall)
gL_gsea <- GSEA(gL, TERM2GENE = hall)
```

    ## preparing geneSet collections...

    ## GSEA analysis...

    ## leading edge analysis...

    ## done...

-   A number of built in plotting functions. Let’s just look at this via
    the barchart for now:

``` r
barplot(gL_enrich, title = "Hallmark Gene Sets Enriched in Smokers")
```

![](Part3-5_files/figure-markdown_github/unnamed-chunk-9-1.png)

-   Some of the coolest plots in this package though allow us to see the
    actual genes and how they relate to these sets. We have ENTREZIDs
    though, so first convert them to standard names, using the genomic
    database object and `setReadable` function:

``` r
gL_enrich_symbol <- setReadable(gL_enrich, OrgDb = 'org.Hs.eg.db', 'ENTREZID')
heatplot(gL_enrich_symbol, foldChange = gL)
```

![](Part3-5_files/figure-markdown_github/unnamed-chunk-10-1.png)

-   These are fairly small enriched sets (I chose them because of this -
    so it’s easy to visualize in graphs), but often you have much larger
    and highly overlapping sets. Check out the upset plots and
    enrichment map functions in as part of this package as well.
-   Note: `bitr` function in this package helps facilitate a lot of gene
    Identifier conversions.
-   We can get the classic GSEA plot for our single enriched gene set
    with these built-in plotting functions as well. We need specify the
    index \# of the gene set, which for us there is only 1.

``` r
gseaplot2(gL_gsea, geneSetID = 1)
```

![](Part3-5_files/figure-markdown_github/unnamed-chunk-11-1.png)

Not too impressive given the few genes in our list, but shows how to use
this function. The ‘fgsea’ package (which this wraps) is also helpful
for these plots.

Specific database functions for enrichment in `clusterProfiler`
---------------------------------------------------------------

-   As a single example of one of the database-specific functions, look
    at the genes enriched in sets in the DisGeNET database, convert
    their IDs and plot them again.

``` r
gL_DGN <- enrichDGN(names(gL))
gL_DGN <- setReadable(gL_DGN, OrgDb = 'org.Hs.eg.db', 'ENTREZID')
heatplot(gL_DGN, foldChange = gL)
```

![](Part3-5_files/figure-markdown_github/unnamed-chunk-12-1.png)

-   It’s nice to show how these gene sets overlap. Often people are
    confused why, for example, “endometriosis of ovary” would be in a
    lung biopsy dataset. Of course, there’s no reason genes wouldn’t be
    involved in &gt;1 process, but this helps visualize this.
-   For GO term annotations, you should generally specify the specific
    ontology.

``` r
gL_GO_BP <- enrichGO(names(gL), OrgDb = org.Hs.eg.db, ont = "BP")
gL_GO_BP <- setReadable(gL_GO_BP, OrgDb = 'org.Hs.eg.db', 'ENTREZID')
heatplot(gL_GO_BP, foldChange = gL)
```

![](Part3-5_files/figure-markdown_github/unnamed-chunk-13-1.png)

-   (NOTE: If you are having trouble viewing the squished plot, run this
    in the regular console (not markdown) and hit the “Zoom” button )

Volcano plots with `EnhancedVolcano` package
--------------------------------------------

-   Volcano plots are just a dot plot, so terribly easy to plot just the
    points. Annotating them basically is not too hard either (as we will
    see), but getting them just right can be surprisingly tedious.
-   Recently found the `EnhancedVolcano` package which is just amazing
    in its ability to facilitate what should be a simple task and make
    much nicer volcano plots:

``` r
library(EnhancedVolcano)
```

-   We just need a table or tibble or dataframe so we are all set with
    our input tibble.

``` r
EnhancedVolcano(genes , lab = genes$symbol, x = 'log2FC', y = 'pvalue')
```

![](Part3-5_files/figure-markdown_github/unnamed-chunk-15-1.png)

-   Check out all the options (`?EnhancedVolcano`)! Gives you a sense of
    why these seemingly easy dotplots can get pretty tricky to do well.
-   Let’s add a few options in to customize (and as a seque):

``` r
EnhancedVolcano(genes , lab = genes$symbol, x = 'log2FC', y = 'pvalue', 
                drawConnectors = TRUE, boxedLabels = TRUE, 
                ylim = c(0,7), colAlpha = 1, shape = c(1, 12, 4, 5))
```

![](Part3-5_files/figure-markdown_github/unnamed-chunk-16-1.png)

-   A few nice just aesthetic options like boxes and connectors. But
    also a few common point and formatting options that control the
    underlying ggplot2 functions.
    -   `shape`: Actually from base graphics. See `?pch` to find which
        \# for which shape.
    -   `colAlpha`: “alpha” (or some variant) is used to controlling
        transparency. Import with a lot of overlappiong points.
    -   `ylim`: Common format to specify axes limits. Note how we pass a
        vector of 2 values for the range.
-   Much more to do with EnhancedVolcano, but really just wanted to
    introduce it and use to seque to ggplots which this package and
    `enrichplots` use, as do most R plotting functions.

`ggplot2`: powerful graphics in R
---------------------------------

-   ggplot2 has been around quite awhile and is now part of the
    tidyverse.
-   Tidyverse functions can really facilitate getting things set up for
    ggplot2 because they need to be in “tidy” format.
    -   I highly recommend reading further in the ModernDive tidyverse
        walkthrough (see links). It’s very succinct and explains this
        better than I probably will.
    -   This will be a very brief intro to ggplots and tidy data.

### (aside) “Tidy” data

-   “Tidy” data has one piece of information for each variable.
-   Our input feautre data are actually already tidy, because columns
    (variables) for each gene/txps (observations) contains only one type
    of data. This is because we have 2 separate tables for genes versus
    transcripts.
-   However, imagine a table that might seem similarly formatted where
    we had gene identifiers (for example, Entrez IDs) with log2
    fold-change values from the most abundant transcript and the gene
    summarized changes.

``` r
head(joined)
```

    ## # A tibble: 6 x 3
    ##   ENTREZID log2FC_gene log2FC_txp
    ##   <chr>          <dbl>      <dbl>
    ## 1 7105        -0.00692    -0.0152
    ## 2 8813         0.287       0.308 
    ## 3 57147        0.0212     -0.0216
    ## 4 55732       -0.0338     -0.0429
    ## 5 2268        -0.438      NA     
    ## 6 3075        -0.131      -0.0492

-   In this case, we have 3 pieces of information: EntrezID, log2FC
    value and the log2FC type. However, last variable (the log2FC type)
    is stuck together with the value itself. This data is not considered
    tidy.
-   This format, which is probably quite natural to us, is referred to
    as “wide”. Perhaps you can see why when we change this to “long”
    format.
-   The tidyverse has a function for that! Thankfully, because this task
    can be frustrating.

``` r
joined_long <- pivot_longer(joined, names_to = "FeatureType", values_to = "log2FC", cols = -ENTREZID)
head(joined_long)
```

    ## # A tibble: 6 x 3
    ##   ENTREZID FeatureType   log2FC
    ##   <chr>    <chr>          <dbl>
    ## 1 7105     log2FC_gene -0.00692
    ## 2 7105     log2FC_txp  -0.0152 
    ## 3 8813     log2FC_gene  0.287  
    ## 4 8813     log2FC_txp   0.308  
    ## 5 57147    log2FC_gene  0.0212 
    ## 6 57147    log2FC_txp  -0.0216

-   Certainly, you can see the difference in the two tables, though they
    hold the same information.
-   In the `joined_long` table we sill have observations in rows and
    variables in columns, but we now have 2 observations for each Entrez
    ID, but they are still distinct because they are connected to the
    “FeatureType”. The table is **long**er.
-   For me, this is always a bit of a tricky concept, and I want to
    reiterate it is something worth spending some time outside of class
    to understand.
    -   Generally, you will need long format data for plotting in
        ggplot.

`ggplot2`: powerful graphics in R (cont.)
-----------------------------------------

-   Graphs (in any program) are built layer upon layer. You may have
    noticed this if you’ve brought a pdf graph from Prism into a vector
    graphics editor like Illustrator or Inkscape. With ggplots this
    becomes more obvious.
-   ggplots have 3 parts:
    1.  Data: Obvious, but can be tibble, data frame, data.table. Some
        2D object.
    2.  Aesthetics (“aes”): The color, size, shape of X and Y variables.
    3.  Geometry (“geom”): The type of graph (dotplot/scatter,
        histogram, etc.)
-   Let’s build a basic volcano plot like the EnhancedVolcano package
    just did in order to illustrate.
-   You will frequently see 2 slight variants on ways to construct
    graphs, but the 3 parts to a ggplot are always required and these 2
    methods produce the same result.
    1.  The definitions for the graph are created as an object with
        *data* and *aesthetics* first, then *geometry* specified later.
        (I prefer this b/c it’s easier to change the graph type)
    2.  All three parts are specified at once.

``` r
library(ggplot2)
plot <- ggplot(data = genes, aes(x = log2FC, y = pvalue))
plot + geom_point()
```

![](Part3-5_files/figure-markdown_github/unnamed-chunk-20-1.png)

-   This is the same in just one command:

``` r
ggplot(data = genes, aes(x = log2FC, y = pvalue)) + geom_point()
```

-   Now we have the basic plot, but not much of a volcano shape yet
    since we don’t have the log10 pvalues.

``` r
ggplot(data = genes, aes(x = log2FC, y = -log(pvalue))) + geom_point()
```

![](Part3-5_files/figure-markdown_github/unnamed-chunk-22-1.png)

-   That’s pretty much a standard volcano plot with a very simple
    command. Of course, we are missing a lot of formatting and
    highlighting.
-   We can do a lot within the ggplot function (like we did with log
    fxn), but it gets both very long to read and harder to replot.
    Instead, add a variable to color by.
    -   For simplicity’s sake, let’s add a variable to our table that
        specifies groups to color. This might look a litte complex, but
        it’s just a couple nested “ifelse” statement to describe the 4
        types of categories we have for the EnhancedVolcano plots.

``` r
genes <- genes %>% mutate(highlight = if_else(
  pvalue < 0.00001 & abs(log2FC) >= 1, true = "p-value and log2FC", 
  false = if_else(pvalue < 0.00001 & abs(log2FC) < 1, true = "p-value", 
  false = if_else(pvalue >= 0.00001 & abs(log2FC) >=1, true = "log2FC", 
  false = "NS"))))
```

-   We build formatting layer by layer. Which specific color is a
    formatting choice, but how we assign variables to color groups is an
    aesthetic definition.

``` r
ggplot(data = genes, aes(x = log2FC, y = -log10(pvalue))) + 
  geom_point(aes(color=highlight))
```

![](Part3-5_files/figure-markdown_github/unnamed-chunk-24-1.png)

-   Nice. Except I don’t really like the bright color for
    non-significant values. Let’s specify the colors explicitly, again
    we are building up our plot.

``` r
ggplot(data = genes, aes(x = log2FC, y = -log10(pvalue))) + 
  geom_point(aes(color=highlight)) + 
  scale_color_manual(values = c("seagreen2", "grey", "blue", "red"))
```

![](Part3-5_files/figure-markdown_github/unnamed-chunk-25-1.png)

-   Colors can be specified with Hex codes (in quotes) or their natural
    names. There are a ton of named colors (see link).

-   “Themes” are built in combinations of background color and grid
    spacing. Change to minimal:

``` r
ggplot(data = genes, aes(x = log2FC, y = -log10(pvalue))) + 
  geom_point(aes(color=highlight)) +
  scale_color_manual(values = c("seagreen2", "grey", "blue", "red")) + 
  theme_minimal()
```

![](Part3-5_files/figure-markdown_github/unnamed-chunk-26-1.png)

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

![](Part3-5_files/figure-markdown_github/unnamed-chunk-27-1.png)

-   Let’s change the shape of the groups as we did before, and the alpha
    values for transparency.
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

![](Part3-5_files/figure-markdown_github/unnamed-chunk-28-1.png)

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

![](Part3-5_files/figure-markdown_github/unnamed-chunk-29-1.png)

-   Easy, right!?

-   Graphing with ggplots is not exactly easy, but it is practically
    limitless and we just scratched the surface to get a sense of how it
    works.
    -   The link I provided at the bottom (“be awesome in ggplots”) is a
        particularly outstanding resource for ggplots.
-   Many other plot types (geometries) are availabe: `geom_box`,
    `geom_violin`, `geom_contour`, etc. If it was plotted in an R
    function, it was likely plotted with ggplots.

Final Remarks
=============

Feedback:
---------

-   **I would love to hear any suggestions on course order, content,
    coverage, etc.**
-   First time course, completely *de novo*. Lot’s of content in a short
    time frame.
    -   Goals were different than most of these types of classes:
        UofU-resource-specific, working knowledge/technical/lab.
    -   Plan to hold this yearly, likely an official course.

Moving forward in bioinformatics:
---------------------------------

-   Thank you!
-   “Just do it” (please don’t sue me Nike). Free experimentation with
    immediate results.
    -   Google, Stackexchange, Stackedit, Coursera
    -   Talk to each other, talk to me!
-   CHPC training series

Links
=====

-   [clusterProfiler Book
    page](https://yulab-smu.github.io/clusterProfiler-book/chapter1.html)
-   Be awesome in ggplots page: [Awesome
    ggplots](http://www.sthda.com/english/wiki/be-awesome-in-ggplot2-a-practical-guide-to-be-highly-effective-r-software-and-data-visualization)
-   Modern Dive into tidyverse:
    [ModernDive](https://moderndive.com/4-tidy.html)
-   R built-in colors cheatsheet: [R
    colors](https://www.nceas.ucsb.edu/sites/default/files/2020-04/colorPaletteCheatsheet.pdf)
