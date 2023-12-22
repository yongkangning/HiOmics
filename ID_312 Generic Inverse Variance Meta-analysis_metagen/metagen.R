args = commandArgs(trailingOnly=TRUE)
argsCount = 3

if (length(args)!=argsCount) {
  stop("metagen.R libPath inputFile is_sm")
}
.libPaths(args[1])

inputFile <- args[2]

is_sm<- args[3]
if (is.na(is_sm)) {
  is_sm <- "RD" 
}

library(tidyverse)
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

#data<-read.table("input.csv",header = T,sep = ",")
library(meta)



meta4 <- metagen(data[,2],data[,3],
                  studlab = data[,1],
                  sm = is_sm)

svg(filename = "Forest.svg",height =length(data[,1])*0.7 ,width = 12)
forest(meta4,digits.se =2,
       col.diamond.fixed="lightslategray",
       col.diamond.lines.fixed="lightslategray",
       col.diamond.random="maroon",
       col.diamond.lines.random="maroon",
       col.square="skyblue",
       col.study="lightslategray")
dev.off()

svg(filename = "Funnel.svg")
funnel(meta4)
dev.off()

svg(filename = "Egger.svg")
metabias(meta4,plotit=TRUE,k.min = length(data[,1]))
dev.off()

svg(filename = "Sensitivity.svg",height =length(data[,1])*0.7 ,width = 12)
forest(metainf(meta4),
       col.diamond.fixed="lightslategray",
       col.diamond.lines.fixed="lightslategray",
       col.diamond.random="maroon",
       col.diamond.lines.random="maroon",
       col.square="skyblue",
       col.study="lightslategray")
dev.off()
