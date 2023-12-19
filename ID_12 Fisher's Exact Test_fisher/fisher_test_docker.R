
  

args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("fisher_test_docker.R libPath inputFile outputFile outPutFileType")
}
.libPaths(args[1])
inputFile <- args[2]
outputFile <- args[3]
if (is.na(outputFile)) {
  outputFile <- "result"}
outPutFileType <- args[4]
if (is.na(outPutFileType)) {
  outPutFileType <- "txt"
}

outputFileName <- paste(outputFile,outPutFileType,sep = ".")
separator <- "\t"

library(dplyr)
data=read.table(inputFile,header=T,sep="\t",check.names=F,row.names=1,quote = "")

fisher.test <- fisher.test(data)

pvalue=fisher.test$p.value
sig=ifelse(pvalue>= 0.05, "---", 
           ifelse(pvalue< 0.05 & pvalue >= 0.01,"*",
                  ifelse(pvalue< 0.01 & pvalue >= 0.001,"**","***")))
sig_out=data.frame(pvalue,sig)

write.table(sig_out,file=outputFileName,quote=FALSE,sep="\t",row.names=FALSE)





