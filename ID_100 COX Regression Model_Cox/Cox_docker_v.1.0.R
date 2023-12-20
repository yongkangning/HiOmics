
args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("Cox_docker_v.1.0.R libPath inputFile is_fontsize outputFileName")
}
.libPaths(args[1])
 
inputFile <- args[2]
is_fontsize <- as.numeric(args[3])
if (is.na(is_fontsize)) {
  is_fontsize <- "0.7"
}

outputFileName <- args[4]
if (is.na(outputFileName)) {
  outputFileName <- "cox"
}


library(tidyr)
library(survival)
library(survminer)
library(ggplot2)

rt=read.table(inputFile,header=T,sep="\t",check.names=F,row.names=1)#


multiCox=coxph(Surv(futime, fustat) ~ ., data = rt)
multiCox=step(multiCox,direction = "both")


multiCoxSum=summary(multiCox)
muiticox=data.frame(cbind( coef=multiCoxSum$coefficients[,"coef"],
             HR=multiCoxSum$conf.int[,"exp(coef)"],
             lower.95=multiCoxSum$conf.int[,"lower .95"],
             upper.95=multiCoxSum$conf.int[,"upper .95"],
             pvalue=multiCoxSum$coefficients[,"Pr(>|z|)"]))
muiticox=cbind(ID=row.names(muiticox),muiticox)
write.table(muiticox,file=paste(outputFileName,"multiCox.txt",sep="_"),sep="\t",row.names=F,quote=F)

p = ggforest(multiCox, fontsize = is_fontsize,cpositions = c(0.03, 0.2, 0.35),noDigits=2,data = rt)
ggsave(plot=p,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=30,height=20,dpi=600)
