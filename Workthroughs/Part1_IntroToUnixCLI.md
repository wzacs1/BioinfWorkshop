# Main
We will work through some basic Linux commands using the OnDemand CHPC interface.
### Requirements:
- An internet connection with a browser.
- A CHPC account.

## Conventions and Setup
Throughout these documents code that is meant to be entered will be set aside in a "code chunk" like this, with a command prompt `$` at the beginning:
```bash
$ cd $HOME
$ ls
```
You do not enter the `$`.  You will see this as your command-line prompt (usually with your user ID in front of it) and I just include it to make line separations clear and to differentiate between chunks I want you to enter and some that are meant to just show the output (chunks without command prompts).

Reminder: always try to type the code yourself! Don't copy-paste if possible, you won't learn much that way, but if you get behind during workshop time you may need to every once in a while in order to keep up.

Sometimes you will encounter similar looking short chunks in-line, or within the written text like `this`. This is not usually meant to be entered but is just to highlight a command or output.

When you are meant to enter your own values specific to you, I will enclose a word or phrase in less-than and greater-than symbols such as this: `<Your_User_ID_Here>`

Please try to make directories and filenames the same as listed here, so that we can all be on the same page. It's tempting to make your own naming, and fine if you insist, but it makes it slower to help troubleshoot if you haven't followed the same naming as the rest of the class. 

As most code is case-sensitive, it makes everything easier if you consider that everything from this point on in your life is now case-sensitive. 

## Unix and Linux
UNIX is a family of operating systems with a common lineage and many shared features.  Linux and Mac OSX are the Unix operating systems you have most likely encountered and have diverged longer ago than most.  Linux is open-source and comes in many "distributions" you may have heard of including CentOS, RedHat and Debian or Ubuntu. 
Complicated history and relationships but from a biologists point of view, most of what you learn on one Unix system can be directly applied to another, with the most frequent differences encountered between Mac OSX and Linux distributions. This interoperability is thanks in part to the original Unix philosophy of "do one thing, and do it well".  Instead of complicated functions, it is better to chain, or pipe, simple functions together.  The wonderful result of this is that the same basic commands work the same throughout the years, but get extended functionality rather than altered.
Linux commands are generally input through the command line interface (CLI).

## The Command Line Interface
The command line interface, or CLI, is where commands are typed, as opposed to a point-and-click interface you are used to in a graphical user interface, or GUI (often spoken as "gooey"). The command line commands are interpreted through a program called a **shell**, which itself is displayed in applications on your computer usually called something like **terminal**. Phew. The terminology gets a little fuzzy and is often inconsistently or broadly used such that terminal, shell, and CLI often are used interchangeably. This is due to some historical reasons and beyond the scope of this course, but is some interesting reading. For our purpose, know that you use a shell to interpret commands on the command line. 
On your local Mac, you can find the Application called "Terminal" which will open a new shell. 
Note that we will instead use a terminal-like web-based interface on CHPC throughout this course, but in the future if you want to work on your local computer you can generally use Terminal, and all or most of what you learn here will apply directly because Mac-Terminal's default shell (bash) is the same as we will use on Linux.

Why learn the CLI? Won't there be a GUI developed for that if it's really useful?
The short answer is yes, there probalby will be a GUI and it won't be as useful. We see this pattern repeat over and over. Much effort goes into GUI develop because it's requested, but the GUI will have limited options and is difficult to automate tasks with. CLIs persist and will certainly continue to because of their simplicity and power. You should see by the end of this course it actually doesn't take too much to get used to them. They just look really different at first, but our goal is to make you comfortable working at a CLI.


## Shells
The shell is the actual command-line interpreter within the terminal that you use. It interprets what you write. You should be aware that there are several shell languages including bash, zsh, tcsh and fish.  bash is the most commonly used and we will use it throughout the course. Technically, everything we are doing in the Linux/Unix parts of this workshop is actually scripting in `bash`. 

