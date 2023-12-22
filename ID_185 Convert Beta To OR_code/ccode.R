
args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("code.R libPath  BETA SE outputFileName")
}
.libPaths(args[1])

BETA <- as.numeric(args[2])#
if (is.na(BETA)) {
  BETA <- "1.5"
}

SE<- as.numeric(args[3])#
if (is.na(SE)) {
  SE <- "0.36"
}

outputFileName <- args[4]#
if (is.na(outputFileName)) {
  outputFileName <- "result"
}


transform<- function(beta,se) {
  OR= exp(beta)
  LL_OR= exp(beta-se*1.96)
  UL_OR=exp(beta+se*1.96)
  pval<-2*pnorm(abs(beta/se),lower.tail=FALSE)
  OR_P<-cbind(OR,LL_OR,UL_OR,pval)
  print(OR_P)
}

aa <- transform(BETA,SE)

write.csv(aa,paste(outputFileName,".csv",sep=""))
