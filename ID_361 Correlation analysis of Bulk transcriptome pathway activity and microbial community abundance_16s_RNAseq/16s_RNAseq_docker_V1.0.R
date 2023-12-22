

args = commandArgs(trailingOnly=TRUE)
argsCount = 9

if (length(args)!=argsCount) {
  stop("16s_RNAseq_docker_V1.0.R libPath inputFile1 inputFile2 species need_interest_Bacteria inputFile3 corr_method p_adjust in_pvlaue outputFileName1")
}
.libPaths(args[1])
inputFile1 <- args[2]
inputFile2 <- args[3]
species <- args[4]
if (is.na(species)) {
  species <- "Mouse"
}
need_interest_Bacteria <- args[5]
if (is.na(need_interest_Bacteria)) {
  need_interest_Bacteria <- "yes"
}
inputFile3 <- args[6]
corr_method <- args[7]
if (is.na(corr_method)) {
  corr_method <- 'pearson'
}

p_adjust  <- args[8]
if (is.na(p_adjust)) {
  p_adjust <- 'fdr'
}
in_pvlaue <- args[9]
if (is.na(in_pvlaue)) {
  in_pvlaue <- 'padjust'
}


library(pheatmap)
library(progeny)
library(ggplot2)
library(dplyr)
library(reshape2)
library(stringr)
library(tidyverse)

#library(Cairo)

#data1=read.csv('C:/Users/Administrator/Desktop/16s_RNAseq/input1.csv',header=T)
filename1 = inputFile1#='input1.csv'

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
          read.csv(filename1, header = has_header, fileEncoding = encode,sep=",",check.names=FALSE),
          warning = function(e) {
            read.csv(filename1, header = has_header, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
          }
        )
    } else if (filetype == "txt") {
      df <-
        tryCatch(
          read.table(filename1, header = has_header, fileEncoding = encode,sep="\t",check.names=FALSE),
          warning = function(e) {
            read.table(filename1, header = has_header, fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
          }
        )
    }  else {
      stop("[ERRO] Only support txt csv xls xlsx")
    }
    return(df)
    
  }
  data1 = read_data(file = filename1,has_header = T)
  
}else if (filetype %in% c("xls", "xlsx")) {
  
  read_data <- function(filename1, has_header) {
    if(filetype %in% c("xls", "xlsx")){
      df <- readxl::read_excel(filename1,col_names=has_header)
      
    } else {
      stop("[ERRO] Only support txt csv xls xlsx")}
  }
  
  
  data1 = read_data(file = filename1,has_header = T)
  data1 =as.data.frame(data1)

  
}
colnames(data1)[1] <- 'Gene_name'
data1 <- aggregate(.~Gene_name,data1, FUN=sum)
rownames(data1) <- data1$Gene_name
data1 <- data1[,-1]
data1 <- as.matrix(data1)


pathways <- progeny(data1, scale=TRUE,
                    organism=species, 
                    top = 100, perm = 1)

pdf("Pathway_activity_heatmap.pdf",height = 5)
myColor = colorRampPalette(c("Darkblue", "white","#FF3E96"))(100)

pheatmap(t(pathways),fontsize=14, 
         show_rownames = T, show_colnames = T,cluster_rows =F,
         cluster_cols = F,#cellwidth =10,
         #cellheight = 13,
         # scale = 'column',
         name =  paste0('pathways ',"\n",'activity'),
         angle_col = '315',
         color=myColor,
         row_title ="Pathways",
         main = "PROGENy", 
         border_color = NA)
dev.off()

write.csv(pathways,file="pathway_activities.csv",quote=FALSE,row.names=T)

#data2=read.table('C:/Users/Administrator/Desktop/16s_RNAseq/Genus_relative.tsv',header=T,row.names = 1,check.names=F)
###16s
filename2 = inputFile2#='Genus_relative.tsv'
file_suffix <- strsplit(filename2, "\\.")[[1]]
filetype <- file_suffix[length(file_suffix)]

encode <-
  guess_encoding(filename2, n_max = 1000)[1, 1, drop = TRUE]
