args = commandArgs(trailingOnly=TRUE)
argsCount = 5

if (length(args)!=argsCount) {
  stop("sequence_logo.R libPath inputFile is_col is_method outputFileName")
}
.libPaths(args[1])

inputFile <- args[2]

is_col <- args[3]
if (is.na(is_col)) {
  is_col <- "auto"
}

is_method <- args[4]
if (is.na(is_method)) {
  is_method <- "bits"
}
outputFileName <- args[5]
if (is.na(outputFileName)) {
  outputFileName <- "outputFile"
}



library(tidyverse)
library(ggseqlogo)
library(Biostrings)

seqs_dna <- readBStringSet(inputFile, nrec=-1L, skip=0L, seek.first.rec=FALSE, use.names=TRUE)
seqs_dna <- as.vector(seqs_dna) 
str(seqs_dna)

p=ggseqlogo(seqs_dna, method = is_method, col_scheme = is_col)
ggsave(plot=p,filename=paste(outputFileName,"svg",sep="."),
       device='svg',units="cm",dpi=600)




