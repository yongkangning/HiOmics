args = commandArgs(trailingOnly=TRUE)
argsCount = 5

if (length(args)!=argsCount) {
  stop("gene_arrow_maps_run.R libPath inputFile y_title plot_title outputFileName")
}
.libPaths(args[1])

inputFile <- args[2]


y_title <- args[3]
if (is.na(y_title)) {
  y_title <- "y"
}
plot_title <- args[4]
if (is.na(plot_title)) {
  plot_title <- "plot"
  
}

outputFileName <- args[5]
if (is.na(outputFileName)) {
  outputFileName <- "outputFile"
}


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


library(ggplot2)
library(gggenes)

#inputFile="input.csv"
#data <- read.table(inputFile,header = T,sep=",")
#head(data)

p=ggplot(data,
       
       aes(
         xmin = data[,3],
         xmax = data[,4],
         y = data[,1],
         fill = data[,2],
         label = data[,2]
       )) +
  
  geom_gene_arrow(arrowhead_height = unit(3, "mm"),
                  arrowhead_width = unit(1, "mm")) +
  
  geom_gene_label(align = "left") +
  
  facet_wrap( ~ molecule, scales = "free", ncol = 1) +
  
  scale_fill_brewer(palette = "Set3") +
  theme_genes() +
  labs(y=y_title,title =plot_title)+
  guides(fill=guide_legend(title = "gene"))
ggsave(plot=p,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",dpi=600)
  