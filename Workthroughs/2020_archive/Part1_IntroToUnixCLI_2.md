<!-- TOC -->

- [Main](#main)
  - [Requirements:](#requirements)
  - [Expected Inputs:](#expected-inputs)
  - [Connecting to CHPC (again) and obtaining an interactive shell session](#connecting-to-chpc-again-and-obtaining-an-interactive-shell-session)
    - [Start an interactive session on CHPC](#start-an-interactive-session-on-chpc)
  - [Less is not more. Viewing file contents within the CLI](#less-is-not-more-viewing-file-contents-within-the-cli)
  - [Making `head`s and `tail`s of big files](#making-heads-and-tails-of-big-files)
  - [The `cat` command and standard input, output and error.](#the-cat-command-and-standard-input-output-and-error)
  - [Pipes and redirects](#pipes-and-redirects)
  - [Cleaning up (and making) messes. `rm`, a potentially dangerous command.](#cleaning-up-and-making-messes-rm-a-potentially-dangerous-command)
  - [Aliases](#aliases)
  - [Nano - A command-line text editor.](#nano---a-command-line-text-editor)
  - [Renaming or moving files.](#renaming-or-moving-files)
  - [Table manipulation with `cut`, `sort`, `uniq`](#table-manipulation-with-cut-sort-uniq)
  - [Clean Data and Controlled Vocabularies](#clean-data-and-controlled-vocabularies)
  - [Variables](#variables)
    - [An aside on single and double quotes](#an-aside-on-single-and-double-quotes)
    - [Back to variables and Isolating Variables.](#back-to-variables-and-isolating-variables)
- [Practice / With Your Own Data](#practice--with-your-own-data)
- [Notes & References](#notes--references)

<!-- /TOC -->
# Main
These excercises will continue to work through basic Linux commands with the OnDemand interface. As before, these could largely be done on any Unix/Linux interface, but the locations and file references will be different.
### Requirements:
- An internet connection with a browser.
- A CHPC account.

### Expected Inputs:
- A project directory `~/BioinfWorkshop2020/Part1_Linux/` containing 3 files:
  1. read1.fastq
  2. read2.fastq
  3. table.txt

## Connecting to CHPC (again) and obtaining an interactive shell session
In [Part1_IntroToUnix](https://github.com/wzacs1/BioinfWorkshop/blob/master/Workthroughs/Part1_IntroToUnixCLI.md) we tried to use the OnDemand interface to obtain a shell on the lonepeak cluster. There were some issues due to the number of users at one time and the part 1 page has been updated with other ways of connecting to CHPC, but the OnDemand interface is still a nice option and should work well if you are just working though this outside of class.
1. Connect to CHPC with your preferred method (OnDemand, ssh from terminal on local computer[Mac], or Fastx web server)
> Test OnDemand

### Start an interactive session on CHPC
We've been given a reservation on the lonepeak cluster for this course. As noted before, we should avoid running major compute tasks on the head (or login) node of any cluster, and big tasks will be killed automatically. If you just logged in, you will have an interactive session on the head node. Let's try to take advantage of our reservation and each get an interactive session on the compute nodes. NOTE: if working outside of class time this won't work before Tuesday class or after Thursday class, due to our reservation time (thus, Wednesday is a good time to work outside of class!). However, for today, we aren't doing anything computational heavy so head node okay for this practice if needed.

1. Connect to lonepeak cluster
2. Use `srun` to obtain an interactive session on compute node for the class time duration:
```bash
$ srun -A MIB2020 -p lonepeak-shared -n 2 --reservation MIB2020 --time 2:00:00 --pty /bin/bash -l
```
If this command was entered correctly, you will see a message indicating you are in the queue, then after a bit the message should change and say your job has been allocated resources.

Look for the node name to change. This will be after your user ID. `<UNID@NODENAME`. It should change from `lonepeak1` (or 2) to something like `lp001` - `lp006`. This shorthand notation helps to indicate at a glance if you are on a compute node or head node.

A couple points:
1. The `-n` option indicates number of processors. Memory is automatically allocated if you don't specifiy, but you can specifiy this as well.
2. It's worth noting that interactive sessions for major computing is not really what HPC clusters are designed for. Interactive sessions should generally be used for testing out your pipeline on a smaller subset of your data and the major computing should be done with job submissions which we will later review.
3. For this portion of Intro to Unix, we are really doing very very minor computing tasks that are perfectly suited for the head node, so if the interactive session doesn't start up feel free to proceed with today's work on the head node.
4. Some of you may already have an account with your lab group. You can be associated with multiple accounts just fine, and you can try to use your lab group for the account, but will need to remove the reservation option.
D. The reservation option will not usually apply outside of class time. Normally, we will wait in line like everyone else, but generally the waits are not very long. I suspect while we are mostly out of the lab, these are unfortunately longer than usual.


## Less is not more. Viewing file contents within the CLI

There are several ways to view and edit files on the command line. We will keep it to the pretty simple methods, because heavy editing is likely going to be done with a text editing or spreadsheet program on your desktop made for this task. However, it is often handy to view very large tables or files that are frequent in bioinformatics (think millions of reads) and often cannot be opened in your desktop GUI (or will freeze your program).

First, let's use the command `less` to view the read1 file. Make sure you are in the `Part1_Linux` directory to type the following command:
```bash
$ less read1.fastq
```
To reiterate a concept, this is the *relative path* to the table.txt file. It is relative to the directory we are in.  We could open the file providing other relative paths (i.e. relative to home `~/BioinfWorkshop2020/Part1_Linux/read1.fastq`), or the absolute path starting from root `/`.

Less uses the same conventions as we saw with `man` pages to scroll through the file.
- `spacebar`: Full page down
- `d`: 1/2 page down
- `u`: 1/2 page up
- `q`: exit
- `/`: search within the file

Scroll through a bit, then exit the file.

By default, less wraps long lines of text. This can be difficult to view. As in this example fastq file, the sequences and the qualities are wrapped to the next lines.  A fastq file has 4 lines per sequence:
```
@Sequence Identifier
TheSequence
+ (in older formats you'll see the sequence identifier repeated here, but usually just empty besides the "+")
TheQualityScores
```
It is difficutlt to see these 4 lines. This can be really tricky to view bigger tab-delimited tables and tell where each column lines up. One of the many, many options to less is the `-S` flag. Reopen the file with the `-S` flag.
```bash
$ less -S read1.fastq
```
Now, we have the expected look with 1 line per displayed line. Much better. Exit the file.

Notice that when you exit the file view from less, the content you just viewed disappears. Usually this is the preferred behavior. Sometimes it is nice to continue to see the file you just viewed. Not surprisingly, there is a `more` function for this. Don't open read1.fastq with more, but instead compare how less and more work with the `table.txt` file.
```bash
$ less table.txt
$ more table.txt
```
## Making `head`s and `tail`s of big files
The `head` and `tail` commands do probably about what you guessed. They print the beginning (`head`) or end (`tail`) of a file. As you can imagine this can be very handy for very large files.  You will encounter these again in R. By default they each only return 10 lines, but this can be easily modified with the `-n` option. Try them out with the read1 and read2 fastq files:
- `head`: Prints the first n (10 by default) lines of a file
- `tail`: Prints the last n (10 by default) lines of a file

```bash
$ head read1.fastq
$ tail read1.fastq
```
Kind of like more, both of these should have printed out to your terminal. Except, they only print the first 10 lines. Let's just retrieve the first sequence entry in our fastq file read 1. Since each entry is 4 lines:
```bash
$ head -n 4 read1.fastq
```
Easy enough, and of course it should be obvious if we only wanted the *last* entry how we could use tail to accomplish this.
```bash
$ tail -n 4 read1.fastq
```
We will return to these very useful commands shortly. For now though, we have just been using relative terms to describe the position of our sequence entries (i.e. "first", "last"). Perhaps we need to know what number of sequence entry that last sequence is though. For this we would need to know how many entries there are in the file. Let's find out how many lines are in this file to determine this. Enter the `wc` command. Use it to determine how many lines are in each of the read1 and read2 files. In order to count lines, the `-l` option is needed.
- `wc`: **w**ord **c** ount. Return the number of words, characters, lines in a file.

```bash
$ wc -l read1.fastq
$ wc -l read1.fastq
```
Of course, since each entry is 4 lines we would have to divide this by 4 to get the total number of seqs. You can do this kind of simple math in Linux but there are better solutions and it's not something seen frequently, so we will not get into math on the command line. Look into the `expr` command if you are interested. It's a bit odd looking on the command line and this workshop will also use R which is easier to do math in as you might expect. For now, just be aware of the useful `wc` command.

## The `cat` command and standard input, output and error.
This has nothing to do with felines. Instead it is short for 'concatenate', though that is a bit confusing as well based on how it is usually used.
- `cat`: con**cat**enates files (either to each other or standard out)

In order to make more sense of why it is called this, we need to know a bit about the terms "standard output" (and "standard error"). First, use `cat` with the read1.fastq file to see it's behavior with one file.
```bash
$ cat read1.fastq
```
Woa! 4000 lines just printed to your screen. So, clearly `cat` prints the entire file, since we know how many lines were in this file from our use of `wc`. Perhaps it seems strange to call this command after concatenate. The reason it is called this is because it can indeed concatenate 2 files together, which we will show you in a bit. However, what it just did is to concatenate the read1.fastq file to the **standard output**.  The standard output is one of three "file streams" that are generally present in your shell and serves as a defined place to print output (there's always a defined place for everything). This can be a bit of  a confusing concept at first, but just know that everything that is printing out to your screen goes through this standard output. Or, it is standard error.... I won't get into the difference between these here because it's too-much-too-soon, not quite the "error" you might be thinking of, and for the most part we will actually combine them (later on). I'd encourage reading up on these on your own time.
**Standard input** is the third file stream. While it too always has a defined file descriptor, it doesn't necessarily always have something in it until you put something there. Having a place to define standard inputs and outputs allows us to connect, chain or "pipe" commands, and makes Unix/Linux very powerful and very fast (because we don't have to actually write intermediate files all the time). With that aside, let's see how to connect inputs and outputs.

## Pipes and redirects
There are 3 major symbols you will use to redirect inputs and outputs.
- `|`: Usually called a "pipe". Find it on the same key as backslash `\` usually. It redirects, or pipes, the standard output to standard input.
- `>`: A single greater than redirects to a file and overwrites it if present.
- `>>`: A double greater-than redirects to a file and adds (or concatenates) to it instead of overwriting it.

Now we are ready to start doing some more useful commands. First, let's return to `cat` and illustrate how to actually concatenate 2 files together and redirect that standard output into a new file instead of printing to our screen. Concatenate the read1 and read2 files together and print them to a new file. You can concatenate as many files you want and any format so use it wisely. `cat` doesn't care and will try to put together anything it can. Just list the files in order you want them added. Then use the greater-than to redirect to a new file.
```bash
$ cat read1.fastq read2.fastq > BothReads.fastq
```
Check that it worked as expected and your file is 2x long now.
```bash
$ wc -l BothReads.fastq
```
This may seem simple, but think about how you would do this with a 20 million read file (medium sized for Illumina) with your Desktop GUI.  You probably wouldn't because you wouldn't be able to hold those 20M reads (several Gb depending on read-length) in your memory to copy them in the first place.

Now, let's illustrate the double greater-than use. Go ahead and ahead add the read1.fastq onto the end of your combined file, check that the number of lines is another +4000 because it added them on. Then, see what happens if you just used the single greater-than.
```bash
$ cat read1.fastq >> BothReads.fastq
$ wc -l BothReads.fastq
$ cat read1.fastq > BothReads.fastq
$ wc -l BothReads.fastq
```
From the description of these two operators and the line numbers, you can tell that you just overwrote the BothReads.fastq with just the read1.fastq file. It doesn't really contain both reads any more. We'll leave this for now anyway.

Next let's understand how the pipe `|` is different. For most commands you need to provide an input. So far, we have always specified this input file. However, the input can always be the standard input instead for Linux commands. That's what the pipe is for - to redirect output to input. As a first example, use `cat` as we first used it to open the read1.fastq and redirect it to the `head` command.
```bash
$ cat read1.fastq | head
```
Notice how we did not specify the file to head (like before with `head read1.fastq`). It simply took the standard input given to it by the pipe. This is default behavior, nearly always, but the standard input can usually also be explicitly referred to by the dash `-`, and so this is the exact same command:
```bash
$ cat read1.fastq | head -
```
Of course, that's kind of a pointlessly longer command, but serves to illustrate the point for now. Perhaps something more useful (given what we know so far) would be to get the 11th sequence read entry in the read 1 file, then write it to its own small file. We could use head and tail to do this with just the options we have learned. Here is ONE way of doing this:
```bash
$ head -n 44 read1.fastq | tail -n 4 > Read1_Sequence11.fastq
```
We will continue to use these commands, pipes and redirects throughout, so will have more opportunity to practice these. These are some of the most useful Linux commands you will encounter, and wonderfully exemplify how the simplicity of commands in Unix-based systems can be put together to do more complicated tasks yet maintain flexibility.

## Cleaning up (and making) messes. `rm`, a potentially dangerous command.
We've now created some unnecessary files in order to illustrate how to use some of the commands we've learned. You may already have inferred that it will be easy to create a lot of files quickly on the CLI. This is very true and it becomes easy to create a mess quite quickly. Cleaning up should become part of your routine, especially on CHPC, where you only have 50 Gb of home space normally. However, it is also becomes very easy to erase important data, as there is no recycle bin to catch accidental deletions in this interface. It's part of the reason we are starting on a clean CHPC environment instead of your laptops/desktops with all your research data. With just 5 keystrokes you could delete your entire home space in Linux. Of course, you are always backed up right!??

- `rm`: **r**e**m** ove files

Let's remove some of the temporary files we have created. Use `rm` to remove the BothReads.fastq file (at this point it doesn't even have both reads) and the 11th sequence file.
```bash
$ rm BothReads.fastq
```
As with other linux commands, it is very simple. That makes this also very dangerous. There is an option you can add to this to give a prompt to ensure you want to actually remove the file. Try adding the `-i` option to see this:
```bash
$ rm -i Read1_Sequence11.fastq
```
This can be helpful, but it has been said that this really doesn't work like you think it will. The reason is, you'll tend to type a lot and will eventually not look closely at these prompts so if you typed the wrong file in the first place you'll probably just be in the habit of answering "yes" anyways. Can confirm from my early experience unfortunately. More importantly, you can't really automate a task if you have a prompt you need to answer. I would suggest just learning to be very careful with this command. It truly becomes dangerous when paired with the `-R` option which allows you to recursively delete contents of a directory and remove the directory. To illustrate, let's make a new directory. In fact, let's make 2 levels of them with a new option to `mkdir`.

Using the `-p` option with `mkdir` serves 2 important functions. First, it won't throw an error if the directory already exists. This can kill an automated script. Second, it allows you to make what ever directories are needed above it, so you can make multiple nested directories at once. Make a temporary directory and one inside of it with this command:
```bash
$ mkdir -p TestDir/RemoveDir
```
Use `ls` to ensure both directories were made. While we are at it, let's learn how to make an empty file. The `touch` command is used for this.
- `touch`: Creates and empty file
```bash
$ touch TestDir/RemoveDir/NewFile.txt
```
Now, try to remove `TestDir` like you did with the file:
```bash
$ rm TestDir/
```
That didn't work and you received an error. You could use `rm -R` option to remove this. However, there's another way that I think is a bit safer because it forces you to ensure you are removing only empty directories. That is, first you need to remove the files in it, then use a command that only works on empty directories to remove the directory. Remove the file you just created.
```bash
$ rm TestDir/RemoveDir/NewFile.txt
```
Now, try to remove the `TestDir` direcory with the `rmdir` command.
- `rmdir`: **r**e**m**oves an empty **dir** ectory
```bash
$ rmdir TestDir/
```
As you might have expected, this does not work because there is a directory inside of it. So, remove that directory first, then remove the TestDir (use your up arrow and tab autocomplete!).
```bash
$ rmdir TestDir/RemoveDir/
$ rmdir TestDir/
```
Hopefully you can see how this process forces you to think more carefully about what you are deleting and by using `rmdir` instead of `rm -R` you will not delete directories containing useful files. You can also likely imagine how this is tedious (though less so once you learn how to match many files at once), and `rm -R` could be much more quick and useful, particularly for automated tasks. Just use it with caution. Some people like to add the `-i` option to their `rm` command, which provides an interactive prompt for removing, giving you a chance to change your mind. It's not really a good idea to rely on this because you can't automate processes with it and, perhaps more importantly, if you use it all the time you will quickly come to ignore it anyways and it won't work like you want it to anyways.

## Aliases
Aliases are different, generally shorter, ways of providing the same command. Aliases can be really useful when you find yourself typing a command option a lot. In fact, you probably already have a few aliases because some are so common many people get used to them and expect them. On CHPC, as on many linux machines, one of these aliases is `ll`. You won't find this on you mac normally. Try typing `ll` in your directory with files and then also try bringing up its manual page.
```bash
$ ll
$ man ll
```
You will find there is not a manual page for this command because it is actually an alias. You can probably see that `ll` is an alias for `ls -l`. As I mentioned before, `ls -l` is a very frequently typed command. So much so that shortening it by just 3 characters is very helpful.

You can add your own aliases as well. One of those that I find very useful is adding the `-p` option to ls also.  While you (might) have a nice colored output that helps differentiate files and directories, this is not always present and the colors will change from one system to another (in fact you can change them yourself). The `-p` option puts the trailing `/` onto directories so it is always clear which are directories and which are not, even if you aren't doing the long listing format. Try it out to see the difference. But first make another directory here so you can see it in action (since we removed the directories in the last section).
```bash
$ mkdir TestDir2
$ ls
$ ls -p
```
To create an alias there is an alias command. Just use `alias`, the command to assign an alias to, and what alias should be used instead (in quotes).
- `alias`: Assigns an alias to a command. Format: `alias <command>="<new_command>"`
```bash
$ alias ls="ls -p"
```
Now, try typing just `ls` again.
```bash
$ ls
```
You should be able to see that your new director (`TestDir2`) is listed as `TestDir2/`. When assigning an alias like this it will, however, only last for the current session you are in. Luckily, there is a file that is read on startup which we can add these aliases to in order to make them permanently part of your environment. First, let's learn about how to edit a file on the command line.

## Nano - A command-line text editor.
One of the really simple but great parts about the OnDemand interface is that it has an editor as well, sort of making this section obsolete. However, it is still good to know about these built-in editors and how to use them for when you are on another Unix system. Also, for small edits it's much easier to do it on the command line quickly. We will use the editor called **nano**. There are several built-in or often-installed editors and some coders feel oddly strong about their favorite. However, all these editors, by their nature, have to use keyboard shortcuts to do things like move the cursor, save, cut, paste and so forth since this is the CLI. So, you have to know all these strange keyboard combos to use them and people tend to choose one and only use that. I like nano because it is very basic, almost always present and the few shortcuts *required* are actually listed. Others include vi or vim and emacs.

Let's use nano to open the hidden file in your home directory called `.aliases` and edit it. This file may not be present on your environment, and if it is not, nano will just create it.
```bash
$ nano ~/.aliases
```

That will open a (likely) empty file with a cursor at the top and a few keyboard command hints at the bottom. The keyboard commands have a carrot (`^`) to indicate Ctrl key. So Ctrl+X will exit the file for example. Add the same alias for `ls` that we used before:
```
alias ls="ls -p"
```
Notice I didn't put the command prompt in front of this because it is text you should enter, not a command.

Save the file by exiting (Ctrl+X). It will prompt you at the bottom and ask to "Save modified buffer?". Enter a `y` to save and then hit enter to confirm the filename. You can see that because it asks you the filename and allows you to change it, you can open a file and save it as something else if you like as well. Check that your .aliases file is present in your home directory. It will only be looked for there by bash. It's hidden, so you'll have to use the proper option to see it.
```bash
$ ls -a ~/
```

Now that you've opened nano once and saved let's do it again to add 2 more aliases. Use the same procedure as before to open nano, add the 2 below and save and exit nano.
```
alias cp="cp -v"
alias mv="mv -v"
```
Great. What did you just add anyways? You can open the manual page for `cp` to find out, but I can also tell you that the `-v` option to a command is almost always going to be one of two things: "verbose" or "version". In this case it means "verbose". Which is a way of saying give me all the output. Programmers tend to initially write methods that give lots of feedback or status updates about what they are doing, then hide that feedback in the finished product because it's annoying and unnecessary to the every day user. You will often see the phrase "Silence is golden" next to this option. Turning on verbose output brings the status updates back. In the case of `cp` it's just one line. You won't be able to see anything yet from this alias though. That's because these alias files are only read by bash once on login. You can use the `source` command to force read it, or log out and log back in. Just use source.
```bash
$ source ~/.aliases
```
Now, make sure you are in the `Part1_Linux` directory or move there if needed. Use `cp` to create a backup copy of the `table.txt` file.
```bash
$ cp table.txt table2.txt
```
You should see a small message printed that showed what you just did. I think this is a helpful alias to have since a successful copy normally does not print any thing without the verbose option.

The only problem with aliases (at least that I can think of) is that you can become dependent on them and forget that an option is needed for the output you are looking for. For this reason, I don't think it is generally a good idea to set a lot of aliases permanently in the aliases file, particularly while just beginning, so we will leave it to these few for now.

Note: that on Mac you may need to add aliases in ~/.bash_profile or ~/.profile instead. The file will already be present on Mac. The names of these files vary a bit from system to system, but CHPC has been setup to look for the .aliases file specifically.

You may be wondering what the `mv` command we added an alias for is. This is the last of the most basic Linux commands we will now explain.

## Renaming or moving files.
There's actually a `rename` command, but it is a bit more complicated and is made for renaming multiple files with pattern matching which we haven't yet covered. Mostly you are going to use the `mv` command to rename files and directories. The fact that "moving" files is how you rename them should help reinforce the idea that a filename is really the whole path to that file, not just the name you see.
- `mv`: **m**o**v** e (or rename) files or directories.

Previously, we named our table.txt copy "table2.txt". That's not a super useful name for what I plan to have you do with it. Let's rename it to "table_initial.txt".
```bash
$ mv table2.txt table_initial.txt
```
We added an alias to `mv` to make it provide verbose output as well. So, you should see a printed statement about what just happened.
`mv` is otherwise pretty straightforward and can be used to move whole directories as well as files. Try moving the table_initial.txt file to your home directory and back to your current directory to see how you really just have to provide the directory name where you want to move something. Don't forget tab-autocomplete!
```bash
$ mv table_initial.txt ~/
$ mv ~/table_initial.txt ~/BioinfWorkshop2020/Part1_Linux
```
A little side note. Notice that I didn't add the `/` at the end of the second command even though I was referring to a directory. Thankfully Unix has no problem with this and will expand and add the `/` for you when a directory is referenced. This behavior has a lot of implications, but mostly is just really handy, for example in autocompleting directory names.

## Table manipulation with `cut`, `sort`, `uniq`
While you certainly could manipulate the small table I provided outside of the command line, often you will encounter very large tables that are less amenable to this in, for example, excel (and of course your table won't get "excel-ified" unintentionally). For example, large GFF tables that describe all the features of a genome. The `cut` function, while not explicitly for tables, is often very useful for manipulating these large tables and extracting subsets of information very quickly. Later, we will see R and associated packages are best suited for these tasks, but doing these manipulatons or extractions in Unix/Linux is often preferred for simplicity (no need to load a new workspace, import file, load packages, etc. in R).
- `cut`: Retrieve columns (sections) of a file, line by line. Default delimiter is tabs.

As with most Unix utilities, `cut` works line by line. Important to keep this in mind because line endings are always used to denote the next 'entry'. Generally this is obvious but, for example, a common fasta format file that has a sequences over multiple lines in order to make standard width lines would violate this assumption and lead to unexpected behavior.

You will almost always use `cut` with the `-f` option, which specifies specific fields (columns) to pull. First, use one of the commands you've already learned (`less`, `more`, `cat`) to view the table_initial.txt file to get a sense of what it contains. It's a small, mock metadata file with sample IDs that are of the common format you will see from Illumina machines (the run number, X, and sample number), and a single header line describing each column. A very common format. First, get just the second column (Tissue) from this table:
```bash
$ cut -f 2 table_initial.txt
```
Not too remarkable, but shows the basic idea. Now, let's remove the "Well" column from that table and retain everything else. You can specify ranges (eg. 1-4) or specific columns separated by commas (eg. 1,2,4), or a combination of the two (eg. 1-4,6). We want to just remove the 4th column (well), and redirect the output to a new file.
```bash
cut -f 1-3,5,6 table_initial.txt > table_NoWell.txt
```
This is a great way to modify your tables without having to round-robin through excel and worry about formatting issues this causes all too frequently. But, `cut` can use any delimiter you specify, it just uses `tab` by default. Our file is tab-delimited, but notice the 'BreederPair' column has values separated by a `-`. Say I wanted to extract just the males from that column (those with "BreedM"). We can use multiple `cut` commands in a row to get this information.
```bash
cut -f 5 table_NoWell.txt | cut -f 1 -d '-'
```
Notice that I used single-quotes to enclose the delimiter. In this case, you could leave them out, but it is a good idea to have them in. Single and double quotes have different behaviors that can be a bit confusing so we won't go to in depth on them for now, but will discuss more when we start pattern matching. In general though, single quotes prevent whatever is inside of them from being interpreted as special characters. So, here I use `'-'` to ensure this wasn't interpreted as some range, but rather that the `-` character is actually looked for. It's not needed for cut, but it's a good habit to be safe and ensure we have the expected behavior.

So, cut can be used to manipulate tables, but it's real usefulness comes when paired with other commands. I frequently use it to find or count unique values from a large file. Let's use it to count the number of breeding males in this dataset. To do this we will introduce 2 new commands: `sort` and `uniq`. You will often see these two together because `uniq` only works as you expect if values are already sorted.
- `sort`: Sort the input alphanumerically.
- `uniq`: Return the unique values only.

Use the same `cut` command as before and pipe the results into `sort` and `uniq` to see the unique breeder males present in the dataset. Try breaking the expected behavior by not sorting first.
```bash
cut -f 5 table_NoWell.txt | cut -f 1 -d '-' | uniq
cut -f 5 table_NoWell.txt | cut -f 1 -d '-' | sort | uniq
```
That's nice, but if I was just trying to get the unique entries, clearly we've got one too many because the header value is still there. That's good and shows Linux is not making assumptions, but is not what we were looking for. Can you use some of the earlier commands we learned to exclude the header?  There's a few ways to do this and I'll leave it as an excercise for you. For now, let's also count how many times of these breeder males occur. You can use the `-c` option to accomplish this.
```bash
cut -f 5 table_NoWell.txt | cut -f 1 -d '-' | sort | uniq -c
```
Hopefully, these examples show how we can extract information from tables very quickly and you can see how this can be useful for large tables often encountered in bioinformatics.
Both of these have a number of options that allow you to change their behavior to fit your data (eg. ignore-case, sort by dates), so be sure to check the man page when using them.

## Clean Data and Controlled Vocabularies
Hopefully, for most scientists this will be an unneeded reminder. However, this is a good point to serve up a nice reminder and example to enforce the notion of clean data early on. Some of the 'helpful' features of GUI programs have often served to create or allow bad habits. A large portion of time in dealing with big data is frequently spent cleaning it up (whether someone elses or your own). This cleaning is one aspect of so-called "data wrangling". Much of "data-wrangling" is an important and inescapable part of big data analysis, but far too much feels like wasted time due to inconsistent data entry from the beginning. An advantage for bench scientists who are the data collectors and data analysts is that with a little foresight and good practices a considerable amount of time (and/or frustration) data cleaning can be avoided. Most of the problems seem to come down to categorical variables that are inconsistently entered. This is one of the reasons that big data repositories (such as NCBI) often have **controlled vocabularies** for many entries that restrict the possible entries. Of course, there's many other good reasons to have a controlled vocabulary, but it's almost always much (much, much!) easier to work with these controlled vocabularies than a free-form system. As an example of the problem, I've entered a few differences in the entries for the "Tissue" categorical variable in the practice table. Most of these differences would sort as you might hope they would with defaults in a spreadsheet program like Excel, and so represent the kind of common inconsistencies that may never have bothered you before.

Use the same `cut`, `sort` and `uniq` commands you used before to see the different variables in the "Tissue" column. The intention was to have only 2 types of tissues.
```bash
cut -f 2 table.txt | sort | uniq -c
```
"Tissue" was the header, which we did not remove with this command (this is left as an excerise), so that's okay to see that there, but as you can see there is only one type of entry for lung, but 4 types for spleen. Clearly not the intention and 3 types of mistakes have been made. At least 2 of these mistakes are obvious, though common and easy to make. All the mistakes are:
1. *Inconsistent capitalization*: As we've already mentioned, you should always assume case sensitivity. This contrast with, for example, Excel which defaults to case insensitivity. Here, "spleen" and "Spleen" are completely different variables.
2. *Leading space*: This one jumps out visually, and even excel notices this is different. It should be obvious, but you could be forgiven for thinking that all spaces are the same, and often programming languages just recognize "whitespace" between command or variables. More generally speaking, this is not the case and a tab is an actual separate character, not just a series of spaces.
3. *Trailing space*: This one is not obviouse from the command we used to print the unique entries. However, you can see that Linux recognized they are different. Sometimes this doesn't actually cause a problem because built-in functions strip trailing whitespace or hidden characters (for example, the newline) but always better to start out clean.

Hopefully, this example helps to solidify why consistent text entry is imporant if you are not already doing this. Imagine the impact of testing for differences among tissues. The best-case scenario is that the impact of these differences is only extra time cleaning the data. However, as the size of your data grows, it becomes harder to spot these differences as well, and you may not spot them until you run a statistical test and notice the number of factors or degrees-of-freedom are not what they should be. Worse, you never notice. While many data scientists often look down upon spreadsheet programs like Excel or Google Sheets (mainly for data analysis reasons), they can actually be a positive thing for this problem if set up with the issue in mind because it is quite easy to create controlled vocabularies and only allow very specific entries during the data entry process.

## Variables
Variables can be just about anything you can think of, and really just refers to some part of memory that has been assigned a value. If we were doing a serious coding course, we would spend a significant portion of our time here because, as you might imagine, different types of values (integers, text strings, arrays) are stored and interpreted differently. Handling and defining variables is often where programming languages differ considerably. We don't need to go too much into this area with Unix thankfully. You will see once we get into R that understanding difference in variable handling (or data types) is a major aspect.

It's helpful (though not strictly accurate), to just consider two major types of variables in our `bash` shell.
1. Environment Variables: These are set by system.
2. Shell (or User) Variables: These are defined by you, the user, in your current shell.

Generally, we will just refer to "variables" because the distinction is usually not important (or even real), but there are times you will explicitly hear "environmental variables". We can redefine most environmental variables if we want to, and a user variable can become an environmental variable in a new environment.

To see your environmental variables use the `env` command:
```bash
$ env
```
Wow, there's a lot of variables set for you already as you can see. These also show the way to define variables. Variables are defined by a text string, then an equal sign, then the assignment to that variable; all without spaces. Succinctly: `VARIABLE=Assignment`. The all capitalization for the variable is not required, but is often done by convention. It helps to make them stick out.

The other requirement for shell variables is that they cannot START with a number. This is also a common programming restriction and we will see this is true in R. They may contain numbers, but cannot start with numbers.

One variable that may have jumped out to you at the top is HOME. To instruct bash that we are looking for the value of a variable we use the dollar sign special character (`$`) in front of it. This is a fairly common notation among languages. Let's also introduce the `echo` command to print the variable definition.
- `echo`: Prints a line specified by user.

Print the variable definition of HOME:
```bash
$ echo $HOME
```
The `echo` command is very simple and really useful for logging or just seeing what (if anything) the definition of a variable is. You can add more text to it to make it a bit more informative, but if spaces are included you'll need to wrap it in double quotes. For example:
```bash
$ echo "My home directory is $HOME"
$ echo "My current working directory is $PWD"
```
Remember the `pwd` command? We just saw, there's an associated variable for it that gets updated everytime you change directory. That can come in quite handy because it allows us to use "absolute" paths for files in our current directoy with a much shorter notation.

### An aside on single and double quotes

Single and double quotes enclose these differently, and behave fairly similarly in different languages. Use your command history to alter the last command to echo the statement with single quotes:
```bash
$ echo 'My current working directory is $PWD'
```
That's not the behaviour you were probably aiming for with that statement, but it illustrates the difference. Single quotes prevent the interpretation of special characers. It's a way of saying 'I want EXACTLY this!'. This is a very important distinction in a lot of instances, but makes no differences if there is nothing to interpret enclosed in the quotes. This leads to sloppy use of them interchangeably (I admit I'm guilty of this at times), which is often the source of errors, and one of the first things to check for when you encounter errors.

### Back to variables and Isolating Variables.

We saw that some environmental variables contain directory paths because these paths are just text strings. They can contain any other text strings as well, but may need quotes. They can also contain numbers (though in actuality, aren't stored as such), and can be inside of other text. Go ahead and define a variable for the shared basename of our read1 and read2 fastq files (`read1.fastq` and `read2.fastq`):
```bash
$ BaseName="read"
$ echo $BaseName
```

Now, print a message along with that base to describe which file contains contains read 1:

```bash
echo "Read 1 is in: $BaseName1.fastq"
```

This shouldn't have worked as you might have hoped. It's not an error for bash (it printed something just fine), it's just not what we were trying to get, which was more like `Read 1: read1.fastq`. The incorrect output illustrates why we will frequently need to explicitly isolate our variables. It generally can't hurt to do this and I hope to encourage it as habit early on. Additionally, it opens up a lot of cool variable handling functions we will use later on.
- Isolate variables inside curly brackets `${VAR}`

Now try the above command with the variable isolated (remember your command history / up-arrow):
```bash
$ echo "Read 1 is in: ${BaseName}1.fastq"
```

As quick further example, let's get the absolute path to that file, assign it to a variable and view the first sequence. Assuming you are in "Part1_Linux" directory still:
```bash
$ ReadOne=${PWD}/${BaseName}1.fastq
$ head -n 4 ${ReadOne}
```

Of course, we could have gotten away with not isolating ReadOne the second time since it's all by itself, but let's get in the habit.

# Practice / With Your Own Data
- Tail can be very handy for taking all except the first n lines to remove the header of files. Use the man page of tail to figure out how to take all EXCEPT the first line of a file (such as the header in table.txt) and write it to a file. Assume you don't know how many lines are in the file.
- If you've already uploaded your own files to a directory. Create a "Projects" directory and a project specific directory within that. This is a good organization strategy to have. Move your files to that directory using the `mv` command.
- Check out other aliases you might like in the man pages of commands we've used.
- Use `cut` to get columns from a comma-separated values file instead of a tab-separated.
- Get the number of unique tissues or unique female breeders from the practice table.txt without the headers and save it to a new file.
- Use `cut` with different delimiters on the mistakenly entered "Tissue" column to prove that the leading and trailing spaces are indeed there. Hint: start with the default tab delimiter to extract the column as before.

# Notes & References

- Key commands introduced in this part
  - `head`: Prints the first n (10 by default) lines of a file
  - `tail`: Prints the last n (10 by default) lines of a file
  - `less`: Displays the file in a scrollable and searchable interface
  - `cat`: concatenates files (either to each other or standard out)
  - `wc`: Count words, characters, lines in a file.
  - `|`: "pipe". Redirects, or pipes, the standard output to standard input.
  - `>`: Writes output to a file and overwrites it if present.
  - `>>`: Writes output to a file and adds (or concatenates) to it instead of overwriting it.
  - `rm`: remove files.
  - `touch`: Create an empty file.
  - `alias`: Assigns an alias to a command. Format: `alias <command>="<new_command>"`
  - `nano`: A commonly available command-line editor.
  - `mv`: Move (or rename) files or directories.
  - `cut`: Retrieve columns (sections) of a file, line by line. Default delimiter is tabs.
  - `sort`: Sort the input alphanumerically.
  - `uniq`: Return the unique values only.
  - `echo`: Prints a line of whatever is specified.
