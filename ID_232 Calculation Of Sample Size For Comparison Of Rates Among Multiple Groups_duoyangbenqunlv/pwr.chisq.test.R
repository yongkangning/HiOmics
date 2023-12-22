
args = commandArgs(trailingOnly=TRUE)
argsCount = 7

if (length(args)!=argsCount) {
  stop("mantel_test.R libPath is_w nrow_df ncol_df sig_level Power outputFileName")
}
.libPaths(args[1])
is_w <- as.numeric(args[2])
if (is.na(is_w)) {
  is_w <- "0.34"
}
nrow_df<- as.numeric(args[3])
if (is.na(nrow_df)) {
  nrow_df <- "3"
}
ncol_df<- as.numeric(args[4])
if (is.na(ncol_df)) {
  ncol_df <- "2"
}
sig_level<- as.numeric(args[5])
if (is.na(sig_level)) {
  sig_level <- "0.05"
}
Power<- as.numeric(args[6])
if (is.na(Power)) {
  Power <- "0.9"
}

outputFileName <- args[7]#
if (is.na(outputFileName)) {
  outputFileName <- "chisq.test"
}
library(pwr)


aa <- pwr.chisq.test(w=is_w,df=(nrow_df-1)*(ncol_df-1),power=Power,sig.level=sig_level)


w <- aa$w
n <- aa$N
sig.level <- aa$sig.level
power=aa$power
aa1<-cbind(w,n,sig.level,power)


write.csv(aa1,paste0(outputFileName,".csv"),row.names = FALSE)

pdf(paste0(outputFileName,".pdf"))

plot(aa)

dev.off()

