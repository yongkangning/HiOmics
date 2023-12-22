args = commandArgs(trailingOnly=TRUE)
argsCount = 6

if (length(args)!=argsCount) {
  stop("xianxinghuigui.R libPath U F2 sig_level Power outputFileName")
}
.libPaths(args[1])
U <- as.numeric(args[2])
if (is.na(U)) {
  U <- "5"
}

F2<- as.numeric(args[3])
if (is.na(F2)) {
  F2 <- "0.0769"
}

sig_level<- as.numeric(args[4])
if (is.na(sig_level)) {
  sig_level <- "0.05"
}

Power<- as.numeric(args[5])
if (is.na(Power)) {
  Power <- "0.9"
}

outputFileName <- args[6]#
if (is.na(outputFileName)) {
  outputFileName <- "chisq.test"
}

library(pwr)


aa7 <- pwr.f2.test(u=U,f2= F2,sig.level=sig_level,power=Power)


v <- aa7$v

sig_level <- aa7$sig.level

f2 <- aa7$f2

power <- aa7$power

aa77<-cbind(v,f2,sig_level,power)


write.csv(aa77,paste0(outputFileName,".csv"),row.names = FALSE,quote = F)


