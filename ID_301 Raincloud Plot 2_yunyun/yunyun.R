
args = commandArgs(trailingOnly=TRUE)
argsCount = 5

if (length(args)!=argsCount) {
  stop("yunyun.R libPath inputFile1 is_range_scale is_alpha outputFile ")
}
.libPaths(args[1])
inputFile1 <- args[2]

is_range_scale <- as.numeric(args[3])
if (is.na(is_range_scale)) {
  is_range_scale <- "0.5"
}

is_alpha <- as.numeric(args[4])
if (is.na(is_alpha)) {
  is_alpha <- "0.7"
}

outputFile <- args[5]##
if (is.na(outputFile)) {
  outputFile <- "yun"
}



library(ggplot2)
library(gghalves)
library(tidyverse)


#setwd("C:\Users\Administrator\Desktop\yun new")
#data<-read.csv(file.choose(),header = T,row.names = 1)


filename1 = inputFile1
 
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
        read.csv(filename1, header = has_header, row.names =has_rownames,fileEncoding = encode,sep=",",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.csv(filename1, header = has_header,row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename1, header = has_header,row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.table(filename1, header = has_header, row.names =has_rownames,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE, na.string = "")
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

  
  }
  
  

p<-ggplot(data,aes(x=Species,y=Sepal.Length,fill=Species,color=Species))+
  scale_fill_manual(values = c("#8491B4FF", "#00A087FF", "#4DBBD5FF","#E64B35FF","#F39B7FFF","#91D1C2FF"))+
  scale_colour_manual(values = c("#8491B4FF", "#00A087FF", "#4DBBD5FF","#E64B35FF","#F39B7FFF","#91D1C2FF"))
p

p1<-p+geom_half_violin(position=position_nudge(x=0.1,y=0),
                       side='R',adjust=1.2,trim=F,color=NA,alpha=is_alpha)
p1

p2<-p1+geom_half_point(position=position_nudge(x=-0.35,y=0),size =3, shape =19,range_scale = is_range_scale,alpha=is_alpha)
p2
：
p3<-p2+geom_boxplot(outlier.shape = NA, 
                    width =0.1,
                    alpha=is_alpha)
p3

p4<-p3+coord_flip()
p4


ggsave(plot=p4,filename=paste(outputFile,"svg",sep="."),device='svg',units="cm",width=20,height=20,dpi=600)