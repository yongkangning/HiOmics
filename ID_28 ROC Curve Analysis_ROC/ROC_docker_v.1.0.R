

args = commandArgs(trailingOnly=TRUE)
argsCount = 5

if (length(args)!=argsCount) {
  stop("ROC_docker_v.1.0.R libPath inputFile plot_title legend_cex outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]

plot_title <- args[3] 
if (is.na(plot_title)) {
  plot_title <- "ROC_plot"
}
legend_cex <- as.numeric(args[4])
if (is.na(legend_cex)) {
  legend_cex <- "0.6"
}
outputFileName <- args[5]
if (is.na(outputFileName)) {
  outputFileName <- "bubble_plot"
}
library(pROC)              
library(myplot)   
rt=read.table(inputFile,header=T,sep="\t",check.names=F)  
y=colnames(rt)[1]

bioCol=c("#00EEEE")
if(ncol(rt)>1){
  bioCol=rainbow(ncol(rt))}


roc1=roc(rt[,y], as.vector(rt[,2]))
aucText=c( paste0(colnames(rt)[2],"( AUC=",sprintf("%0.3f)",auc(roc1))) )
p=myplot({plot(roc1,main=plot_title,col=bioCol[1],lwd=1,cex.axis=0.8,las=1,font.axis=1)
for(i in 3:ncol(rt)){
  roc1=roc(rt[,y], as.vector(rt[,i]))
  lines(roc1, col=bioCol[i-1],lwd=1)
  aucText=c(aucText, paste0(colnames(rt)[i],"( AUC=",sprintf("%0.3f)",auc(roc1))) )
}
legend("bottomright", aucText,lwd=1,cex=legend_cex,lty=1,bty="n",col=bioCol[1:(ncol(rt)-1)])})

plotsave(p,file=paste(outputFileName,"svg",sep="."),unit="cm",width=15,height=15,dpi=600)
