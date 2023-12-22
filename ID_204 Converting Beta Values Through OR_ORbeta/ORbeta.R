args = commandArgs(trailingOnly=TRUE)
argsCount = 3

if (length(args)!=argsCount) {
  stop("betase.R libPath OR  outputFileName")
}
.libPaths(args[1])

OR <- as.numeric(args[2])
if (is.na(OR)) {
 OR <- "4.48"
}

outputFileName <- args[3]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}

transform<- function(OR) {
  BETA=as.data.frame(log(OR))
       print(BETA)
   }                  
                   
     aa = transform(OR)             
 colnames(aa) <- "BETA"    

write.csv(aa,paste(outputFileName,".csv",sep=""))
