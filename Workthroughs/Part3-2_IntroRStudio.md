<!-- TOC -->

- [Main](#main)
  - [Requirements / Inputs](#requirements--inputs)
  - [Objectives](#objectives)
  - [Start RStudio Server Interactive App on OnDemand](#start-rstudio-server-interactive-app-on-ondemand)
  - [The RStudio Interface Overview](#the-rstudio-interface-overview)
  - [RStudio options](#rstudio-options)
  - [RStudio Projects](#rstudio-projects)
  - [RMarkdown in RStudio](#rmarkdown-in-rstudio)
    - [What is "markdown"?](#what-is-markdown)
    - [The Most Common Markdown Formatting Marks](#the-most-common-markdown-formatting-marks)
    - [R Markdown specifics](#r-markdown-specifics)
  - [Basic R commands - mathematical expressions](#basic-r-commands---mathematical-expressions)
  - [R (variables) objects](#r-variables-objects)
  - [R functions](#r-functions)
  - [R packages](#r-packages)
  - [Accessing elements in a list/array/table in R](#accessing-elements-in-a-listarraytable-in-r)
  - [R Packages - install](#r-packages---install)
  - [R Packages with Bioconductor](#r-packages-with-bioconductor)
  - [Read in data table into R](#read-in-data-table-into-r)
    - [Read in data table into R - `base` R fxns](#read-in-data-table-into-r---base-r-fxns)
    - [Read in data table into R - `readr` fxns](#read-in-data-table-into-r---readr-fxns)
  - [Data frames in R](#data-frames-in-r)
  - [Accessing data frames](#accessing-data-frames)
  - [Accessing data frames: Variable accession](#accessing-data-frames-variable-accession)
  - [Saving workspaces and closing Projects in R](#saving-workspaces-and-closing-projects-in-r)
  - [Install other packages for next time:](#install-other-packages-for-next-time)
- [Links](#links)
- [Today's New Commands (R)](#todays-new-commands-r)

<!-- /TOC -->

# Main

## Requirements / Inputs
1. A CHPC account and OnDemand login
2. (optional) RStudio installed on desktop/laptop
3. Copy metadata table for full Biopsy Sample RNAseq. You can do this now in a shell (you don't need to get an interactive session with `salloc` to do this simple copy, just do it on the head node)
```bash
cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/metadata/SraRunTable_RNAseq_BiopsyOnly.txt \
 ~/BioinfWorkshop2021/Part3_R_RNAseq/metadata/
```

## Objectives
##### I. Start RStudio server on CHPC through OnDemand interface.
##### II. Overview of RStudio interface.
##### III. Basic R usage and functions.
##### IV. Understand packages, install locations.
##### V. Read in data table and introduce the tidyverse set of packages.

## Start RStudio Server Interactive App on OnDemand

This part is specific to CHPC and **RStudio Server**. You don't need to do this if you are running in **RStudio** on your local laptop/desktop. I use RStudio Server for class as it allows me to avoid problems arising from different environment setups people have on their own computers. In practice, my recommendation is to generally use RStudio on your local computer with CHPC space mounted so you can read and write to it.

- *Normally (outside of this workshop)*: On CHPC OnDemand main page after login:
  - "Interactive Apps" -> "Servers: RStudio Server"
  - Choose your R version. Any will do but the Bioconductor ones already have many useful packages installed.
- This workshop has a special allocation/setup. So, instead (*only for this workshop*):
  - "Classes" (top menu) and "MIB2020" will bring up an RStudio server setup page.
  - Normally, you will choose an R install version. This workshop setup has 4.0 only so no choice is available. Also, you normally will have to choose your cluster, account, etc. similarly to how sbatch commands required them.

- Fill in options. For this class we will keep the time and cores a bit lower to allow sufficient resources available to all.
  - R version: R 4.0.3 is only available to us and so is not a choice.
  - Number of cores: 2
  - Number of hours: 3
- Wait for page to refresh and "Connect to RStudio Server" button to come up. Click on this.
- This starts RStudio on CHPC. It will be very similar to how it looks on Desktop App, which you can use if this isn't working for you or are outside of class time.

## The RStudio Interface Overview
- RStudio is an IDE: Integrated Development Environment
- Default Panes:
  - Left (or bottom left): The R console. Where you type R commands. This is the core of R which the rest of RStudio panels facilitate.
    - Notice your current path printed at the top, right under "Console"
    - Notice "Terminal" tab next to console.
      - We can do some *very* basic linux commands here. The environment here is very incomplete and lacks the setup needed to make it useful, so generally I don't use this much. However, with more setup you could do all your Linux / shell commands in this single RStudio IDE potentially. I find it not worth the trouble on CHPC however given the environmental setup required. In your local RStudio it is more useful.
      - Here, you can copy over the metadata table to your local directory if you did not already do this in setup:
      ```bash
      cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/metadata/SraRunTable_RNAseq_BiopsyOnly.txt \
       ~/BioinfWorkshop2021/Part3_R_RNAseq/metadata/
      ```
  - Bottom Right: Help, Plots, Files and installed packages.
    - Note file listing in your current location
    - Will return to the others in more detail.
  - Top Right: Environment, History
    - Environment shows all your variables.
- Each pain can be minimized/max with button on top right window icons.
- Top Right corner: Shutdown button stops session, but not server. Need to delete that on OnDemand page to end.

## RStudio options
A few key options to be aware of in RStudio.
- Tools --> Global Options
  - On general page, change behavior of RStudio on startup as desired.
    - You may want to uncheck the "Restore ..." options. Personal preference, but leave for now.
  - On Terminal page, change shell if you prefer/are using other than bash.
  - Pane layouts tab to change arrangment.

## RStudio Projects
I've tried to have you work with a "project-centric" mindset in this workshop so far, where a given directory contains all the data and code needed for a project. As you've seen with very large seq files this isn't always entirely possible. In RStudio the project mindset is solidified and there are special files to help define a project. RStudio is made with the expectation of a project, but does not actually require it.
- The Project file helps organize your project and connect the variables, history, required packages and opened source or documentation files.
- Start a new Project for today
  1. Upper right hand corner (or menu): "Project --> New Project.."
  2. Start a project in New Project Directory.
  3. New Project
  4. Browse to `~/BioinfWorkshop2021`
  5. Name new folder: "Part3_RStudioIntro".
  6. Click OK, RStudio opens new project.
- In new project, note your path at top of Console.
  - Type command `getwd()` into console as well and hit enter. The R equivalent of `pwd`.
  - Click on File pane. Note the only thing in the directory is your new R Project file called "Part3_RStudioIntro.Rproj"
    - The R project file can be clicked on (in Desktop/Laptop) to start RStudio and load project directly.
-

## RMarkdown in RStudio
- "Markdown" we have already encountered a couple times, though I left it till now to explain it because R's version of Markdown and RStudio make it a bit easier to see in action. First, let's create an RMarkdown document in RStudioServer and follow along.
  - In left pane with Console, click double window icon if present to add another pane above it. You may already have a second pane on the left side.
  - In this pane, we usually have a markdown or other text document open to document our code. Similar to using Atom in a separate window when working interactively with shell commands. This really makes our IDE useful for documentation and reproducibility.
  - Open a new Rmarkdown document. File -> New File -> R Markdown...
    - Keep it as a "Document" and enter your name and a title () and click "OK".

### What is "markdown"?
  - Markdown allows you to easily do common formatting *inline*. So you never have to mouse click and leave the keyboard as in Word Processors. Think about all the formatting options in Microsoft Word and how many you actually use for writing a manuscript for example.
  - Markdown allows to display code chunks (and even outputs at times) in the same document next to your natural language documentation of the code. It allows you to create a narrative around your code.
  - Markdown is not a coding language, but more of a set of syntax guidelines which derives from the rich-text format (.rtf) originally. You may have used some of these rich text formatting characters in the past for blogging or posting in online forums.
    - Markdown comes in many different "flavors". Rmarkdown, GitHub markdown, etc., or just general "Markdown".
    - This may lead to some unexpected behavior at times, but there are numerous commonalities, especially amongst the most basic and frequently used formatting marks.
      - This document (and the others in this class) is *entirely* written with basic markdown formatting but displayed by GitHub using the syntax expected by its markdown flavor. It does a great job doing what I expect it to, for the most part.
 - RMarkdown follows most of the same syntax rules, but really makes markdown shine in RStudio because you can run your code from the markdown document itself. See the link that is populated by default in your new markdown document for more details on RMarkdown.

### The Most Common Markdown Formatting Marks
- There's really only a half dozen or so formats you need to make markdown documents useful and nicely organized.

**Section Headers**
- The `#` characters are used for section headers. Increasing number of them for each level gives simple and effective organization.
  - Notice in your RMarkdown document on the bottom-left there is a little buttton with up and down arrows and some text (will vary depending on where your cursor is in that doc). This can be used to navigate between section headers identified with the `#`, and also code chunks.
**Code blocks/chunks**
- The backtick ( \` - on your `~` key) is used to delineate code. It can be `inline` when enclosed in a single backtick at the beginning and end, or set aside in blocks (like you've seen throughout these documents) with 3 \`\`\` noting the start and 3 \`\`\` noting the end of the block.
  - While you don't *require* it for documentation purposes, you can tell markdown how to highlight words (and run or interpret in RMarkdown) in your codeblock, by specifying what program is to be used after the first the backticks.
  - In R markdown, you have to put the program/language in curly brackets (`{r}`). You can see these in the example chunks.
**Text formats**
- **Bold** and *italics* are very useful to know as well. Use text surrounded by 2 `**` for bold and one `*` for italics.
**Bullet points and Lists**
- Bullet points are added whenever a line starts with a dash (`-`).
    - If you indent the following line (tab OR space *usually*) and add another bullet point, markdown will notice it is a subpoint and format it correctly.
- Numbered lists are created automatically usually when a list is detected. So even though I started each of these numbers with `1. ` when I write them, they still end up as increasing numbers.
1. Every number
1. in this list was
1. actually written as `1. `

- That's really all that is needed but there is much more as you can imagine. Tables, table of contents, references (w/ Latex), links and more also have formatting methods. I encourage you to look at these and use mardown as much as possible, but we will keep it short for our class.
- It is important to note that one of the most obvious differences in markdown flavors is how, or if, hard line breaks (actually hitting the enter key) are required between lines. If you are getting unexpected behavior it is probably because of a lack of line breaks.
    - Extra or unnecessary line breaks (beyond 1) will be stripped, so it's a good idea to add them between lines when unsure.

### R Markdown specifics
- Knitr package is used to put these together in a pdf, html or other format of choosing and facilitates display of graphs and tables.
  - Generally keep this first code chunk as it is for setup.
- Notice how the first code chunk for setup has a `, include=FALSE` in the curly brackets. Statements after the comma allow to specify if a chunk should be shown in the final document, included or evaluated. This one says don't include this in the final doc as it is just setup.
  - Notice the last one has `, echo=FALSE`. This says evaluate it still and make the plot, but don't show the code chunk used to make the plot.
- Look at the little green arrow in the code chunks. You can click these to run that code. Kind of a cool, game-changing bit about R Markdown.
  - On the top-right, the "Run" button dropdown has further control, allowing you to run the current or multiple chunks.
  - **Command+Enter** (Ctrl+Enter in Windows) with your cursor in the code chunk allows you to run it quickly as well.
  - Next to that button, the "Insert" dropdown allows you to quickly insert a languages code chunk.
- When you are done with your markdown, use the "Knit" button dropdown to run the code and create a pdf, html or word doc with graphs.
  - Be aware this will evaluate and run all your code chunks (unless specifically told not to), so your objects can change as a result of this.
  - Go ahead and knit an html doc from the example markdown to see how it looks. The pdf function will probably not work as requires another package not installed by default.
  - The html may popup, but it will also save to your location or ask you where to save it first. The word doc file will save as well. Check it out.

- This is all we will talk about Markdown/RMarkdown. I mostly won't use it in class to run my code just to keep the displayed area a bit tidier and focused. However, I encourage you as you follow along to make use of it and add your notes as you go around your code chunks.

## Basic R commands - mathematical expressions
- R, in contrast to Unix, works fairly naturally in evaluating numbers. Notice how R behaves with whitespace as well.
```r
5 + 3
5+ 3
5+3
```
- Whitespace is still preferably to have for readability though.
- Order of operations are respected in R:
```
(5 + 3) * 2^3
```
- Clearly, R would be a better choice for mathematical operations than Unix. But, you aren't likely to be doing a ton of math in R and instead will be using all it's functions and functions from other packages. First, let's understand how variables are stored.

## R (variables) objects
The broad term variables we used in our Linux shells which might contain any type of data, may be confusing with mathematical variables in R. Here , these data storage bits are usually referred to as "objects", and there's a big difference with how they are stored in R that we won't get into. I'll try to be consistent, but often use variables == objects.
- Objects can contain any type of information.
  - Here, courses usually go into long part about data types. Don't worry about it for now. We can store just about any data type.
  - Naming (generally, same as in Linux!):
    - Can't start with number: `Data02` = OK, `02Data` = Unacceptable
    - Case-sensitive, Avoid special characters except underscore `_`.
    - Here, `-` cannot be used (ranges), and `.` is somewhat inadvisable by convention but not at all a problem (I still use and prefer them). Mainly use `_` for separation in object naming, or the `.` if you are obstinate like me.
- Value assignment: Use `=` or `<-`(2 characters: less than `<` and dash `-`).
  - You can actually do this in multiple ways, but a very strong conventions has developed which we will use so when you see other documentation it will be consistent.
    - Use the `<-` and refer to the object to set on the left side:
      - `OBJECT.NAME <- VALUE`
```r
total.samp <- 62
asthma.samp <- 33
nonasthma.samp <- total.samp - asthma.samp
```
- Assign the sample type to an object as well.
```r
samp.type <- biopsy
```
- Notice how that errors, looking for the object named "biopsy". In bash shell we used the `$` to delineate when something was a variable but we don't have this special notation in R and everything is assumed to be an object. In order to assure the string 'biopsy' is added to that object we need to encapsulate it in quotes.
```r
samp.type <- "biopsy"
samp.type * total.samp
```
- An error is produced as you might expect due to different object types that can't be multiplied naturally (a number times a text string).
- Objects are shown in the top-right (default) Environment pane. They will be broken down by object type, but these are all just single values.
  - In Environment pain, top-right, change between "List" view and "Grid" view. Notice the "Type" listed for each variable in grid view.
- Objects are stored in a file called ".RData" when you exit your workspace. Will come back to this.
  - Default behavior. I prefer it. Notice it is hidden file in your folder though (starts with a `.`). You can save this manually if you prefer as well. File menu option or Save icon in Environment pane will save your "R workspace". For example, if you need to have multiple workspaces in the same folder. But generally there is benefit to using the default name.
- Let's use some R functions with familiar names to manipulate objects.

## R functions
- Functions take generic /conventional form of: **`FunctionName(OptionalDataInput, Options)`**
  - The options ("arguments" or "parameters") can be many things from text strings to values or other functions! Use the helpfiles!
  - The first value passed to a function is *often* and *by convention* input data if the function takes data input. Notice how the first command we typed did not require any input or options, it just returns your directory: `getwd()`.
  - `,` separates options. Use spaces for readability! These can get very long.
- Help files. Each function has a help file. Accessible by prepending the function with a `?`. Look up help file for `getwd()`.
```r
?getwd
```
- Notice at the top it says "getwd {base}". The {base} denotes which package this function is part of, in this case "base R", or the core of R. Base R is not very useful to most biologists. People tend to think they like R, but really they like the specific packages added onto R, and it is packages that make R really powerful.
- There are some commonly named functions in R that we were familiar with in Linux. `ls` and `rm` work similarly, but on objects instead of files.
- Let's remove unnecessary objects with rm functions. Use tab inside of parentheses to list the options. This is one of simplest but best things about RStudio. It brings up the options available in clickable format with help description.
  - `...` is used as a place holder for "your values here". In this case, the objects to be be removed.
  - Once started typing, tab-autcomplete also functions well in R. Use it frequently as in Linux.
```r
ls()
rm(total.samp)
ls()
```
- Frequently, we will pass the output of a function to an object. R determines the type of object to store it as.
```r
MyProjectPath <- getwd()
MyProjectPath
```
Good, that stored as a "character" or string as you can see in Environment pane. You can also use the `str` function to get the **str**ucture of the data stored.
```r
str(MyProjectPath)
```
- Importantly, functions can be nested. This is similar conceptually as using the pipe `|` in Unix, but structure is very different looking. There are a family of `as.` functions in R that can coerce data into a specified format. Try changing the project path object to a numeric in a single command, by nesting `getwd` inside of `as.numeric`:
```r
MyProjectPath <- as.numeric(getwd())
str(MyProjectPath)
```
- First, notice the **warning**. *Not an error*, so command works okay, but it warns it introduced the "NA" value.
  - R uses "NA" for missing values. Not "n.a.", "N/A", etc. Keep this in mind when constructing or cleaning input metadata tables.
    - As with everything in R it varies wildly depending on the packages you have loaded. So the above statement actually refers to base R and some packages allow things like the "N/A" that comes from excel to be recognized as an "NA".
```r
MyProjectPath
MyProjectPath + asthma.samp
```
- Notice there is no error in this last command. Because we changed MyProjectPath to a numeric vector it evaluates properly. This makes no sense, but illustrates how R will try to evaluate things and that NA is a numeric not a string. Remove the MyProjectPath variable: `rm(MyProjectPath)`.

## R packages
- Through other packages which contain prewritten functions more useful to us will be the main way you'll interact with R.
  - Conceptually similar to how modules were loaded in Linux on CHPC, we load packages in R.
  - As with installed modules, they still must be loaded to be used. In R, the `library()` command does this and we will return to it frequently.
  - Some have been preinstalled based on the "Bioinformatics <version>" we chose when we started RStudio Server.
- Examine the bottom right pane, **Packages** tab. This lists the packages *installed* in this RStudio Server Version.
  - Broken down by **User** and **System** Libraries.
- Get your library paths:
```r
.libPaths()
```
You probably have 3 paths listed, but may have a different number if you've worked in R on CHPC before. You should definitely see that the first one listed points to a path in your home directory. You need a writeable path to install your own packages, and you won't have access to the locations in `/usr/local/lib/R`. This is the root cause of a lot package install problems folks encounter, and will be a minor annoyance to an insurmountable hurdle on your local machines without admin privileges because some base R packages installed there will frequently want to be updated by other packages.

## Accessing elements in a list/array/table in R
- Notice how that command printed a numbered list of paths within quotes? Again, we can nest commands to see what the data structure of such a list is:
```r
str(.libPaths())
```
- There are 3 elements `1:3` in mine, and they are stored as characters: `chr`.
- Looking at the main R package installing function help page (`?install.packages`), shows that by default it will install to our first location in the list of `.libPaths()`.
- Let's retrieve the first location in that list:
```r
.libPaths()[1]
```
- Access element in lists/array/vectors/table with number inside square brackets `[]`. This list of paths is a 1-dimensional character vector.
- R is 1-indexed, meaning it starts at 1 instead of 0. Makes the math more natural, but is actually pretty uncommon in programming language.
- If that's not a path somewhere in your home directory, don't worry about it for now, if it is to your somewhere in your home, then copy that path as well.
- You can also tell from the lib path in your home that you have an install for this version 4.0 of R.
  - R and packages updates VERY frequent
  - You will encounter version difference problems and install issues. We will encounter a couple and discuss as part of objectives of the workshop.

## R Packages - install
- Let's illustrate a simple install by installing or updating the package "tibble".

  - After classmake sure the full **tidyverse** package is installed using the base R installer (Bioconductor has it's own).
  - Tidyverse may well already be installed but let's update it anyways if so.
```
install.packages("tibble")
```
- If asks to install it in a personal library location, you didn't have a location to your home in one of the library paths. This shouldn't be the case on RStudioServer on OnDemand, but if you need to create it do so and then check that this location is created with `libPaths()` function again. It should be in 1 now, but if not you can add it with `.libPaths(new="<Your_Path_Here>")`.
- Tibble is part of the "tidyverse". After class please make sure to install the full tidyverse if it is not already in your list of packages that are installed (`install.packages("tidyverse")`). It takes too long to do in class.
  - The tidyverse is collection of packages actually. Check out its home page: [https://www.tidyverse.org/packages/](https://www.tidyverse.org/packages/)
- Note in our installed System library (bottom-right Pane, "Packages" tab), that we already had a package named tibble, but the version was older.
    - Since we installed it again and we can't write to the systems location it went to our user library location.
- Note possible BioConductor version mismatch warning. Current R is 4.0. Warning is prompting to update, but we'd require R version 4.1 and cannot install this ourselves in RStudioServer through OnDemand.
- Load the currently installed tidyverse package with the `library` function. Remember to use tab-autcomplete for everything! Or, note how you can click the checkbox in RStudio.
```r
library(tidyverse)
```
- Note 2 things when tidyverse loads:
1. Tidyverse loads multiple packages.
2. Tidyverse might have functions that conflict with other packages. Shows `package::function` structure.
   - We can access a function in an *installed* package directly:
    ```r
    > ?stats::filter
    ```
   - This is useful where you need the original that got masked because it had the same name or access direct without loading.

## R Packages with Bioconductor
- Bioconductor is a package repository with biology specific packages. So big and useful it has it's own installer/package manager (which actually just calls the normal `install.packages`). It's already installed with the RStudio Server version we chose. Load it and watch it complain about being .01 version behind.
```r
library(BiocManager)
```
- Now unload it. Use detach function or uncheck box:
  - Why should we generally NOT use the GUI and checking boxes? No documentation.
  - **unload packages**.
```r
detach("package:BiocManager", unload = TRUE)
```
- Let's install one more package we'll use to import the RNAseq data we aligned. We'll do more at end of class, but this will suffice for now as an example.
  - **Booleans**: Notice the "TRUE" statement. This is a boolean (True/False, Yes/No,  1/0). Typically in R, these are written as all caps TRUE/FALSE.
- Check out [Bioconductor page of `tximport` package](http://bioconductor.org/packages/release/bioc/html/tximport.html). They always have this install command you can copy and paste, but notice how it trys to update to latest BiocManager each time. You only need to access BiocManager directly to install this packages. Just use the last command to install:
```
BiocManager::install("tximport")
```
- Notice the message at end "Installation path not writable ...". BiocManager is trying to update all these packages that were already installed in a system path not writeable by you. This will be common on your pathology-IT managed machine as well. You may run into version incompatibilites but mostly this won't cause errors and this is hard to escape entirely given the frequency of updates and many interacting packages. The package still installs correctly though. Test it's install by loading it:
```r
library(tximport)
```
- If problems with install path, explicitly tell it your path by adding `lib=<LIBRARY_PATH>` option to BiocManager::install().
- We will use a couple other packages for differential expression analysis. We'll install them at the end of class so we are ready to go next time.

## Read in data table into R
- Copy metadata table using Terminal to your Project Directory if you have not already.
```bash
$ cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2021/Part3_R_RNAseq/metadata/SraRunTable_RNAseq_BiopsyOnly.txt \
 ~/BioinfWorkshop2021/Part3_R_RNAseq/metadata/
```
There are a number of ways to import tables in R. There are common base R packages you should at least be familiar with because you'll encounter them, and we just installed a few more with the tidyverse. There's also a package to read in excel files directly (`readxl`)! Because we manipulated tables in Linux already, some of the options that might have sounded unfamiliar and confuse new R users, should make a little more sense to you. All the read functions can now be used with a GUI interactively in RStudio. They also print the command so you still get to see how the commands work and can copy the actualy command back to your markdown for documentation.

### Read in data table into R - `base` R fxns
- Base R read functions: In the Environment pane (top right by default), click on the "Import Dataset" button. First choose, "From text (base)". This is accesses the family of "base R" functions.
  1. Browse to the table to import. leave all as defaults, but notice the "Heading", "Separator" and "Row names" options.
  2. Call the new table at the top `table_baseR`. Notice the values by default, especially "Header", "Separator" and "NA" options.
  3. Change The "Row names" option to "First Column" and click OK to import it.

- It should have opened a table view in top left pane by default. If not, double click on the "table_baseR" object in top right to open it for viewing.
- Note how it also printed the command you used exactly at the bottom. You can (and should) copy this back to your markdown for documentation.
- Notice in the table_baseR 2 important things in contrast with an Excel table. The columns each are named, instead of the column heading as a letter and header line in row 1 as you might in an excel doc. This was done by the "Header" option we chose and is almost always how you will want your data in R.
  - Similarly, notice the row names are not numbers, but named samples / features. We accomplished this by changing the "Row Names" option. This is frequently preferred and solidifies the structure of most tables. Feature/samples in rows and observations/variables in columns. They don't have to be ordered like this, but frequently are.

### Read in data table into R - `readr` fxns
- `readr` package read functions: As before import the file with the button in the Environment pane, but choose "From text (readr)":
  1. Browse to file, change table name to `table_readr`.
  2. Change delimiter to tab. Notice how the function name in code on the right changes.
  3. Notice helpful options like ability to change what are input "NA"s.
  4. Notice how column header have drop down next to them
     1. Easily ignore / not read in column / "Only" read in one column.
     2. Notice data types. Change the "Age" column to integer and notice how the code changes. Doubles (anything with decimal) takes up more memory space.
  5. Click OK to import.
- Lots of nice options in readr function, but just be aware what stucture of data you just read in. Use `str` command on both tables to learn about them:
```r
str(table_baseR)
str(table_readr)
```

## Data frames in R
- Notice the baseR table is a data frame.
- Data frames are the most common data format in R you will work with.
  - At their simplest, much like a table you are used to thinking about. However, explicitly allows any type of data in the fields. A strict "table" in R can only have one type (i.e. integers or character strings)
    - As data frames allow ANY type of data in them, that can include other tables so can become nested "tables".

- The table read in by `readr` package turned the table into a "tibble". This is an extension of the data frame concept in the tidyverse.
  - Notice how it adds an entry for the structure of the object that explicitly specifies the data type for each column. This is the most visible difference, but there are other in how the data is stored and handled. Notably, we could have changed these data types to factors as the baseR functions appears to recognize them. Many functions downstream will implicitly do this, so it's nice to keep them just as character strings to start with.
  - Most of the time a tibble will input fine when a data frame is expected.

- `data.table` is another great R package with useful features for table interaction you should be aware of. We won't really use it in this workshop though.

## Accessing data frames
- Again, some of the functions you encountered in Linux are available in R
- Use `head` and `tail` functions to access the tibble (`readr` imported) table.
```r
head(table_readr)
head(table_baseR)
tail(table_readr)
```

- We do have one more column in the table_baseR, but you can still see the tidyverse makes the tibble a little easier to view. Or at least tries to.
- You can use `names()` or `colnames()` to get the column/variable names and `row.names()` to get rows.
```r
names(table_readr)
colnames(table_readr)
row.names(table_readr)
row.names(table_baseR)
```

- The fact that 'names' function does the same as colnames hints at common structure of tables in R. Really expecting names of variables to be in columns, not rows. You can certainly import data in the other way and work with it, but R definitley thinks more along the lines of columns == variables and rows == observations.

- The `summary` function is helpful as well to display more info about a table and even show distribution of data.
```r
summary(table_readr)
```
- Note there are several other functions that came with tidyverse for this type of data summation. We'll stick with base functions where possible though.
- You can transpose tables so easily in R it's hard to find the function: `t`:
```r
table_readr.t <- t(table_readr)
str(table_readr.t)
```

- It is still a tibble, but the structure doesn't make a ton of sense anymore. Remove it with `rm()`.

## Accessing data frames: Variable accession
- Here, we use the same symbol `$` to access the variables/columns as we did in Linux.
  - It's just that the variables are inside an object, so we first refer to the object.
  - Get the variable age from the table:
```r
table_readr$Age
str(table_readr$Age)
```
- Want to access a specific element in that variable? As before, add the square brackets:
```r
table_readr$Age[4]
```

- Data frames are 2 dimensional, so can be described with the same square brackets but with [row,column] notation.
- Let's create a new table removing the extraneous "BioSample" column. We'll pass a list of column numbers, but we could do the same with the quoted names.
```r
table_readr <- table_readr[, c(1,2,3,5,6,7,8,9,10)]
```
- Notice how we could directly overwrite the table_readr in the same function.
  - Very common in R. Think about if you went back and redid this command?

```r
 table_readr <- table_readr[, c(1,2,3,5,6,7,8,9,10)]
```
- Error here because of way we listed all columns.
- However, here's another way to accomplish the same thing (with the other table), using a negative to say NOT this column:
```r
table_baseR <- table_baseR[,-3]
```
- Now, repeat that command. It executes okay, dropping the 3rd column again.
- **Be careful of repeating commands on overwritten data!** When in doubt, save multiple version of your objects / rename them as you go.

- Let's read back in that table now since we messed it up and it is actually our metadata table for the rest of class. **This time call the object "metadata"**. While reading in, change a few things as before:
1. Change "Delimiter" (at the bottom) to "Tab".
2. Make sure "First Row As Names" box is checked.
3. For column "Age", click the arrow drop down and change it to "Integer"
4. In bottom left "Name" field, change the name of the object to import into to: "metadata".


## Saving workspaces and closing Projects in R
- First, save your "workspace". This includes all your objects. 2 ways to do this:
  1. Click "Session" -> "Save Workspace As..", OR in Environment pane, just click the save button. Name it ".RData". You can name it different but this is the default.
  2. Just close your project and exit and RStudio will ask or do it for you by default. This working is dependent on some user settings, so we will cover this next to make sure we are on the same page.
- **Saving your Project**
  - Mainly, the .RData is your project. This with your RMarkdown should be all you need, but using the project files helps maintain your RStudio state with packages loaded and windows.
  - Save your markdown. In that window click save button and name it and place in your project directory.
  - In the top right, choose Project -> Close Project (don't do this quite yet though. If you did reload your project).
    - This may ask to save your .RData file if setup to do so, or it may just save it automatically on exit. Your project is now saved and can be reloaded later.

## RStudio Settings to Check
- There a number of settings and options in RStudio that I encourage you to look through and customize your environment. There are a couple important ones that we talk about though so I have an idea of how your environment is behaving and are just generally useful.
  1. Go to the "Tools" menu and "Global Options".
  2. Go to or stay on the "General" tab
  3. "Save Workspace to Rdata on exit". I recommend putting it as "Ask" or "Always"
  4. "Restore most recently opened project at startup" and "Restore .RData into workspace" go hand-in-hand and it probably makes most sense to keep both checked or neither. Else you can end up loading a different .RData file into a different project. Not a big deal, but probably not ideal behavior either.
- Note you can also set options per Project in the "Project Options" file menu item.

## Install other packages for next time:
- We will try to get out ahead of next class and ensure we are setup and not spending time in class waiting for installs.
  - Note again that installs are permanent and not tied to a project, but may be tied to major versions of R. The package loading (`library()`) is specific to the project.
- Use `c()` to construct a vector or list of values containing the packages to install.
  - We will come back to vectors next class with a better example.
- The first 2 commands just show how a vector looks and is structured. Only the last is important for install.
```r
c("DESeq2", "fishpond", "tximeta", "tidyverse")
str( c("DESeq2", "fishpond", "tximeta", "tidyverse") )
BiocManager::install( c("DESeq2", "fishpond", "tximeta", "tidyverse") )
```
- You'll need to monitor this to say yes to all updates, OR you can just include `ask = FALSE` which, perhaps confusingly, will just update all packages without prompting you.
- Notably, the tidyverse isn't biology specific at all and is normally installed through the standard install.packages command, but again because BiocManager just calls this function it works okay.


# Links
  - R Markdown: [http://rmarkdown.rstudio.com](http://rmarkdown.rstudio.com)
  - **R For Data Science**: *[https://r4ds.had.co.nz/](https://r4ds.had.co.nz/)*
  - **Modern Dive to R and the tidyverse**: *[https://moderndive.com/index.html](https://moderndive.com/index.html)*
  - Google: [google.com](google.com). Seriously. Thee is soooo much out there for R that is excellent and free training. Just start working!
  - Bioconductor FAQ on installing packages: [https://bioconductor.org/help/faq/](https://bioconductor.org/help/faq/)

# Today's New Commands (R)
  - getwd()
  - rm()
  - ls()
