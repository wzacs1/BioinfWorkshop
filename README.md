# Intro to Bioinformatics Tools Workshop
> Initial: Summer Semester 2020 \
> Author: W. Zac Stephens

This workshop is geared towards learning the basics of common bioinformatic tools. The objective is not necessarily to teach specific analyses, but to get biologists with no previous coding experience some exposure and working understanding of basic command-line skills so that they can continue learning by doing with their own datasets, and better take advantage of the many online tutorials that go through specific types of analyses.

We use the OnDemand interface at the University of Utah's Center for High-Performance Computing throughout because it provides a common environemnt for all users, and also because we will extensively discuss CHPC's usage for high-throughput sequencing experiments in particular.

Here I provide detailed workthroughs from each workshop day as individual pages. Each served as the basis for the slides from each day, and have more written explanation so that they can hopefully be worked through alone. I will upload them before each class and then, likely, update them at the end of each day according to how far we get.

1. [Part 1-1: Introduction to Linux Command-Line Interface](https://github.com/wzacs1/BioinfWorkshop/blob/master/Workthroughs/Part1_IntroToUnixCLI.md)
2. [Part 1-2: Introduction to Linux Command-Line Interface](https://github.com/wzacs1/BioinfWorkshop/blob/master/Workthroughs/Part1_IntroToUnixCLI_2.md)
3. [Part 1-3, Part 2-1: Intro to Linux CLI and CHPC (cont.), Documentation and QIIME2 with Conda](https://github.com/wzacs1/BioinfWorkshop/blob/master/Workthroughs/Part1-2_UnixContinued_CHPCEnvironment_QIIME2Intro.md) 
4. [Part 2-2: SRA pull seqs and QIIME2 16S seq process](https://github.com/wzacs1/BioinfWorkshop/blob/master/Workthroughs/Part2_QIIME2_16S_SeqAnalysis.md)
5. [Part 2-3: QIIME2 16S seq analysis](https://github.com/wzacs1/BioinfWorkshop/blob/master/Workthroughs/Part2-3_QIIME2_16S_Seq_AnalysisPart.md)

Tentative Schedule:

Day #  |  Date  | Title  | Topics
------ | ------ | ------ | -----
1 | May 12 | Part 1-1: Intro to Linux | Basic commands, moving around CLI 
2 | May 14 | Part 1-2: Intro to Linux | More commands, moving around CLI, file manipulation
3 | May 19 | Part 1-3: Linux and CHPC, Part 2-1: Documentation & Intro to QIIME2 |  for loops, grep, CHPC, paths, Atom intro, conda install
4 | May 21 | Part 2-2: 16S seq process with QIIME2 | sra-toolkit, QIIME2 install, 16S seq processing
5 | May 26 | Part 2-2 (cont.): 16S seq process with QIIME2 | 16S seq preprocessing, batch job submission, intro to markdown
6 | May 28 | Part 2-3: 16S seq analysis with QIIME2 | microbiome data analysis in QIIME2, markdown
7 | June 2 | Part 3-1: RNAseq process and alignments | sequence QC and alignments 
8 | June 4 | Part 4-1: Intro to R and R Studio | basic R, R packages, bioconductor
9 | June 9 | Part 4-2: Intro to R and R Studio. | basic R, R markdown
10 | June 11 | Part 5-1: RNAseq analysis 1: DE analysis | differential expression analysis
11 | June 16 | Part 5-2: RNAseq analysis 2: GSEA and higher-level results interpretation | fgsea, term enrichment, clusterprofiler
12 | June 18 | Part 6-1: Containers with Singularity | containers overview, singularity, humann2
