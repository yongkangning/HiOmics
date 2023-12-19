

args = commandArgs(trailingOnly=TRUE)
argsCount = 11

if (length(args)!=argsCount) {
  stop("Y_break.R libPath inputFile xdata ydata is_group y_min y_max x_title y_title plot_title outputFileName")
}
.libPaths(args[1])

inputFile <- args[2]


xdata <- args[3]
if (is.na(xdata)) {
  xdata <- "AAP"
}
ydata <- args[4]
if (is.na(ydata)) {
  ydata <- "mean"
}
is_group <- args[5]
if (is.na(is_group)) {
  is_group <- "Sex"
}

y_min<- as.numeric(args[6])
if (is.na(y_min)) {
  y_min <- "500"
}
y_max<- as.numeric(args[7])
if (is.na(y_max)) {
  y_max <- "1200"
}

x_title <- args[8]
if (is.na(x_title)) {
  x_title <- "x"
}
y_title <- args[9]
if (is.na(y_title)) {
  y_title <- "y"
}
plot_title <- args[10]
if (is.na(plot_title)) {
  plot_title <- "barplot"
}

outputFileName <- args[11]
if (is.na(outputFileName)) {
  outputFileName <- "outputFile"
}
#setwd("C:\\Users\\Administrator\\Desktop\\Y-break")
library(ggbreak)
library(ggplot2)
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
  #row.names(data)=data[,1]
  #data = data[,-1]
}   
#data <- read.table(inputFile,header = T)

p=ggplot(data=data, aes_string(x=xdata, y=ydata, group=is_group, fill=is_group)) +
  
  geom_col(position="dodge") +
  
  
  geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd),width=0.6,
                position=position_dodge(0.9)) + 
  scale_y_break(c(y_min,y_max),
                scales = 1,
                space = 0.18,
                expand = c(0,0))+
  
  labs(y=y_title,x=x_title,title =plot_title)+
  theme_minimal() +
  theme(axis.line = element_line(color = "#3D4852"),    
        axis.ticks = element_line(color = "#3D4852"))

ggsave(plot=p,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",dpi=600)

