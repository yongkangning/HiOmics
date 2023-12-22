args = commandArgs(trailingOnly=TRUE)
argsCount = 3

if (length(args)!=argsCount) {
  stop("betase.R libPath BETA  outputFileName")
}
.libPaths(args[1])

BETA <- as.numeric(args[2])
if (is.na(BETA)) {
  BETA <- "1.5"
}

outputFileName <- args[3]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}

transform<- function(beta) {
  OR=as.data.frame(exp(beta))
       print(OR)
   }                  
                   
     aa = transform(BETA)             
 colnames(aa) <- "OR"    

write.csv(aa,paste(outputFileName,".csv",sep=""))
