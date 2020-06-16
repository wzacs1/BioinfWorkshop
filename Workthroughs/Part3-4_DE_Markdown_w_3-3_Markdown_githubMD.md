-   [Main](#main)
    -   [Requirements](#requirements)
    -   [Objectives](#objectives)
    -   [General workflow overview](#general-workflow-overview)
    -   [Summarized Part3-3 for metadata table import and
        formatting](#summarized-part3-3-for-metadata-table-import-and-formatting)
        -   [Setup / Background](#setup-background)
        -   [Data import](#data-import)
        -   [Filter out unneeded
            metadata](#filter-out-unneeded-metadata)
        -   [Create subsets of data](#create-subsets-of-data)
        -   [Add the paths for each alignment
            sample](#add-the-paths-for-each-alignment-sample)
        -   [Join the paths into each subsetted
            table](#join-the-paths-into-each-subsetted-table)
        -   [Cleaning](#cleaning)
    -   [Part 3-4: Import and DE
        analysis](#part-3-4-import-and-de-analysis)
        -   [Step 0. Link transcriptome
            indexes](#step-0.-link-transcriptome-indexes)
        -   [Step 1. Format the metadata for `tximeta` and
            `fishpond`](#step-1.-format-the-metadata-for-tximeta-and-fishpond)
        -   [Step 2. Import mapping/alignment
            counts](#step-2.-import-mappingalignment-counts)
        -   [Step 4. Prepare summarized experiment for
            DE](#step-4.-prepare-summarized-experiment-for-de)
        -   [Step 5: DTE analysis with
            swish](#step-5-dte-analysis-with-swish)
        -   [Step 6 (optional): DGE analysis with
            swish](#step-6-optional-dge-analysis-with-swish)
        -   [Step 7 (optional): Examine differential transcript isoform
            usage](#step-7-optional-examine-differential-transcript-isoform-usage)
        -   [Step 8: Built-in plots with
            fishpond](#step-8-built-in-plots-with-fishpond)
        -   [Step 9: Extract the table of
            results](#step-9-extract-the-table-of-results)
        -   [Install packages for graphing and term
            enrichment:](#install-packages-for-graphing-and-term-enrichment)
-   [Links](#links)

Main
====

Requirements
------------

-   An RStudio Interactive session on lonepeak-shared with 4 cores (by
    default 2GB memory per core. We should have at least 6 GB for
    today).
-   Installed packages in R (`tidyverse`, `tximeta`, `fishpond`).

Objectives
----------

1.  Import counts/alignments into an R object
2.  Test for differential expression at transcript and gene level.

General workflow overview
-------------------------

It’s always a good idea to draw out your workflow before you begin. Here
is a general RNAseq analysis workflow. Our specific functions will vary
depending on how you aligned/mapped/counted transcripts and the packages
you use, but the same general structure holds.

![ProjectOverview](https://drive.google.com/uc?export=view&id=1ONysRItFKzaTEcXeBDaX64brMqZLDc_2)

Summarized Part3-3 for metadata table import and formatting
-----------------------------------------------------------

Here I am just succinctly listing the relevant working code from the
previous session for importing and formatting the table. This is shown
here because it should all be part of the same markdown as it is needed
for reproducibility, but does not need to be run again if it was already
done in the previous session.

### Setup / Background

``` r
suppressPackageStartupMessages(library(tidyverse))
```

Purpose: Practice data wrangling with tidyverse and import and clean our
RNAseq metadata table.

### Data import

``` r
metadata <- read_delim("/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/metadata/SraRunTable_RNAseq_BiopsyOnly.txt",
  "\t", escape_double = FALSE, col_types = cols(Age = col_integer()),
  trim_ws = TRUE)
```

### Filter out unneeded metadata

1.  Remove the BioSample identifier because these are all unique and
    redundant with Run.

``` r
metadata <- metadata[,c(1,2,3,5,6,7,8,9,10)]
```

### Create subsets of data

1.  Filter out samples without replicates for replicates only subset.

``` r
metadata_repsOnly <- filter(metadata, Run != "SRR10571716" & Run != "SRR10571713" & Run != "SRR10571682" & is.na(replicate) == FALSE)
```

1.  Remove the replicate and tissue columns no longer needed.

``` r
metadata_repsOnly <- select(metadata_repsOnly, -replicate & -tissue)
```

1.  In one command, create subset of samples without replicates:

``` r
metadata_singleSamp <- metadata %>%
  filter(replicate == "biological replicate 1" | is.na(replicate)) %>%
  select(-replicate & -tissue)
```

### Add the paths for each alignment sample

``` r
ShareDir <- "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/BiopsyOnly"
```

Create a new tibble data frame.

``` r
align_paths <- tibble(Run = metadata$Run)
```

Add a new variable with the full shared directory path to each, and a
variable with the quant.sf file name:

``` r
align_paths <- mutate(align_paths, shared_dir = ShareDir, quant_file = "quant.sf")
```

Add a new variable for the sample/run specific directories.

``` r
align_paths <- mutate(align_paths, samp_dir = paste(align_paths$Run, "salm_quant", sep = "_"))
```

Now add the 3 different columns to give the full path to each file:

``` r
align_paths <- mutate(align_paths, fullpath = paste(align_paths$shared_dir, align_paths$samp_dir, align_paths$quant_file, sep = "/")) %>% select(Run, fullpath)
```

### Join the paths into each subsetted table

``` r
metadata_repsOnly <- left_join(metadata_repsOnly, align_paths)
```

    ## Joining, by = "Run"

``` r
metadata_singleSamp <- left_join(metadata_singleSamp, align_paths)
```

    ## Joining, by = "Run"

### Cleaning

Removing input metadata and ShareDir objects no longer
required/duplicated

``` r
rm(ShareDir, metadata)
```

Part 3-4: Import and DE analysis
--------------------------------

We will examine differential transcript and gene abundances between
smoking and asthma status using the “swish” (SAMseq With Inferential
Replicates Helps) functions in the “fishpond” package.

``` r
suppressPackageStartupMessages(library(tximeta))
```

In the interest of time and processing speed, we will just focus on the
subset of samples with a single sample per individual (those now listed
in “metadata\_singleSamp” object).

There are 2 major points worth noting here that are either not always
done or more recent applications. 1. Differential Transcript Expression
(DTE) analysis. It is not uncommon to start by mapping to genes and
perform DE analysis. This is inadvisable because differential transcript
usage within the same gene can occur and is lost at the beginning,
though can of course be analyzed with an entirely different analysis.
This is analogous to the issue we discussed with 16S data of clustering
to OTUs and losing finer-level amplicon variants. We must map to the
transcriptome (which we have) to allow different transcript analysis. We
can still regroup to genes later (and we will). 2. Inferential
replicates. These methods use bootstrapping or resampling (in our case
Gibb’s resampling) to model technical replicates with single samples.
This is a newer method now implemented in a few different RNAseq
analysis packages (eg. Kalisto, swish) that addresses some of the known
biases in RNAseq experiments and should allow more accurate
quantification of transcripts. 3. Linked references and provenance
tracking. As we saw with QIIME2, one of the major goals of contemporary
bioinformatic packages (such as QIIME2) is to link all the input data
and functions performed on a data set which allows much better
documentation by tracking the provenance, or where a result came from,
of objects/results. For RNAseq it is critical we know and report at a
minimum the exact transcriptome from which an analysis is performed.

### Step 0. Link transcriptome indexes

The `tximeta` package is a nice newer package that reads in our mapped
files to a SummarizedExperiment object by taking in information in a GTF
file about the features (transcripts) themselves such as genomic
location, length, name, etc. The `SummarizedExperiment` and
`GenomicRanges` packages used by tximeta are very frequently used for
these tasks in Bioconductor/R analysis of HTSeq data. This is always the
first step after mapping/aligning, but this method also links them to
the reference transcriptome from which they came, IF we linked the data
to the reference we created (as we did here) or used their precomputed
transcriptome. As this was human, we could indeed have used a
precomputed transcriptome, but instead I linked it with the `tximeta`
package functions in order to show you how it is done. The below code
does not need to be run again (only once for a reference), but is shown
for your information:

``` r
indexDir <- "/uufs/chpc.utah.edu/common/home/round-group1/reference_seq_dbs/salmon_indices/Hs.GRCh38.cdna.all_salmon_0.11/"
fastaFTP <- "ftp://ftp.ensembl.org/pub/release-100/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz"
gtfFTP <- "ftp://ftp.ensembl.org/pub/release-100/gtf/homo_sapiens/Homo_sapiens.GRCh38.100.gtf.gz"
makeLinkedTxome(indexDir = indexDir, source = "Ensembl", organism = "Homo sapiens", release = "100", genome = "GRCh38", fasta = fastaFTP, gtf = gtfFTP)
```

### Step 1. Format the metadata for `tximeta` and `fishpond`

First, we need to rename the column names as expected by tximeta (using
tidyverse “rename” function). It’s a little unusual you can’t just
specify the column names but, for now at least, tximeta looks for
specific column names for the name of the sample and the filepath.

``` r
metadata_singleSamp <- rename(metadata_singleSamp, files = fullpath, names = Run)
```

Additionally, usually we will need factors within variables to be
explicitly stored as such within our object for downstream statistical
testing. Tibble in the tidyverse makes no assumptions about our data and
reads them in as characters only, which is nice, but means we do have to
set them to be factors. Let’s just do this for our factors of interest
for simplicity, but other variables would need to be changed as well if
you want to test them. However, before we do this we need to remove the
“Ex-smoker” samples because swish currently can only deal with 2 factor
levels.

``` r
metadata_singleSamp <- filter(metadata_singleSamp, smoking_status != "Ex-smoker")
```

Now, change our two variables of interest to factors.

``` r
str(metadata_singleSamp)
```

    ## tibble [37 × 8] (S3: tbl_df/tbl/data.frame)
    ##  $ names         : chr [1:37] "SRR10571666" "SRR10571669" "SRR10571671" "SRR10571672" ...
    ##  $ Age           : int [1:37] 41 52 41 53 57 29 52 54 47 52 ...
    ##  $ asthma_status : chr [1:37] "Asthma" "Non-asthma" "Asthma" "Asthma" ...
    ##  $ LibraryName   : chr [1:37] "Biopsy_SIB049" "Biopsy_SIB047" "Biopsy_SIB046_rep1" "Biopsy_SIB006_rep1" ...
    ##  $ obesity_status: chr [1:37] "Obese" "Non-obese" "Obese" "Obese" ...
    ##  $ sex           : chr [1:37] "female" "female" "male" "female" ...
    ##  $ smoking_status: chr [1:37] "No" "Yes" "No" "No" ...
    ##  $ files         : chr [1:37] "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/BiopsyOnly/SRR10571666_salm_quant/quant.sf" "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/BiopsyOnly/SRR10571669_salm_quant/quant.sf" "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/BiopsyOnly/SRR10571671_salm_quant/quant.sf" "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/BiopsyOnly/SRR10571672_salm_quant/quant.sf" ...

``` r
metadata_singleSamp <- metadata_singleSamp %>% mutate(asthma_status = as.factor(asthma_status), smoking_status = as.factor(smoking_status))
head(str(metadata_singleSamp))
```

    ## tibble [37 × 8] (S3: tbl_df/tbl/data.frame)
    ##  $ names         : chr [1:37] "SRR10571666" "SRR10571669" "SRR10571671" "SRR10571672" ...
    ##  $ Age           : int [1:37] 41 52 41 53 57 29 52 54 47 52 ...
    ##  $ asthma_status : Factor w/ 2 levels "Asthma","Non-asthma": 1 2 1 1 1 1 1 1 1 1 ...
    ##  $ LibraryName   : chr [1:37] "Biopsy_SIB049" "Biopsy_SIB047" "Biopsy_SIB046_rep1" "Biopsy_SIB006_rep1" ...
    ##  $ obesity_status: chr [1:37] "Obese" "Non-obese" "Obese" "Obese" ...
    ##  $ sex           : chr [1:37] "female" "female" "male" "female" ...
    ##  $ smoking_status: Factor w/ 2 levels "No","Yes": 1 2 1 1 2 1 2 1 1 1 ...
    ##  $ files         : chr [1:37] "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/BiopsyOnly/SRR10571666_salm_quant/quant.sf" "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/BiopsyOnly/SRR10571669_salm_quant/quant.sf" "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/BiopsyOnly/SRR10571671_salm_quant/quant.sf" "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/BiopsyOnly/SRR10571672_salm_quant/quant.sf" ...

    ## NULL

``` r
summary(metadata_singleSamp)
```

    ##     names                Age           asthma_status LibraryName       
    ##  Length:37          Min.   :21.00   Asthma    :19    Length:37         
    ##  Class :character   1st Qu.:32.00   Non-asthma:18    Class :character  
    ##  Mode  :character   Median :41.00                    Mode  :character  
    ##                     Mean   :42.22                                      
    ##                     3rd Qu.:53.00                                      
    ##                     Max.   :60.00                                      
    ##  obesity_status         sex            smoking_status    files          
    ##  Length:37          Length:37          No :25         Length:37         
    ##  Class :character   Class :character   Yes:12         Class :character  
    ##  Mode  :character   Mode  :character                  Mode  :character  
    ##                                                                         
    ##                                                                         
    ## 

Certainly you can do these two steps in the opposite order without
error, but what happens to the levels? If you set the levels first, then
remove the “Ex-smoker”, while the rows will be removed, the information
on those levels will remain associated with the tibble. A small, but
important point.

### Step 2. Import mapping/alignment counts

As I noted above, `tximeta` depends on the commonly used
SummarizedExperiment package, and it will export a common “SE” or
summarized experiment object which contains counts per feature as well
as metadata you provide. `tximeta` additionally adds metadata for the
transcriptome reference as well. It is made to work with Salmon by
default but results from other methods can be imported as well, and by
default transcript-level info is assumed, but again can be used with
gene-level info. We’ll call the imported object simply `sS_se` for
“single sample summarized experiment”. Because our metadata file has the
paths to the alignment/counts files we just need to provide this table.

``` r
sS_se <- tximeta(metadata_singleSamp)
```

    ## importing quantifications

    ## reading in files with read_tsv

    ## 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37

    ## Warning: `select_()` is deprecated as of dplyr 0.7.0.
    ## Please use `select()` instead.
    ## This warning is displayed once every 8 hours.
    ## Call `lifecycle::last_warnings()` to see where this warning was generated.

    ## Warning: `filter_()` is deprecated as of dplyr 0.7.0.
    ## Please use `filter()` instead.
    ## See vignette('programming') for more help
    ## This warning is displayed once every 8 hours.
    ## Call `lifecycle::last_warnings()` to see where this warning was generated.

    ## found matching linked transcriptome:
    ## [ Ensembl - Homo sapiens - release 100 ]
    ## loading existing EnsDb created: 2020-06-10 16:49:58
    ## loading existing transcript ranges created: 2020-06-10 16:51:46

    ## Warning in checkAssays2Txps(assays, txps): 
    ## 
    ## Warning: the annotation is missing some transcripts that were quantified.
    ## 8176 out of 178517 txps were missing from GTF/GFF but were in the indexed FASTA.
    ## (This occurs sometimes with Ensembl txps on haplotype chromosomes.)
    ## In order to build a ranged SummarizedExperiment, these txps were removed.
    ## To keep these txps, and to skip adding ranges, use skipMeta=TRUE
    ## 
    ## Example missing txps: [ENST00000631435, ENST00000632524, ENST00000633009, ...]

It’s worth noticing the warning of differences between annotations and
transcripts that were quantified. We quantified/mapped/aligned &gt;178k
transcripts! Of course it is a much greater number than the number of
genes in the human genome, but why are &gt;8k of these transcripts
missing a listing from the GTF file? The warning gives the answer
generally as well, and since human genomes will have a very high amount
of known haplotypic differences this is as expected. In fact, if we look
at the slit of transcripts missing they are almost all TCR and BCR/Ig
sequences. It’s worth noting this and thinking carefully about your
input reference. This could be a potential downside to transcript-level
quantification if the features of the transcripts are not at the same
resolution as the reference transcripts.

### Step 4. Prepare summarized experiment for DE

``` r
suppressPackageStartupMessages(library(fishpond))
```

First, we run a couple functions to prepare the summarized experiment
object. We will scale the inferential replicates so they are properly
compared and then do a default filtering of transcripts for which we
have few counts among few samples. The latter is an important
consideration which should always be performed at some level in order to
reduce the amount of noise in your data and reduce multiple hypothesis
testing correction effect due to features/transcripts which we don’t
have enough counts to do reasonable tests in the first place. Think of a
transcript that shows up in only one of your samples as an extreme
situation which would be filtered here. Nicely, the function does not
actually “filter” them out, but simply masks them from the subsequent
tests.

``` r
sS_se <- scaleInfReps(sS_se)
sS_se <- labelKeep(sS_se, minCount = 100, minN = 5)
```

#### (aside) S4 objects in R and the SummarizedExperiment Object

It is important to understand a little bit about how this big object is
storing data because it is not just a very big data frame or table. S4
class objects and functions in R are very common amongst bioinformatics
packages. What are these? You can probably imagine it would be very
difficult (impossible?) to maintain all the information about a
gene/transcript/feature, sample, experiment/assay, sample metadata,
gene/feature metadata and experimental model in a single 2D table or
data frame. Thus, different classes of data storage have been devised
which allow nesting of data in a standardized manner and allow you to
store multiple data types together. I think of them as tables within
tables, though this is an oversimplification. The S4 class is one of
these which is frequently used in bioconductor packages. The `sS_se`
summarized experiment object is an S4 class object. First, use the `str`
function to view the structure of this object.

``` r
str(sS_se)
```

Woa! A lot of information is stored in this object! That makes sense
given that we have counts for each transcript in each sample, linked
transcriptome and metadata in here, among others. Scroll through the
printed structure to get a sense of it, but head to the first part of
the output. Notice how it says the “… with 6 slots”. These “slots” each
have a type of data and can have slots nested within them as well as you
can see in this hierarchical structure. These slots can be accessed with
the `@` if you want to access them directly, just like you accessed
variables/columns in a data frame with the `$`. Use `slotNames` to view
the top-level slots:

``` r
slotNames(sS_se)
```

    ## [1] "rowRanges"       "colData"         "assays"          "NAMES"          
    ## [5] "elementMetadata" "metadata"

Generally though, you won’t access these slots or data in an S4 object
like this because you need to know a bit about how each specific S4
class object is constructed in order to make sense of them. Instead,
these S4 class objects usually have associated functions specific to the
object type in order to access the data within them, so-called
“accessor” function. One such accessor for SummarizedExperiments is the
`colData()` function to show the experimental metadata. Let’s look at it
to see if our experimental metadata was read in correctly.

``` r
library(SummarizedExperiment)
```

``` r
colData(sS_se)
```

    ## DataFrame with 37 rows and 7 columns
    ##                   names       Age asthma_status        LibraryName
    ##             <character> <integer>      <factor>        <character>
    ## SRR10571666 SRR10571666        41        Asthma      Biopsy_SIB049
    ## SRR10571669 SRR10571669        52    Non-asthma      Biopsy_SIB047
    ## SRR10571671 SRR10571671        41        Asthma Biopsy_SIB046_rep1
    ## SRR10571672 SRR10571672        53        Asthma Biopsy_SIB006_rep1
    ## SRR10571674 SRR10571674        57        Asthma Biopsy_SIB045_rep1
    ## ...                 ...       ...           ...                ...
    ## SRR10571748 SRR10571748        26        Asthma      Biopsy_SIB012
    ## SRR10571751 SRR10571751        58    Non-asthma Biopsy_SIB010_rep1
    ## SRR10571760 SRR10571760        34        Asthma      Biopsy_SIB002
    ## SRR10571749 SRR10571749        32    Non-asthma      Biopsy_SIB011
    ## SRR10571717 SRR10571717        41    Non-asthma      Biopsy_SIB018
    ##             obesity_status         sex smoking_status
    ##                <character> <character>       <factor>
    ## SRR10571666          Obese      female             No
    ## SRR10571669      Non-obese      female            Yes
    ## SRR10571671          Obese        male             No
    ## SRR10571672          Obese      female             No
    ## SRR10571674          Obese      female            Yes
    ## ...                    ...         ...            ...
    ## SRR10571748          Obese      female             No
    ## SRR10571751          Obese      female             No
    ## SRR10571760      Non-obese        male             No
    ## SRR10571749          Obese      female            Yes
    ## SRR10571717          Obese        male            Yes

Notice how the “asthma\_status” and “smoking\_status” are listed as
factors as we specified them, but the others are not. Another useful
accessor is `rowRanges()` for the genomic ranges info of all the
features. `mcols()` function is a generic S4 accessor function (i.e. not
specific to SummarizedExperiment) which we can use to get info for each
gene. Use this to see how some of the first listed transcripts (TCRs and
Ig) which have 0 or very low mean counts are set to keep = FALSE by the
`labelKeep()` function earlier.

``` r
mcols(sS_se)
```

    ## DataFrame with 170341 rows and 8 columns
    ##                           tx_id             tx_biotype tx_cds_seq_start
    ##                     <character>            <character>        <integer>
    ## ENST00000415118 ENST00000415118              TR_D_gene         22438547
    ## ENST00000434970 ENST00000434970              TR_D_gene         22439007
    ## ENST00000448914 ENST00000448914              TR_D_gene         22449113
    ## ENST00000604642 ENST00000604642              IG_D_gene         20003840
    ## ENST00000603326 ENST00000603326              IG_D_gene         20004797
    ## ...                         ...                    ...              ...
    ## ENST00000612259 ENST00000612259 unprocessed_pseudogene               NA
    ## ENST00000506922 ENST00000506922 unprocessed_pseudogene               NA
    ## ENST00000420212 ENST00000420212 unprocessed_pseudogene               NA
    ## ENST00000538284 ENST00000538284 unprocessed_pseudogene               NA
    ## ENST00000411576 ENST00000411576 unprocessed_pseudogene               NA
    ##                 tx_cds_seq_end         gene_id         tx_name
    ##                      <integer>     <character>     <character>
    ## ENST00000415118       22438554 ENSG00000223997 ENST00000415118
    ## ENST00000434970       22439015 ENSG00000237235 ENST00000434970
    ## ENST00000448914       22449125 ENSG00000228985 ENST00000448914
    ## ENST00000604642       20003862 ENSG00000270961 ENST00000604642
    ## ENST00000603326       20004815 ENSG00000271317 ENST00000603326
    ## ...                        ...             ...             ...
    ## ENST00000612259             NA ENSG00000278589 ENST00000612259
    ## ENST00000506922             NA ENSG00000250114 ENST00000506922
    ## ENST00000420212             NA ENSG00000231258 ENST00000420212
    ## ENST00000538284             NA ENSG00000256626 ENST00000538284
    ## ENST00000411576             NA ENSG00000236504 ENST00000411576
    ##                            log10mean      keep
    ##                            <numeric> <logical>
    ## ENST00000415118                    0     FALSE
    ## ENST00000434970                    0     FALSE
    ## ENST00000448914 6.51217099699069e-05     FALSE
    ## ENST00000604642                    0     FALSE
    ## ENST00000603326                    0     FALSE
    ## ...                              ...       ...
    ## ENST00000612259                    0     FALSE
    ## ENST00000506922                    0     FALSE
    ## ENST00000420212   0.0172819268991122     FALSE
    ## ENST00000538284                    0     FALSE
    ## ENST00000411576    0.534121869151834     FALSE

Check out SummarizedExperiments’s bioconductor page (listed below in
links) for more information, but this very short intro should suffice to
understand that these objects are different than just a big table or
data frame and require different methods to access the data within them.

### Step 5: DTE analysis with swish

Now we get to the heart of differential expression analysis with the
swish function. The function itself is fairly straightforward when only
testing for one effect, but has options for covariates and pairing of
samples which I hoped to get into as well, but this “intro” was getting
too long. An important point though is that this method performs a
number of permutations with random sampling. Whenever any function does
these type of permutational analyses they will not be totally
reproducible if you don’t set the random seed to the same number, so we
do this first (the number is somewhat arbitrary, but setting 1 is always
safest and allows you to be consistent). We are going to reduce the
number of permutations to 10 just to run this a bit faster in class, and
we will test for effect of smoking.

``` r
set.seed(1)
sS_se <- swish(sS_se, x = "smoking_status", nperms = 10)
```

Now, briefly, use the `mcols()` function again to see how the p-values,
q-values and fold changes were added as a column to the transcripts.

``` r
mcols(sS_se)
```

`mcols()` is returning a data frame of an S4 class (not a tibble data
frame like we used earlier) so we can’t yet use our tidyverse functions
on it directly, but we could change it to a tibble data-frame and use
tidyverse functions. Importantly however, this dissociates it from the
specific hypothesis test we made so leaves no context for those pvalues.
Thus, if you do this, make sure it is named as such. Let’s just use some
of the functions we already have used to count to see how many values
have q &lt; 0.05.

``` r
mcols(sS_se) %>% as_tibble() %>% filter(qvalue < 0.05) %>% nrow()
```

    ## [1] 231

### Step 6 (optional): DGE analysis with swish

We can still perform gene-level differential expression (DGE) analysis
because transcripts can be grouped by the genes they come from. The
reverse is not necessarily true (i.e. if we did gene level
counting/alignments we couldn’t necessarily back out to
transcript-level). The testing of differences is basically the same, but
we first need to regroup them to genes. `tximeta` provides a function
for this, and because we linked all the reference information to the
index, all the information required to do this is already together.

``` r
sS_se_gene <- summarizeToGene(sS_se)
```

    ## loading existing EnsDb created: 2020-06-10 16:49:58

    ## obtaining transcript-to-gene mapping from TxDb

    ## loading existing gene ranges created: 2020-06-14 22:59:17

    ## summarizing abundance

    ## summarizing counts

    ## summarizing length

    ## summarizing inferential replicates

Notice the object is still a summarized experiment object, but is \~
4.5X smaller. Clearly we have lost a LOT of information by doing
gene-level analysis. That is not to say this is inappropriate or not
what we are looking for. As before, we scale filter/mask genes with low
counts. If we started with gene level grouping we would need to do
`scaleInfReps()` as well first, but since these reps are at the level of
transcript and we already scaled them we don’t need to do it again.

``` r
sS_se_gene <- labelKeep(sS_se_gene, minCount = 100, minN = 5)
```

Let’s run swish again to test for differences at the gene-level. Because
this is much smaller we can run a lot more permutations quickly than we
did with the transcript-level data set.

``` r
set.seed(1)
sS_se_gene <- swish(sS_se_gene, x = "smoking_status", nperms = 50)
```

Then, let’s just retrieve the number of genes with a q &lt; 0.05 as
before.

``` r
mcols(sS_se_gene) %>% as_tibble() %>% filter(qvalue < 0.05) %>% nrow()
```

    ## [1] 180

It’s interesting to compare this gene-level number with the
transcript-level result. Proportionally, there are \~5X as many genes
differential abundant than there are transcripts (there’s \~31k genes
and 170k transcripts). Why? Love and Patro lab’s papers provide some
great discussion on this and why transcript-level expression makes more
sense usually. There certainly some biologically reasonbale reasons for
this, but there’s also different amounts of variation between the 2
datasets and so different filtering/masking of low abundance features
should really be applied. This is dataset-specific and I think should be
considered more carefully for your experiments. Regardless, we do have
some differences between smokers and non-smokers.

### Step 7 (optional): Examine differential transcript isoform usage

We actually can’t do this with the package version we have. In order to
install the newer versions of fishpond that contain a function for this
we would need to upgrade our R installation as well, which we cannot do
with OnDemand through CHPC (admins must do this although you can run any
version of regular R without R Studio on CHPC). I just note here that
this is an option, which you would need to perform on your local RStudio
installation or when the OnDemand install is updated soon. It is nice to
be able to do this within the same package. If you have the newer
version (&gt;1.4) of fishpond, the transcript isoform analysis will
filter/mask transcripts with only one isoform then perform the test for
differential usage with the following commands:

``` r
sS_se_iso <- isoformProportions(sS_se)
sS_se_iso <- swish(sS_se_iso, x="smoking_status", nperms=50)
```

### Step 8: Built-in plots with fishpond

The `fishpond` package as with most good packages, provides a few simple
graphing functions to help you get a sense of your data as you move
along. However, most of your graphing will be done with
graphing-specific packages (such as `ggplots`) or other downstream
analysis packages. We’ll just look at an MA plot and a plot of
inferential replicates for a gene to see how they look.

-   First, the MA plot.

It’s always good to inspect your data with significant differences
highlighted with an MA plot to see if there is any obvious systematic
bias. These should *usually* look pretty evenly centered around 0
log2FC. If you have a strong detection bias you might see only
significant differences towards the right or only major fold changes at
one end of these plots. Because one of Salmon and swish’s main goals is
to model and correct for known biases these plots look really good.

``` r
plotMASwish(sS_se)
```

![](Part3-4_DE_Markdown_w_3-3_Markdown_files/figure-markdown_github/unnamed-chunk-36-1.png)

-   Plot the range of counts from inferential replicates for a given
    gene amongst all samples.

``` r
plotInfReps(sS_se, idx = "ENST00000380859", x = "smoking_status")
```

![](Part3-4_DE_Markdown_w_3-3_Markdown_files/figure-markdown_github/unnamed-chunk-37-1.png)
This transcript actually has one of the lowest q-values. You can see it
is different amongst smokers (orange) and non-smokers (blue), but many
smokers it is still quite low. While this difference may not look very
impressive, it is reflective of how actual human data often looks, and I
think serves as a better example than data often attached to packages
and worked through in vignettes because it is more reflective of how
human data tends to look.

### Step 9: Extract the table of results

Before we extract the results let’s add NCBI Entrez Gene IDs to the
data. These common numeric IDs are frequently used to access genes and
their associated annotations and are supposed to be resistant to gene
name changes. We currently have ENSEMBL IDs that serve a similar
purpose.

-   Install the genome wide annotation for humans.

These genome wide annotations are available precompiled for many model
organisms and you can create your own as well quite easilty from NCBI’s
repository for an organism with the annotation forge package. These are
very useful packages because they contain just about all the info for an
organism you can think of in a single place (genes, transcripts,
functions, ontological annotations/terms, alternative gene names/IDs,
etc.). These greatly facilitate the downstream analysis and regrouping
functions and we will use it extensively in the following section for
graphing and regrouping.

``` r
BiocManager::install('org.Hs.eg.db')
```

Load the library:

``` r
library(org.Hs.eg.db)
```

Now add the ENTREZIDs for each gene. Notice that we use gene = TRUE flag
for the transcrtipts because ENTREZIDs are for genes.

``` r
sS_se <- addIds(sS_se, column = "ENTREZID", gene = TRUE)
```

    ## mapping to new IDs using 'org.Hs.eg.db' data package
    ## if all matching IDs are desired, and '1:many mappings' are reported,
    ## set multiVals='list' to obtain all the matching IDs

    ## gene=TRUE and rows are transcripts: using 'gene_id' column to map IDs

    ## 'select()' returned 1:many mapping between keys and columns

``` r
sS_se_gene <- addIds(sS_se_gene, column = "ENTREZID", gene = TRUE)
```

    ## mapping to new IDs using 'org.Hs.eg.db' data package
    ## if all matching IDs are desired, and '1:many mappings' are reported,
    ## set multiVals='list' to obtain all the matching IDs
    ## 'select()' returned 1:many mapping between keys and columns

Now, let’s create a tibble with the results for ALL transcripts and one
for ALL genes using commands we have learned before. We’ll just maintain
all that were tested for now, but this is often a good time to do some
extra filtering as well (maybe log fold changles, or only those which
were 1 q &lt; 0.05):

``` r
txps <- mcols(sS_se) %>% as_tibble() %>% filter(keep == TRUE)
genes <- mcols(sS_se_gene) %>% as_tibble() %>% filter(keep == TRUE)
```

### Install packages for graphing and term enrichment:

These packages we will use next time, and one of them takes a little
while so let’s get them installed now.

``` r
BiocManager::install('clusterProfiler', quiet = TRUE)
BiocManager::install('EnhancedVolcano')
```

Links
=====

-   [Bioconductor page explaining SummarizedExperiments
    objects](https://bioconductor.org/packages/release/bioc/vignettes/SummarizedExperiment/inst/doc/SummarizedExperiment.html)
-   The swish bioconductor page vignette: [Swish
    method](https://bioconductor.org/packages/release/bioc/vignettes/fishpond/inst/doc/swish.html#the_swish_method)
-   [R markdown
    cheatsheet](https://rstudio.com/wp-content/uploads/2016/03/rmarkdown-cheatsheet-2.0.pdf)
    -   NOTE that R cheat sheets are available in RStudio through
        `Help --> Cheathseets..` menu.
