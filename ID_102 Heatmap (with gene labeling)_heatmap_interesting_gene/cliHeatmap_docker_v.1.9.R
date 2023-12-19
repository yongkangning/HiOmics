
args = commandArgs(trailingOnly=TRUE)
argsCount = 10


if (length(args)!=argsCount) {
  stop("cliHeatmap_docker_v.1.9.R libPath inputFile1 annotation inputFile2 inputdata inputFile3 legend_title is_height is_withd outputFileName")
}
.libPaths(args[1])
inputFile1 <- args[2]

annotation <- args[3]
if (is.na(annotation)) {
  annotation <- "yes"
}
inputFile2 <- args[4]

inputdata <- args[5]
if (is.na(inputdata)) {
  inputdata <- "yes"
}
inputFile3 <- args[6]
 
legend_title <- args[7]
if (is.na(legend_title)) {
  legend_title <- "matrix"
}
is_height <- as.numeric(args[8])
 if (is.na(is_height)) {
  is_height <- "15"
}
is_withd <- as.numeric(args[9])
 if (is.na(is_withd)) {
  is_withd <- "30"
}
outputFileName <- args[10]
if (is.na(outputFileName)) {
  outputFileName <- "heatmap"
}
#setwd("F:\\zuotu\\Complex_heatmap_interesting_gene")
library(ComplexHeatmap)
library(pheatmap)
#library(myplot)
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
rt1 = read_data(file = filename1,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename1, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename1,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  rt1 = read_data(file = filename1,has_header = T)
  rt1 =as.data.frame(rt1)
  row.names(rt1)=rt1[,1]
  rt1 = rt1[,-1]
  
  }

#rt1=read_data(filename1, has_header=T, has_rownames=1)       

#for (i in 1:nrow(rt)) rt[i, ] <- scale(log(unlist(rt[i, ]) + 1, 2))
#rt1 <- as.matrix(rt)

no_annotation <- c("no")
yes_annotation <- c("yes")

if(annotation %in% yes_annotation){

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

#Type=read_data(filename2, has_header=T, has_rownames=1)     

sameSample=intersect(colnames(rt1),row.names(Type))
rt2=rt1[,sameSample]
Type=Type[sameSample,,drop = FALSE]
#Type=Type[order(Type[,var]),]   
#rt=rt[,row.names(Type)]
heat <- Heatmap(rt2, name = legend_title,
                col = colorRampPalette(c('SeaGreen4', 'white', 'IndianRed1'))(100), 
                heatmap_legend_param = list(legend_height = unit(30,'mm')),  
                 cluster_columns= FALSE,  
				  cluster_rows = T,
                   show_column_names=FALSE,  
				    show_row_names = T, 
                top_annotation = HeatmapAnnotation(df = Type,
                                  simple_anno_size = unit(4, 'mm'),
                                # col = list(Group = c('A' = '#00DAE0', 'B' = '#FF9289')),  
                               show_annotation_name = FALSE),
                           column_names_gp = gpar(fontsize = 10),
                        row_names_gp = gpar(fontsize = 8))
	

input_alldata <- c("no")
input_interest_genedata <- c("yes")

svg(filename = paste(outputFileName,"svg",sep="."),height = is_height,width = is_withd)
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



#interest_gene <- read_data(filename3, has_header = F)
heat + rowAnnotation(link = anno_mark(at = which(rownames(rt2) %in% interest_gene$V1),
                                    labels = interest_gene$V1, labels_gp = gpar(fontsize =8)))
#p=myplot({heat + rowAnnotation(link = anno_mark(at = which(rownames(rt) %in% interest_gene$V1),
#                                     labels = interest_gene$V1, labels_gp = gpar(fontsize =8)))
#									 })
}else if(inputdata %in% input_alldata){

#p=myplot({heat})
heat
}


	
}else if(annotation %in% no_annotation){

heat <- Heatmap(rt1, name = legend_title,
                col = colorRampPalette(c('SeaGreen4', 'white', 'IndianRed1'))(100), 
                heatmap_legend_param = list(legend_height = unit(15,'mm')),  
                 cluster_columns= FALSE,  
				  cluster_rows = T,
                   show_column_names=FALSE,  
				    show_row_names = T) 
									

input_alldata <- c("no")
input_interest_genedata <- c("yes")

svg(filename = paste(outputFileName,"svg",sep="."),height = is_height,width = is_withd)
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



#interest_gene <- read_data(filename3, has_header = F)
heat + rowAnnotation(link = anno_mark(at = which(rownames(rt1) %in% interest_gene$V1),
                                    labels = interest_gene$V1, labels_gp = gpar(fontsize =8)))
#p=myplot({heat + rowAnnotation(link = anno_mark(at = which(rownames(rt) %in% interest_gene$V1),
#                                     labels = interest_gene$V1, labels_gp = gpar(fontsize =8)))
#									 })
}else if(inputdata %in% input_alldata){

#p=myplot({heat})
heat
}
}
dev.off()
#plotsave(p,file=paste("outputFileName","svg",sep="."),unit="cm",width=20,height=20,dpi=600)
