args = commandArgs(trailingOnly=TRUE)
argsCount = 5

if (length(args)!=argsCount) {
  stop("yangbenlvyizhilv.R libPath H K power sig_level outputFileName")
}
.libPaths(args[1])
H <- as.numeric(args[2])
if (is.na(H)) {
  H <- "0.9"
}

sig_level <- as.numeric(args[3])
if (is.na(sig_level)) {
  sig_level <- "0.05"
}


power <- as.numeric(args[4])
if (is.na(power)) {
  power <- "0.80"
}



outputFileName <- args[5]
if (is.na(outputFileName)) {
  outputFileName <- "SampleN"
}


library(pwr)


ES.h(0.9,0.8)
## [1] 0.2837941


aa <-pwr.p.test(h = H,
           sig.level = sig_level,
           power = power,
           alternative = "greater"
)

n <- aa$n

h <- aa$h

sig_level <- aa$sig.level

aa1<-cbind(n,h,sig_level,power=aa$power,alternative=aa$alternative)


write.csv(aa1,paste0(outputFileName,".csv"),row.names = FALSE,quote = F)

