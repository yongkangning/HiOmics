


args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("haplot.R libPath inputFile1 inputFile2 outputFileName")
}
.libPaths(args[1])
inputFile1 <- args[2]
inputFile2 <- args[3]
outputFileName <- args[4]
if (is.na(outputFileName)) {
  outputFileName <- "haplotype"
}

library(haplo.stats)
data <-read.table(inputFile1, header = T,sep = "\t")
geno <- data[,-1]
y.ordinal<-as.numeric(data[,1])

label <- read.table(file=inputFile2,header = F, sep = "\t")
label <- as.matrix(label)
label<- as.vector(label)


score.ordinal <- haplo.score(y.ordinal, geno, locus.label=label,trait.type="ordinal")	

	   score1 <-  cbind(score.ordinal$hap.prob,score.ordinal$score.haplo,score.ordinal$score.haplo.p)	
      colnames(score1)=c("Hap-Freq","Hap-Score","p-val")	
	score_out <- cbind(score.ordinal$haplotype,score1)
	
write.csv(score_out,file=paste(outputFileName,"csv",sep="."))



						 