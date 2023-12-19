


args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("SNP_densityplot_docker_v.1.0.R libPath inputFile is_binsize outputFileName")
}
.libPaths(args[1])
 
inputFile <- args[2]

is_binsize<- as.numeric(args[3])
if (is.na(is_binsize)) {
  is_binsize <- "1000000"
}
outputFileName <- args[4]
if (is.na(outputFileName)) {
  outputFileName <- "SNP_densityplot "
}


library(CMplot)
library(myplot)
data <- data.table::fread(inputFile, header = T )
d=myplot({CMplot(data,plot.type = "d",bin.size =is_binsize,dpi=600,col = c("blue","red","yellow"), file.output = F)
})

plotsave(d,file=paste(outputFileName,"svg",sep="."),unit="cm",width=18,height=15,dpi=600)

