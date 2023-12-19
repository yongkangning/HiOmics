args = commandArgs(trailingOnly=TRUE)
argsCount = 6

if (length(args)!=argsCount) {
  stop("spiral_track.R libPath inputFile spiral_start fill_col track_height is_date")
}
.libPaths(args[1])

inputFile <- args[2]

spiral_start<- as.numeric(args[3])
if (is.na(spiral_start)) {
  spiral_start <- "180" 
}
fill_col<- as.numeric(args[4])
if (is.na(fill_col)) {
  fill_col <- "2" 
}
track_height<- as.numeric(args[5])
if (is.na(track_height)) {
  track_height <- "0.6" 
}
is_date <- args[6]
if (is.na(is_date)) {
  is_date <- "yes"
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


library(spiralize)
library(dplyr)
svg(filename = "result.svg")

#inputFile="input.csv"
#data <- read.table(inputFile,header = T,sep = ",")

if(is_date %in% c("yes")){ 
  data[,1] <- as.Date(data[,1]) 
  spiral_initialize_by_time(xlim = range(data[,1]),
                            start = spiral_start , 
                            unit_on_axis = "months",
                            period = "year",
                            period_per_loop = 12,
                            polar_lines_by = 360/12)
  spiral_track(height = track_height,ylim = range(data[,2])) 
  spiral_axis()
  spiral_lines(data[,1], data[,2], area = TRUE, gp = gpar(fill = fill_col, col = NA))
  spiral_yaxis()
  
}else if(is_date %in% c("no")){ 
  
  spiral_initialize(xlim = range(data[,1]),
                    start = spiral_start , 
                    polar_lines_by = 360/12)
  spiral_track(height = track_height,ylim = range(data[,2])) 
  spiral_axis()
  spiral_lines(data[,1], data[,2], area = TRUE, gp = gpar(fill = fill_col, col = NA))
  spiral_yaxis() 
  
  
}

dev.off()

