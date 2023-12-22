args = commandArgs(trailingOnly=TRUE)
argsCount = 5

if (length(args)!=argsCount) {
  stop("LYBxiangtong.R libPath H power sig_level outputFileName")
}
.libPaths(args[1])


H <- as.numeric(args[2])
if (is.na(H)) {
  H <- "0.85"
}


power <- as.numeric(args[3])
if (is.na(power)) {
  power <- "0.8"
}

sig_level <- as.numeric(args[4])
if (is.na(sig_level)) {
  sig_level <- "0.01"
}

outputFileName <- args[5]
if (is.na(outputFileName)) {
  outputFileName <- "SampleN"
}

library(pwr)

aa22 <-pwr.2p.test(h=H,power=power,sig.level=sig_level,alternative="two.sided")



n <- aa22$n

h <- aa22$h

sig_level <- aa22$sig.level

power <-aa22$power

alternative <- aa22$alternative

aa221<- cbind(n,h,sig_level,power,alternative)


write.csv(aa221,paste0(outputFileName,".csv"),row.names = FALSE,quote = F)

pdf(paste0(outputFileName,".pdf"))
plot(aa22, xlab="sample size per group")
dev.off()

