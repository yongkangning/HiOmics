args = commandArgs(trailingOnly=TRUE)
argsCount = 5

if (length(args)!=argsCount) {
  stop("betase.R libPath sig_level power R outputFileName")
}
.libPaths(args[1])
R <- as.numeric(args[2])
if (is.na(R)) {
  R <- "0.8"
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



aa <- pwr.r.test(r=R,
                 sig.level = sig_level,
                 power = power,
                 alternative = "two.sided")

n <- aa$n

sig_level <- aa$sig.level

r <- aa$r

power <- aa$power

aa1<-cbind(n,r,sig_level,power,alternative=aa$alternative)


write.csv(aa1,paste0(outputFileName,".csv"),row.names = FALSE,quote = F)




