


args = commandArgs(trailingOnly=TRUE)
argsCount = 7

if (length(args)!=argsCount) {
  stop("barplot_docker3.R libPath inputFile x_title y_title plot_title is_width outputFileName")
}
.libPaths(args[1])
 
inputFile <- args[2]

x_title <- args[3]
if (is.na(x_title)) {
  x_title <- "x"
}
y_title <- args[4]
if (is.na(y_title)) {
  y_title <- "y"
}
plot_title <- args[5]
if (is.na(plot_title)) {
  plot_title <- "barplot"
}
is_width <- as.numeric(args[6])
if (is.na(is_width)) {
  is_width <- "barplot"
}
outputFileName <- args[7]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}

library(reshape2)
library(ggplot2)
library(dplyr)
library(colourpicker)
library(tidyverse)

#data=read.table(inputFile,header=T,sep="\t",check.names=F,row.names=1,quote = "")

filename = inputFile
 
  file_suffix <- strsplit(filename, "\\.")[[1]]
  filetype <- file_suffix[length(file_suffix)]
  
  encode <-
    guess_encoding(filename, n_max = 1000)[1, 1, drop = TRUE]
  # print(encode)
  if(is.na(encode)) {
    stop(paste("[ERRO]", filename,"encoding_nonsupport"))
  }
  if(filetype %in% c("csv","txt")){
  
read_data <- function(filename, has_header,has_rownames) {
 
    if (filetype == "csv") {
    df <-
      tryCatch(
        read.csv(filename, header = has_header, row.names =has_rownames, fileEncoding = encode,sep=",",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.csv(filename, header = has_header, row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename, header = has_header, row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.table(filename, header = has_header, row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  }  else {
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
    
}
data = read_data(file = filename,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  data = read_data(file = filename,has_header = T)
  data =as.data.frame(data)
  
  }



Perccol <-  prop.table(as.matrix(data),2)

id <- row.names(Perccol)
Mydata <- as.data.frame(cbind(id,Perccol),stringsAsFactors = F)



Mydata$id <- factor(Mydata$id,levels = rev(Mydata$id))
Mydata <- melt(Mydata,id.vars="id")

col_map <- c("#FF6A6A", "#EEAD0E", "#00FFFF", "#87CEFA", "#FF6EB4", "#76EE00",
             "#757575", "#AB82FF", "#7AC5CD", "#EEEE00", "#9AC0CD", "#EEA9B8",
             "#6CA6CD", "#CD96CD", "#FF4040","#CD3333", "#6B8E23",   "#8B5A00", 
             "#836FFF",  "#CD6600", "#7FFFD4", "#6959CD", "#0000FF", "#E0EEEE", 
             "#838B83", "#8B4726", "#CD0000", "#00C5CD",   "#68228B","#EE00EE", 
             "#228B22","#8B7E66","#EEE9BF", "#0A0A0A","#F8F8FF", "#9400D3", 
             "#556B2F", "#EE7600", "#EEC900", "#CDAD00","#98F5FF", "#008B8B", 
             "#DEB887","#B0B0B0",  "#008B00", "#00EE00", "#27408B", "#473C8B",
             "#2E8B57", "#8B2252", "#F5DEB3", "#FFFF00", 
             "#4876FF",  "#B03060", "#B4CDCD", "#7A8B8B", "#CD1076", "#FFE1FF", 
             "#FF7F00", "#B8860B", "#2F4F4F", "#EEE8CD", "#FFE7BA", 
             "#FF8C00",  "#A3A3A3", "#424242", "#858585",  "#CD5555",
             "#EEEED1", "#191970", "#EE8262", "#9FB6CD", "#D02090", "#FFA54F",
             "#CD919E", "#DA70D6", "#FF4500", "#EEDC82", "#8B814C", "#8B8970",
             "#CDBE70", "#00008B")
			 

p = ggplot(data=Mydata,aes(x=variable,y=as.numeric(value),fill=id))+
  geom_bar(stat="identity",position="stack", color="NA", 
           width=0.7,size=1,alpha=0.7)+
  scale_y_continuous(labels = function(x) paste0(100*x),expand=c(0,0))+
  theme_bw()+ labs(x=x_title,y=y_title,title=plot_title)+
  theme(plot.title = element_text(size =15,hjust = 0.5),
        axis.title.x=element_text(size=10),
        axis.title.y=element_text(size=10),
        axis.text.x=element_text(angle=45,vjust =1.2,hjust =1.2,size = 8),
        axis.text.y=element_text(size =8),axis.ticks = element_line(size=0.2),
        panel.border = element_blank())+
  theme(legend.key.size = unit(10,"pt"))+
  theme(legend.text = element_text( size =8),legend.title = element_blank())+
  theme(panel.grid.major=element_blank(),
        panel.background = element_rect(fill = "transparent",colour = NA),
        plot.background = element_rect(fill = "transparent",colour = NA),
        panel.grid.minor = element_blank(),
        panel.border = element_blank())+
		scale_fill_manual(values=rep(col_map,5))+
  theme(axis.line = element_line(colour="black",size = 0.2))
  #guides(fill = guide_legend(override.aes = list(colour = "NA")))+
  
ggsave(plot=p,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=is_width,height=10,dpi=600)
















