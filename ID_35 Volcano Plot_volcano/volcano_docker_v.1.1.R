
args = commandArgs(trailingOnly=TRUE)
argsCount = 15

if (length(args)!=argsCount) {
  stop("volcano_docker_v.1.1.R libPath inputFile x_lab y_lab p_filter FC_filter point_size point_alpha x_title y_title plot_title is_legend is_label max_overlaps outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]

x_lab <- as.numeric(args[3])
if (is.na(x_lab)) {
  x_lab <- "2"
}
y_lab <- as.numeric(args[4])
if (is.na(y_lab)) {
  y_lab <- "6"
}

p_filter <- as.numeric(args[5])
if (is.na(x_lab)) {
  x_lab <- "0.05"
}
FC_filter<- as.numeric(args[6])
if (is.na(x_lab)) {
  x_lab <- "2"
}
point_size <- as.numeric(args[7])
if (is.na(point_size)) {
  point_size <- "0.8"
}
point_alpha <- as.numeric(args[8])
if (is.na(point_alpha)) {
  point_alpha <- "0.5"
}

x_title <- args[9]
if (is.na(x_title)) {
  x_title <- "logFC"
}

y_title <- args[10]
if (is.na(y_title)) {
  y_title <- "-log10(pvalue)"
}
plot_title <- args[11] 
if (is.na(plot_title)) {
  plot_title <- "volcano"
}

is_legend <- args[12] 
if (is.na(is_legend)) {
  is_legend <- "right"
}

is_label <- args[13]
if (is.na(is_label)) {
  is_label <- "yes"
}

max_overlaps <- as.numeric(args[14]) 
if (is.na(max_overlaps)) {
  max_overlaps <- "5"
}

outputFileName <- args[15]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}

library(ggplot2)
library(ggrepel)
library(tidyverse)
#data=read.table(inputFile,sep="\t",header=T,check.names=F,row.names = 1)

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
  
read_data <- function(filename1, has_header,has_rownames) {
 
    if (filetype == "csv") {
    df <-
      tryCatch(
        read.csv(filename1, header = has_header, row.names =has_rownames,fileEncoding = encode,sep=",",check.names=FALSE),
        warning = function(e) {
          read.csv(filename1, header = has_header,row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename1, header = has_header,row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE),
        warning = function(e) {
          read.table(filename1, header = has_header, row.names =has_rownames,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
        }
      )
  }  else {
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
    
}
data = read_data(file = filename1,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename1, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename1,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  data = read_data(file = filename1,has_header = T)
  data =as.data.frame(data)
  row.names(data)=data[,1]
  data = data[,-1]
  
  }
rowname <- row.names(data)

data_row <- as.data.frame(cbind(rowname,data),stringsAsFactors = F)

pvalue <- -log10(data_row[,y_lab])
if(ncol(data_row)>y_lab){
rt <- cbind(data_row[,1:(y_lab-1)],pvalue,data_row[,(y_lab+1):ncol(data_row)])
}else{rt=cbind(data_row[,1:(y_lab-1)],pvalue)}


Significant=ifelse((data_row[,y_lab]<p_filter & abs(data_row[,x_lab])>log2(FC_filter)), ifelse(data_row[,x_lab]>log2(FC_filter),"Up","Down"), "Not")

rt$label <- ifelse((data_row[,y_lab]<p_filter & abs(data_row[,x_lab])>log2(FC_filter)), as.character(rownames(data_row)),"")



 p0 = ggplot(rt, aes_string(colnames(rt)[x_lab], colnames(rt)[y_lab]))+
          geom_point(aes(col=Significant),size=point_size,alpha=point_alpha)+
           scale_color_manual(values=c("#00BFFF", "#BFBFBF", "#FF0000"))+
             labs(x=x_title,y=y_title,title=plot_title)+
                 theme_bw()+
                 theme(panel.grid.major=element_blank(),
                 panel.background = element_rect(fill = "transparent",colour = "black"),
                 #plot.background = element_rect(fill = "transparent",colour = NA),
                 panel.grid.minor = element_blank(),
                 panel.border = element_blank())+   
              theme(plot.title = element_text(size =15,hjust = 0.5),
                    axis.title.x=element_text(size=10),
                    axis.title.y=element_text(size=10),
                    axis.text.x=element_text(angle=0,size = 8),
                    axis.text.y=element_text(size =8),
                    axis.ticks = element_line(size=0.2)
                        )+
              theme(legend.key.size = unit(10,"pt"),
                    legend.title = element_text(size=10,vjust = 0.9),
                    legend.text = element_text(size =8,vjust = 0.8),
                    legend.position = is_legend
                         )+
   theme(axis.line = element_line(colour="black",size = 0.2))+
   geom_vline(xintercept = c(-log2(FC_filter),log2(FC_filter)),lty = 2,col = "red",lwd = 0.3)+
   geom_hline(yintercept = -log10(p_filter),lty = 2,col = "red",lwd = 0.3)

yes_label=c("yes")
no_label=c("no")

if(is_label %in% yes_label){p1 = p0+geom_text_repel(aes(label = label),
                  size = 3, 
                
                  segment.color = "skyblue", 
                  max.overlaps =max_overlaps,  
                  show.legend = FALSE)
  ggsave(plot=p1,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)
   }else if(is_label %in% no_label){
   ggsave(plot=p0,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)
}