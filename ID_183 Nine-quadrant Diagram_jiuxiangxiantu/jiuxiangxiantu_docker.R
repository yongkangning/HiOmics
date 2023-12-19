

args = commandArgs(trailingOnly=TRUE)
argsCount = 10

if (length(args)!=argsCount) {
  stop("bubble.R libPath inputFile1 inputFile2 ncol_log2FC_RNA ncol_log2FC_Ribo FC_RNA FC_Ribo x_title y_title outputFileName")
}
.libPaths(args[1])
inputFile1 <- args[2]
inputFile2 <- args[3]
ncol_log2FC_RNA <- as.numeric(args[4])
if (is.na(ncol_log2FC_RNA)) {
  ncol_log2FC_RNA <- "2"
}
ncol_log2FC_Ribo <- as.numeric(args[5])
if (is.na(ncol_log2FC_Ribo)) {
  ncol_log2FC_Ribo <- "2"
}

FC_RNA <- as.numeric(args[6])
if (is.na(FC_RNA)) {
  FC_RNA <- "2"
}

FC_Ribo <- as.numeric(args[7])
if (is.na(FC_Ribo)) {
  FC_Ribo <- "1.2"
}

x_title <- args[8] 
if (is.na(x_title)) {
  x_title <- "log2FC_RNA"
}
y_title <- args[9]
if (is.na(y_title)) {
  y_title <- "log2FC_Protein"
}

outputFileName <- args[10]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}
library(dplyr)
#RNA =read.table(inputFile1,header=T,sep = "\t", check.names=FALSE,stringsAsFactors = FALSE,quote="")
#Ribo=read.table(inputFile2,header=T,sep = "\t", check.names=FALSE,stringsAsFactors = FALSE,quote="")
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
         RNA = read_data(file = filename1,has_header = T)
         
       }else if (filetype %in% c("xls", "xlsx")) {
         
         read_data <- function(filename1, has_header) {
           if(filetype %in% c("xls", "xlsx")){
             df <- readxl::read_excel(filename1,col_names=has_header)
             
           } else {
             stop("[ERRO] Only support txt csv xls xlsx")}
         }
         
         
         RNA = read_data(file = filename1,has_header = T)
         RNA =as.data.frame(RNA)
         
       }  
	

        filename1 = inputFile2
       
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
         Ribo = read_data(file = filename1,has_header = T)
         
       }else if (filetype %in% c("xls", "xlsx")) {
         
         read_data <- function(filename1, has_header) {
           if(filetype %in% c("xls", "xlsx")){
             df <- readxl::read_excel(filename1,col_names=has_header)
             
           } else {
             stop("[ERRO] Only support txt csv xls xlsx")}
         }
         
         
         Ribo = read_data(file = filename1,has_header = T)
         Ribo =as.data.frame(Ribo)
         
       }  
#dim(RNA)
#dim(Ribo)

#head(RNA)
#head(Ribo)
colnames(RNA)[1] <- "ID"
colnames(Ribo)[1] <- "ID"
data= merge(RNA,Ribo,
            by.x="ID",
            by.y="ID",
            suffixes = c("_RNA","_Ribo") ,
            all.x=F,
            all.y=F)

#dim(data)
#head(combine,1)
#cor = round(cor(data$log2FC_RNA,data$log2FC_Ribo),2)
#lab = paste("correlation=",cor,sep="")


