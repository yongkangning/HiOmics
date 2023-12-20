

args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("FerrLnc16.survival_docker_v.1.0.R libPath inputFile is_width outputFileName")
}

 .libPaths(args[1])
inputFile <- args[2]

is_width <- as.numeric(args[3])
if (is.na(is_width)) {
  is_width <- "6.5"
}
outputFileName <- args[4]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}


library(survival)
library(survminer)
library(tidyverse)


  


bioSurvival=function(filename1=null, outFile=null){
  
  #rt=read.table(input, header=T, sep="\t", check.names=F)
  filename1 = inputFile

 
  file_suffix <- strsplit(filename1, "\\.")[[1]]
  filetype <- file_suffix[length(file_suffix)]
  
  encode <-
    guess_encoding(filename1, n_max = 1000)[1, 1, drop = TRUE]
  # print(encode)
  if(is.na(encode)) {
    stop(paste("[ERRO]", filename1,"encoding_nonsupport"))
  }
  if(filetype %in% c("csv","txt")){
  
read_data <- function(filename1, has_header) {
 
    if (filetype == "csv") {
    df <-
      tryCatch(
        read.csv(filename1, header = has_header,fileEncoding = encode,sep=",",check.names=FALSE),
        warning = function(e) {
          read.csv(filename1, header = has_header,fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
         read.table(filename1, header = has_header, fileEncoding = encode,sep="\t",check.names=FALSE),
        warning = function(e) {
          read.table(filename1, header = has_header,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
        }
      )
  }  else {
    stop("[ERRO] txt csv")
  }
  return(df)
    
}
rt = read_data(file = filename1,has_header = T)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename1, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename1,col_names=has_header)
	
  } else {
  stop("[ERRO] xls xlsx")}
  }

 
  rt = read_data(file = filename1,has_header = T)

  }
  
  
  
  diff=survdiff(Surv(futime, fustat) ~ risk, data=rt)
  pValue=1-pchisq(diff$chisq, df=1)
  if(pValue<0.001){
    pValue="p<0.001"
  }else{
    pValue=paste0("p=",sprintf("%.03f",pValue))
  }
  fit <- survfit(Surv(futime, fustat) ~ risk, data = rt)
  #print(surv_median(fit))
  
  
  surPlot=ggsurvplot(fit, 
                     data=rt,
                     conf.int=T,
                     pval=pValue,
                     pval.size=6,
                     surv.median.line = "hv",
                     legend.title="Risk",
                     legend.labs=c("High risk", "Low risk"),
                     xlab="Time(years)",
                     break.time.by = 1,
                     palette=c("red", "blue"),
                     risk.table=TRUE,
                     risk.table.title="",
                     risk.table.col = "strata",
                     risk.table.height=.25)
  #pdf(file=outFile, onefile=FALSE, width=6.5, height=5.5)
   svg(filename = outFile,width=is_width)
  print(surPlot)
  dev.off()
}


bioSurvival(filename1=inputFile, outFile=paste(outputFileName,"survival.svg",sep="_"))



