       
args = commandArgs(trailingOnly=TRUE)
argsCount = 5

if (length(args)!=argsCount) {
  stop("Dumbbell.R libPath inputFile x_title y_title outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]

x_title <- args[3] 
if (is.na(x_title)) {
  x_title <- "Control"
}
y_title <- args[4]
if (is.na(y_title)) {
  y_title <- "Patient"
}

outputFileName <- args[5]
if (is.na(outputFileName)) {
  outputFileName <- "Dumbbell_plot"
}

#data <- read.table("input.txt",header = T,sep = "\t",na.strings = "")
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


library(ggplot2)
library(reshape2)
data_melt <- melt(data)
head(data_melt)

p <- ggplot(data_melt,aes(x = value, y = data_melt[,1])) +  
  geom_line(aes(group = data_melt[,1])) +
  geom_point(aes(color = variable), size = 3)+
  theme_light()+
  theme(panel.grid =element_blank())+
  labs(x=x_title,y=y_title)

ggsave(plot=p,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",dpi=600)












