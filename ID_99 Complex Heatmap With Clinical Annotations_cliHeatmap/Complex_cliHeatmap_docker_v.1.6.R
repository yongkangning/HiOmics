
args = commandArgs(trailingOnly=TRUE)
argsCount = 8


if (length(args)!=argsCount) {
  stop("Complex_cliHeatmap_docker_v.1.6.R libPath inputFile1 is_scale annotation inputFile2 inputdata inputFile3 outputFileName")
}
.libPaths(args[1])
inputFile1 <- args[2]

is_scale <- args[3]
if (is.na(is_scale)) {
  is_scale <- "none"
}
annotation <- args[4]
if (is.na(annotation)) {
  annotation <- "yes"
}
inputFile2 <- args[5]
inputdata <- args[6]
if (is.na(inputdata)) {
  inputdata <- "no"
}

inputFile3 <- args[7]
outputFileName <- args[8]
if (is.na(outputFileName)) {
  outputFileName <- "heatmap"
}

library(pheatmap)
library(myplot)
library(tidyverse)

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

no_annotation <- c("no")
yes_annotation <- c("yes")
if(annotation %in% yes_annotation){
#rt=read.table(inputFile1, sep="\t", header=T, row.names=1, check.names=F)       
#Type=read.table(inputFile2, sep="\t", header=T, row.names=1, check.names=F)     
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
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
  }
                              Type <- read_data(file = filename2,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {
read_data <- function(filename2, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename2,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }
  
  Type = read_data(file = filename2,has_header = T)
  Type =as.data.frame(Type)
  row.names(Type)=Type[,1]
  Type = Type[,-1]
                          # cancer_type <- read_data(file = filename2,has_header = F,has_rownames=1)
                           #cancer_type <- read.table(inputFile2,header=F,row.names=1)
						  
}


sameSample=intersect(colnames(rt),row.names(Type))
rt=rt[,sameSample]
Type=Type[sameSample,,drop = FALSE]
#Type=Type[order(Type[,var]),]   
#rt=rt[,row.names(Type)]


input_alldata <- c("no")
input_interest_genedata <- c("yes")


if(inputdata %in% input_interest_genedata){


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
          read.csv(filename3, header = has_header,fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename3, header = has_header,fileEncoding = encode,sep="\t",check.names=FALSE),
        warning = function(e) {
          read.table(filename3, header = has_header,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
        }
      )
  }  else {
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
  }
                              interest_gene <- read_data(file = filename3,has_header = F)

}else if (filetype %in% c("xls", "xlsx")) {
read_data <- function(filename3, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename3,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }
  
  interest_gene = read_data(file = filename3,has_header = F)
 # interest_gene =as.data.frame(interest_gene)
 #row.names(interest_gene)=interest_gene[,1]
 # interest_gene = interest_gene[,-1]
						  
}

#interest_gene <- read.table(inputFile3)
interest_gene <- interest_gene$V1
data_interest_gene <- rt[interest_gene,]



heatmap=myplot({pheatmap(data_interest_gene, annotation=Type, 
         color = colorRampPalette(c("green", "white", "red"))(50),
         cluster_cols =F,    
         scale=is_scale,  
         show_colnames=F,
         fontsize=7.5)
		 })
		 
}else if(inputdata %in% input_alldata){

heatmap=myplot({pheatmap(rt, annotation=Type, 
         color = colorRampPalette(c("green", "white", "red"))(50),
         cluster_cols =F,    
         scale=is_scale,  
         show_colnames=F,
         fontsize=7.5)
		 })
		 
		 
}		 
 
}else if(annotation %in% no_annotation){

input_alldata <- c("no")
input_interest_genedata <- c("yes")


if(inputdata %in% input_interest_genedata){


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
          read.csv(filename3, header = has_header,fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename3, header = has_header,fileEncoding = encode,sep="\t",check.names=FALSE),
        warning = function(e) {
          read.table(filename3, header = has_header,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
        }
      )
  }  else {
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
  }
                              interest_gene <- read_data(file = filename3,has_header = F)

}else if (filetype %in% c("xls", "xlsx")) {
read_data <- function(filename3, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename3,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }
  
  interest_gene = read_data(file = filename3,has_header = F)
 # interest_gene =as.data.frame(interest_gene)
 #row.names(interest_gene)=interest_gene[,1]
 # interest_gene = interest_gene[,-1]
						  
}

#interest_gene <- read.table(inputFile3)
interest_gene <- interest_gene$V1
data_interest_gene <- rt[interest_gene,]



heatmap=myplot({pheatmap(data_interest_gene, 
         color = colorRampPalette(c("green", "white", "red"))(50),
         cluster_cols =F,    
         scale=is_scale,  
         show_colnames=F,
         fontsize=7.5)
		 })
		 
}else if(inputdata %in% input_alldata){

heatmap=myplot({pheatmap(rt, 
         color = colorRampPalette(c("green", "white", "red"))(50),
         cluster_cols =F,    
         scale=is_scale,  
         show_colnames=F,
         fontsize=7.5)
		 })
}
}
plotsave(heatmap,file=paste(outputFileName,"svg",sep="."),unit="cm",width=20,height=20,dpi=600)

