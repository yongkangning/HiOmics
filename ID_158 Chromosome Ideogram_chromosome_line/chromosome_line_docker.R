

args = commandArgs(trailingOnly=TRUE)
argsCount = 6

if (length(args)!=argsCount) {
  stop("chromosome_heatmap_docker.R libPath inputFile1 inputFile2 inputFile3 labeltype outputFileName")
}
.libPaths(args[1])

 
inputFile1 <- args[2]
inputFile2 <- args[3]
inputFile3 <- args[4]
labeltype <- args[5]
if (is.na(labeltype)) {
  labeltype <- "line"
}
								  
outputFileName <- args[6]
if (is.na(outputFileName)) {
  outputFileName <- "chromosome_line"
}


options(stringsAsFactors = FALSE) 
library(RIdeogram)
library(tidyverse)
#location <- read.csv(chromosome_pos)
#logfc <- read.csv(DEGs_LFC)
#marker <- read.csv(gene_type)

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
         
         read_data <- function(filename1, has_header) {
           
           if (filetype == "csv") {
             df <-
               tryCatch(
                 read.csv(filename1, header = has_header,fileEncoding = encode,sep=",",check.names=FALSE),
                 warning = function(e) {
                   read.csv(filename1, header = has_header, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
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
             stop("[ERRO] Only support txt csv xls xlsx")
           }
           return(df)
           
         }
         karyotype = read_data(file = filename1,has_header = T)
         
       }else if (filetype %in% c("xls", "xlsx")) {
         
         read_data <- function(filename1, has_header) {
           if(filetype %in% c("xls", "xlsx")){
             df <- readxl::read_excel(filename1,col_names=has_header)
             
           } else {
             stop("[ERRO] Only support txt csv xls xlsx")}
         }
         
         
         karyotype = read_data(file = filename1,has_header = T)
         karyotype =as.data.frame(karyotype)
         
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
                 read.csv(filename2, header = has_header,fileEncoding = encode,sep=",",check.names=FALSE),
                 warning = function(e) {
                   read.csv(filename2, header = has_header, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
                 }
               )
           } else if (filetype == "txt") {
             df <-
               tryCatch(
                 read.table(filename2, header = has_header, fileEncoding = encode,sep="\t",check.names=FALSE),
                 warning = function(e) {
                   read.table(filename2, header = has_header,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
                 }
               )
           }  else {
             stop("[ERRO] Only support txt csv xls xlsx")
           }
           return(df)
           
         }
         overlaid = read_data(file = filename2,has_header = T)
         
       }else if (filetype %in% c("xls", "xlsx")) {
         
         read_data <- function(filename2, has_header) {
           if(filetype %in% c("xls", "xlsx")){
             df <- readxl::read_excel(filename2,col_names=has_header)
             
           } else {
             stop("[ERRO] Only support txt csv xls xlsx")}
         }
         
         
         overlaid = read_data(file = filename2,has_header = T)
         overlaid =as.data.frame(overlaid)
         
       }      

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
                 read.csv(filename3, header = has_header,fileEncoding = encode,sep=",",check.names=FALSE),
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
             stop("[ERRO] Only support txt csv xls xlsx")
           }
           return(df)
           
         }
         label = read_data(file = filename3,has_header = T)
         
       }else if (filetype %in% c("xls", "xlsx")) {
         
         read_data <- function(filename3, has_header) {
           if(filetype %in% c("xls", "xlsx")){
             df <- readxl::read_excel(filename3,col_names=has_header)
             
           } else {
             stop("[ERRO] Only support txt csv xls xlsx")}
         }
         
         #
         label = read_data(file = filename3,has_header = T)
         label =as.data.frame(label)
         
       }      
	   


ideogram(
         karyotype = karyotype, 
         overlaid = overlaid, 
         label = label,
         label_type = labeltype, 
         colorset1 = c("#e5f5f9", "#99d8c9", "#2ca25f")
         ) 
convertSVG("chromosome.svg", file = outputFileName, device = "pdf",dpi = 900)