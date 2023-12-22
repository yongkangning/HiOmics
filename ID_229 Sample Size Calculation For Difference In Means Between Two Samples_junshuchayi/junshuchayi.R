args = commandArgs(trailingOnly=TRUE)
argsCount = 5

if (length(args)!=argsCount) {
  stop("betase.R libPath D sig_level power outputFileName")
}
.libPaths(args[1])
D <- as.numeric(args[2])
if (is.na(D)) {
  D <- "0.8"
}

sig_level <- as.numeric(args[3])
if (is.na(sig_level)) {
  sig_level <- "0.05"
}

power <- as.numeric(args[4])
if (is.na(power)) {
  power <- "0.5"
}


outputFileName <- args[5]
if (is.na(outputFileName)) {
  outputFileName <- "SampleN"
}

library(pwr)

aa <-pwr.t.test(d =D,
           sig.level = sig_level,
           power = power,
           type = "two.sample",
           alternative = "two.sided"
)


n <- aa$n

d <- aa$d

sig_level <- aa$sig.level

aa1<-cbind(n,d,sig_level,power=aa$power,alternative=aa$alternative)


write.csv(aa1,paste0(outputFileName,".csv"),row.names = FALSE,quote = F)

