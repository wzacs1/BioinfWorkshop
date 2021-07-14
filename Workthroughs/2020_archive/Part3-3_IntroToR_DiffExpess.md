<!-- TOC -->

- [Main](#main)
  - [Requirement:](#requirement)
  - [Load Project"](#load-project)
  - [Read in metadata table as "tibble"](#read-in-metadata-table-as-tibble)
  - [Accessing data frames (quick review)](#accessing-data-frames-quick-review)
  - [Accessing data frames: Variable accession](#accessing-data-frames-variable-accession)
    - [(aside) Create vectors and lists with c()](#aside-create-vectors-and-lists-with-c)
  - [Accessing data frames: by coordinates](#accessing-data-frames-by-coordinates)
  - [Basic data wrangling with the tidyverse](#basic-data-wrangling-with-the-tidyverse)
    - [The pipe operator](#the-pipe-operator)
    - [Subsetting data with filter and select](#subsetting-data-with-filter-and-select)
      - [Evaluating expressions](#evaluating-expressions)
      - [`filter()`](#filter)
      - [`select()`](#select)
      - [Combine commands to filter and subset in one step](#combine-commands-to-filter-and-subset-in-one-step)
    - [Adding new variables with mutate()](#adding-new-variables-with-mutate)
    - [Joining tables in the tidyverse](#joining-tables-in-the-tidyverse)
  - [Close and save your project and export objects](#close-and-save-your-project-and-export-objects)
  - [Start new Project for our RNAseq analysis](#start-new-project-for-our-rnaseq-analysis)
  - [Install tximeta and fishpond](#install-tximeta-and-fishpond)
  - [R Markdown](#r-markdown)
- [Practice / With Your Own Data](#practice--with-your-own-data)
- [Links](#links)
- [Today's New Commands (R)](#todays-new-commands-r)

<!-- /TOC -->

# Main
**Objectives**:
1. Finish intro to data frames from previous class
2. Introduce data wranging with tidyverse functions.
3. Create metadata tables with full alignment file paths.
4. Introduce R markdown.

## Requirement:
- RStudio Server Interactive App session on lonepeak
- R Packages installed: tidyverse
- Input metadata table. Copy to your 'metadata' directory (if not already done):
`/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/metadata/SraRunTable_RNAseq_BiopsyOnly.txt`

## Load Project"
**Load Project from last class**:
- In the upper right hand corner of RStudio underneath power button, or with `File -> Open Project..`, browse to and open the project file that should be named the same as the Folder "Part3_RStudioIntro.Rproj".
  - *NOTE*: You may not have saved your project and/or workspace because we skipped around last time and didn't get to the end I anticipated, and thus didn't talk about closing and saving projects. This is okay, just create a new project if you somehow didn't save it (RStudio saves these when you close the project, but you may have just closed the server tab).
  - If you did save your workspace and your objects don't load you can load them directly, but change the behavior of RStudio to load the workspace when you load your project. Go to "Tools -> Project options" and change to load .Rdata workspace.

**OR**

**Create a new project** as we did last time:
- If you just didn't save the Rproject, your directory should already be there as should an R project file. If you missed class, you won't have the directory, so choose to either create new project in existing directory or new project in new directory as appropriate.
- Create a project in a directory called "Part3_RStudioIntro". `File -> New Project..`

## Read in metadata table as "tibble"
- We will read in the same table from last time we were reading in. You already did this and should have it as an R object if you loaded your saved R project from last class. Do it again, to ensure we have the same input table in the same format for this class.
- Note that the input file *is purposely in a different directory*! (admittedly, I should have chosen more distinct-sounding directory names). It is easiest if you copy it from the shared space to your local folder. The file is here:
`/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/metadata/SraRunTable_RNAseq_BiopsyOnly.txt`
  - It's easier to reference if you copied it to your metadata directory in *"Part3_R_RNAseq"* directory already.

```r
> library(tidyverse)
```
Use the "readr" function with the button to read in the file (Environment pane -> "Import dataset" -> "From text (readr)"). Remember, this file is not in the same R project directory we are in, but should be in `~/BioinfWorkshop2020/Part3_R_RNAseq/metadata`.

While reading in, change a few things:
1. Change "Delimiter" (at the bottom) to "Tab".
2. Make sure "First Row As Names" box is checked.
3. For column "Age", click the arrow drop down and change it to "Integer"
4. In bottom left "Name" field, change the name of the object to import into to: "metadata".

The readr function should look like this (you **don't** need to enter this)(one command over multiple lines shown here):
```r
> metadata <- read_delim(
    "~/BioinfWorkshop2020/Part3_R_RNAseq/metadata/SraRunTable_RNAseq_BiopsyOnly.txt",
    "\t", escape_double = FALSE, col_types = cols(Age = col_integer()),
    trim_ws = TRUE)
```

## Accessing data frames (quick review)
- Again, some of the funtions you encountered in Linux are available in R
- Use `head` and `tail` functions to access the table.
```r
> head(metadata)
> tail(metadata)
```

- Tidyverse makes the tibble a little easier to view. Or at least tries to.
- You can use `names()` or `colnames()` to get the column/variable names and `row.names()` to get rows.
```
> names(metadata)
> colnames(metadata)
> row.names(metadata)
```

- The fact that 'names' function does the same as colnames hints at common structure of tables in R. Really expecting names of variables to be in columns, not rows. You can certainly import data in the other way and work with it, but R definitley has more of a default expectation as "columns = variables".

- The `summary` function is helpful as well to display more info about a table and even show distribution of data.
```r
> summary(metadata)
```
- Note there are several other functions that came with tidyverse for this type of data summation. We'll stick with base functions where possible.
- You can transpose tables so easily in R it's hard to find the function: `t`:
```r
> metadata.t <- t(metadata)
> str(metadata.t)
```

- It is still a tibble, but the structure doesn't make a ton of sense anymore. Remove it with `rm()`.
```r
> rm(metadata.t)
```

## Accessing data frames: Variable accession
- Here, we use the same symbol `$` to access the variables/columns as we did in Linux.
  - It's just that the variables are inside an object, so we first refer to the object.
  - Get the variable age from the table:
```r
> metadata$Age
> str(metadata$Age)
```
- Want to access a specific element in that 1D *vector*? As before, add the square brackets:
```r
> metadata$Age[4]
```

- However, data frames are 2 dimensional, so can themselves be described with the same square brackets but with [row,column] notation.
- Let's create a new table removing the extraneous "BioSample" column. We'll pass a list of column numbers, but we could do the same with the quoted names.

### (aside) Create vectors and lists with c()
Because we skipped in class the install part that introduced vector construction in R, we will cover it here again briefly using the list of columns as examples and remove the "BioSample" column.
- Vectors are 1 dimensional objects with 1 or more entries. Similar to what you would naturally think of as a "list", but lists in R and other programming languages are a separate, slightly different type of data storage usually.
- We generally use the `c()` function in R to create these vectors.
- Create a list of the column numbers to keep. There are at least 2 ways to accomplish this:
```r
> cols2keep <- c(1,2,3,5,6,7,8,9,10)
> cols2keep <- c(1:3,5:10)
> cols2keep
```
- Notice how we can use the `:` character to specify a range.
- Vectors can contain other types of information (such as character strings), but can hold only 1 type of data. In other words I could also create a list of named columns, but can't mix and match with integers for column numbers.
- We could similarly create a vector of character strings with the c() function.
```r
> cols2keep <- c("Run", "Age", "asthma_status", "LibraryName", "obesity_status", "sex", "smoking_status", "tissue", "replicate")
```

## Accessing data frames: by coordinates
Now let's use our list of columns to keep to remove the 4th column.
- Data frames can be described with the same square brackets notation used for vectors, but with [row, column] notation because they are 2D.
- Pass the vector of columns to keep.
```r
> metadata <- metadata[ , cols2keep]
```
- Notice how we could directly overwrite the metadata table in the same function.
  - Very common in R. Think about if you went back and redid this command? Would it behave as expected?

```r
>  metadata <- metadata[,c(1,2,3,5,6,7,8,9,10)]
```
- Error here because we now have listed a 10th column that does not exist.
- However, here's another way to accomplish the same thing, using a negative to say "REMOVE" this column:
```r
> examp.metadata <- metadata[,-3]
> str(examp.metadata)
```
- Now, repeat that command a couple more times. It executes okay, dropping the 3rd column again.
```r
> examp.metadata <- examp.metadata[,-3]
> str(examp.metadata)
> examp.metadata <- examp.metadata[,-3]
> str(examp.metadata)
> rm(examp.metadatat)
```

- Be careful of repeating commands on overwritten data! When in doubt, save multiple version of your objects / rename them as you go.

## Basic data wrangling with the tidyverse
There is much more we can do with data frames in base R functions, but the tidyverse has a number of similar functions that are more powerful. The tidyverse is so commonly used with data in R, it now seems safe to just use it instead and not spend too much time with the base R functions.

### The pipe operator
The "pipe" operator is introduced as part of one of the packages in tidyverse and acts just like the pipe you saw in Linux (the `|`). However, it uses the 3-character combination symbol: **`%>%`**.
- `%>%`: Pipe symbol in tidyverse. "pipes" output from one function or object to the next.

As a quick example, and to show that you can open and pipe an object (i.e. not just a function's output) read the metadata table and get the column names in 2 different ways
```r
> metadata %>% names()
> names(metadata)
```
Notice how you didn't have to specify the metadata to the names function in the first command. This is behaving as we saw for commands in Linux, where without a specified input, the function takes what was piped to it. In Linux this was called the standard input and it is behaving similarly here.

The most useful thing about the pipe (in my opinion) is that it makes R code much more readable. You can see it is accomplishing the same thing as just nesting functions, but instead of functions within functions within functions, each gets separated by the pipe character making it much more easy for the human eye to parse.

### Subsetting data with filter and select
The `filter()` and `select()` functions in tidyverse are used to subset based on rows and columns/variables respectively. This input dataset contains some samples with biological replicates and some without as you've probably noticed. In addition, a few of the samples listed as biological replicates actually don't have pairs of replicates. Let's make 2 datasets to examine with differential expression analysis later.
1. Samples with replicates only (Input table to create: `metadata_repsOnly`):
2. All indivduals but only 1 replicate: (Input table to create: `metadata_singleSamp`)

#### Evaluating expressions
A number of functions built in can be used to evaluate the conditions of your filter. Here are some of the most commonly used:
- `==`: Equality. Important to understand this is different than a single `=`. Usually, you would want to use the double `==` to evaluate if a string IS in the searched space.
- `>`, `>=`, etc.: Self-explanatory
- `!=`: IS **NOT**. The `!` is common across languages as a symobl for "not"
- `&`: And
- `|`: OR
- `is.na()`: Evaluates if the value is missing "NA".

#### `filter()`
Using the full metadata table, let's first remove a few samples from this full dataset which did not contain any replicates.
```r
> filter(metadata, Run != "SRR10571716" & Run != "SRR10571713" & Run != "SRR10571682")
```

Notice how the values to look for are in quotes, but the column/variable name does not have to be when using tidyverse functions.

We didn't assign this to a new object yet, because we aren't done filtering. We are building up a single filter function. But, it's also not a bad idea to do this with your commands to make sure they are working as expected first.
Now, add another filter to remove those that never had a replicate to begin with ("NA" in the "replicate" column) and create our new table. First, use the is.na() function by itself to see how it behaves:

```r
> is.na(metadata$replicate)
```
Notice how this function returns true or false values for each position, asking if it is NA. Since filtering works on determining TRUE criteria, and we won't those that are not NA (i.e. FALSE), we want the opposite of this result. Now, add this into your function to do the table filtering and assign it to a new object.:

```r
> metadata_repsOnly <- filter(metadata,
 Run != "SRR10571716" & Run != "SRR10571713" & Run != "SRR10571682" &
 is.na(replicate) == FALSE)
```
- Can you think of another way to do this with the `!` symbol?

#### `select()`
Selects works pretty naturally as you might expect, and in the term hints to SQL terminology usage. We could use the same data table accession coordinates we showed earlier, but select has as very common type of syntax derived from SQL that is great for working with tales and is similar to how qiime2 filters out data. As an intial simple example, let's just get rid of the extra columns "replicate" and "tissue" which are the same for all samples now. We'll use the `-` in front of the varialbe to remove, which is commonly used in R notation to remove something, but in this case we could have also used the `!`.

```r
> metadata_repsOnly <- select(metadata_repsOnly, -replicate & -tissue)
```
Pretty straightforward as you might expect. Usually you will be passing simpler criteria to select than to filter().

#### Combine commands to filter and subset in one step
Now, to reinforce the commands we just covered let's create the second table (`metadata_singleSamp`) in one step along with pipes. For this group of samples we want to:
1. Use only samples with a single sample or replicate 1
2. Remove the tissue and replicate columns

```r
> metadata_singleSamp <- metadata %>%
  filter(replicate == "biological replicate 1" | is.na(replicate)) %>%
  select(-replicate & -tissue)
```

### Adding new variables with mutate()
The `mutate()` function "mutates" the input tibble data frame to add a new variable/column you specify. At first glance that may seem simple and something you can do with base R functions (which of course you can). However, mutate is applying a function row-by-row so is often a simpler way to add new variables that were calculated from one or more existing variables.

For our RNAseq analysis, we will first have to know where the alignment files are for each sample to read in to R. It's a good opportunity to illustrate the mutate command and a couple other useful base R commands. Let's create a new object that lists *ALL* the alignment file locations, using the original metadata object. I'll list the path to the shared directory I created that has them all, but you can change it to your directory if you created them as well.

First, create an object with the path to the directory with the alignments (make sure there's not a trailing `/` at the end):
```r
> ShareDir <- "/uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part3_R_RNAseq/BiopsyOnly"
```

1. Create a new tibble dataframe with the Run ID as the first (and only at this point) column. We name the column as we create it.
```r
> align_paths <- tibble(Run = metadata$Run)
```
2. Use mutate to add the shared directory filepath as a new variable. Also, add the filename "quant.sf" which is in each sample's directory as a variable.
```r
> align_paths <- mutate(align_paths, shared_dir = ShareDir, quant_file = "quant.sf")
```
   - Notice how mutate naturally adds entries for the number of rows. Seems obvious, but with base R you'd need to specify how many and replicate them and they must align. Mutate is remarkably flexibile and helpful for doing something iteratively across rows.

3. Use mutate to add the Run/Sample-specific folder name.
Salmon output results into a folder for each RNAseq sample (or Run as it's called in our metadata table). So, we have a folder that is named something like: `SRRXXXXXX_salm_quant` for each result (where XXXXXX is the SRA accession number).
The `paste()` function is frequently useful to join strings together to create a longer string. Here, we will use it twice to first create the folder name for each sample, then use it again to join it with the ShareDir path where all these folders are.
- `paste()`: Joins/pastes character strings together with a specified delimiter
```r
> align_paths <- mutate(align_paths, samp_dir = paste(align_paths$Run, "salm_quant", sep = "_"))
```
Notice how we specified the delimiter to use which puts the underscore `_` in between the items pasted together.

4. Now, join the 3 columns with the direcotry separator forward-slash as the delimiter, to create a full file path for each sample's quant.sf file, and retain only the 2 columns we need.
```r
> align_paths <- mutate(align_paths, fullpath =
  paste(align_paths$shared_dir, align_paths$samp_dir,
    align_paths$quant_file, sep = "/"))
  %>% select(Run, fullpath)
```

### Joining tables in the tidyverse
Joining tables is a common task which comes with all sorts of potentially confusing terminology that comes from SQL syntax. There are all kinds of 'joins': "inner_join", "outer_join", "left_join", etc. We will keep it simple and show one type here, but I encourage you to look into this further as well for more complicated tasks. The base R function these generally replace is "merge", which is actually pretty simple, but using the "join" family of functions opens a lot of tunable options.

We have a separate object in R that has all our file paths of all the samples, but we have 2 different subsets of samples. We want to add just the filepaths of our subsets from the tibble with all the samples to each subset table. Because both our tables have "Run" in the first column, this function will join them naturally as you would expect by "Run". It's worth noting though that this isn't a requirement and you can specify different columns to join on and how to behave with extra/missing rows in one table. See the help file for any of the "join" functions in tidyverse. In order to drop rows that are not present in the smaller 'metadata_repsOnly' and 'metadata_singleSamp' we will use a "left_join". Note how you could accomplish this with a different type of join while adding appropriate options.

```r
> metadata_repsOnly <- left_join(metadata_repsOnly, align_paths)
> metadata_singleSamp <- left_join(metadata_singleSamp, align_paths)
```

Pretty straightforward commands. This isn't a great example of how powerful these joining methods are, but rather what they are intended to accomplish. I very much encourage you to look at their help files and/or furhter into join functions (for example, in the very good "Modern Dive" tutorial that is linked to in the links section.)

## Close and save your project and export objects
RStudio saves the project when you close it as well as prompting for a workspace location to save. It will also prompt to save any markdown or other text files you have open but have not yet saved. Thus, just closing projects is the recommended way to save, but at the least you need to make sure you save your workspace. You can change if RStudio asks to save workspace or not in the global options, or if it just saves it by default. I suggest you leave it to "ask" or just save it to .Rdata by default, but don't change to "never".

We can also export just specific objects in R. Not usually a good idea because this disconnects them from the project, but certainly you should know how to do it. `saveRDS()` saves an external (exteranl to R) file of an object, while `save()` saves the full workspace. Let's save our new table as objects:
```r
saveRDS(metadata_repsOnly, file = "metadata_repsOnly.rds")
saveRDS(metadata_singleSamp, file = "metadata_singleSamp.rds")
```

## Start new Project for our RNAseq analysis
- Our previous project for intro to R was in "Part3_RStudioIntro" directory. We kept it in a separate folder to maintain our project-centric organization and to show you could create a new project in a new directory
- Now, make a new project in an existing directory: "**Part3_R_RNAseq**". This is where we started our RNAseq project with read alignments and you may have been able to get the alignment outputs here. Don't worry if you don't have read alignments here yet, I'll have you copy over mine to follow along.

## Install tximeta and fishpond
Let's get these installing while we discuss R markdown briefly and we will be ready to go with RNAseq analsyis at beginning of next session.

```bash
> BiocManager::install(c("fishpond","tximeta"))
> library(tximeta)
```

## R Markdown
Before we go any further, let's introduce R's special type of markdown for documentation. 

R markdown generally uses the same syntax as we saw for standard markdown, but incorporating it into the RStudio environment allows us to interact with the markdown and run our code directly within it.

1. Open a new markdown document. `File -> New File -> R Markdown ...`
   - Give it the name "Biopsy_RNAseq_Analysis" (or whatever you like really) and put your name in it, but otherwise leave defaults.
   - R may ask to install some packages if this is the first markdown you've created. Allow it to do so.
2. Notice in the new markdown a few things
   - R creates some example code for you to show the syntax again. You can delete all this, but keep the first chunk that contains "r setup".
   - As before, `#` denote heading/section levels. One `#` is top level/largest heading.
   - As before, 3 backticks (same keyboard key as `~`), starts a code chunk over multiple lines and 3 backticks ends the code chunk.
   - Specify the language/program to interpret and highlight a code chunk by adding the name in curly braces after the first 3 backticks. `{r}`
     - Rmarkdown will actually interpret these, so this is important.
     - Use the button at the of markdown to insert an R code chunk. `Insert -> R`
   - Options can be added to each R code chunk by adding a comma after the R in curly brackets.
     - Add comma then hit tab to see complete list pop up.
     - `echo = FALSE`: Don't print R's output to the page.
     - `eval = FALSE`: Don't evaluate the R commands. Useful if you just want to show some chunk, but not perform operations on it.
3. You can run code directly from the markdown!
  - Imagine this as a fully contained script that should be able to run through each chunk and produce all your output including graphs.
    - Reproduce your original code used to create the full metadata files (use R history from previous project, or just copy the commands here) and add it to code chunks in markdown.
  - Use the "Run" menu (in markdown pane at top) to run each chunk and get your input metadata object. Ctrl + Enter is handy to run the current chunk.
  - Add notes around your code.
4. Save your markdown file.
  - Use the save icon in markdown window.
  - Name it whatever you like (I'd call it similar to named in first step: "Biopsy_RNAseq_Analysis") and save it in your project directory. RStudio will add the ".Rmd" file extension for you.
  - Note this code will run from this directory. Relevant, for example, when importing files.

Now, use the markdown file to input code, run it and add natural language notes around it. Remember a few basic markdown formatting is all you need:
- Use dash/hyphen `-` to create bulleted lists.
- Use numbers ot autocreate lists
- Use `**` surrounding text to **bold**
- Use `*` surrounding text to *italicize*

# Practice / With Your Own Data
- Task: We did some subsetting of tables and such in our RStudioIntro project in order to introduce those commands. But we also want to use these tables in our real analysis. Add all the commands we used that are required to create the subsetted tables with full paths to your R markdown document in your "Part3_R_RNAseq" directory. We will do the rest of analysis here.
- Create a metadata table with file paths for your own alignment data. Likely doesn't matter what alignment method you used, tximeta can handle multiple different kinds (but check out it's documentation if unsure).

# Links
  - **R For Data Science**: *[https://r4ds.had.co.nz/](https://r4ds.had.co.nz/)*
  - **Modern Dive to R and the tidyverse**: *[https://moderndive.com/index.html](https://moderndive.com/index.html)*
  - Google: [google.com](google.com). Seriously, so much out there for R that is excellent and free training. Just start working!
  - Bioconductor FAQ on installing packages: [https://bioconductor.org/help/faq/](https://bioconductor.org/help/faq/)

# Today's New Commands (R)
- `%>%`: Pipe symbol in tidyverse. "pipes" output from one function or object to the next.
- `c()`: Construct vectors or lists. Each item separated by commas.
- `paste()`: Join strings with a specified delimiter in betweeen them.
- `filter()`: (tidyverse). Filter out rows based on criteria.
- `select()`: (tidyverse). Filter out columns based on lists or criteria.
- `mutate()`: (tidyverse). Add and construnct a new variable/column and add to data frame.
- `saveRDS()`: Save a single R object to a file.
- `left_join()`: (tidyverse). Join table y to table x, removing extra values in y that are not in x (left join specific)
- `is.na()`: Check for "NA" in entries. Return a logical.
