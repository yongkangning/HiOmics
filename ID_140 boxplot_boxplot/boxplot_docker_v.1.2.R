############ 盒型图 #################
args = commandArgs(trailingOnly=TRUE)
argsCount = 9

if (length(args)!=argsCount) {
  stop("boxplot_docker_v.1.2.R libPath inputFile1 groupfile inputFile2 is_method p_sig x_title y_title outputFileName")
}
.libPaths(args[1])
inputFile1 <- args[2]#提供的数据文件，具有行名和列名

groupfile <- as.logical(args[3])#是否需要上传分组文件#y轴title可自定义(可不填)
if (is.na(groupfile)) {
  groupfile <- "yes"
}

inputFile2 <- args[4]#分组文件（具有分组文件的上传），具有行名和列名

is_method <- args[5]#是否添加显著性检验，不添加'no',添加则有“t.test”、"wilcox.test"、"anova"、"kruskal.test"四种方法
if (is.na(is_method)) {
  is_method <- "t.test"
}
p_sig <- args[6]#显示p值或显著性星号（此情况必须添加显著性检验），选“pvalue”显示p值，选”signif“显示星号（星号显著，ns为不显著）
if (is.na(p_sig)) {
  p_sig <- "signif"
}
x_title <- args[7]##x轴title可自定义(可不填)
if (is.na(x_title)) {
  x_title <- "group"
}

y_title <- args[8]##y轴title可自定义(可不填)
if (is.na(y_title)) {
  y_title <- "value"
}

outputFileName <- args[9]#出图命名自定义
if (is.na(outputFileName)) {
  outputFileName <- "result"
}
library(ggpubr)
library(ggplot2)
library(tidyverse)
library(reshape2)
#data=read.table(inputFile,sep="\t",header=T,check.names=F,row.names = 1)

