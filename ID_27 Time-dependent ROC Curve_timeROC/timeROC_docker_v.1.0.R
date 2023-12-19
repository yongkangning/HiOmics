
args = commandArgs(trailingOnly=TRUE)
argsCount = 6

if (length(args)!=argsCount) {
  stop("timeROC_docker_v.1.0.R libPath inputFile1 inputFile2 is_weighting legend_cex outputFileName")
}
.libPaths(args[1])
inputFile1 <- args[2]
inputFile2 <- args[3]

is_weighting <- args[4]
if (is.na(is_weighting)) {
  is_weighting <- "marginal"
}
   
legend_cex <- as.numeric(args[5])
if (is.na(legend_cex)) {
  legend_cex <- "0.6"
}
outputFileName <- args[6]
if (is.na(outputFileName)) {
  outputFileName <- "timeROC"
}
         
library(myplot)   
library(survival)
library(survminer)
library(timeROC)
  

rt=read.table(inputFile1, header=T, sep="\t", check.names=F, row.names=1)
times=read.table(inputFile2, header=T, sep="\t", check.names=F)

ROC_rt=timeROC(T=rt[,1], delta=rt[,2],
               marker=rt[,3], cause=1,
               weighting=is_weighting,
               times=as.matrix(times))
t=ROC_rt$times
bioCol=c("#00EEEE")
if(length(t)>1){
  bioCol=rainbow(length(t))}

aucText=c( paste0("time=",t[1],",AUC=",sprintf("%0.3f",ROC_rt$AUC[1]))) 
p=myplot({plot(ROC_rt,las=1,cex.axis=0.8,time=t[1],col=bioCol[1],title=FALSE,lwd=1)
for(i in 1:length(t)){
  
  plot(ROC_rt,time=t[i],col=bioCol[i],add=TRUE,title=FALSE,lwd=1)
  aucText[i]=c( paste0("time=",t[i],",AUC=",sprintf("%0.3f",ROC_rt$AUC[i])))  
}
legend("bottomright", aucText,lwd=1,cex=legend_cex,lty=1,bty="n",col=bioCol[1:i])})

plotsave(p,file=paste(outputFileName,"svg",sep="."),unit="cm",width=15,height=15,dpi=600)

