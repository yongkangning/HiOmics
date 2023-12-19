
args = commandArgs(trailingOnly=TRUE)
argsCount = 11

if (length(args)!=argsCount) {
  stop("vioplot_docker_v.1.0.R libPath inputFile is_alpha Palette x_title y_title plot_title is_legend is_method p_sig outputFileName")
}
.libPaths(args[1])
 
inputFile <- args[2]

is_alpha <- as.numeric(args[3])
if (is.na(is_alpha)) {
  is_alpha <- "0.3"
}

Palette <- args[4]
                        
if (is.na(Palette)) {
  Palette <- "npg"
}

x_title <- args[5]
if (is.na(x_title)) {
  x_title <- "x"
}
y_title <- args[6]
if (is.na(y_title)) {
  y_title <- "y"
}
plot_title <- args[7]
if (is.na(plot_title)) {
  plot_title <- "vioplot"
}

is_legend <- args[8] 
if (is.na(is_legend)) {
  is_legend <- "top"
}

is_method <- args[9]
if (is.na(is_method)) {
  is_method <- "t.test"
}
p_sig <- args[10]
if (is.na(p_sig)) {
  p_sig <- "signif"
}


outputFileName <- args[11]
if (is.na(outputFileName)) {
  outputFileName <- "vioplot"
}


library(ggpubr)         
#data=read.table(inputFile,header=T,sep="\t",check.names=F,row.names=1)
library(tidyverse)
filename = inputFile
 
  file_suffix <- strsplit(filename, "\\.")[[1]]
  filetype <- file_suffix[length(file_suffix)]
  
  encode <-
    guess_encoding(filename, n_max = 1000)[1, 1, drop = TRUE]
  # print(encode)
  if(is.na(encode)) {
    stop(paste("[ERRO]", filename,"encoding_nonsupport"))
  }
  if(filetype %in% c("csv","txt")){
  
read_data <- function(filename, has_header,has_rownames) {
 
    if (filetype == "csv") {
    df <-
      tryCatch(
        read.csv(filename, header = has_header, row.names =has_rownames, fileEncoding = encode,sep=",",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.csv(filename, header = has_header, row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename, header = has_header, row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.table(filename, header = has_header, row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  }  else {
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
    
}
data = read_data(file = filename,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  data = read_data(file = filename,has_header = T)
  data =as.data.frame(data)
  
  }


group=levels(factor(data[,1]))
data[,1]=factor(data[,1], levels=group)
comp=combn(group,2)
my_comparisons=list()
for(i in 1:ncol(comp)){my_comparisons[[i]]<-comp[,i]}

p1 = ggviolin(data, x=colnames(data)[1], y=colnames(data)[2],
             # color=colnames(data)[1],
             fill = colnames(data)[1],
			 alpha=is_alpha,
		     #legend.title=x,
              palette = Palette,
			add = "boxplot", add.params = list(fill="white"))+
#stat_compare_means(comparisons = my_comparisons,method = is_method,label = "p.signif")+
        labs(x=x_title,y=y_title,title=plot_title)+
		 theme(plot.title = element_text(size =15,hjust = 0.5),
                      axis.title.x=element_text(size=10),
                      axis.title.y=element_text(size=10),
                      axis.text.x=element_text(angle=0,size = 8),
                      axis.text.y=element_text(size =8),axis.ticks = element_line(size=0.2),
                      panel.border = element_blank())+
              theme(legend.key.size = unit(10,"pt"),
			        legend.title = element_text(size=8,vjust = 0.9),
			        legend.text = element_text(size =8,vjust = 0.8),
					legend.position = is_legend)
		

										
is_method1=c("no")
is_method2=c("t.test")
is_method3=c("wilcox.test")
is_method4=c("anova")
is_method5=c("kruskal.test")

pval=c("pvalue")
sig=c("signif")

if(is_method %in% is_method1){
ggsave(plot=p1,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)
}else if(is_method %in% is_method2){if(p_sig %in% pval){p2_1=p1+stat_compare_means(comparisons = my_comparisons,method = "t.test")
                                                         ggsave(plot=p2_1,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)
                              }else if(p_sig %in% sig){p2_2=p1+stat_compare_means(comparisons = my_comparisons,method = "t.test",label = "p.signif")
                                                         ggsave(plot=p2_2,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)}
}else if(is_method %in% is_method3){if(p_sig %in% pval){p3_1=p1+stat_compare_means(comparisons = my_comparisons,method = "wilcox.test")
                                                         ggsave(plot=p3_1,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)
                              }else if(p_sig %in% sig){p3_2=p1+stat_compare_means(comparisons = my_comparisons,method = "wilcox.test",label = "p.signif")
                                                         ggsave(plot=p3_2,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)}
}else if(is_method %in% is_method4){if(p_sig %in% pval){p4_1=p1+stat_compare_means(method = "anova")
                                                         ggsave(plot=p4_1,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)
                              }else if(p_sig %in% sig){p4_2=p1+stat_compare_means(method ="anova",label = "p.signif")
                                                         ggsave(plot=p4_2,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)}
}else if(is_method %in% is_method5){if(p_sig %in% pval){p5_1=p1+stat_compare_means(method = "kruskal.test")
                                                         ggsave(plot=p5_1,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)
                              }else if(p_sig %in% sig){p5_2=p1+stat_compare_means(method ="kruskal.test",label = "p.signif")
                                                         ggsave(plot=p5_2,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)}
}
