
args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("xingdeseq2.R libPath inputFile name_beta outputFileName")
}

.libPaths(args[1])
inputFile <- args[2]

name_beta <- args[3]
if (is.na(name_beta)) {
  name_beta <- "BETA"
}

outputFileName <- args[4]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}





#setwd("C:\\Users\\Administrator\\Desktop\\")
#dat <- read.csv("result.csv")

dat=read.csv(inputFile)


if(name_beta == "BETA"){dat$pve = (2*(dat$BETA^2*dat$MAF*(1-dat$MAF)))/(2*dat$BETA^2*dat$MAF*(1-dat$MAF) + dat$SE^2*2*220*dat$MAF*(1-dat$MAF))
}else if(name_beta == "OR"){
  
  BETA = log(dat$OR)
  dat$BETA=BETA
dat=dat[,-grep("OR", names(dat))]
dat$pve = (2*(dat$BETA^2*dat$MAF*(1-dat$MAF)))/(2*dat$BETA^2*dat$MAF*(1-dat$MAF) + dat$SE^2*2*220*dat$MAF*(1-dat$MAF))
}


#write.csv(dat,"111want.csv")

write.table(dat,file=paste(outputFileName,"txt",sep="."),quote=FALSE,sep="\t",row.names=FALSE)
