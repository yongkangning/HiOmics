
args = commandArgs(trailingOnly=TRUE)
argsCount = 8

if (length(args)!=argsCount) {
  stop("zuneixgxfx.R libPath inputFile stratum_width is_alpha text_size plot_title outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]

stratum_width <- as.numeric(args[3])
if (is.na(stratum_width)) {
  stratum_width <- "0.3"
}

is_alpha <- as.numeric(args[4])
if (is.na(is_alpha)) {
  is_alpha <- "0.5"}
text_size <- as.numeric(args[5])
if (is.na(text_size)) {
  text_size <- "2"
}
x_size <- as.numeric(args[6])
if (is.na(x_size)) {
  x_size <- "8"
}
plot_title <- args[7]
if (is.na(plot_title)) {
  plot_title <- "sankey"
}
outputFileName <- args[8]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}
library(tidyverse)
library(ggalluvial)
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
          read.table(filename1, header = has_header, fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  }  else {
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
    
}
data = read_data(file = filename1,has_header = F)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename1, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename1,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  data = read_data(file = filename1,has_header = F)
  data =as.data.frame(data)

  }
  
data1=data[which(data$V3=="mRNA"),]
data2=data[which(data$V3=="lncRNA"),]
colnames(data2)=c("a1","a2","a3")
#dim(data1)

bb=full_join(data1,data2,by=c("V2"="a1"))
#dim(bb)

bb1=bb[!duplicated(bb[c("V1","V2","a2")]),]
#dim(bb1)

bb2=subset(bb1, select = -c(V3,a3)) 
colnames(bb2) <- c("mRNA","micRNA","lncRNA")
#write.table(bb2,file = "network1.txt",sep="\t",row.names = F,quote = F)
    
#data=read.table(inputFile, header = T, sep="\t", check.names=F)     
corLodes=to_lodes_form(bb2, axes = 1:ncol(bb2))



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
p=ggplot(corLodes, aes(x = x, stratum = stratum, alluvium = alluvium,fill = stratum, label = stratum)) +
  scale_x_discrete(expand = c(0, 0)) +  
  
  geom_flow(width = stratum_width,aes.flow = "forward") + 
  geom_stratum(alpha =is_alpha,width = stratum_width) +
  scale_fill_manual(values = rep(col_map,10)) +
  
  geom_text(stat = "stratum", size = text_size,color="black") +
        theme_bw() + 
   theme(plot.title = element_text(size =15,hjust = 0.5),
		 axis.line = element_blank(),
         axis.ticks = element_blank(),
         axis.text.y = element_blank(),
         axis.text.x=element_text(size =x_size)) +
         theme(panel.grid =element_blank()) + 
         theme(panel.border = element_blank()) +
		 xlab("") + ylab("") + 
         ggtitle(plot_title) + guides(fill ="none")    
		 
ggsave(plot=p,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)
