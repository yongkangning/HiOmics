
args = commandArgs(trailingOnly=TRUE)
argsCount = 7

if (length(args)!=argsCount) {
  stop("bubble.R libPath inputFile point_size is_face x_title y_title outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]

point_size <- as.numeric(args[3])
if (is.na(point_size)) {
  point_size <- "2"
}
is_face <- args[4] 
if (is.na(is_face)) {
  is_face <- "yes"
}
x_title <- args[5] 
if (is.na(x_title)) {
  x_title <- "condition"
}
y_title <- args[6]
if (is.na(y_title)) {
  y_title <- "value"
}

outputFileName <- args[7]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}
library(dplyr)
#RNA =read.table(inputFile1,header=T,sep = "\t", check.names=FALSE,stringsAsFactors = FALSE,quote="")
#Ribo=read.table(inputFile2,header=T,sep = "\t", check.names=FALSE,stringsAsFactors = FALSE,quote="")
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
	
#data <- read.table("input1.csv",header = T,sep = ",",check.names=FALSE,stringsAsFactors = FALSE,quote="")

library(ggplot2)
library(RColorBrewer)
library(ggpubr) 

#palette <- c(brewer.pal(7,"Set2")[c(4,5)])


if(is_face %in% c("yes")){
p=ggpaired(data, x = colnames(data)[3] , y = colnames(data)[4] ,
         color = colnames(data)[3] ,  
         #palette = palette,  
         line.color = "grey50", 
         line.size =0.2,  
         point.size = point_size,  
         #width=0.6,  
         facet.by = colnames(data)[2] ,  
         short.panel.labs = FALSE)+
  
  stat_compare_means(paired = TRUE)+
  
  theme_minimal()+
  theme(strip.background = element_rect(fill="grey90"),
        strip.text = element_text(size=13,face="plain",color="black"),
        axis.title=element_text(size=13,face="plain",color="black"),
        axis.text = element_text(size=11,face="plain",color="black"),
        panel.background=element_rect(colour="black",fill=NA),
        panel.grid=element_blank(),
        legend.position="none",
        legend.background=element_rect(colour=NA,fill=NA),
        axis.ticks=element_line(colour="black"))+
	labs(x=x_title,y=y_title)

}else if(is_face %in% c("no")){
p=ggpaired(data, x = colnames(data)[3] , y = colnames(data)[4] ,
         color = colnames(data)[3] ,  
         #palette = palette,  
         line.color = "grey50", 
         line.size =0.2,  
         point.size = point_size,  
         #width=0.6,  
         #facet.by = colnames(data)[1] ,  
         short.panel.labs = FALSE)+
  
  stat_compare_means(paired = TRUE)+
  
  theme_minimal()+
  theme(strip.background = element_rect(fill="grey90"),
        strip.text = element_text(size=13,face="plain",color="black"),
        axis.title=element_text(size=13,face="plain",color="black"),
        axis.text = element_text(size=11,face="plain",color="black"),
        panel.background=element_rect(colour="black",fill=NA),
        panel.grid=element_blank(),
        legend.position="none",
        legend.background=element_rect(colour=NA,fill=NA),
        axis.ticks=element_line(colour="black"))+
	labs(x=x_title,y=y_title)
}

ggsave(plot=p,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",dpi=600)


