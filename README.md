# About Mutplot
### Mutplot is an easy-to-use online tool for plotting complex mutation data with flexibility.

# Support file format

**The current verson works for txt and cvs formats.**

**The required columns are Hugo_Symbol, Sample_ID, Protein_Change, and Mutation_Type.**

**An example named exampleforuploading.txt can be downloaded.**

# Run the program through web page

**Step1: go to https://bioinformaticstools.shinyapps.io/lollipop/**

**Step2: browse your local computer to upload a tab/comma-delimited input (an example named exampleforuploading.txt can be downloaded from this website. It is the same as the supporting information S1 Table from the paper)**

**Step3: select “Header” if the uploaded input file has headers (if you use exampleforuploading.txt, select “Header”)**

**Step4: select “Tab” or “Comma” in “Separator” session depends on the uploaded input file (if you use exampleforuploading.txt, select “Tab”)**

**Step5: select a gene name in “Gene” session (if you use exampleforuploading.txt, select “TP53”)**

**Step6: select a number in “Amino acid frequency threshold for highlight” session (if you use exampleforuploading.txt, select “1”)**

**Step7: select a format in “Image file figure format” session**

**Step8: click “Download Plot”**

**Step9: if you want to download the domain information used in the plot, click “Download Domain”. if you want to download the subsetted data used in the plot, click "Download Data"**

# Run the app in local computer.

**Step1: install R, and packages shiny, ggplot2, plyr, httr, drawProteins, ggrepel.**

**Step2: save the source code as R scripts (ui.R and server.R) in a directory.**

**Step3: save the UniProt.txt in the same directory.**

**Step4: launch the app in R using runApp("the path of the directory").**

# New versions

**Please read the release notes**

# Citation

**Zhang W, Wang C, Zhang X.**
**Mutplot: an easy-to-use online tool for plotting complex mutation data with flexibility**
**PLoS One PMID:31091262**