data$location <- case_when(data[,ncol_log2FC_RNA] >= log2(FC_RNA) & data[,ncol(RNA)+ncol_log2FC_Ribo-1] >= log2(FC_Ribo) ~ "3",
                       data[,ncol_log2FC_RNA] >= log2(FC_RNA) & data[,ncol(RNA)+ncol_log2FC_Ribo-1] <= -log2(FC_Ribo) ~ "9",
                       data[,ncol_log2FC_RNA] <= -log2(FC_RNA) & data[,ncol(RNA)+ncol_log2FC_Ribo-1] >= log2(FC_Ribo) ~ "1",
                       data[,ncol_log2FC_RNA] <= -log2(FC_RNA) & data[,ncol(RNA)+ncol_log2FC_Ribo-1] <= -log2(FC_Ribo) ~ "7",
                       abs(data[,ncol_log2FC_RNA]) < log2(FC_RNA) & data[,ncol(RNA)+ncol_log2FC_Ribo-1] > log2(FC_Ribo) ~ "2",
                       abs(data[,ncol_log2FC_RNA]) < log2(FC_RNA) & data[,ncol(RNA)+ncol_log2FC_Ribo-1] < -log2(FC_Ribo) ~ "8",  
                       data[,ncol_log2FC_RNA] > log2(FC_RNA) & abs(data[,ncol(RNA)+ncol_log2FC_Ribo-1]) < log2(FC_Ribo) ~ "6",
                       data[,ncol_log2FC_RNA] < -log2(FC_RNA) & abs(data[,ncol(RNA)+ncol_log2FC_Ribo-1]) < log2(FC_Ribo) ~ "4",
                       abs(data[,ncol_log2FC_RNA]) < log2(FC_RNA) & abs(data[,ncol(RNA)+ncol_log2FC_Ribo-1]) < log2(FC_Ribo) ~ "5")
					   
write.table(data,file=paste(outputFileName,"common.csv",sep="_"),sep=",",quote=F,row.names = F)

#data$part <- case_when(abs(data$log2FC_RNA) >= 1 & abs(data$log2FC_Ribo) >= log2(1.2) ~ "part1",
#                       abs(data$log2FC_RNA) < 1 & abs(data$log2FC_Ribo) > log2(1.2) ~ "part2",
#                       abs(data$log2FC_RNA) > 1 & abs(data$log2FC_Ribo) < log2(1.2) ~ "part3",
#                       abs(data$log2FC_RNA) < 1 & abs(data$log2FC_Ribo) < log2(1.2) ~ "part4")

data$part <- case_when(abs(data[,ncol_log2FC_RNA]) >= log2(FC_RNA) & abs(data[,ncol(RNA)+ncol_log2FC_Ribo-1]) >= log2(FC_Ribo) ~ "part1",
                       abs(data[,ncol_log2FC_RNA]) < log2(FC_RNA) & abs(data[,ncol(RNA)+ncol_log2FC_Ribo-1]) > log2(FC_Ribo) ~ "part2",
                       abs(data[,ncol_log2FC_RNA]) > log2(FC_RNA) & abs(data[,ncol(RNA)+ncol_log2FC_Ribo-1]) < log2(FC_Ribo) ~ "part3",
                       abs(data[,ncol_log2FC_RNA]) < log2(FC_RNA) & abs(data[,ncol(RNA)+ncol_log2FC_Ribo-1]) < log2(FC_Ribo) ~ "part4")					   
head(data)
mytheme <- theme_bw()+
  theme(text=element_text(family = "sans",colour ="gray30",size = 12),
        panel.grid = element_blank(),
        panel.border = element_rect(size = 0.6,colour = "gray30"),
        axis.line = element_blank(),
        axis.ticks = element_line(size = 0.6,colour = "gray30"),
        axis.ticks.length = unit(1.5,units = "mm"))
p0 <-ggplot(data,aes(data[,ncol_log2FC_RNA],data[,ncol(RNA)+ncol_log2FC_Ribo-1],color=part))

p1 <- p0+geom_point(size=1.2)+
  guides(color="none")+
  geom_hline(yintercept = c(-log2(FC_Ribo),log2(FC_Ribo)),
                             size = 0.5,
                              color = "grey40",
                              lty = "dashed")+
  geom_vline(xintercept = c(-log2(FC_RNA),log2(FC_RNA)),
             size = 0.5,
             color = "grey40",
             lty = "dashed")+
	labs(x=x_title,y=y_title)+
 # geom_text(x = -5.2, y = 0.4, label = lab, color="gray40")+
  mytheme
  
ggsave(plot=p1,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)



