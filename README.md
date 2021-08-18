# Intro to Bioinformatics Tools Workshop
> Current: Summer Semester 2021 \
> Author: W. Zac Stephens

This workshop is geared towards learning basic bioinformatic skills on the Linux command-line and R with RStudio. The objective is not necessarily to teach specific analyses, but to get biologists with no previous coding experience some exposure and working understanding of basic command-line skills so that they can continue learning by doing with their own datasets, and better take advantage of the many online tutorials that go through specific types of analyses.

We use the OnDemand interface at the University of Utah's Center for High-Performance Computing throughout because it provides a common environemnt for all users, and also because we will extensively discuss CHPC's usage for high-throughput sequencing experiments in particular.

Here I provide detailed workthroughs from each workshop day
as individual pages. Each served as the basis for the slides from each day, and have more written explanation so that they can hopefully be worked through alone. I will upload them before each class and then, likely, update them at the end of each day according to how far we get. The idea is that only the time during the workshop is needed, but if one can't make it to a specific class, these can be used to workthrough the day's lesson on their own and keep up.

- [Part 1-1: Introduction to Linux Command-Line Interface](https://github.com/wzacs1/BioinfWorkshop/blob/master/Workthroughs/Part1-1_IntroToLinuxCLI.md)
- [Part 1-2: Introduction to Linux Command-Line and Common Commands](https://github.com/wzacs1/BioinfWorkshop/blob/master/Workthroughs/Part1-2_IntroToLinux.md)
- [Part 1-3: Linux, CHPC and Software Install Methods](https://github.com/wzacs1/BioinfWorkshop/blob/master/Workthroughs/Part1-3_CHPCandLinuxContinued.md)
- [Part 2-1: Regex and For Loops, Begin 16S Seq Pull and Processing](https://github.com/wzacs1/BioinfWorkshop/blob/master/Workthroughs/Part2-1_SRAPull_16SseqProcessQiiime2.md)
- [Part 2-2: 16S Seq Process with QIIME2](https://github.com/wzacs1/BioinfWorkshop/blob/master/Workthroughs/Part2-2_16SseqProcessQiime2.md)
- [Part 2-3: 16S Seq analysis with QIIME2](https://github.com/wzacs1/BioinfWorkshop/blob/master/Workthroughs/Part2-3_16SseqAnalysis.md)
- [Part 3-1: RNAseq process and alignments, Git and GitHub](https://github.com/wzacs1/BioinfWorkshop/blob/master/Workthroughs/Part3-1_RNASeq_Alignments2GitIntro.md)
- [Part 3-2: Intro R and RStudio](https://github.com/wzacs1/BioinfWorkshop/blob/master/Workthroughs/Part3-2_IntroRStudio.md)
- [Part 3-3: Intro R continued and ](https://github.com/wzacs1/BioinfWorkshop/blob/master/Workthroughs/Part3-3_IntroRCont_DE.md)

Tentative Schedule:

Day #  |  Date  | Title  | Topics | VideoLink
------ | ------ | ------ | ----- | -----
1 | July 14 | Part 1-1: Intro to Linux | Basic commands, moving around CLI |  [Class 1 ]( https://www.youtube.com/playlist?list=PL_Pe_9PaIEBN-MDiucIgx4sR1NLbneDDE)
2 | July 17 | Part 1-2: Intro to Linux | More commands, moving around CLI, file manipulation | [Class 2](https://www.youtube.com/watch?v=8xwjIng3LrE&list=PL_Pe_9PaIEBN-MDiucIgx4sR1NLbneDDE&index=2)
3 | July 21 | Part 1-3: Linux, CHPC and Software Install Methods |  CHPC, paths, install methods, QIIME2 conda install | [Class 3](https://www.youtube.com/playlist?list=PL_Pe_9PaIEBN-MDiucIgx4sR1NLbneDDE)
4 | July 23 | NO CLASSS |
5 | July 28 | Part 2-1: regex and for loop in Linux, Begin 16S seq process with QIIME2,  | sra-toolkit, grep, for loops, QIIME2 16S seq processing | [Class 4](https://www.youtube.com/watch?v=xfRUAr7F0BE&list=PL_Pe_9PaIEBN-MDiucIgx4sR1NLbneDDE&index=4)
6 | July 30 | Part 2-2: 16S seq process with QIIME2 | 16S seq preprocessing, batch job submission | [Class 5](https://www.youtube.com/watch?v=ujmYcYiC6Ls&list=PL_Pe_9PaIEBN-MDiucIgx4sR1NLbneDDE&index=5)
7 | Aug 4 | Part 2-3: 16S seq analysis with QIIME2 | microbiome data analysis in QIIME2, intro to git and github | [Class 6](https://www.youtube.com/watch?v=dSmLceHxSiU&list=PL_Pe_9PaIEBN-MDiucIgx4sR1NLbneDDE&index=6)
8 | Aug 6 | CLASS CANCELLED  |   |
9 | Aug 11 | Part 3-1: RNAseq process and alignments, Git and GitHub | sequence QC and alignments, Git/GitHub | [Class 7](https://www.youtube.com/watch?v=aEjxUhSzuWE&list=PL_Pe_9PaIEBN-MDiucIgx4sR1NLbneDDE&index=7)
10 | Aug 13 | Part 3-2: Intro to R and R Studio | basic R, R packages, R markdown | [Class 8](https://www.youtube.com/watch?v=gOma0g91o9w&list=PL_Pe_9PaIEBN-MDiucIgx4sR1NLbneDDE&index=8)
11 | Aug 18 | Part 3-3: Intro to R cont. & RNAseq DTE/DGE analysis. | tidyverse functions, DTE/DGE with swish/fishpond | [Class 9]
12 | Aug 20 | Part 3-4: RNAseq DTE/DGE analysis: | differential expression analysis | [Class 10]
13 | TBD/Homework | Part 3-5: RNAseq analysis 2: Higher-level results interpretation and plotting | gsea/term enrichment, clusterprofiler, volcano plots, ggplots | [Class 11]
