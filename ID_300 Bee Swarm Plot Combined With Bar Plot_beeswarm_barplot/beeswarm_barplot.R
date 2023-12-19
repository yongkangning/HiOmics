args = commandArgs(trailingOnly=TRUE)
argsCount = 7

if (length(args)!=argsCount) {
  stop("beeswarm_barplot.R libPath inputFile is_cex is_size is_alpha y_title outputFileName")
}
.libPaths(args[1])

inputFile <- args[2]

is_cex<- as.numeric(args[3])
if (is.na(is_cex)) {
  is_cex <- "2.5" 
}
is_size<- as.numeric(args[4])
if (is.na(is_size)) {
  is_size <- "6" 
}
is_alpha<- as.numeric(args[5])
if (is.na(is_alpha)) {
  is_alpha <- "0.4" 
}

y_title <- args[6]
if (is.na(y_title)) {
  y_title <- "value"
}

outputFileName <- args[7]
if (is.na(outputFileName)) {
  outputFileName <- "outputFile"
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

library(ggbeeswarm)
library(ggplot2)
p = ggplot(data, aes(x=data[,1],y=data[,2],shape=data[,1]))+
  geom_bar(stat="summary",mapping = aes(x=data[,1], y=data[,2], fill=data[,1]),
           width=0.9,
           size=0.5,color='black', fill='white',position=position_dodge())+
  stat_summary(fun.data = 'mean_se', 
               geom = "errorbar", 
               colour = "black",
               width = 0.2)+
  geom_beeswarm(cex = is_cex,dodge.width = 0.8,aes(y = data[,2],x=data[,1],fill=data[,1]),
                size=is_size, alpha = is_alpha,col = 'black', show.legend = FALSE )+
  scale_shape_manual(values =c(21,21,22,22,24,21,21,21,21,22,22,21,21,21))+
  theme_classic()+
  theme(axis.text = element_text(size = 12, color="black"),
        axis.line.y = element_line(color = 'black'),
        axis.title.y = element_text(size = 14, color="black"))+
  theme(axis.title.x = element_blank())+
  theme(panel.grid = element_blank(), 
        panel.background = element_blank())+
  labs(x = "", y = y_title,title = "")+
  scale_y_continuous(expand=c(0,0))
ggsave(plot = p,filename = paste(outputFileName,"svg",sep="."),
       device="svg",units="cm",dpi=600)
