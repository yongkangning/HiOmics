

args = commandArgs(trailingOnly=TRUE)
argsCount = 6

if (length(args)!=argsCount) {
  stop("pianchatu_docker_v1.0.R libPath inputFile x_title y_title group outputFileName")
}

.libPaths(args[1])
inputFile <- args[2]

x_title <- args[3]
if (is.na(x_title)) {
  x_title <- "logFC"
}

y_title <- args[4]
if (is.na(y_title)) {
  y_title <- "gene"
}

group <- args[5]
if (is.na(group)) {
  group <- "group"
}

outputFileName <- args[6]
if (is.na(outputFileName)) {
  outputFileName <- "deviation_map"
}

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
        read.csv(filename1, header = has_header, fileEncoding = encode,sep=",",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.csv(filename1, header = has_header,fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename1, header = has_header,fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.table(filename1, header = has_header,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE, na.string = "")
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



#up_down <- ifelse(data[,2] > 0,"up","down")                 
#data <- cbind(data,up_down)  
#    data <- data[order(data$logFC),]   
#  
   data <- data[order(data$logFC),]   
list <- rev(data[,1])
list <- factor(list,levels = list)
p=ggplot(data,aes(x=data[,2],y=factor(data[,1],levels = list) ))+
  geom_bar(stat = "identity",aes(fill=data[,3]))+
  scale_fill_brewer(palette='Set1',direction = -1)+ 
  labs(x=x_title,y=y_title,fill=group)+
  theme_bw() +  
  theme(plot.title = element_text(size =15,hjust = 0.5),
        axis.title.x=element_text(size=12),
        axis.title.y=element_text(size=12),
        axis.text.x=element_text(size = 8),
        axis.text.y=element_text(size =8),
        axis.ticks = element_line(size=0.2)
  )+
  theme(legend.key.size = unit(10,"pt"))+
  theme(legend.text = element_text( size =8),
  legend.title = element_text(size = 8))

ggsave(plot=p,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",dpi=600)




