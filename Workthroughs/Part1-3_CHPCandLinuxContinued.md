<!-- TOC -->

- [Main](#main)
	- [Obtain interactive shell session on lonepeak cluster](#obtain-interactive-shell-session-on-lonepeak-cluster)
		- [Today's Objectives:](#todays-objectives)
		- [Requirements and Expected Inputs](#requirements-and-expected-inputs)
	- [Review](#review)
		- [Generalized Command Structure](#generalized-command-structure)
		- [Variables](#variables)
	- [More on CHPC](#more-on-chpc)
		- [Accounts, allocations and partitions](#accounts-allocations-and-partitions)
			- [Accounts:](#accounts)
			- [Allocations:](#allocations)
			- [Partitions:](#partitions)
		- [Disk space and scratch directories](#disk-space-and-scratch-directories)
			- [Softlinks to scratch space.](#softlinks-to-scratch-space)
		- [Interactive Versus Submitted/Batch Jobs and The Slurm Scheduler](#interactive-versus-submittedbatch-jobs-and-the-slurm-scheduler)
		- [More training on CHPC](#more-training-on-chpc)
	- [Software Installation Methods and Virtual Environments](#software-installation-methods-and-virtual-environments)
		- [Modules and software](#modules-and-software)
			- [The `$PATH` environmental variable](#the-path-environmental-variable)
		- [Install a binary file and put it in your path](#install-a-binary-file-and-put-it-in-your-path)
			- [Adding a location to your path permanently](#adding-a-location-to-your-path-permanently)
		- [Conda Virtual Environments - QIIME2 install](#conda-virtual-environments---qiime2-install)
			- [Installing miniconda into your own module on CHPC](#installing-miniconda-into-your-own-module-on-chpc)
			- [Create a QIIME2 environment and install the software](#create-a-qiime2-environment-and-install-the-software)
		- [Containers](#containers)
- [Practice / With Your Own Data](#practice--with-your-own-data)
- [Links, Cheatsheets and Today's Commands](#links-cheatsheets-and-todays-commands)

<!-- /TOC -->
# Main

## Obtain interactive shell session on lonepeak cluster
1. Log in to CHPC via your preferred method (OnDemand, ssh from Terminal, or FastX Web server).
2. Obtain an interactive session with 2 processors.
```bash
 salloc -A notchpeak-shared -p notchpeak-shared -n 2 --time 2:30:00
# OR
 salloc -A mib2020 -p lonepeak-shared -n 2 --time 2:30:00
```

### Today's Objectives:
#### I. Understand CHPC structure, software installation and run options.
  - Install a binary (`seqkit`) and a python virtual environment (`QIIME2`).
  - Discuss and setup an installed CHPC module (`fasterqdump`).

#### II. Introduce regular expressions, grep and for loops. (if time)
	- More advanced and useful Linux commands.

### Requirements and Expected Inputs
- Internet connection
- CHPC interactive bash shell session.
- Previous day's `table.txt` and `read1.fastq`

## Review

### Generalized Command Structure
This command structure we have seen is really common. Let's briefly review the structure. It's also worth noting that the order can matter for inputs and outputs sometimes when not specified explicity with options.

```bash
COMMAND [OPTIONS/PARAMETERS] INPUT OUTPUT
```

Frequently a command will have other functions associated with it and these usually go right after the main command:

```bash
COMMAND [OPTIONS/PARAMETERS] FUNCTION [OPTIONS/PARAMETERS] INPUT OUTPUT
```

It's nice when everything including inputs/outputs must be specified with a flag and *usually* when this is the case the order doesn't matter. Like this, for example:

```bash
COMMAND [OPTIONS/PARAMETERS] FUNCTION -i INPUT -o OUTPUT -p PARAMETER1 -t PARAMETER2
```

### Variables
- Variables can be anything: strings/texts, numbers, statements
- In bash, we set variables simply by declaring them and setting them with an equal sign.
- If spaces are included (as in statements) we must use quotes.
- When later referring to a variable we use a `$` to indicate it as such.
```bash
VARIABLE="VARIABLES can refer to other ${VARIABLES}"
```
- We should try to enclose variables in curly brackets when referring to them to avoid unexpected behaviour (and make more use of them later!)


## More on CHPC
Previously, I just introduced the overall structure of CHPC as a distributed computing cluster. Now, we will go further into details of CHPC with an emphasis on practical use for all users. I encourage you to review CHPC's excellent documentation for more details, particularly after the course is through. See the links in the last section and throughout here. For brand new users that are used to working on a single computer, the different terms and structure can be a bit confusing, but after running through an initial workthough on CHPC (as in this workshop), it should help to solidify how high-performance computing (HPC) clusters such as CHPC are managed.

### Accounts, allocations and partitions

#### Accounts:

Each user must have a user account, clearly. These user accounts give you access to CHPC and 50GB of home space, which **is NOT backed up**.

- User accounts are also associated with a group account, and generally when we say "account" on CHPC we will be referring to this group account rather than your user account.
    - For this class we have a special, but temporary, account called "mib2020" that allowed us to ensure you could all work on CHPC even if your PI had not signed up for an account yet.
    - When submitting jobs or obtaining an interactive session you must provide a group account as well. You can be (and probably are) associated with multiple accounts. These accounts are used to determine which *allocation* and/or mode to use when submitting jobs. Will return to this in a moment. Allocations and accounts go hand-in-hand.

- CHPC has a command to show you your account and allocation combinations. Input this command to print your CHPC account-allocation-partition combos:


```bash
myallocation
```
PIs, it is a good idea after this course to ensure your group has an account so that your lab is associated properly with you. Also, and perhaps most importantly, you can get a general computing allocation for your group (more about this in allocation section). You can also assign a delegate to manage your space, purchase extra storage, backup space, or even your own node! I highly recommend this if you are at all serious about bioinformatics. For not much more money than a decent Mac desktop you can get a very powerful node always available to your ENTIRE group, so you never have to wait in the queue. CHPC operates in what they call "condominium" style, where an owner node is available to the general CHPC community when you aren't using it, but your group preempts other if you own it.

All others make sure to get associated with your PI after the course if you are not already. Will send email regarding this later.

#### Allocations:

Each group can be allocated a number of compute hours each semester. Allocations can be broken down into 2 main types: general or owner.
- Owner allocation: When you own a compute node of your own.
- General allocation: Requested yearly by PI or their delegate.
    - Small allocations of 20,000 compute hours per semester now available. Short form application.
      - "Quick Allocation" availabe for first time CHPC PIs.
    - Regular allocations (>20,000 hours) requested by somewhat larger application.

- Running jobs without an allocation

If your group does not have a general allocation, you can still run jobs on CHPC in *unallocated* OR *pre-emptable* (freecycle) mode. An allocation ensures your jobs will run until finished, while in pre-emptable mode your jobs will run on available owner nodes but will be killed if needed to make resources available for owners. With careful requesting of resources you can actually run pretty effectively with no allocation. However, it's very easy to request a general allocation, CHPC has streamlined the process for small allocations, and the 20,000 hours per semester could be quite sufficient for your needs. Additionally, you can currently run jobs *unallocated* on some nodes, such as lonepeak currently.

- In summary:
    - Allocated: Not pre-emptable. Your PI (or delegate) completed application and has an allocation each semester. (this workshop also has an allocation for the duration). Notchpeak (only allocated), lonepeak, kingspeak.
    - Unallocated: Not pre-emtpable. Currently (2021) on lonepeak and kinsgpeak. Your group does not have an allocation.
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

Notably, there is a separate, "protected" environment and cluster for sensitive data, such as PHI. See CHPC's page on PHI: [https://www.chpc.utah.edu/documentation/pefaq.php](https://www.chpc.utah.edu/documentation/pefaq.php).

If you own a node, you have your own partition as well. For example my lab group's is `round-np` and we have a `round-np-shared` partition also.

The distribution of resources and types of partitions is always changing as CHPC manages their system. For example, the "ember" cluster was recently retired and kingspeak became available to run on without an allocation, as notchpeak grows with the newer hardware.

### Disk space and scratch directories

You are provided 50GB of home space with your account. This is not very much in the world of high-throughput sequencing. Note PIs can buy fairly cheap additional space, but I'd argue it's generally not a good idea to consider CHPC somewhere for any type of long-term storage. Most of you will have an IT department (Path-IT) that is better suited for storing and managing backups and/or syncing of your data. You should use them for data management. It is definitely possible to backup or sync your CHPC space, but the emphasis is more on facilitating computing.

File space usage on a high-performance computing cluster is a bit different than you may be used to. You need to have a mentality that it is easier and cheaper to recompute than to store many large files. This explains why you have a fairly small home space. But you will need to temporarily store very large files (usually sequences) in order to work on them and manage intermediary results. Enter "scratch" space. This is a general term not specific to CHPC that you may have encountered before. It is large disk storage space that is intended for temporary files only.
- Scratch: space for temporary file storage. On CHPC, files on scratch will be removed after 60 days (don't count on it!).

- Think about the CHPC structure and how the different spaces are connected to a compute node to build a distributed computing system. For example, tracing the lines highlighted in cyan in the below image if you are on a lonepeak node:

![CHPC structure conceptualization](https://drive.google.com/uc?export=view&id=1_YkuFcq9mIodtHlm7T9lJ3ZiI_vYOIZx)

- CHPC page on storage systems, including scratch: [https://www.chpc.utah.edu/resources/storage_services.php](https://www.chpc.utah.edu/resources/storage_services.php)

There are 2 main scratch files systems I will mention. These are always changing, but these appear to be the most stable currently:
- `/scratch/general/lustre`
- `/scratch/general/nfs1`

There are differences among these that do matter for speed, but we won't get into it. You're unlikely to care much about the read/write access speed differences for quite awhile in your bioinformatics. For now, setup a directory for yourself on lustre. Remember, when I show <VALUE>, this indicates you should enter your own value and NOT the `<` and `>`.
```bash
mkdir -p /scratch/general/lustre/<YOUR_UNID>/
```

#### Softlinks to scratch space.
It should be pretty easy to find this, given the short path, but you may forget which scratch system you are on. This is one situation it may be helpful to make a 'soft link' to your scratch space. Soft links are analogous to shortcuts you are familiar with on your desktop. Just a pointer to another directory/file. Make a softlink in your home space to your scratch space with `ln` command. List your home space contents to see how this link looks.
- `ln`: Makes link to file/directory. **Recommend always use with `-s` option for soft links.** Format: `ln -s <TARGET> <LINKNAME>`

```bash
cd ~/
ln -s /scratch/general/lustre/<YOUR_UNID>/ scratch_lustre
ls -l ~/
```

Making a bunch of softlinks around your data is generally not a good habit. It's often tempting for beginners especially, but the problem is that these links are relative filepaths and we want to generally use absolute paths for better documentation, and especially as a beginner it is good to understand the structure of your environment and not rely on links that give appearances of being elsewhere too much. I'm comfortable doing this for scratch space because it is, by definition, temporary file space so any references to it will not last anyways.

### Interactive Versus Submitted/Batch Jobs and The Slurm Scheduler

Currently, we are running an interactive session on a compute node (if you used `salloc` command). This is actually a managed job itself that provisioned resources, but gives you a shell to interactively type command and view the output. Interactive sessions are very helpful of course, particularly for development purposes. However, I think it's fair to say this is not really the intended method of interacting with a HPC cluster like CHPC. Generally, if you can do it in an interactive session, you can likely accomplish the computing needed on your desktop or laptop. Most computing that actually requires HPC resources is going to take awhile or just generally won't be amenable to interactive sessions. There are a number of situations where you really just need one big computer for a bit and interactive sessions might be a good fit. Somewhat surprising, anecdotally, it seems methods for interactive sessions are actually increasing, but still mostly we should have the mentality to do our computing with submitted jobs, aka "**batch**" jobs, when possible.
- Batch scripts: Submitted, or non-interactive job scripts.

There's also a big advantage to batch scripts over interactive. The job script itself serves as your documentation, whereas with interactive sessions you'll either need some kind of notebook, or copy-paste to your markdown (jupyter notebooks or markdown in atom for our class).

Any HPC cluster clearly is going to need some program to effectively manage the hundreds of users submitting hundreds of jobs. CHPC uses the slurm scheduler and the command to submit jobs to this scheduler is `sbatch`. We will return to this as we built up job scripts. Some of the important Slurm commands are:

- `sbatch`: Submit a batch job to the slurm job scheduler. Requires SBATCH directives to specify account, partition, etc.
- `salloc`: Use to get an interactive session.
- `srun`: This used to be used in place of `salloc` as well. Manages parallel jobs.
- `squeue`: View your currently submitted (and/or running) jobs. Check this out now adding your uNID to the -u option:
```bash
squeue -u <uNID>
```
  - If you have an interactive session already (as you should) you will see that this session is already listed with the time left on it and a "JOBID" listed first.
- `scancel`: along with the JOBID you can cancel or end a slurm scheduled job.

### More training on CHPC
- This is a very brief and coarse overview of CHPC and slurm scheduler still. It is well worth attending CHPC's seminars on these sessions. I just touched on a bit of material from 3, 2-hour sessions given by CHPC: "Overview of CHPC", "Introduction to Modules" and "Introduction to Slurm Batch Scripts". There is also a session on the protected environment when working with PHI.
  - [https://www.chpc.utah.edu/presentations/index.php](https://www.chpc.utah.edu/presentations/index.php)


## Software Installation Methods and Virtual Environments

Simple software installation can be a major hurdle in bioinformatics because of different environments and assumptions in many open source software packages that are not usually well supported or have installers. And, as we all have likely encountered, one doesn't always have install/admin permissions. Therefore, we spend time in this workshop working through a few different methods to use programs and software. Virtual environments alleviate a lot of the difficulty and have had an important impact on reproducibility and ease of use. The 4 methods we will cover are:

1. Use of software installed by CHPC - **modules**.
2. Use and installation of precompiled binaries or executables.
3. Conda Virtual environments
4. Containers (probably just discuss)

### Modules and software

If everyone on CHPC had all installed software available to them all the time you can imagine things might become quite slow, and there would inevitably be numerous conflicts. CHPC uses a module system to load and unload programs, software, paths, etc. as you need them. Hence the general term modules. This keeps a much cleaner environment. List your currently loaded modules:
```bash
module list
```
You'll at least see the "CHPC" module listed that helps setup your environment. There are many programs already installed including many of the bioinformatics packages you may need. List what is available (scroll with spacebar as you did for `less`):
```bash
module avail
```
- (D) denotes default versions
- Use `module spider <QUERY>` to search available modules

Let's load the SRA toolkit that facilitates the pulling of sequences from NCBI's sequence read archives. Notice you can use tab autocomplete here, and this can be helpful to see which versions are available.
```bash
module load sra-toolkit
```
Note that you can also use an alias already provided to you, `ml`, for module loading. Now, ensure it was loaded properly and check the version:
```bash
module list
```
For now, unload sra-toolkit (we'll come back to it):
```bash
module unload sra-toolkit
```
You can also use `module purge` to unload all your modules at once, except those that are "sticky" such as CHPC's module.

#### The `$PATH` environmental variable

One of the main things that happened when you loaded the modules is that the path to the executables was put into your environmental variable called `$PATH`. By doing this you can run a program by just typing it's name instead of the full path to it. The `$PATH` locations are also searched in when you do tab-autocomplete (if setup; it should be for you on CHPC). You can add to your own path and often when following some install instructions you will hear the phrase "make sure SOME_PROGRAM is in your path", so you should be aware of how to do this. This is one of those things that is so basic to coders/computer scientists it often goes completely unexplained and is unnecessarily mysterious to those coming from outside the field. First, let's see what your path currently looks like (this is one of those environmental variables):
```bash
echo $PATH
```

The `$PATH` variable holds a list of variables (in this case text strings that are directory locations), separated by colons. You have several paths listed there. Now see how module loading adds to your path. Repeat the loading of SRA toolkit, but this time let's also specify the newer (non-default) version:
```bash
module load sra-toolkit/2.10.9
echo $PATH
```
- You should see the path where sra-toolkit resides now at the beginning of your path (/uufs/chpc.utah.edu/sys/installdir/sra-toolkit/2.10.9/bin). This tells your shell to search that directory for executable files, making them available to run.
- You can see the different exectubable files if you list that directory that has now been loaded into your path:
```bash
ls /uufs/chpc.utah.edu/sys/installdir/sra-toolkit/2.10.9/bin
```
- We will be using the one called `fasterqdump`. To show that this command has been added to your path, while in your current directory, start typing `faste` and hit tab to get the `fasterqdump` command. It will autocomplete if it is now in your path.
- A useful command to see where a program is located, or sometimes to tell WHICH program is being run (you'll see that we can often have multiple installs), use the which command in front. If the command is not loaded in your path it will say so. Remember, use Ctrl+A to get to the beginning of a line.
```bash
which fasterqdump
```
- This shows the first way to load software/programs. Use a module already installed on CHPC. These tend to be the most stable, but are often not the version you want or maybe you just can't wait. It's worth noting that CHPC staff is usually quite quick to respond and happy to install modules that might be of use to others as well.
- Not as great sometimes for reproducibility. Make sure you note your versions of software, best to do when loading.
- Before we move on to the next method, let's finish setting up sra-tookit for us. If this is first time loading that module, it may need some config. If you, for example, ran that command to look at the help file `fasterqdump --help`, it would ask you to run this setup command first.
```bash
vdb-config --interactive
```
- This should bring up a blue screen with "SRA configuration" at the top and some tabs that can be accessed with the highlighted letter. We don't need to do much:
  1. Make sure there is an [X] next to Enable Remote access. Press `E` to check/uncheck the box.
  2. Go to the Cache page by pressing `C`. If not present already, add your scratch space `/scratch/general/lustre/<YOUR_uNID>` to the field for "location of user-repository" and make sure "enable local file-caching" is checked. This is where files will be initially downloaded so you want to make sure it's not in your home space that could get filled too quickly.
  3. Press `s` to save and then exit.

- This is a handy setup tool that this new version of SRA toolkit has included, but don't generally expect something like this from modules already installed.

### Install a binary file and put it in your path

- We can also install any executable file of our own, as long as it can be installed and function from our home directory. The simplest example of this is a precompiled binary. Binaries are system architecture dependent so this is often not an option, especially on Linux. But, you can also often compile them yourself (not discussed here) on your system and, more importantly, this gives me an opportunity to illustrate how to add an installed binary to your path.
- We will download and install (by adding to our path) the **seqkit** toolkit for basic sequence processing and manipulation in a high-throughput manner. Check out its main page here [https://github.com/shenwei356/seqkit](https://github.com/shenwei356/seqkit). You might click over to "Installation" and notice that the author list 3 of the 4 installation methods I am showing you now. If you click on "Download" in method 1 you can see the list of precomplied binaries. We are on a Linux system so we will get that link. You don't need to go there, I have it in the command alrady here.
- You will commonly see `curl` or `wget` to download items on the command line. Let's use `wget` to download the seqkit binary. But first, make a directory in your user home for binary files. Commonly, this is simply called `bin`.

1. Make a directory for your binaries and move into it:
```bash
mkdir -p ~/software/
cd ~/software
```

2. Use `wget` to pull the linux 64-bit binary:
```bash
wget https://github.com/shenwei356/seqkit/releases/download/v0.16.1/seqkit_linux_amd64.tar.gz
```
- `wget`: Pull something from the web. Use the `-o` option to provide a different filename when downloading. By default uses the same filename.
3. Unpack/decompress with tar and gzip
```bash
tar -zxvf seqkit_linux_amd64.tar.gz
```
- `tar`: Archives many files together in a single file. Use `-z` to pass through `gzip` as well.
- `gzip`: Compression/Decompression utility. Frequently used on an archive from `tar` for effective compression.

4. Clean up the download that we extracted the binary from:
```bash
rm seqkit_linux_amd64.tar.gz
```

Seqkit exists as a single binary file. Notice it should have `x` file permissions for you with the `ls -l` command. If it doesn't add them with `chmod`.

You can call your binary by just referring to it directly if you are in the directory it is in. Or, if outside of that directory, by giving the full path to it. We'll finish this install by adding it to your path next so you can refer to it no matter where you are. But it should run as is. Use the or `--help` option to get the help file. This is a very common convention for help files and is almost always available in a program.
```bash
seqkit --help
```
It has a number of functions listed. These are entered after the command, another common convention. Let's bring up the helpfile for the fastq to fasta conversion function:
```bash
seqkit fq2fa --help
```
Notice by default with the `-w` option it will output the fasta format with fixed line width. Yuck! But, nice to have this option I suppose as it usually is not built-in to these toolkits. Let's turn it off and convert our read1.fastq file to a fasta file (no quality sequences, different ID line identifier ((`>`) instead of `@`)). Makes sure to move back to our Part1 diretory first:
```bash
cd ~/BioinfWorkshop2021/Part1_Linux/
seqkit fq2fa -w 0 read1.fastq > read1.fasta
```
- Hopefully, that didn't work. Or, you may have noticed the fq2fa did not autocomplete in the first place and thought something was fishy. This didn't work even though you already installed it because the directory in which it resides is not currently in your path. Now, let's add it to your path.

#### Adding a location to your path permanently

- You could just use $HOME variable in the filepath and append '/software', but since we are still a bit new to variables let's explicitly list the absolute path of the directory it is in. Note that in the ondemand shell interface if you highlight a line it copies it automatically.
```bash
cd ~/software
pwd -P
```
- Copy that full path as it printed. Open ~/.bash_profile with nano, but first make a backup copy of it just in case.
```bash
cp ~/.bash_profile ~/.bash_profile_backup
nano ~/.bash_profile
```
- I'll open this file with the OnDemand file explorer in class to illustrate it's functionality and introduce a handy new tool. You'll need to check the "show dot files" checkbox if you do this in OnDemand.
- If you see a line like `PATH=$PATH:$HOME/bin`, then you can just add the absolute path of your `software` directory to the end of that line, after adding a colon to separate. In other words, just add (without `<` `>`) `:<PASTE_YOUR_SOFTWARE_DIRECTORY_PATH_HERE>`
  - If you already had a PATH statement in your .bash_profile file like this, you should also have a statement at the end that says `export PATH`.
  - The `export` command makes a variable available to child processes as well. When we normally set a variable it is only available to bash our current shell process.
- If you didn't have the path statement above already, you can add it and the export command in one line. Arrow down to the end and add this line (you may have a section that says "# User specific environment and startup programs"). Paste in your absolute path to your home directory where it is noted below WITHOUT the `<` and `>`:

```bash
export PATH=$PATH:<PASTE_PATH_HERE>
```
Save and exit nano with `Ctrl + X` as we did before when adding aliases. This file works similarly and is sourced on initialization of a bash shell.
Now, to complete it and see if it worked, source the `.bash_profile` file, and use the `which` command to see if your session is aware of the installed program now. It should return the path to it.
```bash
source ~/.bash_profile
which seqkit
```

- You should see that seqkit location path in your software directory, which is now in your path. You can leave it here or move seqkit to a `bin` (would need to be created) directory in your home space if you already had `$HOME/bin` in your .bash_profile file. Having this value in that file by default is a new thing that actually broke my initial example because it was already there (it's a very common place to put binaries) so I made a software directory for it instead. We will actually use this directory later so it's fine to keep it.

To finish up, just move to your directory with the sequence files and see if the command runs now:

```bash
cd ~/BioinfWorkshop2021/Part1_Linux/
seqkit fq2fa -w 0 read1.fastq > read1.fasta
less read1.fasta
```

### Conda Virtual Environments - QIIME2 install

Here is another part where we are doing this specifically to address the workshop objectives. Not necessarily because it is the easiest or quickest solution, but there are several advantages as well. QIIME2 already has a CHPC module, but in order to address common ways of installing bioinformatics packages we will work through an install with the most recent version of QIIME2.

- Conda virtual environments basically allow you to create a similar environment on top of your system environment. Thus allowing you to install whatever you want without having root privileges. In the image below we cannot write to system directories (outlined in red) but we can to our home space (green). Notice how the paths exposed (in cyan) now include both system installs and home installation locations within a conda environment:

![Conda Env Conceptualization](https://drive.google.com/uc?export=view&id=1650jCppxPcZSnLbKtqZgry6gcfqGK4m-)

- Also very useful for installing multiple versions of the same program (not uncommon when working with open source software).

QIIME2 is a particularly good example of a software package that can benefit from a managed virtual environment because (at least right now) it is updated or added to frequently (so far, every couple months) and it has many 3rd party plugins which require install privileges. Also, these plugins might interfere with each other, so you may at times need to create different environments for them. Conda is a package manager that sets up a virtual environment within your main environment (CHPC in this case). This allows you to install anything you want inside the virtual environment and keeps it safely isolated from your main environment. This is really cool and empowering! But, it can be a bit confusing at first for sure. Anaconda and Miniconda are the main programs that you'll see to run Conda. We will use miniconda, and follow exactly [the instructions CHPC has provided](https://www.chpc.utah.edu/documentation/software/python-anaconda.php) to first setup a miniconda3 environment into which we will then install QIIME2.

#### Installing miniconda into your own module on CHPC

1. Create a new directory for your miniconda3 install:
```bash
mkdir -p ~/software/pkg/miniconda3
```
2. Download and install miniconda3 using their shell script, then remove the install script when it's finished
```bash
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash ./Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/software/pkg/miniconda3 -s
rm Miniconda3-latest-Linux-x86_64.sh
```
3. Create a user environmental module:
```bash
mkdir -p ~/MyModules/miniconda3
cp /uufs/chpc.utah.edu/sys/installdir/python/modules/miniconda3/latest.lua ~/MyModules/miniconda3
```
4. Load your user module.
```bash
module use ~/MyModules
module load miniconda3/latest
```

Now, we've just installed a module of our own called miniconda3/latest. miniconda3 is just the software that manages the different virtual environments we create. Installing it indepenetn of the normal modules system is ununusal but has important reasons for CHPC's setup that we won't get into. We still need to install QIIME2 in an actual virtual environment.

#### Create a QIIME2 environment and install the software

- See QIIME2's page for further install details including the below command. From our starting point, just make sure you have loaded your miniconda3 module.
- We will create an environment called qiime2-2021.4 (with the `-n` option in the command below), but note that we could call this environment whatever we want to.
  - It can be beneficial to create multiple, minimal virtual environments specific for a program instead of a few big environments. Useful for documentation and reproducibility purposes.

```bash
wget https://data.qiime2.org/distro/core/qiime2-2021.4-py38-linux-conda.yml
conda env create -n qiime2-2021.4 --file qiime2-2021.4-py38-linux-conda.yml
```

- This will take quite awhile. It's particularly useful to illustrate why these types of environments are so so much easier than installing them all yourself. All those packages you would have to install individually if you wanted QIIME2 fully. Many programs depend on others and these build up in complexity as we go. These dependencies can make installs (and reproducibility) difficult, but is also what makes powerful software.
-  Virtual environments also avoid needing root privileges.

While we wait we will discuss containers briefly and very useful `grep` and regular expressions.

- After this is done installing, list your conda environments, then activate it for your first time:
```bash
conda env list
conda activate qiime2-2021.4
```

### Containers

- Containers are a newer solution also available to use on CHPC to deploy different software packages. They are similar in principle and use to Conda Virtual Environments, but actually very different and have some advantages in how they access resources, as well as how they are defined which makes for the best reproducibility. Using virtualization containers one can fairly easily define and share your computing environment, ensuring the code you run is executed with the same software versions, libraries and environment.
- We will hopefully return to them after our R session, dependent on time. Since it's another virtual environment method I keep it optional for this workshop at this stage.
- There is also a CHPC presentation specifically on them each semester.[https://chpc.utah.edu/presentations/Containers.php](https://chpc.utah.edu/presentations/Containers.php)

# Practice / With Your Own Data

- First, if you didn't finish in class, make sure you get the QIIME2 conda virtual env installed.
- If you have 16S seqs of your own you'd like to analyze, follow along, starting with setting up a project directory like we've done today in your own Projects folder.
- Find a cool project on SRA with 16S sequences or bulk RNAseq (both ideally), or find the accessions numbers from a paper with a dataset of interest. Get the accessions numbers from a couple samples to test out with at first. Follow along in the following days as well.

# Links, Cheatsheets and Today's Commands
- Intro to CHPC lecture by CHPC: [https://www.chpc.utah.edu/presentations/Overview.php](https://www.chpc.utah.edu/presentations/Overview.php)
- CHPC lecture series on Linux and shell scripting: [https://www.chpc.utah.edu/presentations/IntroLinux3parts.php](https://www.chpc.utah.edu/presentations/IntroLinux3parts.php)
- CHPC page on **accounts and partition** options: [https://www.chpc.utah.edu/documentation/guides/index.php#parts](https://www.chpc.utah.edu/documentation/guides/index.php#parts)
- CHPC page on setting up a conda environment: [https://www.chpc.utah.edu/documentation/software/python-anaconda.php](https://www.chpc.utah.edu/documentation/software/python-anaconda.php)
- Conda cheatsheet: [https://docs.conda.io/projects/conda/en/latest/_downloads/843d9e0198f2a193a3484886fa28163c/conda-cheatsheet.pdf](https://docs.conda.io/projects/conda/en/latest/_downloads/843d9e0198f2a193a3484886fa28163c/conda-cheatsheet.pdf)
- Today's New Commands:
  - `wget`: Pull something from the web. Use the `-o` option to provide a different filename when downloading.
  - `module`: Use with `load`, `unload`, `purge`, `list` and `spider` to manage loaded software.
  - `which`: Show the path of a command/installled program.
  - `ln`: Make links to files/directories. Generally, use with `-s` option.