# print(encode)
if(is.na(encode)) {
  stop(paste("[ERRO]", filename2,"encoding_nonsupport"))
}
if(filetype %in% c("csv","txt",'tsv')){
  
  read_data <- function(filename2, has_header,has_rownames) {
    
    if (filetype == "csv") {
      df <-
        tryCatch(
          read.csv(filename2, header = has_header,row.names =has_rownames,fileEncoding = encode,sep=",",check.names=FALSE),
          warning = function(e) {
            read.csv(filename2, header = has_header,row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
          }
        )
    } else if (filetype == "txt") {
      df <-
        tryCatch(
          read.table(filename2, header = has_header,row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE),
          warning = function(e) {
            read.table(filename2, header = has_header,row.names =has_rownames,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
          }
        )
    }else if (filetype == "tsv") {
      df <-
        tryCatch(
          read.table(filename2, header = has_header,row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE),
          warning = function(e) {
            read.table(filename2, header = has_header,row.names =has_rownames,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
          }
        )
    } else {
      stop("[ERRO] txt csv")
    }
    return(df)
    
  }
  data2 = read_data(file = filename2,has_header = T,has_rownames=1)
  
}else if (filetype %in% c("xls", "xlsx")) {
  
  read_data <- function(filename2, has_header) {
    if(filetype %in% c("xls", "xlsx")){
      df <- readxl::read_excel(filename2,col_names=has_header)
      
    } else {
      stop("[ERRO] xls xlsx")}
  }
  
  
  data2 = read_data(file = filename2,has_header = T)
  data2 =as.data.frame(data2)
  row.names(data2)=data2[,1]
  data2 = data2[,-1]
  
}

level1_rowsum=rowSums(data2)
data_barplot <- as.data.frame(cbind(data2,level1_rowsum))
data_barplot<- data_barplot[order(data_barplot$level1_rowsum,decreasing = T),]
#sort(data$level1_rowsum,decreasing = T)
 
if(need_interest_Bacteria %in% c('yes')){
  
  
  
  #exprMatrix <- read.table(inputFile1,header=TRUE,row.names=1, as.is=TRUE)
  filename3 = inputFile3#='insteret.xls'
  
  
  file_suffix <- strsplit(filename3, "\\.")[[1]]
  filetype <- file_suffix[length(file_suffix)]
  
  encode <-
    guess_encoding(filename3, n_max = 1000)[1, 1, drop = TRUE]
  # print(encode)
  if(is.na(encode)) {
    stop(paste("[ERRO]", filename3,"encoding_nonsupport"))
  }
  if(filetype %in% c("csv","txt")){
    
    read_data <- function(filename3, has_header,has_rownames) {
      
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
    interest_Bacteria = read_data(file = filename3,has_header = F)
    
  }else if (filetype %in% c("xls", "xlsx")) {
    
    read_data <- function(filename3, has_header) {
      if(filetype %in% c("xls", "xlsx")){
        df <- readxl::read_excel(filename3,col_names=has_header)
        
      } else {
        stop("[ERRO] xls xlsx")}
    }
    
    
    interest_Bacteria = read_data(file = filename3,has_header = F)
    interest_Bacteria =as.data.frame(interest_Bacteria)
    
    
  }
 colnames(interest_Bacteria)<- 'bacteria'
  
  data_barplot <- data_barplot[interest_Bacteria$bacteria,-ncol(data_barplot)]
  
}else if(need_interest_Bacteria %in% c('no')){
  
  
 if( nrow(data_barplot)>30 ){

  data_barplot <- data_barplot[1:30,]
  
} else {data_barplot <- data_barplot}


}


library(psych)
library(reshape)
#library(Cairo)

p.mat <- corr.test(pathways,t(data2),method = corr_method,adjust = p_adjust)
p.mat.r <- p.mat$r 
#p.mat.r =melt(t(p.mat.r))
p.mat.p <- p.mat$p 
#p.mat.p =melt(t(p.mat.p))
p.mat.pjust <- p.mat$p.adj
#p.mat.pjust =melt(t(p.mat.pjust))
dim(p.mat.pjust)
cor_P <- merge(merge(melt(t(p.mat.r)),melt(t(p.mat.p)),by=c('X1','X2')),melt(t(p.mat.pjust)),by=c('X1','X2'))
colnames(cor_P) <- c('Bacteria','Pathway','r','pvalue','p_adjust')
write.csv(cor_P,file="Pathway_correlation.csv",quote=FALSE,row.names=T)




if(in_pvlaue %in% 'Pvlaue'){
  
  p.mat.p[p.mat.p>=0 & p.mat.p < 0.001] <- "***"

p.mat.p[p.mat.p>=0.001 & p.mat.p < 0.01] <- "**"

p.mat.p[p.mat.p>=0.01 & p.mat.p < 0.05] <- "*"

p.mat.p[p.mat.p>=0.05 & p.mat.p <= 1] <- ""
  
  
pdf("Pathway_correlation_heatmap.pdf",height = 7,width =11)
pheatmap(p.mat.r[,c(colnames(p.mat.r)) %in% row.names(data_barplot)],scale = "none",
         border_color= "white",
         number_color= "white",
         fontsize_number=12,
         fontsize_row=12,
         fontsize_col=12,name =  paste0(corr_method,' r'),
         #cellwidth=15,
         # cellheight=15,
         cluster_rows=T,
         cluster_cols=T,
         angle_col = '315',#treeheight_row = 140,treeheight_col = 70,
         display_numbers= p.mat.p[,c(colnames(p.mat.p)) %in% row.names(data_barplot)],
         show_rownames=T)
dev.off() 

}else if(in_pvlaue %in% 'padjust'){
  
  p.mat.pjust[p.mat.pjust>=0 & p.mat.pjust < 0.001] <- "***"
  
  p.mat.pjust[p.mat.pjust>=0.001 & p.mat.pjust < 0.01] <- "**"
  
  p.mat.pjust[p.mat.pjust>=0.01 & p.mat.pjust < 0.05] <- "*"
  
  p.mat.pjust[p.mat.pjust>=0.05 & p.mat.pjust <= 1] <- ""
  
  
  
  pdf("Pathway_correlation_heatmap.pdf",height = 7,width =11)
  pheatmap(p.mat.r[,c(colnames(p.mat.r)) %in% row.names(data_barplot)],scale = "none",
           border_color= "white",
           number_color= "white",
           fontsize_number=12,
           fontsize_row=12,
           fontsize_col=12,name = paste0(corr_method,' r'),
           #cellwidth=15,
           # cellheight=15,
           cluster_rows=T,
           cluster_cols=T,
           angle_col = '315',#treeheight_row = 140,treeheight_col = 70,
           display_numbers= p.mat.pjust[,c(colnames(p.mat.pjust)) %in% row.names(data_barplot)],
           show_rownames=T)
  dev.off() 
  
  
}
















