<!-- TOC -->

- [Requirements](#requirements)
- [Objectives](#objectives)
- [Start RStudio Server Interactive App on OnDemand](#start-rstudio-server-interactive-app-on-ondemand)
- [The RStudio Interface Overview](#the-rstudio-interface-overview)
- [RStudio options](#rstudio-options)
- [RStudio Projects](#rstudio-projects)
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
- [Links](#links)
- [Today's New Commands (R)](#todays-new-commands-r)

<!-- /TOC -->

# Requirements
- CHPC account and OnDemand login
- (optional) RStudio installed on desktop/laptop
- Copy metadata table for full Biopsy Sample RNAseq
```bash
$ cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/metadata/SraRunTable_RNAseq_BiopsyOnly.txt \
 ~/BioinfWorkshop2020/Part3_R_RNAseq/metadata/
```

# Objectives
1. Start RStudio server on CHPC through OnDemand interface.
2. Overview of RStudio interface
3. Basic R usage and functions
4. Understand packages, install locations
5. Read in data table and intro tidyverse

# Start RStudio Server Interactive App on OnDemand
- On CHPC OnDemand main page after login:
  - "Interactive Apps" -> "RStudio Server on Lonepeak"
- Fill in options as you have for srun command.
  - R version: R 3.6.2 Bioinformatics packages
  - Number of cores: 2
  - Number of hours: 2
  - Memory per job: default
  - Account and Reservation: MIB2020
  - Partition: lonepeak-shared
- Wait for page to refresh and "Connect to RStudio Server" button to come up.
- This starts RStudio on CHPC. It will be nearly identical to how it looks on Desktop App, which you can use if this isn't working for you or are outside of class time.

# The RStudio Interface Overview
- RStudio is an IDE: Integrated Development Environment
- Default Panes:
  - Left (or bottom left): The R console. Where you type R commands. This is the core of R which the rest of RStudio panels facilitate.
    - Notice your current path printed at the top, right under "Console"
    - Notice "Terminal" tab next to console.
      - We can do some basic linux commands here.
  - Bottom Right: Help, Plots, Files and Install
    - Note file listing in your current location
    - Will return to the others in more detail.
  - Top Right: Environment, History
    - Environment shows all your variables.
- Each pain can be minimized/max with button on top right window icons.
- Top Right corner: Shutdown button stops session, but not server. Need to delete that on OnDemand page to end.
- In left pane with Console, click double window icon if present to add another pane above it.
- In this pane, we usually have a markdown or other text document open to document.
  - Open a new Rmarkdown document. File -> New

# RStudio options
A few key options to be aware of in RStudio.
- Tools --> Global Options
  - On general page, change behavior of RStudio on startup as desired.
    - You may want to uncheck the "Restore ..." options. Personal preference, but leave for now.
  - On Terminal page, change shell if you prefer/are using other than bash.
  - Pane layouts tab to change arrangment.

# RStudio Projects
I've tried to have you work with a "project-centric" mindset in this workshop so far, where a given directory contains all the data and code needed for a project. As you've seen with very large seq files this isn't usually entirely possible. In RStudio the project mindset is solidified and there are special files to help define a project. RStudio is made with the expectation of a project, but does not actually require it.
- The Project file helps organize your project and connect the variables, history, required packages and opened source or documentation files.
- Start a new Project for today
  1. Upper right hand corner (or menu): "Project --> New Project.."
  2. Start a project in New Project Directory.
  3. New Project
  4. Browse to `~/BioinfWorkshop2020`
  5. Name new folder: "Part3_RStudioIntro".
  6. Click OK, RStudio opens new project.
- In new project, note your path at top of Console.
  - Type command `getwd()` into console as well and hit enter. The R equivalent of `pwd`.
  - Click on File pane. Note the only thing in the directory is your new R Project file called "Part3_RStudioIntro.Rproj"
    - The R project file can be clicked on (in Desktop/Laptop) to start RStudio and load project directly.

# Basic R commands - mathematical expressions
- R, in contrast to Unix, works fairly naturally in evaluating numbers. Notice how R behaves with whitespace as well.
```r
> 5 + 3
> 5+ 3
> 5+3
```
- Whitespace is still nice to have for readability though.
- Order of operations are respected in R:
```
> (5 + 3) * 2^3
```
- Clearly, R would be a better choice for mathematical operations than Unix. But, you aren't likely to be doing a ton of math in R and instead will be using all it's functions and functions from other packages. First, let's understand how variables are stored.

# R (variables) objects
The broad term variables we used in our Linux shells which might contain any type of data, may be confusing with mathematical variables in stats and R. Here , these data storage bits are usually referred to as "objects". I'll try to be consistent, but often use variables == objects.
- Objects can contain any type of information.
  - Here, courses usually go into long part about data types. Don't worry about it for now. We can store just about any data type.
  - Naming (generally, same as in Unix!):
    - Can't start with number: `Data02` = OK, `02Data` = Unacceptable
    - Case-sensitive, Avoid special characters except underscore `_`.
    - Here, `-` cannot be used (ranges), and `.` is somewhat inadvisable (I still use them). Mainly use `_` for separation in object naming.
- Value assignment: Use `=` or `<-` (preferred convention in R).
```r
> total.samp <- 62
> asthma.samp <- 33
> nonasthma.samp <- total.samp - asthma.samp
```
- Assign the sample type to an object as well.
```r
> samp.type <- biopsy
```
- Notice how that errors, looking for the object named "biopsy". In bash shell we used the `$` to delineate when something was a variable but we don't have this special notation in R. In order to assure the string 'biopsy' is added to that variable we need to encapsulate it in quotes.
```r
> samp.type <- "biopsy"
> samp.type * total.samp
```
- An error is produced as you might expect due to different object types that can't be multiplied.
- Objects are shown in the top-right (default) Environment pane. They will be broken down by object type, but these are all just single values.
  - In Environment pain, top-right, change between "List" view and "Grid" view. Notice the "Type" listed for each variable in grid view.
- Objects are stored in a file called ".Rdata" when you exit your workspace.
  - Default behavior. I prefer it. Notice it is hidden file in your folder though (starts with .). You can save this manually if you prefer as well. File menu option or Save icon in Environment pane will save your "R workspace".
- Let's use some R functions with familiar names to manipulate objects.

# R functions
- Functions take generic /conventional form of: **`FunctionName(OptionalDataInput, Options)`**
  - The options ("arguments" or "parameters") can be many things from text strings to values or other functions! Use the helpfiles!
  - The first value passed to a function is *often* and *by convention* input data if the function takes data input. Notice how the first command we typed did not require any input or options, it just returns your directory: `getwd()`.
  - `,` separates options. Use spaces for readability.
- Help files. Each function has a help file. Accessible by prepending the function with a `?`. Look up help file for `getwd()`.
```r
?getwd
```
- Notice at the top it says "getwd {base}". The {base} denotes which package this function is part of, in this case "base R", or the core of R.
- There are some commonly named functions in R that we were familiar with in Linux. `ls` and `rm` work similarly, but on objects instead of files.
- Let's remove unnecessary objects with rm functions. Use tab inside of parenthese to list the options. This is one of simplest but best things about RStudio. It brings up the options available in clickalbe format with help description.
  - `...` is used as a place holder for "your values here". In this case, the objects to be be removed.
```r
> ls()
> rm(total.samp)
> ls()
```
- Frequently, we will pass the ouput of a function to an object. R determines the type of object to store it as.
```r
> MyProjectPath <- getwd()
> MyProjectPath
```
Good, that stored as a "character" or string as you can see in Environment pane. You can also use the `str` function to get the **str**ucture of the data stored.
```r
> str(MyProjectPath)
```
- Importantly, functions can be nested. This is similar conceptually as using the pipe `|` in Unix, but structure is very different looking. There are a family of `as.` functions in R that can coerce data into a specified format. Try changing the project path object to a numeric in a single command, by nesting `getwd` inside of `as.numeric`:
```r
> MyProjectPath <- as.numeric(getwd())
> str(MyProjectPath)
```
- First, notice the warning. Not an error, so command works okay, but it warns it introduced the "NA" value.
  - R uses "NA" for missing values. Not "n.a.", "N/A", etc. Keep this in mind when constructing or cleaning input metadata tables.
```r
> MyProjectPath
> MyProjectPath + asthma.samp
```
- Notice there is no error in this last command. Because we changed MyProjectPath to a numeric vector it evaluates properly. This makes no sense. Remove the MyProjectPath variable: `rm(MyProjectPath)`.

# R packages
- Through other packages which contain prewritten functions more useful to us will be the main way you'll interact with R.
  - Conceptually similar to how modules were loaded in Linux on CHPC, we load packages in R.
  - Some have been preinstalled based on the "Bioinformatics <version>" we chose when we started RStudio Server.
- Examine the bottom right pane, **Packages** tab. This lists the packages *installed* in this RStudio Server Version.
  - Broken down by **User** and **System** Libraries.
- Get your library paths:
```r
> .libPaths()
```
You probably have 3 paths listed, but may have a different number if you've worked in R on CHPC before. You should definitely see that the first one listed points to a path in your home directory. You need a writeable path to install your own packages, and you won't have access to the locations in `/usr/local/lib/R`. This is ther root cause of a lot package install problems folks encounter, and will be a minor annoyance to an overcomable hurdle on your local machines without admin privileges because some base R packages installed there will frequently want to be updated by other packages.

## Accessing elements in a list/array/table in R
- Notice how that command printed a numbered list of paths within quotes? Again, we can nest commands to see what the data structure of such a list is:
```r
> str(.libPaths())
```
- There are 3 elements `1:3` in mine, and they are stored as characters: `chr`.
- Looking at the main R package installing function help page (`?install.packages`), shows that by default it will install to our first location in the list of `.libPaths()`.
- Let's retrieve the first location in that list:
```r
> .libPaths()[1]
```
- Access element in lists/array/vectors/table with number inside square brackets `[]`. This list of paths is a 1-dimensional character vector.
- R is 1-indexed.
- If that's not a path somewhere in your home directory, don't worry about it for now, if it is to your somewhere in your home, then copy that path as well.
- You can also tell from the lib path in your home that you have an install for this version 3.6 of R.
  - R and packages updates VERY frequent
  - You will encounter version difference problems and install issues. We will encounter a couple and discuss as part of objectives of the workshop.

# R Packages - install
- Let's make sure the full **tidyverse** package is installed using the base R installer (Bioconductor has it's own).
```
> install.packages("tidyverse")
```
- If asks to install it in a personal library location, you didn't have a location to your home in one of the library paths. This shouldn't be the case on RStudioServer on OnDemand, but if you need to create it do so and then check that this location is created with `libPaths()` function again. It should be in 1 now, but if not you can add it with `.libPaths(new="<Your_Path_Here>")`.
- Will take a bit to install. Tidyverse is collection of packages actually. Check out its home page: [https://www.tidyverse.org/packages/](https://www.tidyverse.org/packages/)
  - Note in our installed System library (bottom-right Pane, "Packages" tab), that we already have a package named tibble.
    - Notice at the end how the tidyvere install will install tibble again in our home (writable) location.
- Note possible BioConductor version mismatch warning. Current R is 4.0. Warning is prompting to update, but we'd require R version 4.0
- Load the newly installed package with the `library` function. Remember to use tab-autcomplete for everything! Or, note how you can click the checkbox in RStudio.
```r
> library(tidyverse)
```
- Note 2 things when tidyverse loads:
1. Tidyverse loads multiple packages.
2. Tidyverse might have functions that conflict with other packages. Shows `package::function` structure.
   - We can access a function in an *installed* package directly:
    ```r
    > ?stats::filter
    ```
   - This is useful where you need the original that got masked or access direct without loading.

# R Packages with Bioconductor
- Bioconductor is a package repository with biology specific packages. So big and useful it has it's own installer/package manager. It's already installed with the RStudio Server version we chose. Load it and watch it complain about being .01 version behind.
```
> library(BiocManager)
```
- Now unload it. Uncheck box or use detach function:
```r
> detach("package:BiocManager", unload = TRUE)
```
- Let's install a couple packages we'll use to understand the RNAseq data we aligned.
- Check out [Bioconductor page of `tximport` package](http://bioconductor.org/packages/release/bioc/html/tximport.html). They always have this install command you can copy and paste, but notice how it trys to update to latest BiocManager each time. You only need to access BiocManager directly to install this packages. Just use the last command to install:
```
> BiocManager::install("tximport")
```
- Notice the message at end "Installation path not writable ...". BiocManager is trying to update all these packages that were already installed in a system path not writeable by you. This will be common on your pathology-IT managed machine as well. You may run into version incompatibilites but mostly this won't cause errors and this is hard to escape entirely given the frequency of updates and many interacting packages. The package still installs correctly though. Test it's install by loading it:
```r
> library(tximport)
```
- We will 2 other packages for differential expression analysis. Let's install them both by providing a list to the BiocManager.
  - Use `c()` to construct a vector or list of values.
```r
> c("DESeq2", "swish")
> str(c("DESeq2", "swish"))
> BiocManager::install(c("DESeq2", "swish"))
```
- That may take a bit as well, but should install okay. If problems with install path, explicitly tell it your path by adding `` option to BiocManager::install().
- Both these packages have a number of other package dependencies they need to install as well likely. But many of them are very common dependancies of other bioinformatics packages so once they are installed others will install faster as well.

# Read in data table into R
- Copy metadata table using Terminal to your Project Directory if you have not already.
```bash
$ cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/metadata/SraRunTable_RNAseq_BiopsyOnly.txt \
 ~/BioinfWorkshop2020/Part3_R_RNAseq/metadata/
```
There are a number of ways to import tables in R. There are common base R packages you should at least be familiar with because you'll encounter them, and we just installed a few more with the tidyverse. There's also a package to read in excel files directly (`readxl`)! Because we manipulated tables in Linux already, some of the options that might have sounded unfamiliar and confuse new R users, should make a little more sense to you. All the read functions can now be used with a GUI interactively in RStudio. They also print the command so you still get to see how the commands work.

## Read in data table into R - `base` R fxns
- Base R read functions: In the Environment pane (top right by default), click on the "Import Dataset" button. First choose, "From text (base)". This is accesses the family of "base R" functions.
  1. Browse to the table to import. leave all as defaults, but notice the "Heading", "Separator" and "Row names" options.
  2. Call the new table at the top `table_baseR`. Notice the values by default, especially "Header", "Separator" and "NA" options.
  3. Change The "Row names" option to "First Column" and click OK to import it.

- It should have opened a table view in top left pane by default. If not, double click on the "table_baseR" object in top right to open it for viewing.
- Note how it also printed the command you used exactly at the bottom.
- Notice in the table_baseR 2 important things in contrast with an Excel table. The columns each are named, instead of the column heading as a letter and header line in row 1 as you might in an excel doc. This was done by the "Header" option we chose and is almost always how you will want your data in R.
  - Similarly, notice the row names are not numbers, but named samples / features. We accomplished this by changing the "Row Names" option. This is frequently preferred and solidifies the structure of most tables. Feature/samples in rows and observations/variables in columns. They don't have to be ordered like this, but usually are.

## Read in data table into R - `readr` fxns
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
> str(table_baseR)
> str(table_readr)
```


# Data frames in R
- Notice the baseR table is a data frame.
- Data frames are the most common data format in R you will work with.
  - Much like a table you are used to thinking about, but explicitly allows any type of data in the fields. A strict "table" can only have one type (i.e. integers or character strings)

- The table read in by `readr` package turned the table into a "tibble". This is an extension of the data frame concept in the tidyverse.
  - Notice how it adds an entry for the structure of the object that explicitly specifies the data type for each column. This is the most visible difference, but there are other in how the data is stored and handled. Notably, we could have changed these data types to factors as the baseR functions appears to recognize them. Many functions downstream will implicitly do this, so it's nice to keep them just as character strings to start with.


# Accessing data frames
- Again, some of the functions you encountered in Linux are available in R
- Use `head` and `tail` functions to access the tibble (`readr` imported) table.
```r
> head(table_readr)
> head(table_baseR)
> tail(table_readr)
```

- We do have one more column in the table_baseR, but you can still see the tidyverse makes the tibble a little easier to view. Or at least tries to.
- You can use `names()` or `colnames()` to get the column/variable names and `row.names()` to get rows.
```
> names(table_readr)
> colnames(table_readr)
> row.names(table_readr)
> row.names(table_baseR)
```

- The fact that 'names' function does the same as colnames hints at common structure of tables in R. Really expecting names of variables to be in columns, not rows. You can certainly import data in the other way and work with it, but R definitley thinks more columns = variables.

- The `summary` function is helpful as well to display more info about a table and even show distribution of data.
```r
> summary(table_readr)
```
- Note there are several other functions that came with tidyverse for this type of data summation. We'll stick with base functions where possible.
- You can transpose tables so easily in R it's hard to find the function: `t`:
```r
> table_readr.t <- t(table_readr)
> str(table_readr.t)
```

- It is still a tibble, but the structure doesn't make a ton of sense anymore. Remove it with `rm()`.

# Accessing data frames: Variable accession
- Here, we use the same symbol `$` to access the variables/columns as we did in Linux.
  - It's just that the variables are inside an object, so we first refer to the object.
  - Get the variable age from the table:
```r
> table_readr$Age
> str(table_readr$Age)
```
- Want to access a specific element in that variable? As before, add the square brackets:
```r
> table_readr$Age[4]
```

- Data frames are 2 dimensional, so can be described with the same square brackets but with [row,column] notation.
- Let's create a new table removing the extraneous "BioSample" column. We'll pass a list of column numbers, but we could do the same with the quoted names.
```r
> table_readr <- table_readr[,c(1,2,3,5,6,7,8,9,10)]
```
- Notice how we could directly overwrite the table_readr in the same function.
  - Very common in R. Think about if you went back and redid this command?

```r
>  table_readr <- table_readr[,c(1,2,3,5,6,7,8,9,10)]
```
- Error here because of way we listed all columns.
- However, here's another way to accomplish the same thing (with the other table), using a negative to say NOT this column:
```r
> table_baseR <- table_baseR[,-3]
```
- Now, repeat that command. It executes okay, dropping the 3rd column again.
- Be careful of repeating commands on overwritten data! When in doubt, save multiple version of your objects / rename them as you go.

# Links
  - **R For Data Science**: *[https://r4ds.had.co.nz/](https://r4ds.had.co.nz/)*
  - **Modern Dive to R and the tidyverse**: *[https://moderndive.com/index.html](https://moderndive.com/index.html)*
  - Google: [google.com](google.com). Seriously, so much out there for R that is excellent and free training. Just start working!
  - Bioconductor FAQ on installing packages: [https://bioconductor.org/help/faq/](https://bioconductor.org/help/faq/)

# Today's New Commands (R)
  - getwd()
  - rm()
  - ls()
