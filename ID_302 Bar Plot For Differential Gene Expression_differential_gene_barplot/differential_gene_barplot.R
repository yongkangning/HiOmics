args = commandArgs(trailingOnly=TRUE)
argsCount = 7

if (length(args)!=argsCount) {
  stop("differential_gene_barplot.R libPath inputFile up_col down_col up_title down_title outputFileName")
}
.libPaths(args[1])

inputFile <- args[2]

up_col <- args[3]
if (is.na(up_col)) {
  up_col <- "firebrick2"
}
down_col <- args[4]
if (is.na(down_col)) {
  down_col <- "steelblue"
}
up_title <- args[5]
if (is.na(up_title)) {
  up_title <- "Upregulated"
}
down_title <- args[6]
if (is.na(down_title)) {
  down_title <- "Downregulated"
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

library(ggplot2)

#data <- read.csv("input.csv", header = T)   


data[which(data[,2] == 'down'),colnames(data)[3]] <- data[which(data[,2] == 'down'),colnames(data)[3]] * -1


levels <- as.vector(unique(data[,1]))
data[,1] <- factor(data[,1], levels = levels)


label_adjust = max(data[,3]) * 0.1
data$label_adjust <- ifelse(data[,3] > 0, data[,3] + label_adjust, data[,3] - label_adjust)


p <- ggplot(data, aes(x = group, y = num)) +
geom_col(aes(fill = type, color = type), width = 0.3) +
geom_text(aes(color = type, label = label, y = label_adjust), size = 5) +
  scale_color_manual(values = c(up = up_col, down = down_col)) +
  scale_fill_manual(values = c(up = up_col, down = down_col)) +
theme(panel.grid.major.y = element_line(color = 'gray', linetype = 2), panel.grid.minor = element_blank(), 
    panel.background = element_blank(), legend.position = 'nome', 
    axis.line.x = element_line(color = 'gray', linetype = 2), 
    axis.line.y = element_line(color = 'black'), 
    axis.ticks.x = element_blank(), axis.ticks.y = element_line(color = 'gray'), 
    axis.text.x = element_text(size = 15, face = 'bold',color = 'black'), 
    axis.text.y = element_text(size = 13, color = 'black'), 
    axis.title.y = element_text(size = 15, face = 'bold')) +
geom_hline(yintercept = 0) +
labs(x = '', y = paste0(down_title,"                ",up_title))

ggsave(plot = p,filename = paste(outputFileName,"svg",sep="."),device="svg",units="cm",dpi=600)
