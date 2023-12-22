args = commandArgs(trailingOnly=TRUE)
argsCount = 6

if (length(args)!=argsCount) {
  stop("logistic.R libPath P1 OR alpha power outputFileName")
}
.libPaths(args[1])
P1 <- as.numeric(args[2])
if (is.na(P1)) {
  P1 <- "0.2"
}

OR <- as.numeric(args[3])
if (is.na(OR)) {
  OR <- "1.8"
}

alpha <- as.numeric(args[4])
if (is.na(alpha)) {
  alpha <- "0.05"
}

power <- as.numeric(args[5])
if (is.na(power)) {
  power <- "0.8"
}

outputFileName <- args[6]
if (is.na(outputFileName)) {
  outputFileName <- "SampleN"
}


library(powerMediation)



N <- SSizeLogisticCon(p1 = P1, OR = OR, alpha = alpha, power = power)


aa1<-cbind(N=N,P=P1,OR=OR,alpha=alpha,power=power)


write.csv(aa1,paste0(outputFileName,".csv"),row.names = FALSE)

