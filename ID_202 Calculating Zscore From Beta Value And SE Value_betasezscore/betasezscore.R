args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("betase.R libPath BETA SE outputFileName")
}
.libPaths(args[1])

BETA <- as.numeric(args[2])
if (is.na(BETA)) {
  BETA <- "1.5"
}

SE<- as.numeric(args[3])
if (is.na(SE)) {
SE <- "1.63"
}

outputFileName <- args[4]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}


transform<- function(beta,se) {
      zscore=as.data.frame(beta/se)
       print(zscore)
   }                  
                   
     aa = transform(BETA,SE)             
 colnames(aa) <- "zscore"    

write.csv(aa,paste(outputFileName,".csv",sep=""))
