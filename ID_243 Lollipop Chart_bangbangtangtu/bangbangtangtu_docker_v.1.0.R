


args = commandArgs(trailingOnly=TRUE)
argsCount = 9

if (length(args)!=argsCount) {
  stop("mantel_test.R libPath inputFile x_lab y_lab have_group group have_size is_size outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]

x_lab <- args[3] 
if (is.na(x_lab)) {
  x_lab <- "logFC"
}
y_lab <- args[4]
if (is.na(y_lab)) {
  y_lab <- "Description"
}
have_group <- args[5]
if (is.na(have_group)) {
  have_group <- "yes"
}

group <- args[6]
if (is.na(group)) {
  group <- "Category"
}
have_size <- args[7]
if (is.na(have_size)) {
  have_size <- "yes"
}
is_size <- args[8]
if (is.na(is_size)) {
  is_size <- "Count"
}
outputFileName <- args[9]
if (is.na(outputFileName)) {
  outputFileName <- "bubble_plot_facet"
}

library(tidyverse)
library(RColorBrewer)
library(ggplot2)


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
          read.csv(filename1, header = has_header, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename1, header = has_header, fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE, na.string = ""),
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

#data <- read.table("kegg.txt",header = T,sep = "\t",na.strings = "")
#head(data)
list <- rev(data[,y_lab]) 
list <- factor(list,levels = list) 

color=c("#FF6A6A", "#EEAD0E", "#00FFFF", "#00EE00", "#FF6EB4", "#87CEFA", "#7A8B8B", "#008B00", "#EE7600",
                  "#AB82FF", "#7AC5CD", "#EEEE00", "#EEA9B8",
                 "#6CA6CD", "#CD96CD", "#FF4040","#CD3333", "#6B8E23",   "#8B5A00", 
                 "#836FFF",  "#CD6600", "#7FFFD4", "#6959CD", "#0000FF", "#E0EEEE", 
                 "#838B83", "#8B4726", "#CD0000", "#00C5CD","#76EE00",   "#68228B","#EE00EE", 
                 "#228B22","#8B7E66","#EEE9BF", "#0A0A0A","#F8F8FF", "#9400D3", 
                 "#556B2F", "#EEC900", "#CDAD00","#98F5FF", "#008B8B", "#757575",
                 "#DEB887","#B0B0B0",   "#27408B", "#473C8B",
                 "#2E8B57", "#8B2252", "#F5DEB3", "#FFFF00", "#9AC0CD", 
                 "#4876FF",  "#B03060", "#B4CDCD", "#CD1076", "#FFE1FF", 
                 "#FF7F00", "#B8860B", "#2F4F4F", "#EEE8CD", "#FFE7BA", 
                 "#FF1C00",  "#A3A3A3", "#424242", "#858585",  "#CD5555",
                 "#EEEED1", "#191970", "#EE8262", "#9FB6CD", "#D02090", "#FFA54F",
                 "#CD919E", "#DA70D6", "#FF4500", "#EEDC82", "#8B814C", "#8B8970",
                 "#CDBE70", "#00008B")
				 
				 
				 
if(have_group %in% c("yes")){
   if(have_size %in% c("yes")){			 
p=ggplot(data,aes_string(x=x_lab, 
                y=factor(data[,y_lab],levels=list)))+ 
  geom_point(aes_string(size=is_size,
                 color=group))+
  geom_segment(aes_string(x=0,xend=x_lab,
                   y=y_lab,yend=y_lab,color=group),cex=1)+
  scale_y_discrete(position = 'left')+  
  labs(y=NULL)+
  theme_bw()+
  scale_size(range = c(1,4))+
  scale_color_manual(values = rep(color,20))+
  theme(legend.position = "right")+
  theme(axis.ticks.length.x = unit(0.05,'cm'),
        axis.ticks.y = element_blank(),
        axis.text.x = element_text(size=14),
        axis.title.x = element_text(size = 20),
        axis.text.y = element_text(size = 10,
                                   face = 'bold'))

#category=unique(data$Category)
#for(i in 1:length(data$Category)){
#  for(j in 1:length(category)){
#    if(category[j]==data$Category[i])
#      col[i]=color[j]
#   }
#}
category=unique(data[,group])
col <- rep('black', length(data[,group]))
for(i in 1:length(data[,group])){
  for(j in 1:length(category)){
    if(category[j]==data[,group][i])
      col[i]=rep(color,10)[j]
  }
}


p1=p+
  theme(axis.text.y = element_text(color = rev(col))) 
  
  
  }else if(have_size %in% c("no")){
  p=ggplot(data,aes_string(x=x_lab, 
                y=factor(data[,y_lab],levels=list)))+ 
  geom_point(aes_string(#size=is_size,
                 color=group))+
  geom_segment(aes_string(x=0,xend=x_lab,
                   y=y_lab,yend=y_lab,color=group),cex=1)+
  scale_y_discrete(position = 'left')+  
  labs(y=NULL)+
  theme_bw()+
  scale_size(range = c(1,4))+
  scale_color_manual(values = rep(color,20))+
  theme(legend.position = "right")+
  theme(axis.ticks.length.x = unit(0.05,'cm'),
        axis.ticks.y = element_blank(),
        axis.text.x = element_text(size=14),
        axis.title.x = element_text(size = 20),
        axis.text.y = element_text(size = 10,
                                   face = 'bold'))

#category=unique(data$Category)
#for(i in 1:length(data$Category)){
#  for(j in 1:length(category)){
#    if(category[j]==data$Category[i])
#      col[i]=color[j]
#   }
#}
category=unique(data[,group])
col <- rep('black', length(data[,group]))
for(i in 1:length(data[,group])){
  for(j in 1:length(category)){
    if(category[j]==data[,group][i])
      col[i]=rep(color,10)[j]
  }
}


p1=p+
  theme(axis.text.y = element_text(color = rev(col)))
  
  }
  
}else if(have_group %in% c("no")){

   if(have_size %in% c("yes")){
p1=ggplot(data,aes_string(x=x_lab, 
                y=y_lab))+ 
  geom_point(aes_string(size=is_size,
                 color=y_lab))+
  geom_segment(aes_string(x=0,xend=x_lab,
                   y=y_lab,yend=y_lab,color=y_lab),cex=1)+
  scale_y_discrete(position = 'left')+  
  labs(y=NULL)+
  theme_bw()+
  scale_size(range = c(1,4))+
  scale_color_manual(values = rep(color,20))+
  theme(legend.position = "right")+
  theme(axis.ticks.length.x = unit(0.05,'cm'),
        axis.ticks.y = element_blank(),
        axis.text.x = element_text(size=14),
        axis.title.x = element_text(size = 20),
        axis.text.y = element_text(size = 10,
                                   face = 'bold'))

}else if(have_size %in% c("no")){
p1=ggplot(data,aes_string(x=x_lab, 
                y=factor(data[,y_lab],levels=list)))+ 
  geom_point(aes_string(#size=is_size,
                 color=y_lab))+
  geom_segment(aes_string(x=0,xend=x_lab,
                   y=y_lab,yend=y_lab,color=y_lab),cex=1)+
  scale_y_discrete(position = 'left')+  
  labs(y=NULL)+
  theme_bw()+
  scale_size(range = c(1,4))+
  scale_color_manual(values = rep(color,20))+
  theme(legend.position = "right")+
  theme(axis.ticks.length.x = unit(0.05,'cm'),
        axis.ticks.y = element_blank(),
        axis.text.x = element_text(size=14),
        axis.title.x = element_text(size = 20),
        axis.text.y = element_text(size = 10,
                                   face = 'bold'))

}

}

ggsave(p1,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",dpi=600)
