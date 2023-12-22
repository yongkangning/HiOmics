args = commandArgs(trailingOnly=TRUE)
argsCount = 6

if (length(args)!=argsCount) {
  stop("Plate_Plot.R libPath inputFile is_title colour is_size is_type")
}
.libPaths(args[1])

inputFile <- args[2]

is_title<- args[3]
if (is.na(is_title)) {
  is_title <- "Custom_Title" 
}
colour<- args[4]
if (is.na(colour)) {
  colour <- "colour1" 
}
is_size<- as.numeric(args[5])
if (is.na(is_size)) {
  is_size <- "96" 
}
is_type <- args[6]
if (is.na(is_type)) {
  is_type <- "round"
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


library(ggplate)
svg(filename = "result.svg")
if(colour %in% c("colour1")){ 
plate_plot(
  data = data,
  position = well,
  value = value,
  title = is_title, 
  plate_size = is_size, 
  plate_type = is_type) 
  
}else if(colour %in% c("colour2")){ 
plate_plot(
  data = data,
  position = well,
  value = value,
  title = is_title,
  plate_size = is_size,
  plate_type = is_type,
  colour = c("#000004FF", "#51127CFF", "#B63679FF", "#FB8861FF", "#FCFDBFFF"))

}else if(colour %in% c("colour3")){ 
  plate_plot(
    data = data,
    position = well,
    value = value,
    title = is_title,
    plate_size = is_size,
    plate_type = is_type,
    colour = c("white", "red"))
}
dev.off()