<!-- TOC -->

- [Main](#main)
  - [Today's Objectives:](#todays-objectives)
  - [Requirements and Expected Inputs](#requirements-and-expected-inputs)
  - [Obtain interactive shell session on lonepeak cluster](#obtain-interactive-shell-session-on-lonepeak-cluster)
  - [Intro to Loops. The `for` loop.](#intro-to-loops-the-for-loop)
  - [Introduction to Regular Expressions and `grep`](#introduction-to-regular-expressions-and-grep)
  - [Installing Precompiled binaries](#installing-precompiled-binaries)
  - [More on CHPC](#more-on-chpc)
    - [Accounts, allocations and partitions](#accounts-allocations-and-partitions)
      - [Accounts:](#accounts)
      - [Allocations:](#allocations)
      - [Partitions:](#partitions)
    - [Disk space and scratch directories](#disk-space-and-scratch-directories)
      - [Softlinks to scratch space.](#softlinks-to-scratch-space)
    - [Interactive versus Submitted/Batch Jobs](#interactive-versus-submittedbatch-jobs)
    - [Modules and software](#modules-and-software)
      - [The `$PATH` environmental variable](#the-path-environmental-variable)
  - [Adding to your $PATH](#adding-to-your-path)
  - [A reminder on mounting CHPC space on your computer](#a-reminder-on-mounting-chpc-space-on-your-computer)
  - [Documentation, Project Directories and Atom](#documentation-project-directories-and-atom)
    - [Atom](#atom)
    - [Putting it all together. How to build a simple pipeline](#putting-it-all-together-how-to-build-a-simple-pipeline)
      - [A batch script using bash](#a-batch-script-using-bash)
  - [Our First Bioinformatics Project](#our-first-bioinformatics-project)
    - [Step 1: Setup a Project Directory](#step-1-setup-a-project-directory)
  - [Installing QIIME2 in a conda environment](#installing-qiime2-in-a-conda-environment)
    - [While we wait for Qiime2 installing:](#while-we-wait-for-qiime2-installing)
      - [Why QIIME2?](#why-qiime2)
      - [Find / show project on SRA](#find--show-project-on-sra)
  - [Installing QIIME2 in a conda environment (finishing up the install)](#installing-qiime2-in-a-conda-environment-finishing-up-the-install)
- [Practice / With Your Own Data](#practice--with-your-own-data)
- [Links, Cheatsheets and Today's Commands](#links-cheatsheets-and-todays-commands)

<!-- /TOC -->
# Main
### Today's Objectives:
1. Finish introducing remaining shell commands and concepts
2. Install an executable pre-compiled program.
3. Introduce more details on CHPC
4. Discuss project organization and documentation methods.
5. Introduce and create a conda environment for QIIME2.
6. Pull SRA sequences (time permitting).

### Requirements and Expected Inputs
- Internet connection
- CHPC account, *with a bash shell!* and interactive session.
- Previous day's `table.txt` and `read1.fastq`

## Obtain interactive shell session on lonepeak cluster
1. Log in to CHPC via your preferred method (OnDemand, ssh from Terminal, or FastX Web server). Note that it is preferable to NOT use ssh from Terminal for this session, unless you have mounted your CHPC home space or otherwise know how to download files via command line only (Eg. `scp`).
2. Obtain an interactive session with 2 processors.
```bash
$ srun -A MIB2020 -p lonepeak-shared -n 2 --reservation MIB2020 --time 2:00:00 --pty /bin/bash -l
```

## Intro to Loops. The `for` loop.
Loops are a family of statements that iterate through items in different manners. This is where we really start to do some programming and see the power of the command line or scripting. Loops are nearly always at the core of coding, and I am introducing them early because they are so helpful to understand. We will use just one simple examples here and then frequently expand on them as we move forward. Their syntax varies a bit from language to language, but the basic structure is the same: A condition and something to do for that condition. The main loops you will likely use in bash are:

- `for` loop: Takes in a number of values and does something **for** each one.
- `while` loop: **while** the condition is true do the function.

These loops will be written over mulitple lines. They aren't just a long single entry separated by a `\` like we've seen before, but multiple command-line entries. When entering a `for` loop bash knows to expect more input for the command after you type the for statement, so does not return anything and provides the `>` prompt for more entry. To tell bash you're done with the loop you enter the (you guessed it!) `done` statement.  The basic structure of a for loop is like this (don't enter this):

```bash
for VARIABLE_NAME in LIST
do
SOME_COMMANDS
done
```

A list of variables is simply provided with spaces in between them. Let's just make a list of column numbers in our `table.txt` as variables. As bash iterates through the list it assigns it to a new varialble. Thus, the VARIABLE_NAME part is not defined to start with and so doesn't take a `$` for its initial call, but will require it for the subsequent command. In order to print the names of the first 3 columns in our table let's to do a simple for loop with 2 command we learned earlier.
First make sure you are in the correct directory where these files should be:
```bash
cd ~/BioinfWorkshop2020/Part1_Linux/
```
```bash
$ for Column in 1 2 3
$ do
$ cut -f ${Column} table.txt | head -n 1
$ done
```

If you got stuck or misentered something and bash is still giving you the `>` prompt, you can get out of it with `Ctrl + c`. This is called a signal interrupt and is the best way to kill a command or incorrect entry that has you stuck and needing to get back your command prompt.

Now, let's do something more useful and add in another command we previously learned. Building up functions like this is a good method to make more complicated functions. Let's count unique entries in each column:

```bash
$ for Column in 1 2 3
$ do
$ cut -f ${Column} table.txt | head -n 1
$ cut -f ${Column} table.txt | sort | uniq -c
$ done
```

Note here that mulitple command line entries can be entered at once if separated by a semi-colon `;`. I do this frequently, but it is much harder to read. For example this is the exact same for loop as above:

```bash
$ for Column in 1 2 3; do; cut -f ${Column} table.txt | head -n 1; cut -f ${Column} table.txt | sort | uniq -c; done
```

## Introduction to Regular Expressions and `grep`

"Regular expressions" (AKA "regex") are sequences of characters usually used for searching text strings. They are extremely powerful and we could spend probably spend a full session or two on them but will keep it very simple instead, in line with the objectives of this workshop. I strongly encourage more reading on them outside of class time as you can really make those annoying formatting tasks simple, fast and more consistent. "Cheatsheets" are really helpful. I used to use regular expresssions a lot more to deal with various odd sequence filtering and reformatting tasks, but with the proliferation of bioinformatics tools specifically designed for this, I tend to use them less and less. A few patterns are still really helpful to know of.

One regular expression pattern many may have encountered already is the commonly used `*` wildcard, which matches anything. This is very frequently used to lists subsets of files with common extensions. Let's use it to list all the .fastq sequence files here, then the different table files we may have created:
```bash
$ ls *fastq
$ ls table*
```
So, what happened here? This wildcard matched *zero or more* of anything (except linebreaks usually). It's sort of the biggest catch-all wildcard; it will match alphanumeric characters or spaces or symbols. Commands in linux (such as ls) are a bit limited in what they can interpret easily like this because a lot of the special characters in pattern matching are already in use. For example the `.` in regex will normally matches *exactly one* of anything, but used naturally is all over in filename. So, we'll actually use the grep command to illustrate further regex, but first let's see how you can also use ranges to get filenames:

```bash
$ ls read[1-2].fastq
```
Much like we saw in the cut command for specifying fields, you can use ranges (`-`) or a list of characters to match patterns. As it only matches a single character you don't need to separate them by commas (in other words you could also type `ls read[12].fastq` above).

Regular expressions have a lot of commonalities in their intrepretation from one program to the next, but a few differences do exist. `grep` is a function used all over the place, including Unix/Linux and R, and stands for global regular expression print. There are a few different flavors of it, but again we will keep it to basics that are usually common among them. If you encounter unexpected behavior with grep you probably mean to use on of the others, such as `fgrep` or `egrep` (the extended grep will actually behave best usually). To first show how grep in Linux normally works, look at the sequence identifiers in the read1.fastq file using `head`. You can see they share a lot of the same information which identifies the machine, run, etc for which all sequences in a given run will have the same information. Let's pull all the sequence identifiers just using this common information. To avoid priting all 4k lines we'll pipe the output to `head`.
- `grep`: **g**lobal **r**gular **e**xpression **p** rint. Format: `grep "<REGEX_PATTERN>" <FILE_INPUT>`

```bash
$ grep "M00736:301" read1.fastq | head
```
We actually didn't use any special characters in our pattern, but this is still pattern matching. Now let's look at one way of using special characters to indicate position of matches. The `^` specifys that the following patter should be at the beginning of a line. It's frequently useful. In this case, these seqeunces are from amplicons, so they should have primer sequences at the beginning of them. The primers are also degenerate, so in some places could have multiple different bases. First, use the primers with degenerate base notation and search for them at the beginning of the sequences:
```bash
$ grep "^TGCCTACGGGNBGCASC" read1.fastq
```
Nothing there, which is good, but Illumina does report "N"s in sequences. Now, use multiple nucleotide characters to search for those primers, replacing the degenerate bases with their possibilities at that position. Add the `--color` option to highlight the matches. Grep returns the lines that match as with most utilities in Linux:
```bash
$ grep --color "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq
```
There's 1,000 sequences in that file. How many have the appropriate primer at their start? Pipe the output to `wc -l` to find out. Then, remove the `^` to see if some of these sequences don't have the primer at the start
```bash
$ grep --color "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq | wc -l
$ grep --color "TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq | wc -l
```
So, there's a few in there that don't have the primer at the beginning. Let's just isolate the sequences with the primer the beginning. But, we would probably want to maintain the sequence format with the identifier on the line before. Grep has options to retrieve lines before (`-B`) and after (`-A`) the match. Add those to our command with the `^` to grab all the sequences with primers at the front as expected and their identifiers.

One minor annoyance is that grep outputs this `--` in between groups of matches, which we don't want. But it's a good opportunity to illustrate the inverse match and the character escape. Here the `-v` option inverts and takes the non-matching lines, so we can use it to remove those `--`.

- The backslash `\` is used to escape special characters and allow them to be read as is. This is common behaviour for this key.

Work up the command line by line to get the sequence ID and sequence of each sequence with primer at the front and print it to a new file. For a simple check of behavior continue to pipe the output to `wc -l` to see if the output is as expected based on the known 931 sequence matches we determined above.


```bash
$ grep -B 1 -A 2 "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq | wc -l
$ grep -B 1 -A 2 "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq | grep -v "\-\-" | wc -l
$ grep -B 1 -A 2 "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq | grep -v "^\-\-" | wc -l
$ grep -B 1 -A 2 "^TGCCTACGGG[AGCT][CGT]GCA[GC]C" read1.fastq | grep -v "^\-\-" > read1_SeqsWithPrimer.fastq
```
Hopefully, this demonstrates both some basic pattern matching, and you can see how you don't necessarily need to have a program installed to do some really simple sequence searching and retrieval very quickly on millions of reads.

There's also a ton of great sequence manipulation tools out there now. Some are already installed on CHPC. Let's look at another in the next section.

## Installing Precompiled binaries
A major goal of this course is to address common scenarios you will encounter when trying to use a bioinformatics package. Here I will show the simplest case of an install - a precompiled binary. This is a simple executable file that contains all the methods needed for a program and is ready to run as it is. Precompliled binaries are compiled for a given system architecture and so will not always be availbe for your system, and even then may not work as expected so compilation is often preferred.

Let's install a really simple sequence manipulation toolkit as an example. It's a decent little toolkit, though there are many others out there.

1. Make a directory for your binaries and move into it:
```bash
$ mkdir -p ~/bin/
$ cd ~/bin
```

2. Use `wget` to pull the linux 64-bit binary:
```bash
$ wget https://github.com/shenwei356/seqkit/releases/download/v0.12.1/seqkit_linux_amd64.tar.gz
```
- `wget`: Pull something from the web. Use the `-o` option to provide a different filename when downloading.
3. Unpack/decompress with tar and gzip
```bash
$ tar -zxvf seqkit_linux_amd64.tar.gz
```
- `tar`: Archives many files together in a single file. Use `-z` to pass through `gzip` as well.
- `gzip`: Compression/Decompression utility. Frequently used on an archive from `tar` for effective compression.

4. Clean up the download that we extracted the binary from:
```bash
$ rm seqkit_linux_amd64.tar.gz
```

Seqkit exists as a single binary file. Notice it should have `x` file permissions for you with the `ls -l` command. If it doesn't add them with `chomd`.

For now, you can call your binary by just referring to it if you are in the directory it is in. Or, if outside of that directory, by giving the full path to it. We'll finish this install by adding it to your path in a later section so you can refer to it no matter where you are. But it should run as is. Use the or `--help` option to get the help file. This is a very common convention for help files and is almost always available in a program.
```bash
$ seqkit --help
```
It has a number of functions listed. Let's bring up the helpfile for the fastq to fasta conversion function:
```bash
$ seqkit fq2fa --help
```
Notice by default with the `-w` option it will output the fasta format with fixed line width. Yuck! But, nice to have this option I suppose as it usually is not built-in to these toolkits. Let's turn it off and convert our read1.fastq file. Makes sure to move back to our Part1 diretory first:
```bash
$ cd ~/BioinfWorkshop2020/Part1_Linux/
```
Now, since our system doesn't know about this executable yet we will have to specify where it is in order to execute it. It will print the processed fasta seq file to standard out normally, so redirect it to a new file.

```bash
$ ~/bin/seqkit fq2fa -w 0 read1.fastq > read1.fasta
```

That's a handy little utility that you may notice also has built in parallelization (the `-n` option) so we can run really fast. We will return in a moment to show how to add this to our path so it comes up with autocomplete and we don't need remember where it is.

## More on CHPC
Previously, I just introduced the overall structure of CHPC as a distributed computing cluster. Now, we will go further into details of CHPC with an emphasis on practical use for all users. I encourage you to review CHPC's excellent documentation for more details, particularly after the course is through. See the links in the last section and throughout here. For brand new users used to working on a single computer, the different terms and structure can be a bit confusing, but after running through an initial workthough on CHPC (as in this workshop), it should help to solidiy how high-performance computing (HPC) clusters such as CHPC are managed.

### Accounts, allocations and partitions

#### Accounts:
Each user must have a user account, clearly. These user accounts give you access to CHPC and 50Gb of home space, which **is NOT backed up**.

User accounts are also associated with a group account, and generally when we say "account" on CHPC we will be referring to this group account rather than your user account. For this class we have a special, but temprorary, account called "MIB2020" that allowed us to ensure you could all work on CHPC even if your PI had not signed up for an account yet. When submitting jobs or obtaining an interactive session you must provide a group account as well. You can be (and probably are) associated with multiple accounts. These accounts are used to determine which *allocation* and/or mode to use when submitting jobs. Will return to this in a moment. Allocations and accounts go hand-in-hand.

CHPC now has a command to show you your account and allocation combinations. Input this command to print your CHPC account-allocation-partition combos:

```bash
$ myallocation
```

PIs, it is a good idea after this course to ensure your group has an account so that your lab is associated properly with you. Also, and perhaps most importantly, you can get a general computing allocation for your group (more about this in allocation section). You can also assign a delegate to manage your space, purchase extra storage, backup space, or even your own node! I highly recommend this if you are even serious about bioinformatics. For not much more $$ than a decent Mac desktop you can get a very powerful node always available to your group, so you never have to wait in the queue. CHPC operates in what they call "condominium" style, where an owner node is available to the general CHPC community when you aren't using it, but your group preempts other if you own it.

All others make sure to get associated with your PI after the course if you are not already. Will send email regarding this later.

#### Allocations:

Each group can be allocated a number of compute hours each semester. Allocations can be broken down into 2 main types: general or owner.
- Owner allocation: When you own a compute node of your own.
- General allocation: Requested yearly by PI or their delegate.
    - Small allocations of 20,000 compute hours per semester now available. Short form application.
      - "Quick Allocation" availabe for first time CHPC PIs.
    - Regular allocations (>20,000 hours) requested by somewhat larger application.

- Running jobs without an allocation
  If your group does not have a general allocation, you can still run jobs on CHPC in *unallocated* OR *pre-emptable* (freecycle) mode. An allocation ensures your jobs will run until finished, while in pre-emptable mode your jobs will run on available owner nodes but will be killed if needed to make resources available for owners. With careful requesting of resources you can actually run pretty effectively with no allocation. However, it's very easy to request a general allocation, CHPC has streamlined the process for small allocations, and the 20,000 hours per semester could be quite sufficient for your needs. Additionally, you can currently run jobs *unallocated* on some nodes, such as lonepeak currently. In summary:
    - Allocated: Not pre-emptable. Your PI (or delegate) completed application and has an allocation each semester.
    - Unallocated: Not pre-emtpable. Currently only on lonepeak (?). Your group does not have an allocation.
    - Pre-emptable / freecycle: Pre-emptable. Runs on owner nodes as guest. AVOID / IGNORE unless you know how to use a pipeline manager.

I tried to simplify accounts and allocations to what is most important to get a working understanding, but this is all an oversimplification and actively changes a bit. Make sure to see CHPC's documentation for more info:

- CHPC has a very useful couple tables to further illustrate combos of account and paritions: [https://www.chpc.utah.edu/documentation/guides/index.php#parts](https://www.chpc.utah.edu/documentation/guides/index.php#parts)
- CHPC allocations page: [https://www.chpc.utah.edu/userservices/allocations.php](https://www.chpc.utah.edu/userservices/allocations.php)

#### Partitions:
Bring up your allocation information with the `myallocations` command again if you don't have the information up still. You can see that these are combined with partitions to give the full information needed to understand your allocation of resources at CHPC.

It is easiest, but incorrect, to think of partitions as synonymous with the clusters I mentioned in the first part. For some reason I still make this mistake in my thinking. However, among these clusters there are multiple partitions, which may illustrate that partition is really used more generally. There are 3 main clusters we will discuss, each with *at least* 3 partitions.
- kingspeak cluster
  - kingspeak [*jobs take entire node*]
  - kingspeak-shared [*must specify number of processes*]
  - kingspeak-freecycle [*pre-emptable*]
- lonepeak cluster
  - lonepeak [*jobs take entire node*]
  - lonepeak-shared [*must specify number of processes*]
  - lonepeak-freecycle [*pre-emptable*]
- notchpeak cluster
  - notchpeak [*jobs take entire node*]
  - notchpeak-shared [*must specify number of processes*]
  - notchpeak-freecycle [*pre-emptable*]


- Notably, there is a separate environment and cluster for sensitive data, such as PHI. The **redwood** cluster.
- If you own a node, you have your own partition as well. For example my lab group's is `round-np` and we have a `round-np-shared` partition also.

The distribution of resources and types of partitions is always changing as CHPC manages their system. For example, the "ember" cluster was recently retired and kinsgpeak became available to run on without an allocation, as notchpeak grows with the newer hardware.

### Disk space and scratch directories

You are provided 50Gb of home space with your account. This is not very much in the world of high-throughput sequencing. Note PIs can buy fairly cheap additional space, but I'd argue it's generally not a good idea to consider CHPC somewhere for any type of long-term storage. Most of you will have an IT department (Path-IT) that is better suited for storing and managing backups and/or syncing of your data. You should use them for data management. It is definitely possible to backup or sync your CHPC space, but the emphasis is more on facilitating computing.

File space usage on a high-performance computing cluster is a bit different than you may be used to. You need to have a mentality that it easier and cheaper to recompute than to store many large files. This explains why you have a fairly small home space. But you do need to temporarily store very large files (usually sequences) in order to work on them and manage intermediary results. Enter "scratch" space. This is a general term not specific to CHPC that you may have encountered before. It is large disk storage space that is intended for temporary files only.
- Scratch: space for temporary file storage. On CHPC, files on scratch will be removed after 60 days (don't count on it!).

- CHPC page on storage systems, including scratch: [https://www.chpc.utah.edu/resources/storage_services.php](https://www.chpc.utah.edu/resources/storage_services.php)

Currently, there are 3 main scratch files systems, which are now all accessible from any cluster:
- /scratch/general/lustre
- /scratch/kingspeak/serial
- /scratch/general/nfs1

There are differences among these that do matter for speed, but we won't get into it. You're unlikely to care much about the read/write access speed differences for quite awhile in your bioinformatics. For now, setup a directory for yourself on lustre:
```bash
$ mkdir -p /scratch/general/lustre/<YOUR_UNID>/
```

#### Softlinks to scratch space.
It should be pretty easy to find this, given the short path, but you may forget which scratch system you are on. This is one situation it may be helpful to make a 'soft link' to your scratch space. Soft links are analgous to shortcuts you are familiar with on your desktop. Just a pointer to another directory/file. Make a softline in your homespace to your scratch space with `ln` command. List your homepsace contents to see how this link looks.
- `ln`: Makes link to file/directory. **Recommend always use with `-s` option for soft links.** Format: `ln -s <TARGET> <LINKNAME>`

```bash
$ cd ~/
$ ln -s /scratch/general/lustre/<YOUR_UNID>/ scratch_lustre
$ ls -l ~/
```

It's notable to mention that making a bunch of softlinks around your data is not a good habit. It's often tempting for beginners especially, but the problem is that these links are relative filepaths and we want to generally use absolute paths for better reproducibiltiy and documentation. I'm comfortable doing this for scratch space because it is, by definition, temporary file space so any references to it will not last anyways.

### Interactive versus Submitted/Batch Jobs
Currently, we are running an interactive session on a compute node (if you use `srun` command). This is actually a managed job itself that provisioned resources, but gives you a shell to interactively type command and view the output. Notice how we add `/bin/bash` to specify the bash shell. Interactive sessions are very helpful of coures, particularly for development purposes. However, I think it's fair to say this is not really the intended method of interacting with a HPC cluster like CHPC. Generally, if you can do it in an interactive session, you can likely accomplish the computing needed on your desktop or laptop. Most computing that actually requires HPC resources is going to take awhile or just generally won't be amenable to interactive sessions. There are a number of situations where you really just need one big computer for a bit and interactive sessions might be a good fit. Somewhat surprising, anecdotally, it seems methods for interactive sessions are actually increasing, but still mostly we should have the mentality to do our computing with submitted jobs, aka ""**batch**" jobs, when possible.
- Batch scripts: Submitted, or non-interactive job scripts.

There's also a big advantage to batch scripts over interactive. The job script itself serves as your documentation, whereas with interactive sessions you'll either need some kind of notebook, or copy-paste to your markdown (jupyter notebooks or markdown in atom for our class).

Any HPC cluster clearly is going to need some program to effectively manage the hundreds of users submitting hundreds of jobs. CHPC uses the slurm scheduler and the command to submit jobs to this scheduler is `sbatch`. We will return to this as we built up job scripts.
- `sbatch`: Submit a batch job to the slurm job scheduler. Requires SBATCH directives to specify account, partition, etc.
- `srun`: Use to get an interactive session. (actually manages parallel jobs, but used for interactive as well)

### Modules and software
If everyone on CHPC had all installed software available to them all the time you can imagine things might become a bit slow, and there would inevitably be numerous conflicts. CHPC uses a module system to load and unload programs, software, paths, etc. as you need them. Hence the general term modules. This keeps a much cleaner environment. List your currently loaded modules:
```bash
$ module list
```
You'll at least see the "CHPC" module listed that helps setup your environment. There are many programs already installed including many of the bioinformatics packages you may need. List what is available (scroll with spacebar as you did for `less`):
```bash
$ module avail
```
- (D) denotes default versions
- Use `module spider <QUERY>` to search available modules

Let's load the SRA toolkit that facilitates the pulling of sequences from NCBI's sequence read archives. Notice you can use tab autocomplete here, and this can be helpful to see which versions are available.
```bash
$ module load sra-toolkit
```
Note that you can also use an alias already provided to you, `ml`, for module loading. Now, ensure it was loaded properly and check the version:
```bash
$ module list
```
For now, unload sra-toolkit:
```bash
$ module unload sra-toolkit
```
You can also use `module purge` to unload all your modules, except those that are "sticky" such as CHPC's module.

#### The `$PATH` environmental variable
One of the main things that happened when you loaded the modules is that the path to the executables was put into your environmental variable called `$PATH`. By doing this you can run a program by just typing it's name instead of the full path to it. The `$PATH` locations are also searched in when you do tab-autocomplete (if setup; it should be for you on CHPC). You can add to your own path and often when following some install instructions you will hear the phrase "make sure SOME_PROGRAM is in your path", so you should be aware of how to do this. First, let's see what your path currently looks like:
```bash
$ echo $PATH
```
The `$PATH` variable holds a list of variables, separated by colons. You have several paths listed there. Now see how module loading adds to your path. Repeat the loading of SRA toolkit:
```bash
$ module load sra-toolkit
$ echo $PATH
```
You should see the path where sra-toolkit resides now at the beginning of your path (/uufs/chpc.utah.edu/sys/installdir/sra-toolkit/2.10.0/bin).

## Adding to your $PATH
Previously, we added the executable `seqkit` to our `bin` folder in our homespace. It would be great to have this show up in our autocomplete as well as just be able to type the seqkit command without specifying where it is. Additionally, as other components of a software package (or other software) may depend on each other, they also may need to just call the program and won't know where it is. Let's add seqkit to our path. We can do this for a session only, and the commands are the same, but it usually is going to make more sense to always have this in your path.

Add the bin directory you created to your path. You could just use $HOME in the filepath, but it's safer to use your full home file path so get this first and copy it (note that in the ondemand shell interface if you highlight a line it copies it automatically).
```bash
$ cd ~/
$ pwd -P
```
Copy the full path to your home. Open ~/.bash_profile with nano, but first make a backup copy of it just in case.
```bash
$ cp ~/.bash_profile ~/.bash_profile_backup
$ nano ~/.bash_profile
```
Arrow down to the end and add this line at the end (you may have a section that says "# User specific environment and startup programs"). Paste in your absolute path to your home directory where it is noted below without the `<` and `>`:

```bash
export PATH=$PATH:<PASTE_HOME_PATH_HERE>/bin/
```
Save and exit nano with `Ctrl + X` as we did before when adding aliases. This file works similarly and is sourced on initialization of a bash shell.
Now, to complete it and see if it worked, source the `.bash_profile` file, and use the `which` command to see if your session is aware of the installed program now. It should return the path to it.
```bash
$ source ~/.bash_profile
$ which seqkit
```

## A reminder on mounting CHPC space on your computer
If you are on campus or on a campus VPN, you can mount CHPC homespace directly on your computer. The way I wrote this would have worked much better if we were all on campus because it's easier to save your markdown from the Atom GUI on your computer directly to your CHPC project directory. Still helpful to practice this habit, you just need to upload/download your markdown file to/from your local project directory. Outside of class time, I encourage you to get your CHPC home space mounted as well described on CHPC page: [Direct mounts on CHPC](https://www.chpc.utah.edu/documentation/data_services.php#Direct_mounts).

## Documentation, Project Directories and Atom
I certainly don't intend to lecture other scientists on the importance of documentation here at all. Rather, I want to try to highlight the importance, ease and differences of documentaton while coding. The methods I describe here are one way of doing it, and you will likely find your own eventually. The cool thing about documentation for bioinformatics is that the method you are performing is being typed anyways, so you are sort of creating your lab notebook at the same time you perform the task. How nice would that be at the lab bench! It doesn't leave much excuse for poor documentation. Though bad organization and references can destroy even the best documentation. You may be able to guess that it's really easy to create A LOT of files fast in bioinformatics. You've probably had a lab project that ballooned and had so many files in it's project directory it became difficult to find a specific file. This problem will be magnified several fold in bioinformatics. So:
- **Make extensive use of directories for organization**
- Start with a "project-centric" organization.

Many of you may already have (or attempt) organization by projects in your computer files. This is a great way to organize and is how you will see software projects always organized. In reality, science is quite different than software engineering and projects more frequently split or merge in unexpected ways, but this should still be your goal and you'll see that a lot of the software we will use expect this type of organization to some degree. Also, if you start out this way, you can copy or move directories to maintain a project centric structure when these splits and merges do happen. Let's introduce Atom as our text editor which also shows how project directory mentality can make it easier to use Atom.

There's 2 easy ways to document your code that we will go over.
1. Comments in your submitted job scripts. This is easiest because you're typing the commands already and the script is your documentation. Needs comments to make it useful as a "notebook" others can make sense of.
2. Markdown. This looks nicer and easier to browse if used properly. We'll use it in R and show it for Linux commands when we are working interactively for analysis.

### Atom
Really any plain text editor can be used to facilitate your documentation. I have recently come to like Atom for it's easy add-in/package manager and pleasing format. I really just want make sure we are all using the same editor for simplicity though. Atom has many possible add-in/extension/packages provided by the community which makes it super useful. We'll add a couple packages shortly.
- Open Atom and open a folder on your computer (`File -> Open Folder...`). Let's say just your Documents folder at first. This shows again the Project directory centric mentality as the sidebar lists all the files in this folder, and even labels this sidebar "Project"! You can easily open other files in your project directory with a click. They should open in new tabs in Atom by default. Nice, but this is just to illustrate Atom's behavior.

We will return to atom frequently, and use it to build our scripts and to document our code. Keep it open.

### Putting it all together. How to build a simple pipeline
Now that we understand differences between interactive and batch/non-interactive jobs and have learned more about CHPC, you may start to see how you might put together a pipeline that could be run through batch submission. A common process goes like this:
1. Work with a small subset of data in an interactive session to test out commands.
2. As you get each command working, copy the working commands to a new file in the order they will run. This will be your batch script.
3. Add the required SBATCH directives and submit the job to the slurm scheduler on CHPC.

Let's follow this process, and start with a file to copy the commands to.

#### A batch script using bash
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

You may ask why we use Atom locally and not the built-in text editor nano. Well, this is actually a good idea. I'm just having you use Atom because it's easier to keep a different window open in another program and may be an easier setup to document while working on command line too.

## Our First Bioinformatics Project
Now that we've finally learned a whole bunch of linux commands and created a nice bash shell environment, we will workthrough a dataset to get practice and reinforce some of these commands, as well as learn a really useful sotware package for microbiologists (and others really). We will work for the rest of this part on a 16S sequence dataset within QIIME2. In order to maximize our time, I'm going to jump in and out of the data at first while I explain a couple other concepts as well, so the organization may appear a bit funny / non-linear.

### Step 1: Setup a Project Directory
- Create your project directory
```bash
$ mkdir -p ~/BioinfWorkshop2020/Part2_Qiime_16S
```
- Make a `jobs` directory within that where we will eventually put our job submission script. I like having this separate because I'll save the outputs there as well, which can sometimes build up if a lot of troubleshooting is required.
```bash
$ mkdir -p ~/BioinfWorkshop2020/Part2_Qiime_16S/jobs
```
- Make a `metadata` directory as well
```bash
$ mkdir -p ~/BioinfWorkshop2020/Part2_Qiime_16S/metadata
```

## Installing QIIME2 in a conda environment
Here is another part where we are doing this to address the workshop objectives. QIIME2 already has a CHPC module, but in order to address common ways of installing bioinformatics packages we will work through an install with the most recent version of QIIME2.

QIIME2 is a particularly good example of a software package that can benefit from a managed virtual environment because (at least right now) it is updated or added to frequently (so far, every couple months) and it has many 3rd party plugins which require install privileges. Also, these plugins might interfere with each other, so you may at times need to create different environments for them. Conda is a package manager that sets up a virtual environment within your main environment (CHPC in this case). This allows you to install anything you want inside the virtual environment and keeps it safely isolated from your main environment. This is really cool and empowering! But, it can be a bit confusing at first for sure. Anaconda and Miniconda are the main programs that you'll see to run Conda. We will use miniconda, and follow exactly [the instructions CHPC has provided](https://www.chpc.utah.edu/documentation/software/python-anaconda.php) to first setup a miniconda3 environment into which we will then install QIIME2.

1. Create a new directory for your miniconda3 install:
```bash
$ mkdir -p ~/software/pkg/miniconda3
```
2. Download and install miniconda3 using their shell script, then remove the install script when it's finished
```bash
$ wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
$ bash ./Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/software/pkg/miniconda3
$ rm Miniconda3-latest-Linux-x86_64.sh
```
3. Create a user environmental module:
```bash
$ mkdir -p ~/MyModules/miniconda3
$ cp /uufs/chpc.utah.edu/sys/installdir/python/modules/miniconda3/latest.lua ~/MyModules/miniconda3
```
4. Load your user module.
```bash
$ module use ~/MyModules
$ module load miniconda3/latest
```
5. Install QIIME2. Instructions for installing in a conda environment are provided on [QIIME's install page](https://docs.qiime2.org/2020.2/install/)
  A)  Make sure conda is updated. Note: may need to activate conda first.
  ```bash
  $ conda update conda
  $ conda install wget
  ```
  B) Install QIIME2 with the provided scripts into a virtual environment called "qiime2-2020.2":
  ```bash
  $ wget https://data.qiime2.org/distro/core/qiime2-2020.2-py36-linux-conda.yml
  $ conda env create -n qiime2-2020.2 --file qiime2-2020.2-py36-linux-conda.yml
  ```
This is going to take a bit. QIIME2 has a huge amount of dependencies. These should now be scrolling by. If you wanted to truly "manually" install QIIME2 you would have to install all of these! Let's move on while this is installing.

### While we wait for Qiime2 installing:
#### Why QIIME2?
If you intend to do any 16S sequencing analysis the answer is obvious, but otherwise might be unclear. Truthfully, mainly I think it is a pretty easy to use program on the Linux CLI so I think it's a good opportunity to practice our skills and build a batch script for, and learn some other things about methods in bioinformatics (like the conda environment we are setting up for it).

QIIME stands for "Quantitative Insights Into Microbial Ecology" so you can guess it's main intent. However, if we take a step back and consider what it's doing, you may notice that it actually could be quite useful for many non-microbial ecology questions as well. Broadly, I break QIIME (and other microbial ecology packages) into 2 groups of functions:
1. Processing of marker genes sequences.
2. Analysis of feature tables.

While QIIME is built around analysis of 16S rRNA gene sequences any single gene sequence could benefit from some of it's tools, in particular those resulting from PCR amplification/detection methods. This could include ITS, 18S or other functional marker genes. It could even extend to things like TCR and BCR sequences, though likely with advent of single cell seq technologies this won't be the case. It also has methods to facilitate phylogenetic tree construction and classification. Most have absolutely nothing to do with microbial ecology specifically, and you'll see that a huge chunk of QIIME2 actually calls functions that wrap around other programs not made for microbial ecological analyses.

Next, a feature table is just a general term for features counts (microbial taxa, genes, traits) by samples. In fact, until recently, we called these OTU tables which was specific to microbial ecology, but it was not lost on many that most of the functions and metrics don't really care what the features are. Many (most?) microbial ecology metrics actually are not ecology specific at all, and often were never developed with this in mind, or even with biology in mind (a lot are from economics originally!). Thus, any feature table can benefit from some of the analyses in QIIME2. Whether microbial ecology dataset or not, the user needs to know if the metric/index is appropriate.

We'll talk about some of the other neat features in QIIME2 as we use them as well. For now, let's return to the install if it's done, or find some sequences on SRA if it is not still.

#### Find / show project on SRA
I go through this because I'm often asked how to pull SRA datasets. It's incredibly easy now, but the sra-toolkit has some historical terminology that makes it seem more confusing than it is. I'm not trying to spend time showing you how to browse some website's interface, as this type of thing is always changing, but still will walk through this to show *one way* of pulling an SRA-hosted dataset and make sure we are all on the same page.

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

Now we can use these with SRA toolkit and qiime to pull the sequences from the SRA and analyze them in qiime with the associated metadata. First, let's finish our QIIME2 install.

## Installing QIIME2 in a conda environment (finishing up the install)
  5. (continued) Install QIIME2. Instructions for installing in a conda environment are provided on [QIIME's install page](https://docs.qiime2.org/2020.2/install/)
    C)  After the install is done, activate your new virtual environment with QIIME2 and test that the installation worked.
    ```bash
    $ source activate qiime2-2020.2\
    $ qiime --version
    ```

# Practice / With Your Own Data
- `grep` can take a file with a list of patterns to search for as well, using the `-f` option. Can you modify the final grep command in the grep section to just get the sequence identifiers in a new file, then use this file to extract the 4 lines for each sequence from the original read 1 file?
- Play around with for loops. Use for loops with pattern matching (eg. `*.fastq`) to list read1 and read2 automatically and perform a function on them.
- If you have 16S seqs of your own you'd like to analyze, follow along, starting with setting up a project directory like we've done today in your own Projects folder.
- Find a cool project on SRA with 16S sequences, or find the accessions numbers from a paper with a dataset of interest. Get the accessions numbers from a couple samples to test out with at first. Follow along in the following days as well.

# Links, Cheatsheets and Today's Commands
- Intro to CHPC lecture by CHPC: [https://www.chpc.utah.edu/presentations/Overview.php](https://www.chpc.utah.edu/presentations/Overview.php)
- CHPC lecture series on Linux and shell scripting: [https://www.chpc.utah.edu/presentations/IntroLinux3parts.php](https://www.chpc.utah.edu/presentations/IntroLinux3parts.php)
- CHPC page on **accounts and partition** options: [https://www.chpc.utah.edu/documentation/guides/index.php#parts](https://www.chpc.utah.edu/documentation/guides/index.php#parts)
- CHPC page on setting up a conda environment: [https://www.chpc.utah.edu/documentation/software/python-anaconda.php](https://www.chpc.utah.edu/documentation/software/python-anaconda.php)
- Conda cheatsheet: [https://docs.conda.io/projects/conda/en/latest/_downloads/843d9e0198f2a193a3484886fa28163c/conda-cheatsheet.pdf](https://docs.conda.io/projects/conda/en/latest/_downloads/843d9e0198f2a193a3484886fa28163c/conda-cheatsheet.pdf)
- Today's New Commands:
  - `grep`: **g**lobal **r**gular **e**xpression **p** rint. Format: `grep "<REGEX_PATTERN>" <FILE_INPUT>`
  - `wget`: Pull something from the web. Use the `-o` option to provide a different filename when downloading.
  - `module`: Use with `load`, `unload`, `purge`, `list` and `spider` to manage loaded software.
  - `which`: Show the path of a command/installled program.
  - `ln`: Make links to files/directories. Generally, use with `-s` option.
