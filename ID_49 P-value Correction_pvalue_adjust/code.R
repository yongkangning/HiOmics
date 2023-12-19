
args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("code.R libPath inputFile method outputFileName")
}
.libPaths(args[1])
 
inputFile <- args[2]
method <- args[3]
if (is.na(method)) {
  method <- "BH"
}
outputFileName <- args[4]
if (is.na(outputFileName)) {
  outputFileName <- "FDR"
}

data <- read.table(inputFile,header = T,row.names=1)



d<-round(p.adjust(data[,1],method,length(data[,1])),3) 

d=data.frame(d)
colnames(d) <- "FDR"
rownames(d) <- row.names(data)
ID <- row.names(data)
d <- cbind(ID,d)
write.table(d,paste(outputFileName,"csv",sep="."),sep=",",row.names=F)   






