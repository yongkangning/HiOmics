
args = commandArgs(trailingOnly=TRUE)
argsCount = 3

if (length(args)!=argsCount) {
  stop("mantel_test.R inputFile1 inputFile2 labrow")
}

inputFile1 <- args[1]
inputFile2 <- args[2]


labrow <- as.logical(args[3]) 
if (is.na(labrow)) {
  labrow <- "T"
}
library(tidyverse)
library(ggpubr)
library("minfi")
library("impute")
library("wateRmelon")
library(RColorBrewer)
#setwd("F:\\zuotu\\")

#info=read.table("group.txt",sep="\t",header=T)
#rt=read.table("data.txt",sep="\t",header=T, row.names=1, blank.lines.skip = FALSE)
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
        read.csv(filename1, header = has_header, row.names =has_rownames,fileEncoding = encode,sep=",",check.names=FALSE,fill=TRUE),
        warning = function(e) {
          read.csv(filename1, header = has_header,row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE,fill=TRUE)
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename1, header = has_header,row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE),
        warning = function(e) {
          read.table(filename1, header = has_header, row.names =has_rownames,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE)
        }
      )
  }  else {
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
    
}
rt = read_data(file = filename1,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename1, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename1,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  rt = read_data(file = filename1,has_header = T)
  rt =as.data.frame(rt)
  row.names(rt)=rt[,1]
  rt = rt[,-1]
  
  }

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
  