## Open your first shell
In your browser, navigate to CHPC OnDemand. 
[https://ondemand.chpc.utah.edu/](https://ondemand.chpc.utah.edu/)
Login with your usual UNID credentials.

This is a really nice, clean (and fairly new) interface that can be accessed anywhere without special program install and gives access to your CHPC files, a shell to access CHPC, as well as job submission and monitoring. It also simplifies teaching a lot because we all work on the same interface and thus I asked that you all sign up for a CHPC account before beginning (besides, you should anyways. CHPC is an awesome resource available to you all!).

Look around the OnDemand interface: 
1. Open your home space to view files. Top left "Files" drop down then "Home Directory". Should open a new window with a fairly self-explanatory interface for your files. Not much here yet if you are new CHPC user. We will return to this later. For now, just note the text string at the top when you are in your home directory. It will look similar to this `/uufs/chpc.utah.edu/common/home/<Your_UNID>`
2. Access the Lonepeak cluster in a new shell. At the top middle menu "Clusters", click on the ">_Lonepeak Shell Acess". A new window pops up and asks you for your password. Same password as your usual UNID credentials. 
3. Determine which directory you are in. Enter the "print working directory" command as shown below. This tells you where you are, and it should return a result identical to the text you saw for your home directory in step 1 because you always start off in your home directory. 
```bash
$ pwd 
```
Keep this window open.



## A brief CHPC overview
The University of Utah Center for High-Performance Computing (CHPC) is an outstanding resource where your high-throughput sequencing data is most likely being processed already, whether you know it or not. It actually consists of multiple computing **clusters** that each contain many **nodes** which themselves are each powerful computers. These nodes are all can connected to multiple file systems including your home directory. Thus, by separating the computing and files you can scale easily and also use whichever resources are currently available on any cluster you have access to, but it is a differnt concept than your single laptop or desktop. It *conceptually* looks a bit like this:


![enter image description here](https://drive.google.com/uc?export=view&id=15FtdIKUWeIyWCLZT39xx_R5mRI-q0DIC)


We will return to this later as we learn how to take better advantage of CHPC's power, but for now this overview suffices to understand that there are different computing clusters which can all access the filesystems, and that the head node (or login node) on each cluster is not to be used for major computing tasks.
### Mounting your CHPC home space on your computer
The OnDemand interface provides a way to download and upload files directly, so really is all you need. However, it can be handy to mount your CHPC space directly on your computer and have it show up as another folder, allowing easy drag and drop of files. You must be connnected to the University of Utah network for this to work. The procedure is different depending on your OS, so I will not go through it, but CHPC provides information on how to do this here, under the "Direct Mounts of CHPC file systems" section:
[https://www.chpc.utah.edu/documentation/data_services.php](https://www.chpc.utah.edu/documentation/data_services.php)


## Root and Directory Structure
"Root" refers to the absolute highest/base level of a file system and is referred to by the very first forward slash `/` at the beginning of the text string above that describes where your home is. You will not have access here on CHPC or even on your own computer normally. It obviously needs to be kept isolated. Everything else starts here though.
Note: "folder" == directory

On your Mac, the typical directory strucutre looks something like this (with many directories removed):
![Mac directory structure](https://drive.google.com/uc?export=view&id=1P0NQ5OXx4I50SuiTgVIBQCDXr7kWyCyg)

On CHPC, the directory structure is more complicated, and as you've seen your home directory is instead in `/uufs/chpc.utah.edu/common/home/<User_ID>`. However, it helps to understand that the directory structure is always a tree with root at the top level. 

Because home is so common to refer to, it gets it's own special symbol: `~`

## A Few Words on File(Directory) Naming Conventions
### Naming

Before we go further it is good to make a point about naming files and directories. Currently, you may often name your files with spaces according to natural language.  While this is still technically possible, you should completely end this behaviour at this point. Spaces are used to identify discrete commands, options, identifiers, etc. in all programming languages to some (or entirely) degree. Therefore, spaces become a major problem and a special character is required to be typed everytime to interpret them as you expect. Thus, you will almost never see spaces in the filenames of someone that has been coding for even a short period of time. Two major solutions exist (or more often than not, some combination of the two):
- "**Camel case**": Simply capitalize the first letter of everyword. For example: MyFileName.txt
- **Underscores** ( _ ): Instead of spaces, just use underscores. For example: My_File_Name.txt

You might ask why these 2 solutions and  not other symbols?  Well, almost every other symbol on your keyboard has some special meaning in some or most languages, which you will encounter later on . Underscores are nearly always not associated with a special meaning.  Note that the dash "-" is frequently used as well, and generally you can get away with it, but I recommned staying away from it's use as much as possible.  It is often interepreted as a range (eg.  from one to three is `1-3`), just as you might expect, and so can cause problems at times.

###  File extensions/suffixes
It is often misunderstood that the file extension (for example, ".txt" or ".docx") defines the content or format of a file. This is not the case and in fact the *file extension is simply part of the name*. Thus, really it is a misnomer to say this is a "file extension" or "suffix". The confusion arises because operating systems use the extension to inform which program should be used to open and/or interpret a file. This is quite handy, but as you may be aware you can change these associations in your OS as well.  There are 3 important points here though:
1. The content of the file does not change if the extension is changed. For example, if I exported a table as a tab-separated plain text file, I could change the extension to .tsv, .txt, .xls or anything I wanted and the content of the file does not change. 
2. The "extension", if present, must be included when referring to a file because, again, it is part of the filename.
3. Only the extension after the last `.` matters for most OS recognition. So, there is generally no problem having `.` throughout the filename and it can be helpful to do so. For example, `sequences.fasta.gz` is perfectly fine and refers to a gzip compressed file of fasta-formatted sequences which would unzip naturally on a Mac OS if double-clicked.

It is generally a good idea to include file extensions so you or others know what the format or content of the file is, but this only works if you follow conventions. A few examples of conventional extensions you will encounter :
- `.txt`: A general, plain text file
- `.tsv`: A tab-separated value file. Quite frequently, these are also just listed as .txt
- `.csv`: comma-separaed value file.
- `.md`: A markdown file
- `.py`: a Python script

## First Linux Commands: Moving around and Creating Your Environment
Now that we have a little background, let's create a more useful environment for you to explore and understand Linux commands more in the next section. For most of you, as new users your home likely appears empty right now. Let's start by ensuring we are in our home directory, then creating a directory that will contain all the work for this course. 

In your shell in your terminal window, you should still be in your home directory. If you moved around already, make sure to move back to home first.

- `mkdir`: "**m**a**k**e **dir**ectory"

Use `mkdir` to make a course directory.  Notice that I don't use spaces in the directory name
```bash
$ mkdir BioinfWorkshop2020
```
Now, in the terminal window you created earlier, use the `ls` command to list the directory contents of your home directory in 2 different ways, just to illustrate how the tilde `~` refers to your home directory:
```bash
$ ls /uufs/chpc.utah.edu/common/home/<Your_User_ID>/
$ ls ~/
```
You should now have at the least the new directory you created (BioinfWorkshop2020) listed.
Now, move into that directory using the change directory command:
- `cd`: **c**hange **d**irectory

```bash
$ cd BioinfWorkshop2020
```
Use `pwd` to show where you are and verify you have changed directories:
```bash
$ pwd
```
Make a directory for this part of the course within this directory:
```bash
$ mkdir Part1_Linux
```
Directory structures are key to efficient bioinformatic analysis (and speed!). It's quite common, and a good idea, to make many directory levels for a project.  We just made 2 levels, but it took us three commands to do so. (`mkdir`, `cd` to new directory `mkdir` again). It's not that bad, but it can become tedious, and worse we changed our location, which in non-interactive settings can end up with commands run in the wrong place. We will return to `mkdir` shortly to show how we can make it more useful. 

### Tab autocompletion, history and a couple keyboard shortcuts aside:
Before we move any further let's talk about your new best friend - the tab key. You can probably already see there is going to be a lot of typing.  There is also going to be a lot of room for small/hard-to-see errors in typing what you see on the screen. Such as, capital I or l. Tab autocompletion is here to help and is part of any Linux system. 2 ways to use this:
- Press Tab key once when start typing. If only one possible match exists it will autocomplete to this match
- Press Tab key twice after you start typing. Your shell will list the possible matches and maintain what you have already typed.

To try this out first `cd` to your new `Part1_Linux` directory by just starting to type it then hitting tab to autocomplete it and press enter to finish the command.
```bash
$ cd Par
```
Again, use `pwd` to make sure you are in the `Part1_Linux` directory.

Now, we are going to have you copy a few test files to illustrate some more Linux commands. These files reside ln CHPC in my group's space, which is a bit of a long text string from where you are, so employ the tab autocomplete to ensure you type it correctly. You can use tab-tab at any point when typing this, as well as many times as you like.
- `cp`: **c**o**p**y. Format: `cp <File_To_Be_Copied> <Where_to_copy_the_file>`

Notice where the 2 spaces are in this command. One after  `cp`, then one separating the file to be copied and where it should be copied to. As this command is long, I will use the backslash `\` to show it all and allow the command to be continued on a new line. You do not need to include it but you can as well.
```bash
$ cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part1_Linux/table.txt \
~/BioinfWorkshop2020/Part1_Linux/
```
The command above is the same as this command (you don't need to enter this, but it won't hurt):
```bash
$ cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part1_Linux/table.txt \
~/BioinfWorkshop2020/Part1_Linux/table.txt
```
In other words, if pointing to a directory, `cp` will simply copy the file to that directory with the same name. If pointing to a file name, `cp` can be used to copy and rename the file at the same time.

Now, also copy the 2 .fastq files I have in that directory as well. However, to illustrate another common Linux reference use the `./` to refer to the directory you are in. Previously, we used `~` to refer to your home and then listed the directories below that:
- `./`: "Here". Refers to the directory you are in.
```bash
$ cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part1_Linux/read1.fastq ./
```
#### Command Line History
The up and down arrows can be used to scroll through the histroy of your commands. Very helpful to prevent having to retype long commands.  In order to copy the read2.fastq file in the same directory as the read1.fastq file, use the up arrow to get your previous command and change the read1.fastq to read2.fastq. Like this:
```bash
$ cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part1_Linux/read2.fastq ./
```
#### A couple useful keyboard shortcuts
It can be useful to move to the end or the beginning of a very long command. 
- Ctrl+A: Moves cursor to the beginning of command line
- Ctrl+E: Moves cursor to the end command line.

Now that we have seen a bit about how files and directories are referred to, let's take a moment to lay it all out and expand on this to make sure it's clear. We will continue to encounter all these concepts, but for now let's just define them all explicitly.

### Directory references and paths

- "Path": Generally, a path is, as you might expect, the route or path one takes to a given file or directory. It can be absolute or relative.
- "Absolute Path": Refers to when the path to a file is listed beginning with root, and thus tends to contain the full text for each directory leading to the file or directory of interest. For example, instead of `~`, we would have `/uufs/chpc.utah.edu/common/home/<UNID>/` as the absolute path to your home directory. It is always safer to use absolute paths, but the lengths can become cumbersome, thus...
- "Relative Paths": The path to a file *relative* to the directory you are in or some other shortcut/link (such as `~`). 
- `./`: The current directory you are in
- `../`: The directory up one level from what you are in.
- `~`: Your home directory. 

Use `ls` with iterations of `../` to list the contents of directories further and further up in your directory structure:
```bash
$ ls ../
$ ls ../../
```
Etc. Try combining with `~` and names of directory to explore the behavior more.

### More on file listing with `ls`  and options to commands
This may be the most common command you will type, because the command line interface doesn't give you that constant folder view you have on your Desktop. So, we will spend a bit more time expanding on `ls`. For directories with lots of files you may actually find the CLI listing preferable to a windows view. As with all other Linux commands options can be added to it to make it more useful.

Options are given directly after the command, separated by a space, and proceeded by a dash `-`. **Notably**, this structure, is generally shared amongst many programming interfaces! It is a convention though, not usually a rule. Also, often an option has a short, single-letter version and/or a long full word version which is preceded by two dashes `--`. Most useful Linux command options will just use the short single letter format.

`ls` has a number of useful options to add to it:
- `-l`: This is the long listing format which gives file permissions and sizes, and lists one file per line.
- `-h`: Human-readable format for file sizes.
- `-t`: sort them by timestamp
- `-a`: Show all files (including those hidden: files that start with a `.`)

Try adding these options to your file listings. From the `Part1_Linux` directory (since it may be the only directory with files in it currently for you.
```bash
$ ls -l
$ ls -l -h
$ ls -lh
```
Notice how `ls -l -h` and `ls -lh` procuce the same output. Many Linux command options can be put together like this.  This only works for those that are "flags", which act like switches turning something on, as most Linux options do. 
```bash
$ ls -l -a ~/
```
This last command listed the file contents of your home directory, INCLUDING the hiddden files! You will notice there actually is some files in there you didn't put there. Some of these help define your environment and we will return to them later. Hidden files start with `.` and are not normally listed unless you specifiy the `-a` option.
### Manual pages for commands
Manual pages are built in and available for nearly all commands. They have a common format and list the availalbe options for a command up front. They are accessible by using the `man` command.
- `man`: Format `man <command>`

Open the manual page for the `ls` command to see all the options. 
```bash
$ man ls
```

Scroll through it with the `spacebar` to move a full page down or `d` and `u` keys to move 1/2 page down and up.  Use `q` to exit the manual page. Use `/` to bring up a text input and search within the manual page.
There's even a manual page for the `man` command. Not to be confused with the experimental band form the early 2000s, `man man` has a wealth of information.


### The `chmod` command for file permissions.
Finally, for this part, lets talk about what all those `-`'s and `r`'s mean when you do the long file listings. These are the type of listing, as well as the file permissions for three different user groups. There are 10 spaces. In order from left to right:
- Position 1: What type of listing is it. `-` for a regular file, `d` for directory, `l` for links
- Position 2,3,4: File permission for the user `u`
- Position 5,6,7: File permission for the group `g`
- Position 8,9,10: File permission for others `o` 

In the file permission sections, there are 3 positions which indicate read (`r`), write (`w`) or execute (`x`) permissions. If it's a directory, `x` indicates whether it is searchable or not. For files `x` is generally irrelevant, but needed for programs or executable files. To summarize with image example:

![File Permisssions](https://drive.google.com/uc?export=view&id=1Nyi8364J2jLBm-27Z3bHSppEOi-zGnbV)

The `chmod` command can be used to change file permissions of a file or directory. It has a somewhat unique format, where the options provided to it do not take a dash`-` before them, but instead are a sort of formula starting with the single letter indicating the user, group, other or all; then a `+` or `-` to indicate add or remove; then the permissions to change. Some examples
- `chmod u+w <FILENAME>`: Add the write permission (`w`) for the user.
- `chmod a+wrx <FILENAME>`:  Add the write(`w`), read (`r`) and execute (`x`) permissions for all `a`.
- `chmod g-w <FILENAME>`: Remove the write (`w`) permissions from the group (`g`).

Because you 'copied ' the previous read1, read2 and table.txt files, creating a new file with yourself as the owner, you should have read and write permissions for them already. However, often depending on how you get a file from someone else you may often encounter situations where you lack write permission, for example. You may also want to remove write permissions (even from yourself, you can always add back later) from important files to prevent accidentally deleting them.

# With Your Own Data
Little to do for the intro parts. But you can still setup some things and practice moving around
- Create a project directory.
- Upload metadata files or sequence files to your project directory.
- Change the file permissions. Try removing read permissions from a file and then try to copy it.
- How can you change permissions for a directory?
- Explore options on the manual page for `mkdir` and `pwd`.

# Notes & References
- CHPC overview lecture slides Spring 2020: [https://www.chpc.utah.edu/presentations/CHPCOverviewSpring2020.pdf](https://www.chpc.utah.edu/presentations/CHPCOverviewSpring2020.pdf)
- Key commands in this part:
	- `pwd`
	- `ls`
	- `mkdir`
	- `cd`
	- `cp`
	- `chmod`
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTcxMTUzNzIzNCwtMTcwOTc3NzQzLC0zND
E2MjA3NDQsMTUyMzI5MDYxLC0xNjkzNTg4Njk0LDcyMjAyNjYx
MCwxNjQzNDc3NzQ1LDExNjU2ODk0MjMsMTA1MjA3OTk5MSw4Nj
I0MTk1NzMsLTEyMTQ1MTIxNiw1MTA0MDk1MTksMjMxMTczMjc5
LDQzODAwNDI5OCwtOTM5ODY4NDQxLDExMTg1OTEyNTcsLTEzNT
A1ODMwNywyNzM5ODY0NTgsMTk1MTAzNTA1LDE0MjQ1NzE4NjZd
fQ==
-->
