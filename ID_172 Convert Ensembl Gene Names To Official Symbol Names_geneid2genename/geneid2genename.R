

args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("trans2genename.R libPath inputFile1 inputFile2 outputFile")
}

libPath <- args[1]
inputFile1 <- args[2]
inputFile2 <- args[3]
outputFile <- args[4]
.libPaths(libPath)
library(dplyr)

#readCountMatrix <- read.table(GeneCountMatrixFile, header = T,sep = "\t",check.names = F)

readCountMatrix=read.table(inputFile1, header = T,sep = "\t",check.names = F)

colnames(readCountMatrix)[1] <- "gene_id"

#transFile <- read.table(geneid2genenameFile, header = T,sep = "\t",check.names = F)

transFile=read.table(inputFile2, header = T,sep = "\t",check.names = F)

colnames(transFile) <- c("gene_id","gene_name")
geneid2genename <- transFile[transFile$gene_name != "",]

geneid2genename <- geneid2genename %>% distinct(gene_id,gene_name,.keep_all = T) 


join_result <- inner_join(readCountMatrix, geneid2genename,by=c("gene_id" = "gene_id"))
cols_nums <- length(colnames(join_result))
join_result <- join_result[,c(cols_nums,2:(cols_nums-1))]
colnames(join_result)[1] <- "genename"

merge_join_result <- join_result %>% group_by(genename) %>% summarise_all(.,sum)
merge_join_result <- as.data.frame(merge_join_result)

GeneCountMatrixOut <- apply(merge_join_result[-1],2,as.integer)
GeneCountMatrixOut <- data.frame(genename=merge_join_result$genename,GeneCountMatrixOut)
write.table(GeneCountMatrixOut,file=outputFile,quote = F,row.names = F,sep = "\t")

