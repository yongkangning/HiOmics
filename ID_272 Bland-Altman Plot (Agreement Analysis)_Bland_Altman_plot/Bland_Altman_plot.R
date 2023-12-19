args = commandArgs(trailingOnly=TRUE)
argsCount = 7

if (length(args)!=argsCount) {
  stop("Bland_Altman_plot.R libPath inputFile point_col is_type fill_col outputFileName1 outputFileName2")
}
.libPaths(args[1])

inputFile <- args[2]

point_col<- args[3]
if (is.na(point_col)) {
  point_col <- "orange" 
}
is_type<- args[4]
if (is.na(is_type)) {
  is_type <- "histogram" 
}
fill_col<- args[5]
if (is.na(fill_col)) {
  fill_col <- "orange" 
}
outputFileName1 <- args[6]
if (is.na(outputFileName1)) {
  outputFileName1 <- "outputFile1"
}
outputFileName2 <- args[7]
if (is.na(outputFileName2)) {
  outputFileName2 <- "outputFile2"
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

library("ggExtra")
library("ggplot2")
library("plotrix")
#set.seed(123)
#mEDV<-  rnorm(100,117,30)
#sEDV <- rnorm(100,114,30)
#BAdata<- cbind( mEDV,sEDV )
#data <- read.csv("input.csv",header = T)
BAdata2 <- transform(data,diff=data[,2]-data[,1],meand =(data[,2]+data[,1])/2)
BAdata2 <- BAdata2[,c(3,4)]

x_lab <- paste0("(",colnames(data)[2],"+",colnames(data)[1],")/2")
y_lab <- paste0("(",colnames(data)[2],"-",colnames(data)[1],")/2")

y_max <- mean(BAdata2$diff) + 1.96*sd(BAdata2$diff)
y_min <- mean(BAdata2$diff) - 1.96*sd(BAdata2$diff)
y_mean <- mean(BAdata2$diff)
y_se <- std.error(BAdata2$diff)
mean_and_95ci <- paste(paste0("Mean=",round(y_mean,1)),paste0("95%CI(",round(y_mean-2*y_se,1),",",round(y_mean+2*y_se,1),")"))
strwrap(mean_and_95ci,width =0,simplify = T)

BAplot <- ggplot(BAdata2, aes(meand, diff)) + 
  geom_point(size=3,shape=16,colour = point_col) + 
  geom_hline(yintercept = 0, lty = 3,lwd=1,color="red") +
  geom_hline(yintercept = mean(BAdata2$diff),lty = 1,lwd=1,color="red") +
  geom_hline(yintercept = mean(BAdata2$diff) + 1.96*sd(BAdata2$diff), linetype = 2,color="red") +
  geom_hline(yintercept = mean(BAdata2$diff) - 1.96*sd(BAdata2$diff), linetype = 2,color="red") +
  labs(x=x_lab,y=y_lab)+
  theme(axis.line.x = element_line(color="black", size = 1),
        axis.line.y = element_line(color="black", size = 1))+
  theme(axis.text= element_text(  size=12),
        axis.title.x=element_text(size=12),
        axis.title.y =element_text(size=12))+
  #scale_x_continuous(limits=c(60,160),breaks=seq(60,160,20))+
  #scale_y_continuous(limits=c(-120,130),breaks=seq(-120,130,30))+
  geom_text(x=0.91*max(BAdata2$meand), y=y_max, label=paste0("+1.96SD=",round(y_max,1)),size=5)+ 
  geom_text(x=0.91*max(BAdata2$meand), y=y_min, label=paste0("-1.96SD=",round(y_min,1)),size=5)+
  geom_text(x=0.91*max(BAdata2$meand), y=y_mean, label=paste0(strwrap(mean_and_95ci,width =1,simplify = T),collapse = "\n") ,size=5)

p1=BAplot1 <- BAplot+theme( panel.background = element_rect(fill = "white"))+
               theme_bw()

p2=ggMarginal(BAplot1, type=is_type,fill=fill_col,col =1)

ggsave(plot=p1,filename=paste(outputFileName1,"svg",sep="."),device='svg',units="cm",dpi=600)
ggsave(plot=p2,filename=paste(outputFileName2,"svg",sep="."),device='svg',units="cm",dpi=600)

