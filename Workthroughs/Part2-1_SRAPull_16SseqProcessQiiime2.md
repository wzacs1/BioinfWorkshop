<!-- TOC -->

- [Main](#main)
  - [Setup and Background](#setup-and-background)
    - [Today's Objectives:](#todays-objectives)
    - [Requirements and Expected Inputs](#requirements-and-expected-inputs)
  - [Review](#review)
  - [Introduction to Regular Expressions and `grep`](#introduction-to-regular-expressions-and-grep)
    - [Build a complex grep command](#build-a-complex-grep-command)
      - [**A.** Maintain the fastq sequence format with IDs and quality scores.](#a-maintain-the-fastq-sequence-format-with-ids-and-quality-scores)
      - [**B.** Use Inverse matches and escape characters to remove `--`.](#b-use-inverse-matches-and-escape-characters-to-remove---)
      - [**C.** Use anchoring characters `^` and `$` to ensure correct match](#c-use-anchoring-characters-^-and--to-ensure-correct-match)
      - [**D.** (alternative) Use number in curly braces to indicate the exact number of matches. Extended grep.](#d-alternative-use-number-in-curly-braces-to-indicate-the-exact-number-of-matches-extended-grep)
      - [**E.** Finally, pipe the output to a new file.](#e-finally-pipe-the-output-to-a-new-file)
  - [Intro to Loops. The `for` loop.](#intro-to-loops-the-for-loop)
  - [Putting it all together. How to build a processing pipeline in a batch script.](#putting-it-all-together-how-to-build-a-processing-pipeline-in-a-batch-script)
    - [Intro to Using Atom (Or Other Plain Text Editor)](#intro-to-using-atom-or-other-plain-text-editor)
    - [Workflow overview for High-Performance Compute Clusters](#workflow-overview-for-high-performance-compute-clusters)
    - [Create and Initial Setup of Your Batch Script.](#create-and-initial-setup-of-your-batch-script)
  - [Our First Bioinformatics Project](#our-first-bioinformatics-project)
    - [Step 0: Draw out your methods and project goals](#step-0-draw-out-your-methods-and-project-goals)
    - [Step 1: Setup a Project Directory and Variables Required.](#step-1-setup-a-project-directory-and-variables-required)
      - [(aside) Find / show project on SRA](#aside-find--show-project-on-sra)
    - [Step 2: Pull sequences with SRA](#step-2-pull-sequences-with-sra)
    - [Step 3: Import sequences into a QIIME2 artifact](#step-3-import-sequences-into-a-qiime2-artifact)
      - [(optional) Loading the CHPC QIIME2 module](#optional-loading-the-chpc-qiime2-module)
    - [Step 3: Import sequences into a QIIME2 artifact (continued)](#step-3-import-sequences-into-a-qiime2-artifact-continued)
      - [Manifest File Option 1: Make it on the fly with Linux commands](#manifest-file-option-1-make-it-on-the-fly-with-linux-commands)
      - [Manifest File Option 2: Copy and change to your scratch filespace](#manifest-file-option-2-copy-and-change-to-your-scratch-filespace)
    - [Step 3: Import sequences into a QIIME2 artifact (continued 2)](#step-3-import-sequences-into-a-qiime2-artifact-continued-2)
    - [Step 4: Trim primers and join sequences](#step-4-trim-primers-and-join-sequences)
    - [Step 5: Denoise with Deblur and create a table](#step-5-denoise-with-deblur-and-create-a-table)
      - [OTUs versus ASVs/ESVs](#otus-versus-asvsesvs)
    - [Step 6: Build phylogeny](#step-6-build-phylogeny)
    - [Step 7: Call Taxonomies](#step-7-call-taxonomies)
    - [Step 8: Cleanup!](#step-8-cleanup)
    - [Final Step: Finish the batch script and submit.](#final-step-finish-the-batch-script-and-submit)
      - [Change the sra-toolkit command to pull all the 16S sequences.](#change-the-sra-toolkit-command-to-pull-all-the-16s-sequences)
      - [Add SBATCH/Slurm directives](#add-sbatchslurm-directives)
        - [Note on partition, processes and time](#note-on-partition-processes-and-time)
  - [Submit Your Batch Script on CHPC](#submit-your-batch-script-on-chpc)
- [Practice / With Your Own Data](#practice--with-your-own-data)
- [Links, Cheatsheets and Today's Commands](#links-cheatsheets-and-todays-commands)

<!-- /TOC -->

# Main

## Setup and Background
- Obtain an interactive shell session:
1. Log in to CHPC via your preferred method (OnDemand, ssh from Terminal, or FastX Web server).
2. Obtain an interactive session with 2 processors.
```bash
 salloc -A mib2020 -p lonepeak-shared -n 2 --time 2:30:00
 # OR
 salloc -A notchpeak-shared-short -p notchpeak-shared-short -n 2 --time 2:30:00
```

### Today's Objectives:

#### I. Introduce regular expressions, grep and for loops.
- Gaining more command line practice.

#### II. Begin First Bioinformatics Project
##### A. Build Job Script
##### B. Pull sequences from the SRA

### Requirements and Expected Inputs

- CHPC interactive bash shell session.
- `table.txt` and `read1.fastq` and `read2.fastq` in Directory `~/BioinfWorkshop2021/Part1_Linux`
  - If needed (you don't have them), `cd` into your `Part1_Linux` directory and copy them from my directory.
  ```bash
  cd ~/BioinfWorkshop2021/Part1_Linux/
  cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part1_Linux/table.txt ./
  cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part1_Linux/read1.fastq ./
  cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part1_Linux/read2.fastq ./
  ```

- QIIME2 installed in conda environment.
  - Begin install now if not: [https://github.com/wzacs1/BioinfWorkshop/blob/master/Workthroughs/Part1-3_CHPCandLinuxContinued.md#conda-virtual-environments---qiime2-install](https://github.com/wzacs1/BioinfWorkshop/blob/master/Workthroughs/Part1-3_CHPCandLinuxContinued.md#conda-virtual-environments---qiime2-install)
  	- Obtain second interactive shell session to continue while that installs.

## Review
#####

## Introduction to Regular Expressions and `grep`

"Regular expressions" (AKA "regex") are sequences of characters usually used for searching text strings (for example, nucleic acid and amino acid sequences). They are extremely powerful and we could easily spend a full session or two on them but will keep it very simple instead, in line with the objectives of this workshop.
  - I strongly encourage more reading on them outside of class time as you can really make those annoying formatting tasks simple, fast and more consistent. "Cheatsheets" are really helpful. A few patterns are particularly common and helpful to know of.

One regular expression pattern many may have encountered already is the commonly used `*` wildcard, which matches anything. This is very frequently used to lists subsets of files with common extensions. Let's use it to list all the .fastq sequence files here, then the different table files we may have created:

```bash
cd ~/BioinfWorkshop2021/Part1_Linux
ls *fastq
ls table*
```

So, what happened here? This wildcard matched *zero or more* of anything (except line breaks usually). It's sort of the biggest catch-all wildcard; it will match alphanumeric characters or spaces or symbols. Commands in linux (such as `ls`) are a bit limited in what they can interpret easily like this because a lot of the special characters in pattern matching are already in use. For example the `.` in regex will normally matches *exactly one* of anything, but used naturally is all over in filenames. So, we'll actually use the `grep` command to illustrate further regex, but first let's see how you can also use ranges to get filenames:

```bash
ls read[1-2].fastq
```

Much like we saw in the cut command for specifying fields, you can use ranges (`-`) or a list of characters to match patterns. As it only matches a single character you don't need to separate them by commas (in other words you could also type `ls read[12].fastq` above).

- Regular expressions have a lot of commonalities in their interpretation from one program to the next, but a few differences do exist. `grep` is a function used all over the place, including Unix/Linux and R, and stands for global regular expression print.
  - There are a few different flavors of it, but again we will keep it to basics that are usually common among them. If you encounter unexpected behavior with grep you probably mean to use on of the others, such as `fgrep` or `egrep` (these can alos be accessed with options to the standard `grep`).
  - The `man` page for grep contains an impressively concise section on regular expressions as well.
- `grep`: **g**lobal **r**gular **e**xpression **p** rint. Format: `grep "<REGEX_PATTERN>" <FILE_INPUT>`

To first show how grep in Linux normally works, look at the sequence identifiers in the read1.fastq file using `head`. You can see they share a lot of the same information which identifies the machine, run, etc for which all sequences in a given run will have the same information. Let's pull all the sequence identifiers just using this common information. To avoid printing all 4k lines we'll pipe the output to `head`.


```bash
grep "M00736:301" read1.fastq | head
```

We actually didn't use any special characters in our pattern, but this is still pattern matching. Now let's look at one way of using special characters to indicate position of matches. The `^` specifies that the following patter should be at the beginning of a line. It's frequently useful. In this case, these sequences are from amplicons, so they should have primer sequences at the beginning of them.
- The primers are also degenerate, so in some places could have multiple different bases. First, use the primers with degenerate base notation and search for them at the beginning of the sequences, where they **should** be:

```bash
grep "^TGCCTACGGGNBGCASC" read1.fastq
```

Nothing there, which is good, but Illumina does report "N"s in sequences. Now, use multiple nucleotide characters to search for those primers, replacing the degenerate bases with their possibilities at that position.
- Add the `--color` option to highlight the matches. This **may** not work due to special escape characters used for coloring output on the command line. It's a safety measure. If so, use the `--colors=always` option instead.

```bash
grep --color "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq
```

Notice that grep **returns the entire lines** that match as with most utilities in Linux. If we want only the matching pattern, use the `-o` option:

```bash
grep --color -o "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq
```


There's 1,000 sequences in that file. How many have the appropriate primer at their start? Pipe the output to `wc -l` to find out. Then, remove the `^` to see if some of these sequences don't have the primer at the start

```bash
grep --color "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq | wc -l
grep --color "TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq | wc -l
```
So, there's a few in there that don't have the primer at the beginning. We don't want these.

### Build a complex grep command
- Now, let's work up a command line-by-line to get the sequence ID, sequence and quality scores of each sequence with primer at the front and print it to a new file.

##### **A.** Maintain the fastq sequence format with IDs and quality scores.

Grep has options to retrieve lines before (`-B`) and after (`-A`) the match. Add those to our command with the `^` to grab all the sequences with primers at the front as expected and their identifiers.

```bash
grep -B 1 -A 2 "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq
```
- Let's check the command is working as expected as we build it up. For a simple check of expected behavior continue to pipe the output to `wc -l` to see if the output is as expected based on the known 931 sequence matches we determined above (931 * 4 entries per line = 3724).

```bash
grep -B 1 -A 2 "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq | wc -l
```

That isn't the correct number. There seems to be one less line than we should have. Why? Just run the command without the wc -l and scroll through to see if you can catch the problem. It may be hard to see at first (keep the color option on to highlight).

```bash
grep -B 1 -A 2 --color=always "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq
```
- One minor annoyance is that grep outputs this `--` in between groups of matches, which we don't want. But it's a good opportunity to illustrate the inverse match and the character escape.

##### **B.** Use Inverse matches and escape characters to remove `--`.

- The `-v` option inverts and takes the non-matching lines, so we can use it to remove those `--`.
  - However, we already learned that the dash `-` is a special character used to denote a range. We need to indicate that we want it to be read exactly as that character instead.
- The backslash `\` is used to escape special characters and allow them to be read exactly as that character instead of their special meaning. This is common behaviour for this key across languages (though in Windows it is the directory delimiter).

```bash
grep -B 1 -A 2 "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq | grep -v "\-\-" | wc -l
```
Still off by 1. `-` dashes can be in the quality scores, so we should ensure the dashes are at the beginning of the lines as output by grep.

##### **C.** Use anchoring characters `^` and `$` to ensure correct match
  - The `^` (carrot) is an "anchoring" character. It says only match the following character at the **beginning** of the line only.

```bash
grep -B 1 -A 2 "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq | grep -v "^\-\-" | wc -l
```
This returns the correct number! Nice, but it's not great code because what would happen if we had a quality score line that begins with these two dashes? Let's introduce two more qualifier to your grep command toolkit. We can use the other anchoring character to ensure that there is nothing else between the `--` and the end of the line. Since the quality score is much longer than 2 characters, if we surround the `--` with these 2 anchors only those can be matched.
  - The `$` only matches the proceeding character at the end of the line.

```bash
grep -B 1 -A 2 "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq | grep -v "^\-\-$" | wc -l
```
We already had the correct number of matches without the `$`. This is just to intro this character and to make better, more reliable code.

##### **D.** (alternative) Use number in curly braces to indicate the exact number of matches. Extended grep.
As an alternative to the 2 dashes escaped, we could just explicitly say how many matches we want to have of the dashes.
  - Curly braces `{}` with a number in them specify the exact number of matches of the preceding character.
  - How to indicate them, changes from basic or extended grep.

- This code **should** then be the same as the last code we input:
```bash
grep -B 1 -A 2 "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq | grep -v "^\-{2}$" | wc -l
```
Totally wrong number though now. It's not behaving as expected. This is an example where the curly braces (though they have the same intent across flavors of grep) have to be referred differently in basic grep versus extened grep `egrep`. We can actually escape them to give them their special meaning in basic grep, OR we can just use extended grep. All of these are the same (the last 2 calling extended grep command):

```bash
grep -B 1 -A 2 "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq | grep -v "^\-\{2\}$" | wc -l
grep -B 1 -A 2 "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq | grep -E -v "^\-{2}$" | wc -l
grep -B 1 -A 2 "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq | egrep -v "^\-{2}$" | wc -l
```
- The first one is kind of hard to read. Also, I wanted to show that adding the slash can sometime make the character special instead of escaping it. There are many of these, which we won't cover but be aware this behaviour exists as well. For example, `\d` can refer to any digit, or `\s` can refer to any whitespace. Regex are very powerful but numerous differences exist in their implementation by different programs.

##### **E.** Finally, pipe the output to a new file.
We will use the original regular grep command to get remove the `--` and then also remove the `wc -l` which was just included to check the expected output, and then redirect the output to a new file.

```bash
grep -B 1 -A 2 "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq | grep -v "^\-\-$" > read1_SeqsWithPrimer.fastq
```

- Hopefully, this demonstrates both some basic pattern matching, and you can see how you don't necessarily need to have a program installed to do some really simple sequence searching and retrieval very quickly on millions of reads.

- There are a ton of tools out there now to do this kind of sequence searching, including some we installed above. They also use pattern matching though. There is still tremendous utility in using grep and pattern matching in, and outside of, sequence searching problems, in particular for searching or executing commands over multiple file names with similar naming structure.

## Intro to Loops. The `for` loop.

Loops are a family of statements that iterate through items in different manners. This is where we really start to do some programming and see the power of the command line or scripting. Loops are nearly always at the core of coding, and I am introducing them early because they are so helpful to understand. But, this is pretty early for a nascent bioinformatician so don't worry too much if you are struggling with this section. I'm trying to get you some exposure to a lot of different commands and syntax structure.

- We will use just one simple examples here and then frequently expand on them as we move forward. Their syntax varies a bit from language to language, but the basic structure is the same: A condition and something to do for that condition. The main loops you will likely use in bash are:

- `for` loop: Takes in a number of values and do some function **for** each one.
- `while` loop: **while** the condition is true, do the function.

These loops will be written over multiple lines. They aren't just a long single entry separated by a `\` like we've seen before, but multiple command-line entries. When entering a `for` loop bash knows to expect more input for the command after you type the for statement, so does not return anything and provides the `>` prompt for more entry. To tell bash you're done with the loop you enter the (you guessed it!) `done` statement.  The basic structure of a for loop is like this (don't enter this):

```bash
for VARIABLE_NAME in LIST
do
	SOME_COMMANDS
done
```

A list of variables is simply provided with spaces in between them. Let's just make a list of column numbers in our `table.txt` as variables. As bash iterates through the list it assigns it to a new varialble. Thus, the VARIABLE_NAME part is not defined to start with and so doesn't take a `$` for its initial call, but will require it for the subsequent command. In order to print the names of the first 3 columns in our table let's to do a simple for loop with 2 command we learned earlier.

First make sure you are in the correct directory where these files should be:
```bash
cd ~/BioinfWorkshop2021/Part1_Linux/
```

- Let's get the column header for each of the first 3 columns in our table using the cut command to get each column and the head command to only show the first line (the header).

First, open the table with `more` to remind what it looks like and leave it printed to your terminal:
```bash
more table.txt
```

Now the `for` loop. Your terminal will print a `>` after you hit enter after the first line, but I have to leave these out here so that the command can be copied (if needed, try to type it).
```bash
for Column in 1 2 3
do
	cut -f ${Column} table.txt | head -n 1
done
```

If you got stuck or mistyped something and bash is still giving you the `>` prompt, you can get out of it with `Ctrl + c`. This is called a signal interrupt and is the best way to kill a command or incorrect entry that has you stuck and needing to get back your command prompt (class 1).

Now, let's do something more useful and add in another command we previously learned. Building up functions like this is a good method to make more complicated functions. Let's count unique entries in each column:

```bash
for Column in 1 2 3
do
	cut -f ${Column} table.txt | head -n 1
	cut -f ${Column} table.txt | sort | uniq -c
done
```

Pretty cool and exemplifies some utility in for loops. One potential problem though is that the header is reprinted and counted in the second command, so it's not just giving the number of each entry in the column as we would probably prefer. I left this as an excercise in previous class to figure out how to remove it. I'll give the answer here. By adding `-n +k` (where k is an integer) to the tail command we can output the end of something starting with the N line.

Note here that multiple command line entries can be entered at once if separated by a semi-colon `;`. I do this frequently, but it is much harder to read. For example use your arrow key to get back to your last for loop command and you will see your history displays it as such:

```bash
for Column in 1 2 3; do; cut -f ${Column} table.txt | head -n 1; cut -f ${Column} table.txt | sort | uniq -c; done
```

Now, we will add the `tail -n +2` to remove those column headers in the second command:
```bash
for Column in 1 2 3
do
	cut -f ${Column} table.txt | head -n 1
	cut -f ${Column} table.txt | tail -n +2 | sort | uniq -c
done
```

This is a pretty simple example to just intro loops early. But, it's good to think about already how loops can be useful. Generally, we will use them to loop over many files and perform the same function. Or, you could imagine looping through individual sequence entries in a single file. Both of these are behaviors you've already seen in commands like `ls` (listing each file in a directory) or `grep` (searching line by line). Hopefully you can imagine that loops are at the heart of most useful commands.

## Putting it all together. How to build a processing pipeline in a batch script.
Now that we understand differences between interactive and batch/non-interactive jobs and have learned more about CHPC, you may start to see how you might put together a pipeline that could be run through batch submission. A common process goes like this:
1. Work with a small subset of data in an interactive session to test out commands.
2. As you get each command working, copy the working commands to a new file in the order they will run. This will be your batch script.
3. Add the required SBATCH directives and submit the job to the Slurm scheduler on CHPC.

Let's follow this process, and start with a file to copy the commands to.

### Intro to Using Atom (Or Other Plain Text Editor)

- Really, any plain text editor (not a word processor, like Microsoft Word) can be used to facilitate your documentation. I have recently come to like Atom for it's easy add-in/package manager and pleasing format. I really just want make sure we are all using the same editor for simplicity though, and Atom is cross-platform. Frankly, I actually prefer BBEdit, but it's only available on Mac currently. Atom has many possible add-in/extension/packages provided by the community which makes it super useful, and plays really well with GitHub.

- Open Atom and open a folder on your computer (`File -> Open Folder...`). Let's say just your Documents folder at first (any folder with files will do). This shows again the Project directory centric mentality as the sidebar lists all the files in this folder, and even labels this sidebar "Project"! You can easily open other files in your project directory with a click. They should open in new tabs in Atom by default. Nice, but this is just to illustrate Atom's behavior which is a little different than you are probably used to with word processors.

- Open a new file in Atom.
  1. **"File -> New File"**.
  2. Create a local directory/folder wherever you like on your computer. I'll call mine "BioinfWorkshop" but it's not critical at this point, you just need to be able to find it later.
  2. Save your newly created file to this new directory location with the name: **PreProcess_16S.sh**. (**File -> Save As...**). The extension (`.sh`) is important here.

- I'll just intro a couple features or idiosyncrasies of Atom. Overall, I mainly leave it to you to familiarize yourself with software like this.
  1. Notice in the bottom right hand corner of Atom when you have your "PreProcess_16S.sh" file open, there is a text box that says "Shell Script". You can click on it and it will bring up a window to change the type of script Atom thinks this is. You don't need to change it, it is indeed a shell script (with bash as our shell). Auto-detect is the default behaviour and it detected it based on the file extension we gave the file (`.sh`).
     - This does nothing to the script. It just helps Atom highlight words based on what they might be (commands, strings, variables) and really, really makes it easier to see and write your scripts.
  2. Also in bottom right hand corner there is some text, either "**LF**" or "**CRLF**". These are line-endings. If you are on a Mac it will likely already say "LF", if on a Windows then "CRLF". You can just click to change between them. Linux uses "LF" line endings so we want everything to be "LF".
     - Side note, on CHPC there is a command `dos2unix` which can be used to convert a Windows created file to Unix line endings quickly.
  3. Settings. This is fairly unique and odd in Atom. I just want to point out where it is and won't get into why. Go to "**Packages -> Settings View -> Open**".
  4. Packages. Packages are add-ons that actually make Atom (or other lightweight editors) useful. Within the Settings View page you can see the tab on the left to "Install" packages. You can search there and also see and change those already installed on the "Packages" tab there. This may require admin privileges.

### Workflow overview for High-Performance Compute Clusters
- As previously discussed, we don't have a lot of storage space and indeed want to use HPC type clusters more for the 'computing' than storage.
- Commands in batch scripts on CHPC therefore tend to start with copying large input files to scratch space, and then end with copying smaller results files to save. The computing can just be redone if needed, don't save a bunch of intermediates.

![General Batch Script Process](https://drive.google.com/uc?export=view&id=1OmDxGQeS2wpe6I6B6Dtoin0xxqCvBqGw)

### Create and Initial Setup of Your Batch Script.
Remember, "bash" is the shell we are using. So, in order to have these commands interpreted when submitted as we are doing interactively, we need to specify in our script we want "bash" to do the interpreting. This is accomplished in the first line of our batch script.
1. Open (if not already) your file "PreProcess_16S.sh" in Atom.
2. Add this text to the very first line to indicate it should be read by bash
```bash
#!/bin/bash
```
Notice the 2 characters `#!`. This is called a **shebang** and directs what program should interpret it. It is NOT required (but without it you would need to specify the program to interpret your script) and only looked for in the very first line of a file. If this was a python script, for example, you would add the path to python after the `#!` for example. We are working in bash for this course.

3. As we build up commands in succession in the following interactive sessions, copy your commands to this file. This will then serve as your template for your batch job submission. As it's really a bash script, it could be run on any computer with the required programs. We just add SBATCH specific options (aka "directives") to it later to make it work on CHPC with the slurm scheduler.

4. As you add commands, add comments about what the commands do, expected inputs or anything else you like. To do this, just preface the comment with a `#`. These lines won't be interpreted by the program. Every language has such a comment character. Thankfully, for both bash and R it is the `#`.

Now, for submitted bash scripts you have documentation and the script in the same place. Make useful comments for good documentation! For interactive work (no submitted script; often in RStudio for us) we'll use another method to document what we are doing.

You may ask why we use Atom locally and not the built-in text editor Nano. Well, this is actually a fine idea. However, we use Atom because it's easier to keep a different window open in another program and may be an easier setup to document while working on command line too. What you are then doing is beginning to create an "integrated development environment", or an **IDE** for bash scripting. It's not exactly (an IDE is usually a single piece of software), but you can hopefully start to see what this funny term is because it is exactly what RStudio is to R.

## Our First Bioinformatics Project
Now that we've finally learned a whole bunch of Linux commands and created a nice bash shell environment, we will work through a dataset to get practice and reinforce some of these commands, as well as learn a really useful software package for microbiologists (and others really). We will work for the rest of this part on a 16S sequence dataset within QIIME2.

### Step 0: Draw out your methods and project goals
Of course, this step is technically optional, but it is always a good idea to ensure you know where you are heading, what tools you are using and are focusing your analysis. There's so many bioinformatics tools and methods to analyze sequences that you can really just find yourself floundering around creating potentially neat outputs that just aren't moving towards your project goal. Since this may be your first 16S microbial community analysis it is also helpful for me to show what we are trying to accomplish:
![Sequence_Preprocess_Overview](https://drive.google.com/uc?export=view&id=1S5wm0LPxPYwbLyuDWnoBktmA6fSH0e9e)

### Step 1: Setup a Project Directory and Variables Required.

Besides just being a good idea to plan out your method, your outline can also help you make a good directory structure upfront. It is important to avoid moving directories around in a project because, if you do, you're job scripts may no longer work or refer to the proper files. So, starting out with a good directory tree is helpful to keep any directory from beginning too unwieldy and tempting you to move things around.

Before we begin, we will need a directory to eventually store the job script. Also, I would like to separate this part of the class from the first part.
- Make a new directory on CHPC for `Part2_Qiime_16S` within your `BioinfWorkshop2021` directory, and place a `code` directory in it (remember the `-p` option will make the full directory tree you specify):
```bash
mkdir -p ~/BioinfWorkshop2021/Part2_Qiime_16S/code/
```
- Make a `metadata` directory as well to hold metadata and lists.
```bash
mkdir -p ~/BioinfWorkshop2021/Part2_Qiime_16S/metadata
```

**IMPORTANT: From here until we move to interactive analysis (except where noted), copy all working commands to your "PreProcess_16S.sh" script**. This will help you build a submittable batch job script.

- Make a scratch space and set variables for your scratch and working directory.

It's easy enough to refer to these directories all the time when working interactively, but setting them as variables will make your script a little more readable and easier to re-use later as templates if you wish. Also, good variable practice and makes it easier for me to refer to them across the class which may have them in different locations. Make sure to add your uNID (or other name) for your scratch directory. (remember lines starting with `#` are a comment):

```bash
# Set the scratch directory
SCRATCH=/scratch/general/lustre/<YOUR_UNID>/Part2_Qiime_16S
mkdir -p ${SCRATCH}
# Set the working directory variable and create a subdirectory to store your results in:
WRKDIR=~/BioinfWorkshop2021/Part2_Qiime_16S/results
mkdir -p ${WRKDIR}/results
# Listing the contents is not required, but helps show what is already there in the output if, for example, we need to rerun.
ls ${WRKDIR}
```
It's worth noting that it is generally safer to instead use absolute paths when setting directories and file names as variables. The `~` in this case should work, but as you start passing these to different environments (virtual env) it may lead to unexpected behavior. Similarly if relative to your current directory, the variable won't behave as expected as you move around. I use it here because your path will be slightly different, but I encourage you to use absolute paths in your SBATCH directives.

- Also, we built this up interactively so made the directories first. This will work so long as we are exact in our typing, but if you flip it around and instead define the directory as a variable first, then `mkdir` it, this will ensure that directory exists and commands that need it will run, even if you mistyped. Thus, you will see I usually couple any directory as a variable with a command to make that directory as well. `mkdir` doesn't overwrite the directory if it's already there.

#### (aside) Find / show project on SRA
I'll go through this quick because I'm often asked how to pull SRA datasets. It's incredibly easy now, but the sra-toolkit has some historical terminology that makes it seem more confusing than it is. I'm not trying to spend time showing you how to browse some website's interface, as this type of thing is always changing, but still will walk through this to show *one way* of pulling an SRA-hosted dataset and make sure we are all on the same page. **(NOTE: I probably will skip this part in class in the interest of time)**

NCBI, The National Center for Biotechnology Information, includes everything from PubMed to chemical and sequence repositories. Many of you have probably already published a paper in which the authors were required to deposit sequences at the NCBI or some other public repository. This was likely also accomplished with the SRA-toolkit, though you still may never need to do it yourself. It used to be a bit of catch-all for raw sequecnes, and was more difficult to make use of anything there because of a frequent lack of associated metadata. Now, sequences are required to be associated with BioSamples and BioProjects, making them much more easy to both search and tie metadata to in common formats across NCBI. The structure looks something like this:

- **BioProject** (sometimes an "umbrella" BioProject can encopass >1 BioProjects):
  - *BioSample 1* [with sample metatdata]
  - *...*
  - *BioSample N*
    - SRA deposited Illumina NovaSeq RNAseq reads (for example)
    - SRA deposited Illumina MiSeq 16S reads (for example)

First, let's find a SRA deposited dataset of interest. The SRA has a neat new interface that makes this much easier, called run selector. I've already found one that is a neat example for this class because it has paired 16S and RNAseq. It is BioProject [PRJNA434133](https://www.ncbi.nlm.nih.gov//bioproject/PRJNA434133). If you follow this link and click on the number next to "SRA experiments" it takes you to the list of all SRA entries for the project. Click on the link at the top that says "Send results to Run selector". You can see this is a more useful interface allowing clearer filter of samples. For now we just want to get a couple of this project's 16S sequence files to develop our pipeline. You can explore the website to understand it's use better, but since this isn't the point of this course I'll leave this up to you and just provide the accessions list for you later when we get to the whole dataset. To show the example though, follow this procedure to get the accessions and their associated data.
1. Click the checkbox next to 2 entries with the assay type "AMPLICON". These are 16S amplicons for this project. Doesn't matter which 2 as these are tests, but number 2 and 3 are a bit smaller than the first so I grabbed those.
2. Click the switch above the selected entries that says "Selected". The links under download are updated in the "Selected" row to only download data for those 2 entries.
3. Click on the "Metadata" button under "Downloads" on the "Selected" row. This downloads the metadata locally. Save the file as it's named, but add `_test` to give the filename `SraRunTable_test.txt`.
4. Do the same for "Accessions List", to give the filename `SRR_Acc_List_test.txt`.
5. Upload both these files from your local computer to the metadata directory we created (`~/BioinfWorkshop2021/Part2_Qiime_16S/metadata/`). Use OnDemand's file explorer (you can just drag them into that folder) if possible.
   -  If you are having trouble uploading them you can just copy them from my workshop space on CHPC (do not include these tester files copy in your batch script):
   ```bash
   cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/metadata/*_test.txt ~/BioinfWorkshop2021/Part2_Qiime_16S/metadata/
   ```

Now we can use these with SRA toolkit to pull the sequences from the SRA and analyze them in QIIME2 with the associated metadata.

### Step 2: Pull sequences with SRA
- Now, we are ready to pull our sequences. We will use the newer command from SRA-toolkit called `fasterq-dump`, which really simplifies the whole process. I encourage you to look at the help file for it to examine these options.

- We are setting the output and temporary locations to $SCRATCH because they can be big files. Here, it's only 2 smaller ones, but we are trying to build up a submittable script with bigger and more files. Here, you could just enter the command twice for each accession number we pulled, but let's use it as an opportunity to practice the for loops. Note, this is actually better suited for a while loop to read form the file, but currently I leave that for an exercise to understand while loops. Move to SCRATCH first as well.

```bash
module load sra-toolkit/2.10.9
cd ${SCRATCH}
```

```bash
for accession in SRR10501757 SRR10501758
do
  fasterq-dump ${accession} -e 2 -t ${SCRATCH} -O ${SCRATCH} -p
done
```

- This command (above) is the same as just typing the same command twice with the accessions. **Don't add this to your batch script** (though it actually can't hurt, it will just overwrite them and pull them again:
  ```bash
  fasterq-dump SRR10501757 -e 2 -t ${SCRATCH} -O ${SCRATCH} -p
  fasterq-dump SRR10501758 -e 2 -t ${SCRATCH} -O ${SCRATCH} -p
  ```
  - There's really nothing wrong with this and if you feel more comfortable at this stage listing each as a separate command, go ahead and do so. It just makes for longer more difficult to read code, and also makes it less reusable, but it does have the advantage of listing all the accessions in the same file as the command.

- This test dataset is used to build our pipeline and check our commands before submitting the "full" dataset which has many more accessions. We will read these from a file and I'll give you the command with a `while` loop to do so. I'd love to cover while loops, but not enough time in class so I've left it for an exercise for you outside of class.

### Step 3: Import sequences into a QIIME2 artifact

First, we will need to load our modules on CHPC and load QIIME2. You should have deactivated (`conda deactivate`) your QIIME2 environment after the install. If not, it may interfere with the fasterq-dump command. Reactivate the environment and make sure to add the commands to your bash script.

```bash
module use ~/MyModules
module load miniconda3/latest
source activate qiime2-2021.4
```

#### (optional) Loading the CHPC QIIME2 module
**! If you could not install your miniconda virtual environment and/or qiime2-2020.2 you can follow along with the older module installed on CHPC. It's a little odd right now b/c the message is misleading when trying to load it (I've contacted CHPC), but it should load properly like this. Only use the following command if you are using this older module!**
```bash
module load anaconda3/2019.03
source activate qiime2-2019.4
```

### Step 3: Import sequences into a QIIME2 artifact (continued)

Qiime2 uses it's own unique format of files, which they call **artifacts**. They are a pain to just view files because they are binaries, but they are really a neat solution to the build up and difficulty of file tracking. They allow so-called "provenance" tracking, or tracking the origin and functions performed on each file. This is really great for documentation, and really pushed me to loving QIIME. They even provide a reference for the functions you used! Cool. We'll look at this later but, for now, just know you can't operate directly on raw fastq files in QIIME and instead need to import them as QIIME2 artifact files. Make sure your QIIME2 environment loaded. If not, or you had unresolvable problem with the install, use CHPC's module instead (above).

- Qiime2 has a few different ways to import files and I'll leave it up to you to look at their documentation. We will use the "**manifest**" file format, which takes an input manifest file that lists the location and orientation of the input fastq files. It's pretty easy to create in a spreadsheet program, along with commands you have learned like `pwd` to get file paths.

- I'll show a method to make this "on the fly" in order to practice our Linux skilla dn introduce a new way to use variables. Many find this too much too soon, so feel free to just use the second option below if you'd like to just copy the manifest file I already made.

#### Manifest File Option 1: Make it on the fly with Linux commands
- First, create the header line for the file. It is a comma-separated value file. Save the output to metadata folder where manifest file should probably reside.

```bash
echo "sample-id,absolute-filepath,direction" > ${WRKDIR}/metadata/manifest_test.txt
```

- Now that you see the columns expected, let's create an entry for each file using a for loop. It's a good idea to use `echo` command without directing the output to your file at first, in order to check the output is as expected first. In class we will build this up piece-by-piece.

- The `%` after a variable name, when inside `{}`, says to strip the characters after the `%` from the variable. There's a bunch of really useful little tricks like this for string variables in Unix. Here's a great page explaining a few simple ones with sequence file usage examples: [http://www.metagenomics.wiki/tools/ubuntu-linux/shell-loop/string-split](http://www.metagenomics.wiki/tools/ubuntu-linux/shell-loop/string-split).

```bash
for read1 in *_1.fastq
do
  echo "${read1%_1.fastq},${SCRATCH}/${read1},forward" >> ${WRKDIR}/metadata/manifest_test.txt
done
```

Now, do the same for read2:

```bash
for read2 in *_2.fastq
do
  echo "${read2%_2.fastq},${SCRATCH}/${read2},reverse" >> ${WRKDIR}/metadata/manifest_test.txt
done
```

- We'll save it for an exercise to figure out how you could do this all in one loop instead of 2.

- Let's set this manifest file as a variable now as well. This isn't critical, but if you had made the manifest file before the script it would be a good idea. Mostly, it just makes it easier here for me when people have used option 1 or 2. Notice you could use $WRKDIR or the full path to WRKDIR because we placed this command after WRKDIR was set.

```bash
MANIFEST=${WRKDIR}/metadata/manifest_test.txt
```

- Checkout the manifest file format with `head` or `less`, or import it into excel to see how you just made a nice table. If you couldn't get this working, it's okay, you can copy the output of this section from me later so that you can move forward with the rest of the course, or use option 2 below. I can't give you a manifest file though because the filepaths refer to your specific filespace in scratch.

#### Manifest File Option 2: Copy and change to your scratch filespace

- You could easily just make this in excel or google sheets in practice as well, but if you couldn't make the above manifest file with my for loop commands just copy mine from shared space, then change your replace with your uNID to refer to your scratch space where the SRA downloaded files are.

1. Copy the template:
**Don't add this to your batch script**
```bash
cp /uufs/chpc.utah.edu/common/home/u0210816/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/metadata/manifest_test.txt ~/BioinfWorkshop2021/Part2_Qiime_16S/metadata/manifest_test.txt
```

2. Download the file using the OnDemand file explorer, or if you mounted CHPC, just find it in Finder.
3. Using a *plain text editor*, such as Atom, open the file and use find and replace (Command + F in Atom) to find and replace "uNID" with your uNID. Assuming you have your scratch space on `/scratch/general/lustre` already, we are just referring to your scratch space.
4. Save the file and reupload it to your `~/BioinfWorkshop2021/Part2_Qiime_16S/metadata/` directory with the same name.
5. Set the MANIFEST varialbe to refer to this file (do add this to your batch script):
```bash
MANIFEST=${WRKDIR}/metadata/manifest_test.txt
```

### Step 3: Import sequences into a QIIME2 artifact (continued 2)
Now, use the `qiime` and `import` commands to import these sequences. This first import tends to go pretty slowly unfortunately. Also, remember I'm going to use the backslash `\` when writing long commands so they can be shown over multiple lines, but the last line won't have it so that the final `enter` finalizes the command. First move to your SCRATCH space just to make the file listing shorter for me.

- First, bring up the qiime help file (**don't put this in your batch script**): `qiime tools import --help`. Also, note your autocomplete should work with qiime options, but only if they are all entered on the same line. This is very handy, but know that it is a feature qiime2 devs added in, so don't expect it for other software necessarily.

```bash
cd ${SCRATCH}
```
```bash
qiime tools import \
 --type 'SampleData[PairedEndSequencesWithQuality]' \
 --input-path ${MANIFEST} \
 --output-path seqs_import.qza \
 --input-format PairedEndFastqManifestPhred33
```

After that is done, you now have a QIIME2 artifact file that contains your sequences. We'll keep your sequences for now, but don't forget to clean up if needed later.

If you couldn't get the manifest file going (or just don't want to wait for import to finish), copy this output from my group directory to your scratch space so we can move forward (**Don't put this in your bash script**): `cp  /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/seqs_import.qza ${SCRATCH}`

Let's create our first visualizer in QIIME2. We will use the `demux` plugin for this:

```bash
qiime demux summarize \
  --i-data seqs_import.qza \
  --o-visualization seqs_import.qzv
```

- Copy it back to your working directory. These visualizers are generally pretty small and create a graph of various outputs, so are worth keeping anyways, but also you probably don't have scratch space through OnDemand file explorer or mounted.

```bash
cp seqs_import.qzv ${WRKDIR}/results/seqs_import.qzv
```

Now, download that file from CHPC to your local computer, then drag and drop it to qiime's visualziation page: [https://view.qiime2.org/](https://view.qiime2.org/). Click on the tab for "Interactive Quality Plot" near the top left of page. You can see these are paired-end 150 nucleotide sequences. The quality is quite nice for 16S sequences. You always see a pretty good drop in quality near ends, especially of read 2. Let's do some trimming.

### Step 4: Trim primers and join sequences
These parts differ if you are using DADA2 for denoising. We are going to use Deblur here mainly because it's fast. Some folks feel strongly about one or the other. I think they both have advantages and drawbacks. You'll have to do your own research or buy me a coffee/beer and we can talk more.

Because these are amplicon sequences they have primers at the front. As these were put their by PCR, they represent a technical artifact and we don't want these parts of the sequence to influence phylogenies or taxonomies. Here QIIME2 uses cutadapt to trim the primers. Cutadapt is a commonly used program for removing adapters/primers and is notably also installed as  a module on CHPC and has a number of useful options.

I've provided the primer sequences in the command here, but notice that these are part of the metadata that we downloaded from the SRA. Note the `-p-cores` option sets the number of processes to start. We only have 2, but on a full job submission on a single node you can run many more and go much faster. It's a good idea to put a variable for this for each script so you don't need to change it for each command.

```bash
qiime cutadapt trim-paired \
  --i-demultiplexed-sequences seqs_import.qza \
  --o-trimmed-sequences seqs_trim.qza \
  --p-front-f GTGCCAGCMGCCGCGGTAA \
  --p-front-r GGACTACHVGGGTWTCTAAT \
  --p-cores 2
```

Now, we will join the paired end sequences with vsearch. Note, If using DADA2 you wouldn't join the sequences first. `vsearch` again, is a separate program that QIIME2 is wrapping. I like to keep the verbose option here because it prints useful data to screen that is helpful for troubleshooting and explains why my reads may or may not be merging. I tend to take a somewhat permissive approach at this stage with the options and let the deblur denoising do the main "denoising"/filtering. Most options from this section are specific to your sequencing strategy and sequencing run quality.

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
```bash
cp seqs_trim_join.qzv ${WRKDIR}/results/
```

Notice in the visualizer how some of the sequences drop out after 214 (mouse over the graph). So, of the 10k seqs randomly subsampled for this graph, some are not that long. This is usually the safest place to trim your sequences in the next section, but partly just represents real variation which you may not want to remove. We actually only loose 2 sequences out to 250, so trimming that full 36 bases would be a waste of a lot of sequence info. However, also note that at the very end there are only 1 or 2 seqs that are longer. This part always requires inspection for your sequencing project to determine the appropriate trim length to pass to denoising algorithm. With DADA2 the process is a bit different, but still requires inspection of sequence quality plots at one point, so generally 16S seq preprocessing should not be fully automated.

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

It's worth spending some time to look at the help file for this command and think about your own particular experiment. The defaults may not be appropriate for each option, so be careful here. You can certainly imagine how some of these absolute read number counts could have a very different impact depending on depth of sequencing of an experiment. In general though, they aren't too bad. For most of us, that rare variant that is only present in one sample is going to be too hard to work with anyway, even if it was real. However, removing rare species can have a HUGE impact on some alpha diversity metrics, so ecologists, in particular, should be aware of what's going on here.

#### OTUs versus ASVs/ESVs
You may have heard the term OTU before for microbiota work. Until recently we would be creating an "OTU" table at this step. Now we create an ASV/ESV table. I'll use the term ASV as I think it is slightly more appropriate.

- **OTU**: Operational Taxonomic Unit. Clusters of seqs at some % similarity.
- **ASV**: Amplified Sequence Variant (or ESV - Exact Sequence Variant)

To boil this change down simply, OTUs lost a lot of information because they are clustered at some % similarity (usually 97%) and a representative sequence is then chosen. There are a number of different ways to create clusters though, and then a number of different ways to choose the representative (most abundant? best quality? most representative?). None of the methods is "perfect" in representing the underlying species. By their very nature clusters are an approximation. However, the justification for a long time was (at least) 2-fold. First, 97% similarity of 16S was sort of agreed on as a decent approximation of species across the bacterial phylogeny; 99% as strains 93-ish% as genus and so on with increasingly worse approximations. Remember **phylogeny IS NOT EQUAL TO taxonomy**. Unfortunately, it's closer to reality in some places of the phylogeny and much worse in others, and this varies depending on the 16S region you are looking at. Second, the justification was that these sequences were necessarily very noisy, so clustering them could get rid of some of this, preventing a single nucleotide difference from being a different species, and at the same time reducing size of the table and compute time. Eventually people started arguing that we could get strain-level resolution if we clustered at 99% instead. This is just "kicking the can down the road" because it still ignores the real biology of life and the fact that the difference between a species or strains (or any other taxa difference really) are artificial constructs anyways. But, it does beg the question, why throw away potentially discriminating information? And that's exactly why ASVs have become the general method of choice now. We acknowledge deficiencies in taxonomic definitions and retain as much information as possible, while still employing sequence-level denoising. This is all still a bit of an oversimplification, again due to the nature of this as a workshop not a course, but it's worth noting and thinking about because it is critical that you understand that **the features in this table DO NOT REPRESENT SPECIES**. They never did with OTUs either, but now we just call these "feature tables" instead of OTU tables to further solidify and also because they could hold any type of "feature". Many microbial ecologists especially had thought about this for a long time before this, but here's a nice paper discussing the change if you are interested in further reading: [ESVs should replace OTUs](https://www.nature.com/articles/ismej2017119)

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
Did you see what I did with the table files there? Remember regex?

### Step 6: Build phylogeny
Again, QIIME2 is not the actual code building the phylogeny here. It is, instead, wrapping other functions to do this and, in this case, making a pipeline for making a phylogeny from sequences. There are a number of methods once could use to do an alignment and then build a phylogeny. In this command QIIME2 will align sequences, apply a mask to some of those aligned positions (highly conserved bits, especially all gaps) and then build a phylogenetic tree. So, this is great to do this all in one command instead.

We build phylogenies in 16S seq analysis because they allow a unique type of measure of diversity between communities ("beta diversity"). The measure that has really taken over is called UniFrac, and measures the unique fraction of phylogeny between communities. So, instead of each species (ASV really) contributing equally to a measure of difference between samples, different species found in different samples that are more distantly related will contribute more. A sort of weighting by relatedness. It's a cool concept that stems from the notion that things more closely related are more likely to share similar functions. As a pretty extreme example, consider *E. coli* and *Salmonella enterica*. Sure, they are fairly different functionally in the world of immunology and pathology, but not nearly as differnt as are *E. coli* and the Archaeal species *Methanobrevibacter smithii*. So, the contribution to the differences between 2 communities (beta-diversity) should probably be greater in the case where one community has *M. smithii* and one does not, than when one community has *S. enterica* and one does not. Since we need to know these relationships we need to calculate a phylogenetic tree. At least currently, this is still usually done *de novo* each time.

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
The last step before we start to use more community-level analytical tools to examine differences between samples, is to call phylogenies. The choice of taxonomy reference and method has a tremendous impact on the named species in your community. This is a circular statement, so should be obvious (i.e. species names are a taxa). However, a lot of people look at the inconsistent taxonomic calls and throw their hands in the air and say none of this stuff works and there's nothing useful here. The problem isn't the methods, or even really the taxonomies. The problem is that taxonomies aren't real! We can always improve on them to get better relationships, but they continue to be categoricals we put species into and this will never properly reflect evolution over long time scales (never say never...?). I love this subject so will end here, but suffice it to say your choice of taxonomic classifier and reference makes a big difference. While everyone wants a taxonomy to talk about, this is (in my opinion) where these methods are actually the least useful. You don't have to use taxonomies at all to describe communities though.

For taxonomic calls in QIIME2 we need a trained classifier. This can be done in just a couple steps, but can take awhile and only needs be done once. It's also been shown classifiers work better if the input is trimmed to the region of the query (what you amplified). I've already done this for you and provide the classsifier. Just make a variable reference to it for simplicity. This one is trained on the Greengenes taxonomy and reference set.

```bash
CLASSIFIER=/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part2_Qiime_16S/gg_13_8_515F806R_classifier_sk0.22.1.qza
```
Now, run the classifier. Here we will use sci kit learn. Interestingly, because machine learning is so concerned with the problem of classification, classifiers are getting better and better and really this doesn't matter much that these are biological sequences. Computer scientists have been working hard on classifiers for quite awhile now and continue to do so. Biologists are benefiting in many ways including improved taxonomic classification of sequences.

```bash
qiime feature-classifier classify-sklearn \
--i-classifier ${CLASSIFIER} \
--i-reads repseq.qza \
--o-classification taxonomy.qza \
--p-n-jobs 2
```

```bash
cp taxonomy.qza ${WRKDIR}/results/
```

### Step 8: Cleanup!
While scratch space is cleaned regular, it's still not limitless and the entire campus+ is using it with massive datasets. Make sure you clean it when you are done. I'd also note, usually it makes more sense to actually copy all your files you want to return at this step. I only did it after each step because I don't know how fare we will get in class.

```bash
rm *.fastq
rm *.qz[av]
```

**IMPORTANT: Stop copying commands to your bash script, unless noted**

### Final Step: Finish the batch script and submit.
At this stage, you should have a full pipeline that takes input seqs and outputs a feature table, representative sequences, phylogeny and taxonomy. Nice! You know it works because you tested it out, so you can now extend it to the full 16S sequence dataset. But this will take a bit longer to run (mostly just the pulling of the sequences actually), so we will submit it as a batch job script as CHPC is intended. If you've been adding your commands as you were supposed to you are mostly ready for submission. 2 tasks remain.

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
Normally, any line that starts with a # in a bash script would be a comment, but for slurm processed bash scripts if the lines at the beginning start with a `#SBATCH` (sbatch directives) they will be interpreted by slurm to provide the options required to schedule your job. These are the same options (plus some) that you used for `srun`! One of the other cool bits about OnDemand is that they have some of these templates for you already and you should check them out. For this first sbatch submission, I'll just provide those you should add and tell you about them. Add the following lines at the beginning of your script, after the first line containing the shebang (shown for clarity, don't enter it twice)().

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
- The `-o` option specifies a file to save the standard output to. By default sbatch actually combines standard eror and standard output, hence the extension I like to add, but you can add any extension you want as well. It usually makes sense to name this at least with the same name as script it came from
- `-J` is the jobname that it will be under when you view the queue.

##### Note on partition, processes and time
Unless you go back and change everytime you referred to number of processes (or better yet use a variable for it), there's no sense in taking more than 2 processes. Be nice! Your job will take awhile with only 2 processes, but will finish. Feel free to change this though if you like. In regards to time, standard limit on CHPC is 72 hours, but there are ways to run longer. If you request really long you may wait longer in queue though. CHPC has a formula that determines your job priority. Generally, the less resources/time you request the sooner you will run.

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
- `grep` can take a file with a list of patterns to search for as well, using the `-f` option. Can you modify the final grep command in the grep section to just get the sequence identifiers in a new file, then use this file to extract the 4 lines for each sequence from the original read 1 file?

# Links, Cheatsheets and Today's Commands

- CHPC page on setting up a conda environment: [https://www.chpc.utah.edu/documentation/software/python-anaconda.php](https://www.chpc.utah.edu/documentation/software/python-anaconda.php)
- Conda cheatsheet: [https://docs.conda.io/projects/conda/en/latest/_downloads/843d9e0198f2a193a3484886fa28163c/conda-cheatsheet.pdf](https://docs.conda.io/projects/conda/en/latest/_downloads/843d9e0198f2a193a3484886fa28163c/conda-cheatsheet.pdf)
- One of MANY available **grep** cheatsheets with nice examples: [https://staff.washington.edu/weller/grep.html](https://staff.washington.edu/weller/grep.html)
- Today's New Commands:
  - `grep`: **g**lobal **r**egular **e**xpression **p**rint. Format: `grep "<REGEX_PATTERN>" <FILE_INPUT>`
	- `for`, `do`, `done`: For each item in a list, do a command or commands and be done. Format :
	```bash
	for <TMP_VARIABLENAME_FOR_EACH_LIST_ITEM> in <LIST>
		do <COMMAND>
		(optional) <MORE_COMMANDS>
	done
	```
  - The backslash `\` is used to "escape" special characters and read them as-is.
