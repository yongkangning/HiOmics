args = commandArgs(trailingOnly=TRUE)
argsCount = 9

if (length(args)!=argsCount) {
  stop("jitter_plot.R libPath inputFile jitter_width point_size errorbar_size x_title y_title is_title outputFileName")
}
.libPaths(args[1])

inputFile <- args[2]

jitter_width<- as.numeric(args[3])
if (is.na(jitter_width)) {
  jitter_width <- "0.1" 
}
point_size<- as.numeric(args[4])
if (is.na(point_size)) {
  point_size <- "6" 
}
errorbar_size<- as.numeric(args[5])
if (is.na(errorbar_size)) {
  errorbar_size <- "1.5" 
}
x_title <- args[6]
if (is.na(x_title)) {
  x_title <- "x"
}
y_title <- args[7]
if (is.na(y_title)) {
  y_title <- "y"
}
is_title <- args[8]
if (is.na(is_title)) {
  is_title <- "plot"
}
outputFileName <- args[9]
if (is.na(outputFileName)) {
  outputFileName <- "outputFile"
}


library(tidyverse)
filename1 = inputFile

file_suffix <- strsplit(filename1, "\\.")[[1]]
filetype <- file_suffix[length(file_suffix)]

encode <-
  guess_encoding(filename1, n_max = 1000)[1, 1, drop = TRUE]

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

library(tidyverse)
#setwd('C:/Users/Administrator/Desktop/swxxcl/new/jitter_plot')
#data <- read.table("input.csv",header=T, sep=",")
mytheme <-  theme_bw() +
  theme(axis.line = element_line(colour = 'black', lineend = 'square',size = 0.4),
        axis.text.x = element_text(color = 'black'),
        axis.text.y = element_text(color = 'black'),
        text= element_text(size=18, color = 'black'),
        panel.grid=element_blank()) +
  theme(legend.key = element_blank(),
        legend.background = element_blank(),
        legend.text = element_text(size=12),
        legend.position = "right",
        legend.justification = "left",
        legend.key.width =unit(0.3,'cm'),
        legend.key.height =unit(0.8,'cm'),
        legend.key.size =unit(1,'cm'),
        legend.title=element_blank())
theme_set(mytheme)

nline <- length(unique(data[,1]))-1
c=0.5
for(i in 1:nline){
  c[i]=0.5+i
}

svg(filename= paste(outputFileName,"svg",sep="."))
#p=
ggplot(data, aes(data[,1], data[,2], fill = data[,3])) +
  
  geom_jitter(width = jitter_width,  size = point_size, alpha = 0.4 , color = 'black', shape = 21) +
  
  stat_summary(data=data, aes(data[,1], y, fill = data[,1]),
               geom = 'point', fun = 'mean',
               size = point_size, fill = 'red' , alpha = 0.6, color = 'black', shape = 21) +
  stat_summary(geom = 'errorbar',
               fun.data = 'mean_se' ,width = 0, size = errorbar_size, color = 'steelblue', alpha = 0.6) +
  geom_vline(xintercept=c,color="grey",  
             linetype = 3, size = 0.5) +
  geom_hline(aes(yintercept = 0), 
             linetype = 2, color = 'grey', size = 1)  +
  labs(y =expression('y_title'), 
       x = expression('x_title'), 
       title = is_title, size= 20, face = 'bold' )  
  #theme(legend.position = 'none')  

  #ggsave(plot = p,filename = paste(outputFileName,"svg",sep="."),device="svg",units="cm",dpi=600)
  dev.off()
  