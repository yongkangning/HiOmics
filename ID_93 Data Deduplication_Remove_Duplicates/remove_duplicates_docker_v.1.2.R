

args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("sum_docker_v.1.0.R libPath inputFile r_clunm outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]

r_clunm <- as.numeric(args[3])
if (is.na(r_clunm)) {
  r_clunm <- 1
}

outputFileName <- args[4]
if (is.na(outputFileName)) {
  outputFileName <- "Remove_Duplicates"
}

library(tidyverse)

#data=read.table(inputFile,header=T,sep="\t",quote = "")
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
          read.csv(filename1, header = has_header, fileEncoding = encode,sep=",",check.names=FALSE,fill=TRUE, na.string = ""),
          warning = function(e) {
            read.csv(filename1, header = has_header, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE,fill=TRUE, na.string = "")
          }
        )
    } else if (filetype == "txt") {
      df <-
        tryCatch(
          read.table(filename1, header = has_header, fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE, na.string = ""),
          warning = function(e) {
            read.table(filename1, header = has_header, fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE, na.string = "")
          }
        )
    }  else {
      stop("[ERRO] Only support txt csv xls xlsx")
    }
    return(df)
    
  }
  data = read_data(file = filename1,has_header = T)
  
}else if (filetype %in% c("xls", "xlsx")) {
  
  read_data <- function(filename1, has_header) {
    if(filetype %in% c("xls", "xlsx")){
      df <- readxl::read_excel(filename1,col_names=has_header)
      
    } else {
      stop("[ERRO] Only support txt csv xls xlsx")}
  }
  
  
  data = read_data(file = filename1,has_header = T)
  data =as.data.frame(data)
  
}



library(dplyr)

data <- data[!duplicated(data[,r_clunm], fromLast = F), ]

write.table(data,file = paste(outputFileName,"txt",sep = "."),sep = "\t",row.names = F,quote=FALSE)


















