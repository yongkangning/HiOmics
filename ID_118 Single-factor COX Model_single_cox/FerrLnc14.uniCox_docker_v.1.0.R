

#install.packages("survival")
args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("FerrLnc14.uniCox_docker_v.1.0.R libPath inputFile P_fileter outputFileName")
}

 .libPaths(args[1])
inputFile <- args[2]

P_fileter <- as.numeric(args[3])
 if (is.na(P_fileter)) {
  P_fileter <- "0.01"
}

outputFileName <- args[4]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}

library(survival)      
library(tidyverse)
#setwd("D:\\biyedata\\chapter1\\success\\test\\14.uniCox")     
#rt=read.table("expTime.txt", header=T, sep="\t", check.names=F, row.names=1)     
#t$futime=rt$futime/365      
filename1 = inputFile
pFilter=P_fileter         
 
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
rt = read_data(file = filename1,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename1, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename1,col_names=has_header)
	
  } else {
  stop("[ERRO] xls xlsx")}
  }

  
  rt = read_data(file = filename1,has_header = T)
  rt =as.data.frame(rt)
  row.names(rt)=rt[,1]
  rt = rt[,-1]

  
  }
  
  

outTab=data.frame()
sigGenes=c("futime","fustat")
for(gene in colnames(rt[,3:ncol(rt)])){
  cox=coxph(Surv(futime, fustat) ~ rt[,gene], data = rt)
  coxSummary = summary(cox)
  coxP=coxSummary$coefficients[,"Pr(>|z|)"]
  
  if(coxP<pFilter){
    sigGenes=c(sigGenes,gene)
    outTab=rbind(outTab,
                 cbind(gene=gene,
                       HR=coxSummary$conf.int[,"exp(coef)"],
                       HR.95L=coxSummary$conf.int[,"lower .95"],
                       HR.95H=coxSummary$conf.int[,"upper .95"],
                       pvalue=coxP) )
  }
}


write.table(outTab,file=paste(outputFileName,"uniCox.txt",sep="_"),sep="\t",row.names=F,quote=F)
surSigExp=rt[,sigGenes]
surSigExp=cbind(id=row.names(surSigExp),surSigExp)
write.table(surSigExp,file=paste(outputFileName,"uniSigExp.txt",sep="_"),sep="\t",row.names=F,quote=F)



  row.names(outTab) <- outTab$gene
  rt <- outTab[,-1]
  gene <- rownames(rt)
  hr <- sprintf("%.3f",as.numeric(rt$HR))
  hrLow  <- sprintf("%.3f",as.numeric(rt$"HR.95L"))
  hrLow[hrLow<0.001]=0.001
  hrHigh <- sprintf("%.3f",as.numeric(rt$"HR.95H"))
  Hazard.ratio <- paste0(hr,"(",hrLow,"-",hrHigh,")")
  pVal <- ifelse(rt$pvalue<0.001, "<0.001", sprintf("%.3f", as.numeric(rt$pvalue)))
  
  
  height=(nrow(rt)/15)+8
  #pdf(file=forestFile, width=12, height=height)
  svg(filename = paste(outputFileName,"forest.svg",sep="_"), width=12, height=height )
  n <- nrow(rt)
  nRow <- n+1
  ylim <- c(1,nRow)
  layout(matrix(c(1,2),nc=2),width=c(3,2.5))
  
  
  xlim = c(0,3)
  par(mar=c(4,2.5,2,1))
  plot(1,xlim=xlim,ylim=ylim,type="n",axes=F,xlab="",ylab="")
  text.cex=0.8
  text(0,n:1,gene,adj=0,cex=text.cex)
  text(1.9-0.5*0.2,n:1,pVal,adj=1,cex=text.cex);text(1.9-0.5*0.2,n+1,'pvalue',cex=text.cex,adj=1)
  text(3.1,n:1,Hazard.ratio,adj=1,cex=text.cex);text(3.1,n+1,'Hazard ratio',cex=text.cex,adj=1)
  
  
  par(mar=c(4,1,2,1),mgp=c(2,0.5,0))
  xlim = c(0,max(as.numeric(hrLow),as.numeric(hrHigh)))
  plot(1,xlim=xlim,ylim=ylim,type="n",axes=F,ylab="",xaxs="i",xlab="Hazard ratio")
  arrows(as.numeric(hrLow),n:1,as.numeric(hrHigh),n:1,angle=90,code=3,length=0.05,col="darkblue",lwd=2.5)
  abline(v=1,col="black",lty=2,lwd=2)
  boxcolor = ifelse(as.numeric(hr) > 1, 'red', 'blue')
  points(as.numeric(hr), n:1, pch = 15, col = boxcolor, cex=1.3)
  axis(1)
  dev.off()


