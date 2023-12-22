args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("betase.R libPath BETA P outputFileName")
}
.libPaths(args[1])

BETA <- as.numeric(args[2])
if (is.na(BETA)) {
  BETA <- "1.5"
}

P<- as.numeric(args[3])
if (is.na(P)) {
 P <- "0.03"
}

outputFileName <- args[4]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}


transform<- function(beta,p) {
       c=as.data.frame(-qnorm(p/2))
       print(c)
   }                  
                   
     aa = transform(BETA,P)             
 colnames(aa) <- "zscore"    

write.csv(aa,paste(outputFileName,".csv",sep=""))
