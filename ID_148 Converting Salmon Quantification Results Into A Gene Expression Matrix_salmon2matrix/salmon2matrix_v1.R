args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("salmon2matrix_v1.R RlibraryPath wk_dir sf_file tx2gene_file")
}

RlibraryPath <- args[1]
wk_dir <- args[2]
sf_file <- args[3]
tx2gene_file <- args[4]

.libPaths(args[1])
library(tximport)
library(stringr)
library(R.utils)





# wk_dir = "C:/Users/Administrator/Desktop/quantify/salmon/test"
# sf_file = "C:/Users/Administrator/Desktop/quantify/salmon/salmon.zip"
# tx2gene_file <- "C:/Users/Administrator/Desktop/quantify/salmon/GRCh38.tx2gene"

setwd(wk_dir)

if (grepl(".tar.gz$",sf_file)) {
  untar(tarfile = sf_file, exdir = wk_dir)
} else if (grepl(".zip$",sf_file)) {
  unzip(zipfile = sf_file,exdir = wk_dir)
  
} else {
  stop(paste0("",sf_file))
}
  
files <- list.files(path = wk_dir,pattern = "^quant.sf$",recursive = T)
files <- file.path(wk_dir, files)

if (!all(file.exists(files))) {
  print("")
  stop(print(files))
}

tx2gene=read.table(tx2gene_file,stringsAsFactors = F, header = F)
txi <- tximport(files, type = "salmon", tx2gene = tx2gene)
sampleName <- sapply(strsplit(files,'\\/'),function(x) x[length(x)-1])
colnames(txi$counts) <- sampleName
GeneCountMatrix <- txi$counts
GeneCountMatrixOut <- apply(GeneCountMatrix,2,as.integer)
rownames(GeneCountMatrixOut)=rownames(GeneCountMatrix)
write.table(data.frame(gene=rownames(GeneCountMatrixOut),GeneCountMatrixOut),file = "GeneCountMatrix.txt",row.names = F,quote = F,sep = "\t")