read_data <- function(filename2, has_header) {
 
    if (filetype == "csv") {
    df <-
      tryCatch(
        read.csv(filename2, header = has_header, fileEncoding = encode,sep=",",check.names=FALSE),
        warning = function(e) {
          read.csv(filename2, header = has_header, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename2, header = has_header, fileEncoding = encode,sep="\t",check.names=FALSE),
        warning = function(e) {
          read.table(filename2, header = has_header, fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
        }
      )
  }  else {
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
    
}
info = read_data(file = filename2,has_header = T)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename2, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename2,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  info = read_data(file = filename2,has_header = T)
  info =as.data.frame(info)
  
  }
mat=as.matrix(rt)
mat=impute.knn(mat)
matData=mat$data
matData=matData+0.00001
######normalization
matData=matData[rowMeans(matData)>0.005,]
matData1=melt(matData, nrow = rows, ncol = cols)
pdf(file="rawBox.pdf")
ggboxplot(matData1,	
          x="Var2","value",fill = "Var2",	 
          color ="black" ,
         # alpha=0.7,
          palette = "npg",
          #uchicago/futurama/gsea
          bxp.errorbar = TRUE,
          #linetype = "solid",
          #bxp.errorbar.width = 0.3, 
          # add = "jitter"
)     +   labs(x=NULL,y=NULL,title=NULL)+theme_classic()+
  theme(plot.title = element_text(size =15,hjust = 0.5),
        axis.title.x=element_text(size=10),
        axis.title.y=element_text(size=10),
        #axis.text.x=element_text(angle=0,size = 8),
        axis.text.x=element_text(angle=45,vjust =1,hjust =1,size = 10),
        axis.text.y=element_text(size =8),axis.ticks = element_line(size=0.2),
        panel.border =  element_rect(colour = "black", fill=NA)
        )+
  theme(legend.key.size = unit(10,"pt"),
        legend.title = element_text(size=8,vjust = 0.9),
        legend.text = element_text(size =8,vjust = 0.8),
        legend.position = "none")+
  theme(axis.line = element_line(colour="black",size = 0.2))
#boxplot(matData,col =  c("#EEAD0E", "#00FFFF", "#87CEFA", "#FF6EB4", "#76EE00","blue" ,"red"),plot = TRUE,outline = F)

dev.off()

matData = betaqn(matData)
pdf(file="normalBox.pdf")
#boxplot(matData,col = "red",outline = F)
matData2=melt(matData, nrow = rows, ncol = cols)
ggboxplot(matData2,	
          x="Var2","value",fill = "Var2",	 
          color ="black" ,
          # alpha=0.7,
          palette = "npg",
          #uchicago/futurama/gsea
          bxp.errorbar = TRUE,
          #linetype = "solid",
          #bxp.errorbar.width = 0.3, 
          # add = "jitter"
)     +   labs(x=NULL,y=NULL,title=NULL)+theme_classic()+
  theme(plot.title = element_text(size =15,hjust = 0.5),
        axis.title.x=element_text(size=10),
        axis.title.y=element_text(size=10),
        #axis.text.x=element_text(angle=0,size = 8),
        axis.text.x=element_text(angle=45,vjust =1,hjust =1,size = 10),
        axis.text.y=element_text(size =8),axis.ticks = element_line(size=0.2),
        panel.border =  element_rect(colour = "black", fill=NA)
  )+
  theme(legend.key.size = unit(10,"pt"),
        legend.title = element_text(size=8,vjust = 0.9),
        legend.text = element_text(size =8,vjust = 0.8),
        legend.position = "none")+
  theme(axis.line = element_line(colour="black",size = 0.2))

dev.off()

matData_out <- as.data.frame(cbind(ID=row.names(matData),matData))
#write.table(matData_out,file="norm.xls",row.names = F,sep="\t",quote=F)
grset=makeGenomicRatioSetFromMatrix(matData,what="Beta")

pdf(file="densityBeanPlot.pdf")
#par(oma=c(2,10,2,2))
densityBeanPlot(matData, sampGroups = info[,2], sampNames = info[,1])
dev.off()
pdf(file="mdsPlot.pdf")

mdsPlot(matData, numPositions = 1000, sampGroups = info[,2], sampNames = info[,1])
dev.off()


######Finding differentially methylated positions (DMPs)
M = getM(grset)
dmp <- dmpFinder(M, pheno=info[,2], type="categorical")
dmpDiff=dmp[(dmp$qval<0.05) & (is.na(dmp$qval)==F),]
dmpDiff_out <- cbind(ID=row.names(dmpDiff),dmpDiff)
write.table(dmpDiff_out,file="dmpDiff.xls",row.names = F,sep="\t",quote=F)
diffM <- M[rownames(dmpDiff),]
hmExp=diffM
library('gplots')
hmMat=as.matrix(hmExp)

pdf(file="heatmap.pdf")
#par(oma=c(1,1,1,8))
if(labrow == T){
heatmap.2(hmMat,
          trace="none",#"column","row","both","none"
          cexCol=1, 
          #density.info=c("histogram","density","none"),
          #keysize = 1.5,
          #dendrogram = "row",  #"column","row","both","none"
          col="bluered",#BrBG、PiYG、PRGn、PuOr、RdBu、RdGy、RdYlBu、RdYlGn、Spectral
          srtCol = 35,
          offsetCol = -0.4,
          #labRow =labrow,
          #labCol = NULL
          )
 }else if(labrow == F){
 heatmap.2(hmMat,
          trace="none",#"column","row","both","none"
          cexCol=1, 
          #density.info=c("histogram","density","none"),
          #keysize = 1.5,
          #dendrogram = "row",  #"column","row","both","none"
          col="bluered",#BrBG、PiYG、PRGn、PuOr、RdBu、RdGy、RdYlBu、RdYlGn、Spectral
          srtCol = 35,
          offsetCol = -0.4,#
          labRow =labrow,
          #labCol = NULL
          )
 }
dev.off()

######differentially 
class <- info[,2]
designMatrix <- model.matrix(~factor(class))
colnames(designMatrix) <- unique(class)
dmrs <- bumphunter(grset, design = designMatrix, cutoff = 0.2, type="Beta")
dmrs_table_out <- cbind(ID=row.names(dmrs$table),dmrs$table)
#write.table(dmrs_table_out,file="dmrs.xls",sep="\t",row.names=F,quote=F)
#head(dmrs$table)
