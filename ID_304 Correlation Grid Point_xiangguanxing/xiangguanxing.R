
args = commandArgs(trailingOnly=TRUE)
argsCount = 5

if (length(args)!=argsCount) {
  stop("xiangguanxing.R libPath inputFile1 inputFile2 is_method outputFileName")
}
.libPaths(args[1])
inputFile1 <- args[2]

inputFile2 <- args[3]

is_method <- args[4]
if (is.na(is_method)) {
  is_method <- "spearman"
}

outputFileName <- args[5]##
if (is.na(outputFileName)) {
  outputFileName <- "xiangguanxing"
}




library(ggplot2)
library(ggthemes)

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
df1 = read_data(file = filename1,has_header = T)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename1, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename1,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  df1 = read_data(file = filename1,has_header = T)
  df1 =as.data.frame(df1)
  row.names(df1)=df1[,1]
  df1 = df1[,-1]
  
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
df2 = read_data(file = filename2,has_header = T)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename2, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename2,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  df2 = read_data(file = filename2,has_header = T)
  df2 =as.data.frame(df2)
  row.names(df2)=df2[,1]
  df2 = df2[,-1]
  
  }



#df1 <- read.csv(file.choose(),header = T)
#df2 <- read.csv(file.choose(),header = T)

library(psych)
cor.result<-corr.test(df1,df2,method = is_method )#Spearman, Kendall and Lin
cor.result$p
cor.result$r

#library(tidyverse)
cor.result$p %>% 
  as.data.frame() %>% 
  rownames_to_column() %>% 
  pivot_longer(!rowname) %>% 
  mutate(p_value=case_when(
    value > 0.05 ~ "A",
    value >0.01 & value <= 0.05 ~ "B",
    value > 0.001 & value <= 0.01 ~ "D",
    value <= 0.001 ~ "E"
  )) -> new_df1

ggplot()+
  geom_tile(data=new_df1,
            aes(x=rowname,y=name,fill=p_value))+
  scale_fill_manual(values = c("white","#c0c0c0",
                                      "#808080","#3f3f3f"))+
                                        theme(legend.key = element_rect(colour="black"),
                                              axis.text.x = element_text(angle = 90,hjust=1,vjust=0.5))+
  coord_equal()

cor.result$r %>% 
  as.data.frame() %>% 
  rownames_to_column() %>% 
  pivot_longer(!rowname) %>% 
  mutate(abs_cor=abs(value)) -> new_df2

library(paletteer)
ggplot()+
  geom_tile(data=new_df1,
            aes(x=rowname,y=name,fill=p_value))+
  scale_fill_manual(values = c("white","#c0c0c0",
                                      "#808080","#3f3f3f"))+
                                        theme(legend.key = element_rect(colour="black"),
                                              axis.text.x = element_text(angle = 90,hjust=1,vjust=0.5))+
  coord_equal()+
  geom_point(data=new_df2,
             aes(x=rowname,y=name,
                 size=abs_cor*10,
                 color=value))+
  scale_color_paletteer_c(palette = "ggthemes::Classic Red-Blue")

p = ggplot()+
  geom_tile(data=new_df1,
            aes(x=rowname,y=name,fill=p_value,alpha=p_value))+
  scale_fill_manual(values = c("white","#c0c0c0",
                                      "#808080","#3f3f3f"),
                                      label=c(">0.05",
                                              "0.01~0.05",
                                              "0.001~0.01",
                                              "<0.01"))+
  scale_alpha_manual(values = c(0,1,1,1))+
  guides(alpha=F)+
  theme_bw()+
  theme(legend.key = element_rect(colour="black"),
        axis.text.x = element_text(angle = 90,
                                   hjust=1,
                                   vjust=0.5),)+
  coord_equal()+
  geom_point(data=new_df2,
             aes(x=rowname,y=name,
                 size=abs_cor,
                 color=value))+
  scale_color_paletteer_c(palette = "ggthemes::Classic Red-Blue")

ggsave(plot = p,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=20,height=15,dpi=600)