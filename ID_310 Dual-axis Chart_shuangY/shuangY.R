
args = commandArgs(trailingOnly=TRUE)
argsCount = 7

if (length(args)!=argsCount) {
  stop("shuangY.R libPath inputFile1 inputFile2 x_labs y_labs is_name outputFileName")
}
.libPaths(args[1])
inputFile1 <- args[2]

inputFile2 <- args[3]

x_labs <- args[4]##
if (is.na(x_labs)) {
  x_labs <- "Treat"
}

y_labs <- args[5]##
if (is.na(y_labs)) {
  y_labs <- "Aboveground_biomass"
}



is_name <- args[6]##
if (is.na(is_name)) {
  is_name <- "Belowground_biomass"
}



outputFileName <- args[7]##
if (is.na(outputFileName)) {
  outputFileName <- "shuangY"
}

library(tidyverse)



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
  
read_data <- function(filename1, has_header) {
 
    if (filetype == "csv") {
    df <-
      tryCatch(
        read.csv(filename1, header = has_header,fileEncoding = encode,sep=",",check.names=FALSE,fill=TRUE, na.string = ""),
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
mydata1 = read_data(file = filename1,has_header = T)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename1, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename1,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  mydata1 = read_data(file = filename1,has_header = T)
  mydata1 =as.data.frame(mydata1)
  
  }



filename2 = inputFile2
 
  file_suffix <- strsplit(filename2, "\\.")[[1]]
  filetype <- file_suffix[length(file_suffix)]
  
  encode <-
    guess_encoding(filename2, n_max = 1000)[1, 1, drop = TRUE]
  # print(encode)
  if(is.na(encode)) {
    stop(paste("[ERRO]", filename2,"encoding_nonsupport"))
  }
  if(filetype %in% c("csv","txt")){
 
read_data <- function(filename2, has_header) {
 
    if (filetype == "csv") {
    df <-
      tryCatch(
        read.csv(filename2, header = has_header,fileEncoding = encode,sep=",",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.csv(filename2, header = has_header, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename2, header = has_header, fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.table(filename2, header = has_header,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  }  else {
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
    
}
mydata2 = read_data(file = filename2,has_header = T)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename2, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename2,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  mydata2 = read_data(file = filename2,has_header = T)
  mydata2 =as.data.frame(mydata2)
  
  }


#mydata1$Month <- factor(mydata1$Month,levels = c("Jan","Feb", "Mar","Apr" ,"May", "Jun", "Jul" ,"Aug" ,"Sep", "Oct", "Nov", "Dec"))
#library(scalesextra)
library(ggplot2)
#mydata1$Month <- factor(mydata1$Month,levels = c("Jan","Feb", "Mar","Apr" ,"May", "Jun", "Jul" ,"Aug" ,"Sep", "Oct", "Nov", "Dec"))

#mydata1 <- read.csv(file.choose())
#mydata2 <- read.csv(file.choose())

#windowsFonts(A=windowsFont("Times New Roman"),
#             B=windowsFont("Arial"))

p<- ggplot(mydata1, aes(supp, value)) +
 geom_bar(aes(fill = supp), stat = "identity",color="black",size=0.8,
           position = position_dodge(0.9), width = 0.7,alpha=0.5,data=mydata1)+
  geom_errorbar(
  aes(ymin = value-se, ymax = value+se, group = supp),
    width = 0.3, size=0.8,position = position_dodge(0.9),data=mydata1
  )+
  scale_fill_manual(values = c("#E64B35FF", "#4DBBD5FF", "#00A087FF","#F39B7FFF","#91D1C2FF", "#8491B4FF","#ffffff","#f0f0f0","#787878","#3c3c3c","#ffa500","#3cb371","#6a5acd", "#ff0000", "#0000ff", "#3cb371", "#ee82ee", "#6a5acd", "#ff6347", "#466347", "#46d947" ))+
scale_y_continuous(expand = c(0,0),
                   sec.axis = sec_axis(~./17.5,
                                         name = is_name))+
  labs(x=x_labs,y=y_labs)+
    
  geom_point(data = mydata2,
             aes(x=supp,value*10),
             size=4)+
  geom_line(data = mydata2,
            aes(x=supp,value*10,group=1),
            cex=1.3)+
  
  scale_color_manual(values = c("#8491B4FF" ))+
  
  theme_bw()+
  theme(axis.ticks.length=unit(-0.25, "cm"), 
        axis.text.x = element_text(margin=unit(c(0.5,0.5,0.5,0.5), "cm")), 
        axis.text.y = element_text(margin=unit(c(0.5,0.5,0.5,0.5), "cm")) )+
  theme(text=element_text(family="A",size=20))

ggsave(plot = p,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=20,height=15,dpi=600)
