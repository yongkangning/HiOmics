args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("ORse.R libPath OR SE outputFileName")
}
.libPaths(args[1])

OR <- as.numeric(args[2])
if (is.na(OR)) {
  OR <- "4.48"
}

SE<- as.numeric(args[3])
if (is.na(SE)) {
SE <- "1.63"
}

outputFileName <- args[4]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}


transform<- function(or,se) {
      zscore=as.data.frame(or/se)
       print(zscore)
   }

     aa = transform(OR,SE)
 colnames(aa) <- "zscore"

write.csv(aa,paste(outputFileName,".csv",sep=""))
