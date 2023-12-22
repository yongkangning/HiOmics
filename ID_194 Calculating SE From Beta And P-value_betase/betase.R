args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("betase.R libPath BETA P outputFileName")
}
.libPaths(args[1])

BETA <- as.numeric(args[2])#
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
       se=as.data.frame(sqrt(((beta)^2)/qchisq(p,1,lower.tail=F)))
       print(se)
   }                  
                   
     aa = transform(BETA,P)             
 colnames(aa) <- "se"   

write.csv(aa,paste(outputFileName,".csv",sep=""))
