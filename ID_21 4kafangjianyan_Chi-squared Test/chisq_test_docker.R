
  

args = commandArgs(trailingOnly=TRUE)
argsCount = 3

if (length(args)!=argsCount) {
  stop("zuneixgxfx.R libPath inputFile outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]
outputFileName <- args[3]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}

library(dplyr)

data=read.table(inputFile,header=T,sep="\t",check.names=F,row.names=1,quote = "")

chisq.test <- chisq.test(data)

stdres=chisq.test$stdres
residuals=chisq.test$residuals
expected=chisq.test$expected
observed=chisq.test$observed

chisq.test$method
df=chisq.test$parameter
X_squared=chisq.test$statistic
pvalue=chisq.test$p.value
sig=ifelse(pvalue>= 0.05, "---", 
           ifelse(pvalue< 0.05 & pvalue >= 0.01,"*",
                  ifelse(pvalue< 0.01 & pvalue >= 0.001,"**","***")))
sig_out=data.frame(X_squared,df,pvalue,sig)

write.table(stdres,file=paste(outputFileName,"chisq$stdres.txt",sep="_"),quote=FALSE,sep="\t",row.names=T)
write.table(residuals,file=paste(outputFileName,"chisq$residuals.txt",sep="_"),quote=FALSE,sep="\t",row.names=T)
write.table(expected,file=paste(outputFileName,"chisq$expected.txt",sep="_"),quote=FALSE,sep="\t",row.names=T)
#write.table(observed,file=paste(outputFileName,"chisq$observed.txt",sep="_"),quote=FALSE,sep="\t",row.names=T)
write.table(sig_out,file=paste(outputFileName,"chisq.test_result.txt",sep="_"),quote=FALSE,sep="\t",row.names=FALSE)











