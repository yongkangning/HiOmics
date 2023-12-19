
args = commandArgs(trailingOnly=TRUE)
argsCount = 11

if (length(args)!=argsCount) {
  stop("Correlation_between_cor_analysis_inputpstar_docker_v.1.0.R libPath inputFile1 inputFile2 inputFile3 cor_method in_pstar x_title y_title plot_title legend_title outputFileName")
}
.libPaths(args[1])
inputFile1 <- args[2]
inputFile2 <- args[3]
inputFile3 <- args[4]

cor_method <- args[5]
if (is.na(cor_method)) {
  cor_method <- "pearson"
}
in_pstar <- args[6]
if (is.na(cor_method)) {
  cor_method <- "yes"
}
x_title <- args[7] 
if (is.na(x_title)) {
  x_title <- "cells"
}
y_title <- args[8] 
if (is.na(y_title)) {
  y_title <- "gene"
}
plot_title <- args[9] 
if (is.na(plot_title)) {
  plot_title <- "correlation"
}           
legend_title <- args[10]
if (is.na(legend_title)) {
  legend_title <- "Correlation"
}
outputFileName <- args[11]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}

library(ggplot2)
library(dplyr)
library(data.table)
library(tidyverse)

#ssgsea <- read.table(inputFile1,header = T,row.names = 1,sep = "\t")
#gene_expr <- data.table::fread(inputFile2, data.table = F, )
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
ssgsea = read_data(file = filename1,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename1, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename1,col_names=has_header)
	
  } else {
  stop("[ERRO] xls xlsx")}
  }

  
  ssgsea = read_data(file = filename1,has_header = T)
  ssgsea =as.data.frame(ssgsea)
  row.names(ssgsea)=ssgsea[,1]
  ssgsea = ssgsea[,-1]
 
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
gene_expr = read_data(file = filename2,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename2, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename2,col_names=has_header)
	
  } else {
  stop("[ERRO] xls xlsx")}
  }

  
  gene_expr = read_data(file = filename2,has_header = T)
  gene_expr =as.data.frame(gene_expr)
  row.names(gene_expr)=gene_expr[,1]
  gene_expr = gene_expr[,-1]
 
  }

#rownames(gene_expr) <- gene_expr[,1]
#gene_expr <- gene_expr[,-1]


ssgsea <- ssgsea[colnames(gene_expr),]


#genelist <- read.table(inputFile3)
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
          read.table(filename3, header = has_header, fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
        }
      )
  }  else {
    stop("[ERRO] txt csv")
  }
  return(df)
    
}
genelist = read_data(file = filename3,has_header = F)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename3, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename3,col_names=has_header)
	
  } else {
  stop("[ERRO] xls xlsx")}
  }

  
  genelist = read_data(file = filename3,has_header = F)
  genelist =as.data.frame(genelist)
  colnames(genelist)="V1"

 
  }

genelist <- genelist$V1


gene <- genelist
immuscore <- function(gene){
  y <- as.numeric(gene_expr[gene,])
  colnames <- colnames(ssgsea)
  do.call(rbind,lapply(colnames, function(x){
    dd  <- cor.test(as.numeric(ssgsea[,x]), y , method=cor_method)
    data.frame(gene=gene,immune_cells=x,cor=dd$estimate,p.value=dd$p.value )
  }))
}


data <- do.call(rbind,lapply(genelist,immuscore))


write.csv(data, "correlation.csv", quote = F, row.names = F)

data$pstar <- ifelse(data$p.value < 0.05,
       ifelse(data$p.value < 0.01,
              ifelse(data$p.value < 0.001,"***","**"),"*"),"")
data <- as.data.frame(data)


p = ggplot(data, aes(immune_cells, gene)) + 
             geom_tile(aes(fill = cor), colour = "white",size=0.8)+
               scale_fill_gradient2(low = "blue",mid = "white",high = "red")+
           geom_text(aes(label=pstar),col ="black",size = 4)+
               theme(axis.text.x = element_text(size = 8,angle = 45, hjust = 1),
               axis.text.y = element_text(size = 8),
			   plot.title = element_text(size =15,hjust = 0.5),
               axis.title.x = element_text(size=12),
               axis.title.y = element_text(size=12))
             			   
			 
yes_pstar <- c("yes")	
no_pstar <- c("no")		 
if (in_pstar %in% yes_pstar){p1=p+ labs(x=x_title,y=y_title,title=plot_title,
               fill =paste0(" * p < 0.05","\n\n","** p < 0.01","\n\n","*** p < 0.001","\n\n",legend_title))			   
ggsave(plot=p1,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=25,height=10,dpi=600)
}else if(in_pstar %in% no_pstar){p2=p+labs(x=x_title,y=y_title,title=plot_title,fill =legend_title)
ggsave(plot=p2,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=25,height=10,dpi=600)
}
