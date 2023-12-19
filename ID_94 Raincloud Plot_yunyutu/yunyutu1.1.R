
args = commandArgs(trailingOnly=TRUE)
argsCount = 7

if (length(args)!=argsCount) {
  stop("yunyutu1.1.R libPath inputFile is_alpha x_title y_title plot_title outputFileName")
}
.libPaths(args[1])
 
inputFile <- args[2]

is_alpha <- as.numeric(args[3])
if (is.na(is_alpha)) {
  is_alpha <- "0.7"
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
  plot_title <- "violindot"
}
outputFileName <- args[7]
if (is.na(outputFileName)) {
  outputFileName <- "violindot"
}


library(ggplot2)
library(reshape2)
library(RColorBrewer)
library(grid)
library(see)
library(tidyverse)

#data=read.table(inputFile,header=T,sep="\t",check.names=F)
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
    stop("[ERRO] txt csv")
  }
  return(df)
    
}
data = read_data(file = filename1,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename1, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename1,col_names=has_header)
	
  } else {
  stop("[ERRO] xls xlsx")}
  }

  
  data = read_data(file = filename1,has_header = T)
  data =as.data.frame(data)
  row.names(data)=data[,1]
  data = data[,-1]
 
  }
data = melt(data)
#head(data)
p = ggplot(data, aes(x = variable,
                     y = value, 
                     fill = variable)) +
  geom_violindot(alpha=is_alpha) +
  theme_modern()+
  coord_flip()+
  scale_fill_material()+ 
  labs(title=plot_title,x=x_title,y=y_title)+
  theme(plot.title = element_text(size =15,hjust = 0.5),
        axis.title.x=element_text(size=10),
        axis.title.y=element_text(size=10),
        axis.text.x=element_text(angle=0,size = 8,vjust =1.2,hjust =1.1),
        axis.text.y=element_text(size =8),
        axis.ticks = element_line(size=0.2),
        panel.border = element_blank())+
  theme(legend.key.size = unit(10,"pt"),
        legend.title = element_blank(),
        legend.text = element_text(size =8,vjust = 0.8)
        )

ggsave(plot=p,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)







