args = commandArgs(trailingOnly=TRUE)
argsCount = 6

if (length(args)!=argsCount) {
  stop("Ternary_Plot.R libPath inputFile group_title ave_title outputFileName")
}
.libPaths(args[1])

inputFile <- args[2]

is_alpha<- as.numeric(args[3])
if (is.na(is_alpha)) {
  is_alpha <- "0.6"
}
group_title <- args[4]
if (is.na(group_title)) {
  group_title <- "groups"
}
ave_title <- args[5]
if (is.na(ave_title)) {
  ave_title <- "ave"
}
outputFileName <- args[6]
if (is.na(outputFileName)) {
  outputFileName <- "outputFile"
}

library(viridis)
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
library(ggtern)
library(ggthemes)
x=colnames(data)[3]
y=colnames(data)[2]
z=colnames(data)[4]
p=ggtern(data=data,aes_string(x=x,y=y,z=z)) +
  geom_point(aes(size=data[,5],color=data[,6]),alpha=is_alpha) + 
  scale_color_tableau() +
  theme_bw() + 
  theme_arrowdefault() +
  guides(colour = guide_legend(group_title,override.aes = list(size=3.9,alpha=1)),
         size = guide_legend(ave_title))  
  #labs(x="X",y="Y",z="Z",title="Title")

ggsave(plot=p,filename=paste(outputFileName,"svg",sep="."),
       device='svg',units="cm",dpi=600)