filename1 = inputFile1
 # 猜测文件的字符编码格式
  file_suffix <- strsplit(filename1, "\\.")[[1]]
  filetype <- file_suffix[length(file_suffix)]
  
  encode <-
    guess_encoding(filename1, n_max = 1000)[1, 1, drop = TRUE]
  # print(encode)
  if(is.na(encode)) {
    stop(paste("[ERRO]", filename1,"encoding_nonsupport"))
  }
  if(filetype %in% c("csv","txt")){
  #csv和txt文件读取结果
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

  #Excel文件读取
  data = read_data(file = filename1,has_header = T)
  data =as.data.frame(data)
  row.names(data)=data[,1]
  data = data[,-1]
  
  }
  
  inputgroup <- c("yes")
  noputgroup <- c("no")
  if(groupfile %in% inputgroup){
  filename2 = inputFile2
 # 猜测文件的字符编码格式
  file_suffix <- strsplit(filename2, "\\.")[[1]]
  filetype <- file_suffix[length(file_suffix)]
  
  encode <-
    guess_encoding(filename2, n_max = 1000)[1, 1, drop = TRUE]
  # print(encode)
  if(is.na(encode)) {
    stop(paste("[ERRO]", filename2,"encoding_nonsupport"))
  }
  if(filetype %in% c("csv","txt")){
  #csv和txt文件读取结果
read_data <- function(filename2, has_header,has_rownames) {
 
    if (filetype == "csv") {
    df <-
      tryCatch(
        read.csv(filename2, header = has_header, row.names =has_rownames,fileEncoding = encode,sep=",",check.names=FALSE),
        warning = function(e) {
          read.csv(filename2, header = has_header,row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename2, header = has_header,row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE),
        warning = function(e) {
          read.table(filename2, header = has_header, row.names =has_rownames,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
        }
      )
  }  else {
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
    
}
group = read_data(file = filename2,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename2, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename2,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  #Excel文件读取
  group = read_data(file = filename2,has_header = T)
  group =as.data.frame(group)
  row.names(group)=group[,1]
  group = group[,-1]
  
  }
  
data<- cbind(group,data)
data_melt <- melt(data)

}else if(groupfile %in% noputgroup){
data_melt <- melt(data)
}

if(ncol(data_melt) == 3){
p1 = ggplot(data_melt,aes(variable,value))+ theme(axis.line = element_line(colour="black",size = 0.2))+
    stat_boxplot(aes(fill=data_melt[,1]),geom="errorbar",width=0.3,size=0.5,position=position_dodge(0.4),color="blue")+
    geom_boxplot(aes(fill=data_melt[,1]),
               position=position_dodge(0.4),
               size=0.5,
               width=0.3,
               color="blue",
               outlier.color = "blue",
               outlier.fill = "red",
               outlier.shape = 19,
               outlier.size = 1.5,
               outlier.stroke = 0.5,
               outlier.alpha = 45,
               notch = F,
               notchwidth = 0.5)+
 # theme(axis.title = element_text(size=18),
#        axis.text = element_text(size=14))+
   labs(x=x_title,y=y_title)+
  # stat_compare_means(aes(group = result ),method = "kruskal.test")+
  theme(#panel.grid.major=element_blank(),
        panel.background = element_rect(colour = "black"),
        #plot.background = element_rect(fill = "transparent",colour = NA),
        #panel.grid.minor = element_blank(),
        panel.border = element_rect(colour = "black",fill = NA)
        )+#scale_fill_discrete(name=legend_title)
	guides(fill=guide_legend(title=NULL))#移除图例标题
	
	
is_method1=c("no")
is_method2=c("t.test")
is_method3=c("wilcox.test")
is_method4=c("anova")
is_method5=c("kruskal.test")

pval=c("pvalue")
sig=c("signif")
	
if(is_method %in% is_method1){
p2=p1

}else if(is_method %in% is_method2){if(p_sig %in% pval){p2=p1+stat_compare_means(aes(group = data_melt[,1] ),method = "t.test")
                                             }else if(p_sig %in% sig){p2=p1+stat_compare_means( aes(group = data_melt[,1] ),method = "t.test",label = "p.signif")}
							  
}else if(is_method %in% is_method3){if(p_sig %in% pval){p2=p1+stat_compare_means(aes(group = data_melt[,1] ),method = "wilcox.test")
                                             }else if(p_sig %in% sig){p2=p1+stat_compare_means(aes(group = data_melt[,1] ),method = "wilcox.test",label = "p.signif")}
							 
}else if(is_method %in% is_method4){if(p_sig %in% pval){p2=p1+stat_compare_means(aes(group = data_melt[,1] ),method = "anova")
                                             }else if(p_sig %in% sig){p2=p1+stat_compare_means(aes(group = data_melt[,1] ),method ="anova",label = "p.signif")}
							  
}else if(is_method %in% is_method5){if(p_sig %in% pval){p2=p1+stat_compare_means( aes(group = data_melt[,1] ),method = "kruskal.test")
                                             }else if(p_sig %in% sig){p2=p1+stat_compare_means(aes(group = data_melt[,1] ),method ="kruskal.test",label = "p.signif")}
							  
}	
	
	
}else if(ncol(data_melt) == 2){

  group=levels(factor(data_melt[,1]))
  data_melt[,1]=factor(data_melt[,1], levels=group)#按因子顺序画图
  comp=combn(group,2)#combn(x,n)列出n个x中的元素组合
  my_comparisons=list()
  for(i in 1:ncol(comp)){my_comparisons[[i]]<-comp[,i]}#所有比较组
  
p1 = ggplot(data_melt,aes(variable,value))+ theme(axis.line = element_line(colour="black",size = 0.2))+
    stat_boxplot(aes(fill=data_melt[,1]),geom="errorbar",width=0.3,size=0.5,position=position_dodge(0.4),color="blue")+
    geom_boxplot(aes(fill=data_melt[,1]),
               position=position_dodge(0.4),
               size=0.5,
               width=0.3,
			  # fill="skyblue",
               color="blue",
               outlier.color = "blue",
               outlier.fill = "red",
               outlier.shape = 19,
               outlier.size = 1.5,
               outlier.stroke = 0.5,
               outlier.alpha = 45,
               notch = F,
               notchwidth = 0.5)+
 # theme(axis.title = element_text(size=18),
#        axis.text = element_text(size=14))+
   labs(x=x_title,y=y_title)+
   # stat_compare_means(comparisons = my_comparisons,method = "t.test")+
  theme(#panel.grid.major=element_blank(),
        panel.background = element_rect(colour = "black"),
        #plot.background = element_rect(fill = "transparent",colour = NA),
        #panel.grid.minor = element_blank(),
        panel.border = element_rect(colour = "black",fill = NA)
        )+#scale_fill_discrete(name=legend_title)
	theme(legend.position="none")#移除图例
	
	
is_method1=c("no")
is_method2=c("t.test")
is_method3=c("wilcox.test")
is_method4=c("anova")
is_method5=c("kruskal.test")

pval=c("pvalue")
sig=c("signif")

if(is_method %in% is_method1){
p2=p1

}else if(is_method %in% is_method2){if(p_sig %in% pval){p2=p1+stat_compare_means(comparisons = my_comparisons,method = "t.test")
                                             }else if(p_sig %in% sig){p2=p1+stat_compare_means(comparisons = my_comparisons,method = "t.test",label = "p.signif")}
							  
}else if(is_method %in% is_method3){if(p_sig %in% pval){p2=p1+stat_compare_means(comparisons = my_comparisons,method = "wilcox.test")
                                             }else if(p_sig %in% sig){p2=p1+stat_compare_means(comparisons = my_comparisons,method = "wilcox.test",label = "p.signif")}
							 
}else if(is_method %in% is_method4){if(p_sig %in% pval){p2=p1+stat_compare_means(method = "anova")
                                             }else if(p_sig %in% sig){p2=p1+stat_compare_means(method ="anova",label = "p.signif")}
							  
}else if(is_method %in% is_method5){if(p_sig %in% pval){p2=p1+stat_compare_means(comparisons = my_comparisons,method = "kruskal.test")
                                             }else if(p_sig %in% sig){p2=p1+stat_compare_means(comparisons = my_comparisons,method ="kruskal.test",label = "p.signif")}
							  
}

}

ggsave(plot=p2,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=20,height=13,dpi=600)

