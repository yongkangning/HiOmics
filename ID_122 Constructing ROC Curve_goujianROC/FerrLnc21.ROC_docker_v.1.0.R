

args = commandArgs(trailingOnly=TRUE)
argsCount = 6

if (length(args)!=argsCount) {
  stop("FerrLnc21.ROC_docker_v.1.0.R libPath inputFile1 inputFile2 inputFile3 predict_Time outputFileName")
}

 .libPaths(args[1])
inputFile1 <- args[2]
inputFile2 <- args[3]
inputFile3 <- args[4]
predict_Time <- as.numeric(args[5])
if (is.na(predict_Time)) {
  predict_Time <- "1"
}

outputFileName <- args[6]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}


library(survival)
library(survminer)
library(timeROC)
library(tidyverse)
library(myplot)

filename1 = inputFile1  
  file_suffix <- strsplit(filename1, "\\.")[[1]]
  filetype <- file_suffix[length(file_suffix)]
  
  encode <-
    guess_encoding(filename1, n_max = 1000)[1, 1, drop = TRUE]
  # print(encode)
  if(is.na(encode)) {
    stop(paste("[ERRO]", filename1,"encoding_nonsupport"))
  }
  if(filetype %in% c("csv","txt")){
  
read_data <- function(filename1, has_header,has_rownames) {
 
    if (filetype == "csv") {
    df <-
      tryCatch(
        read.csv(filename1, header = has_header, row.names =has_rownames,fileEncoding = encode,sep=",",check.names=FALSE),
        warning = function(e) {
          read.csv(filename1, header = has_header,row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
         read.table(filename1, header = has_header,row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE),
        warning = function(e) {
          read.table(filename1, header = has_header, row.names =has_rownames,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
        }
      )
  }  else {
    stop("[ERRO] txt csv")
  }
  return(df)
    
}
risk = read_data(file = filename1,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename1, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename1,col_names=has_header)
	
  } else {
  stop("[ERRO] xls xlsx")}
  }

  
  risk = read_data(file = filename1,has_header = T)
  risk =as.data.frame(risk)
  row.names(risk)=risk[,1]
  risk = risk[,-1]
 
  }
risk=risk[,c("futime", "fustat", "riskScore")]


#cli=read.table(cliFile, header=T, sep="\t", check.names=F, row.names=1)
filename2 = inputFile2
  file_suffix <- strsplit(filename2, "\\.")[[1]]
  filetype <- file_suffix[length(file_suffix)]
  
  encode <-
    guess_encoding(filename2, n_max = 1000)[1, 1, drop = TRUE]
  # print(encode)
  if(is.na(encode)) {
    stop(paste("[ERRO]", filename2,"encoding_nonsupport"))
  }
  if(filetype %in% c("csv","txt")){
  
read_data <- function(filename2, has_header,has_rownames) {
 
    if (filetype == "csv") {
    df <-
      tryCatch(
        read.csv(filename2, header = has_header, row.names =has_rownames,fileEncoding = encode,sep=",",check.names=FALSE),
        warning = function(e) {
          read.csv(filename2, header = has_header,row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
         read.table(filename2, header = has_header,row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE),
        warning = function(e) {
          read.table(filename2, header = has_header, row.names =has_rownames,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
        }
      )
  }  else {
    stop("[ERRO] txt csv")
  }
  return(df)
    
}
cli = read_data(file = filename2,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename2, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename2,col_names=has_header)
	
  } else {
  stop("[ERRO] xls xlsx")}
  }

  
  cli = read_data(file = filename2,has_header = T)
  cli =as.data.frame(cli)
  row.names(cli)=cli[,1]
  cli = cli[,-1]
 
  }

samSample=intersect(row.names(risk), row.names(cli))
risk1=risk[samSample,,drop=F]
cli=cli[samSample,,drop=F]
rt=cbind(risk1, cli)


bioCol=rainbow(ncol(rt)-1, s=0.9, v=0.9)
#method <- read.table(file="times.txt",header = F,sep = "\t",check.names = FALSE)
filename3 = inputFile3
  file_suffix <- strsplit(filename3, "\\.")[[1]]
  filetype <- file_suffix[length(file_suffix)]
  
  encode <-
    guess_encoding(filename3, n_max = 1000)[1, 1, drop = TRUE]
  # print(encode)
  if(is.na(encode)) {
    stop(paste("[ERRO]", filename3,"encoding_nonsupport"))
  }
  if(filetype %in% c("csv","txt")){
  
read_data <- function(filename3, has_header) {
 
    if (filetype == "csv") {
    df <-
      tryCatch(
        read.csv(filename3, header = has_header, fileEncoding = encode,sep=",",check.names=FALSE),
        warning = function(e) {
          read.csv(filename3, header = has_header, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
         read.table(filename3, header = has_header, fileEncoding = encode,sep="\t",check.names=FALSE),
        warning = function(e) {
          read.table(filename3, header = has_header,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
        }
      )
  }  else {
    stop("[ERRO] txt csv")
  }
  return(df)
    
}
Times = read_data(file = filename3,has_header = F)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename3, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename3,col_names=has_header)
	
  } else {
  stop("[ERRO] xls xlsx")}
  }

  
  Times = read_data(file = filename3,has_header = F)

 
  }
Times <- as.matrix(Times)
Times <- as.vector(Times)


ROC_rt=timeROC(T=risk$futime,delta=risk$fustat,
               marker=risk$riskScore,cause=1,
               weighting='aalen',
               times=Times,ROC=TRUE)
#pdf(file="ROC.pdf", width=5, height=5)
if(length(Times)==1){
  p=myplot({plot(ROC_rt,time=Times,col=bioCol[1],title=FALSE,lwd=2)
  legend('bottomright', c(paste0('AUC at ', Times,' years: ',sprintf("%.03f",ROC_rt$AUC[2]))),col=bioCol[1], lwd=2, bty = 'n')
})
  }else if(length(Times)>1){
t=ROC_rt$times
if(length(t)>1){
  bioCol1=rainbow(length(t))}

aucText=c( paste0('AUC at ', t[1],' years: ',sprintf("%0.3f",ROC_rt$AUC[1]))) 
p=myplot({plot(ROC_rt,las=1,cex.axis=0.8,time=t[1],col=bioCol1[1],title=FALSE,lwd=1)
  for(i in 1:length(t)){
    
    plot(ROC_rt,time=t[i],col=bioCol1[i],add=TRUE,title=FALSE,lwd=1)
    aucText[i]=c( paste0('AUC at ', t[i],' years: ',sprintf("%0.3f",ROC_rt$AUC[i])))  
  }
  legend("bottomright", aucText,lwd=1,cex=0.8,lty=1,bty="n",col=bioCol1[1:i])
})
}
plotsave(p,file=paste(outputFileName,"ROC.svg",sep="_"),unit="cm",width=15,height=15,dpi=600)

#svg(filename =paste(outputFileName,"ROC.svg",sep="_"))
#plot(ROC_rt,time=1,col=bioCol[1],title=FALSE,lwd=2)
#plot(ROC_rt,time=2,col=bioCol[2],add=TRUE,title=FALSE,lwd=2)
#plot(ROC_rt,time=3,col=bioCol[3],add=TRUE,title=FALSE,lwd=2)
#legend('bottomright',
#       c(paste0('AUC at 1 years: ',sprintf("%.03f",ROC_rt$AUC[1])),
#         paste0('AUC at 2 years: ',sprintf("%.03f",ROC_rt$AUC[2])),
#         paste0('AUC at 3 years: ',sprintf("%.03f",ROC_rt$AUC[3]))),
#       col=bioCol[1:3], lwd=2, bty = 'n')
#dev.off()



predictTime=predict_Time    
aucText=c()
#pdf(file="cliROC.pdf", width=6, height=6)
svg(filename =paste(outputFileName,"clinicalROC.svg",sep="_"))

i=3
ROC_rt=timeROC(T=risk$futime,
               delta=risk$fustat,
               marker=risk$riskScore, cause=1,
               weighting='aalen',
               times=c(predictTime),ROC=TRUE)
plot(ROC_rt, time=predictTime, col=bioCol[i-2], title=FALSE, lwd=2)
aucText=c(paste0("Risk", ", AUC=", sprintf("%.3f",ROC_rt$AUC[2])))
abline(0,1)

for(i in 4:ncol(rt)){
  ROC_rt=timeROC(T=rt$futime,
                 delta=rt$fustat,
                 marker=rt[,i], cause=1,
                 weighting='aalen',
                 times=c(predictTime),ROC=TRUE)
  plot(ROC_rt, time=predictTime, col=bioCol[i-2], title=FALSE, lwd=2, add=TRUE)
  aucText=c(aucText, paste0(colnames(rt)[i],", AUC=",sprintf("%.3f",ROC_rt$AUC[2])))
}

legend("bottomright", aucText,lwd=2,bty="n",col=bioCol[1:(ncol(rt)-1)])
dev.off()


