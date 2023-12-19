

args = commandArgs(trailingOnly=TRUE)
argsCount = 3

if (length(args)!=argsCount) {
  stop("kruwkal_docker.R libPath inputFile outputFileName")
}
.libPaths(args[1])
 
inputFile <- args[2]
outputFileName <- args[3]
if (is.na(outputFileName)) {
  outputFileName <- "kruwkal_test"
}



library(dplyr)
data <- read.table(inputFile,header = T)

data[,2] <- as.factor(data[,2])


kruwkal_test <- kruskal.test(data[,2]~data[,1], data=data) 
Kruskal_Wallis_chi_squared  <- kruwkal_test$statistic
df <- kruwkal_test$parameter
pvalue <- kruwkal_test$p.value
data_out <- data.frame(Kruskal_Wallis_chi_squared,df,pvalue)

write.table(data_out,file=paste(outputFileName,"txt",sep="."),sep="\t",row.names = F)


