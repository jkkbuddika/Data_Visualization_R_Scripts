"
This R script computes rpkm and cpm values using Bioconductor edgeR package.
Read: https://bioconductor.org/packages/release/bioc/html/edgeR.html
Read the manual for additional customizations.
The script assumes that the edgeR library is already installed.

Input data file must be an output generated by featureCounts in .csv format and contain Geneid column, gene length column and read counts in subsequent columns.
Make sure the column names of datasets are simplified by removing the path.
In addtion to the input .csv file, exclude_genes.csv must be in the working directory. 
This file contains gene names of rRNAs, tRNAs, snRNAs, snoRNAs, noncoding RNAs and pseudogenes to be removed from the input .csv file.
Generate this in Biomart and download. You can download this file from here: http://useast.ensembl.org/biomart/martview/c6302ce2e0fe429f2a07e28c205c2828
Column name of the gene names column must be 'Geneid'.

Output cpm.csv and rpkm.csv files will be saved to the working directory.
"

#### Loading required libraries -------------
library(edgeR)

#### Setting up the working environment -------------

## Set-up the working directory.
working_dir <- "/path/to/working/directory/"      ## This path should contain the input file. Ex: gene.csv
setwd(working_dir)

#### Data import and preprocessing -------------

## Import data from FeatureCounts output files.
countdata <- read.csv("gene.csv", header=TRUE, sep = ",")
colnames(countdata)

## To remove rRNA/tRNA/noncoding/pseudogenes
exclude_genes <- read.csv("exclude_genes.csv", header=TRUE, sep = ",")
colnames(exclude_genes)
countdata <- anti_join(countdata, exclude_genes, by = "Geneid")
head(countdata)

## Convert gene length to numeric and transpose
geneLength <- as.numeric(countdata$Length)
geneLength <- t(geneLength)
sapply(geneLength, class)

## To rearrange columns: Remove length data
countdata <- countdata[,c("Geneid", "column_1", "column_2", "column_3", "column_7", "column_8", "column_9")]
colnames(countdata)

## Assign Geneid as the row name column
rownames(countdata) <- countdata[,1]
countdata[,1] <- NULL
head(countdata)

## Convert pre-processed data into a matrix
countdata <- as.matrix(countdata)
colnames(countdata)
class(countdata)
sapply(countdata, class)
head(countdata)

## Create a DGEList for edgeR
d <- DGEList(counts=countdata)
head(d)

## Perform TMM normalization
d <- calcNormFactors(d, method = "TMM")
head(d)

## Calculate cpm values using edgeR cpm function and write results to a .csv file
countdata <- cpm(d)
write.table(countdata, file = "cpm.csv", sep = ",", quote = FALSE)

## Read gene lengths as a matrx
d$genes$Length <- c(geneLength)

## Calculate rpkm values using edgeR rpkm function and write results to a .csv file
countdata <- rpkm(d)
write.table(countdata, file = "rpkm.csv", sep = ",", quote = FALSE)