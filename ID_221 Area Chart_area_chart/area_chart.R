args = commandArgs(trailingOnly=TRUE)
argsCount = 8

if (length(args)!=argsCount) {
  stop("area_chart.R libPath inputFile is_alpha x_title y_title plot_title legend_title outputFileName")
}
.libPaths(args[1])

inputFile <- args[2]


is_alpha<- as.numeric(args[3])
if (is.na(is_alpha)) {
  is_alpha <- "0.5"
}
x_title <- args[4]
if (is.na(x_title)) {
  x_title <- "x"
}
y_title <- args[5]
if (is.na(y_title)) {
  y_title <- "y"
}
plot_title <- args[6]
if (is.na(plot_title)) {
  plot_title <- "plot"
}
legend_title <- args[7]
if (is.na(legend_title)) {
  legend_title <- "group"
}
outputFileName <- args[8]
if (is.na(outputFileName)) {
  outputFileName <- "outputFile"
}

library(viridis)
library(tidyverse)
#setwd("C:\\Users\\Administrator\\Desktop\\swxxcl\\area_chart")
#inputFile="input.txt"
#data <- read.table(inputFile,header = T)
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
# Plot
p=ggplot(data, aes(x=data[,1], y=data[,3], fill=data[,2])) + 
  geom_area(alpha=is_alpha ,
            size=.9, colour="white") +
  scale_fill_viridis(discrete = T) +
  theme_minimal() +
  labs(y=y_title,x=x_title,title =plot_title) + guides(fill=guide_legend(title = legend_title))

ggsave(plot=p,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",dpi=600)
