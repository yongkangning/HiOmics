args = commandArgs(trailingOnly=TRUE)
argsCount = 6

if (length(args)!=argsCount) {
  stop("betase.R libPath F K power sig_level outputFileName")
}
.libPaths(args[1])
F <- as.numeric(args[2])
if (is.na(F)) {
  F <- "0.28"
}

K <- as.numeric(args[3])
if (is.na(K)) {
  K <- "4"
}

power <- as.numeric(args[4])
if (is.na(power)) {
  power <- "0.80"
}

sig_level <- as.numeric(args[5])
if (is.na(sig_level)) {
  sig_level <- "0.05"
}

outputFileName <- args[6]
if (is.na(outputFileName)) {
  outputFileName <- "SampleN"
}
library(pwr)

aa <- pwr.anova.test(f=F,k=K,power=power,sig.level=sig_level)


k <- aa$k
n <- aa$n
f <- aa$f
sig_level <- aa$sig.level
Power <- aa$power

aa1<-cbind(k,n,f,sig_level,Power)


write.csv(aa1,paste0(outputFileName,".csv"),row.names = FALSE)

pdf(paste0(outputFileName,".pdf"))
plot(aa, xlab="sample size per group")
dev.off()



