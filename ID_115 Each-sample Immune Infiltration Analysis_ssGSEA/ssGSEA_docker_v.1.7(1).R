
args = commandArgs(trailingOnly=TRUE)
argsCount = 14

if (length(args)!=argsCount) {
  stop("zuneixgxfx.R libPath inputFile1 inputFile2 inputFile3 is_show_rownames is_show_colnames is_cluster_cols is_cluster_rows is_scale
  cellwidthSize cellheightSize is_width is_height")
}
.libPaths(args[1])

inputFile1 <- args[2]
inputFile2 <- args[3]
inputFile3 <- args[4]

is_show_rownames <- as.logical(args[5])
if (is.na(is_show_rownames)) {
  is_show_rownames <- "F"
}
is_show_colnames <- as.logical(args[6])
if (is.na(is_show_colnames)) {
  is_show_colnames <- "T"
}


is_cluster_cols <- as.logical(args[7])
if (is.na(is_cluster_cols)) {
  is_cluster_cols <- "F"
}
is_cluster_rows <- as.logical(args[8])
if (is.na(is_cluster_rows)) {
  is_cluster_rows <- "T"
}

is_scale <- args[9]
if (is.na(is_scale)) {
  is_scale <- "column"
}
cellwidthSize <- as.numeric(args[10])
if (is.na(cellwidthSize)) {
  cellwidthSize <- 1
}
cellheightSize <- as.numeric(args[11])
if (is.na(cellheightSize)) {
  cellheightSize <- 5
}
is_width <- as.numeric(args[12])
if (is.na(is_width)) {
  is_width <- 20
}

is_height <- as.numeric(args[13])
if (is.na(is_height)) {
  is_height <- 15
}
is_legend <- as.logical(args[14])
if (is.na(is_legend)) {
  is_legend <- "T"
}


library(genefilter)
library(GSVA)
library(Biobase)
library(stringr)
library(ggpubr)
library(ggsignif)
library(pheatmap)
library(tidyverse)
library(ggplot2)
library(data.table)
library(reshape2)
library(myplot)


filename1 = inputFile1

file_suffix <- strsplit(filename1, "\\.")[[1]]
filetype <- file_suffix[length(file_suffix)]

encode <-
  guess_encoding(filename1, n_max = 1000)[1, 1, drop = TRUE]
# print(encode)
if(is.na(encode)) {
  stop(paste("[ERRO]", filename1,"encoding_nonsupport"))
}
if(filetype %in% c("csv","txt",'tsv')){
  
  read_data <- function(filename1, has_header) {
    
    if (filetype == "csv") {
      df <-
        tryCatch(
          read.csv(filename1, header = has_header,  fileEncoding = encode,sep=",",check.names=FALSE,fill=TRUE, na.string = ""),
          warning = function(e) {
            read.csv(filename1, header = has_header, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE,fill=TRUE, na.string = "")
          }
        )
    } else if (filetype == "txt") {
      df <-
        tryCatch(
          read.table(filename1, header = has_header,fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE, na.string = ""),
          warning = function(e) {
            read.table(filename1, header = has_header, fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE, na.string = "")
          }
        )
    }else if (filetype == "tsv") {
      df <-
        tryCatch(
          read.table(filename1, header = has_header,fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE, na.string = ""),
          warning = function(e) {
            read.table(filename1, header = has_header, fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE, na.string = "")
          }
        )
    }  else {
      stop("[ERRO] Only support txt csv xls xlsx")
    }
    return(df)
    
  }
  expression_data = read_data(file = filename1,has_header = T)
  
}else if (filetype %in% c("xls", "xlsx")) {
  
  read_data <- function(filename1, has_header) {
    if(filetype %in% c("xls", "xlsx")){
      df <- readxl::read_excel(filename1,col_names=has_header)
      
    } else {
      stop("[ERRO] Only support txt csv xls xlsx")}
  }
  
  
  expression_data = read_data(file = filename1,has_header = T)
  expression_data =as.data.frame(expression_data)
  
}

#gene_matrix=read.table(inputFile1,header=T,stringsAsFactors = FALSE,row.names=1,check.names = FALSE)
colnames(expression_data)[1] <- 'gene_name'
expression_data <- aggregate(.~gene_name,expression_data, FUN=sum)
rownames(expression_data) <- expression_data$gene_name
expression_data <- expression_data[,-1]
expression_data <- as.matrix(expression_data)





#Cell_markers<-read.table(inputFile2,header=T,sep = "\t",stringsAsFactors = FALSE)

filename2 = inputFile2#='mmc3.csv'

file_suffix <- strsplit(filename2, "\\.")[[1]]
filetype <- file_suffix[length(file_suffix)]

encode <-
  guess_encoding(filename2, n_max = 1000)[1, 1, drop = TRUE]
# print(encode)
if(is.na(encode)) {
  stop(paste("[ERRO]", filename2,"encoding_nonsupport"))
}
if(filetype %in% c("csv","txt","tsv")){
  
  read_data <- function(filename2, has_header,has_rownames) {
    
    if (filetype == "csv") {
      df <-
        tryCatch(
          read.csv(filename2, header = has_header, fileEncoding = encode,sep=",",check.names=FALSE,fill=TRUE, na.string = ""),
          warning = function(e) {
            read.csv(filename2, header = has_header, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE,fill=TRUE, na.string = "")
          }
        )
    } else if (filetype == "txt") {
      df <-
        tryCatch(
          read.table(filename2, header = has_header,  fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE, na.string = ""),
          warning = function(e) {
            read.table(filename2, header = has_header,  fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE, na.string = "")
          }
        )
    }else if (filetype == "tsv") {
      df <-
        tryCatch(
          read.table(filename2, header = has_header,  fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE, na.string = ""),
          warning = function(e) {
            read.table(filename2, header = has_header,  fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE, na.string = "")
          }
        )
    } else {
      stop("[ERRO] Only support txt csv xls xlsx")
    }
    return(df)
    
  }
  Cell_markers = read_data(file = filename2,has_header = T)
  
}else if (filetype %in% c("xls", "xlsx")) {
  
  read_data <- function(filename2, has_header) {
    if(filetype %in% c("xls", "xlsx")){
      df <- readxl::read_excel(filename2,col_names=has_header)
      
    } else {
      stop("[ERRO] Only support txt csv xls xlsx")}
  }
  
  
  Cell_markers = read_data(file = filename2,has_header = T)
  Cell_markers =as.data.frame(Cell_markers)
  
  
}




filename3 = inputFile3#='BLCA_clinical2.txt'

file_suffix <- strsplit(filename3, "\\.")[[1]]
filetype <- file_suffix[length(file_suffix)]

encode <-
  guess_encoding(filename3, n_max = 1000)[1, 1, drop = TRUE]
# print(encode)
if(is.na(encode)) {
  stop(paste("[ERRO]", filename3,"encoding_nonsupport"))
}
if(filetype %in% c("csv","txt",'tsv')){
  
  read_data <- function(filename3, has_header,has_rownames) {
    
    if (filetype == "csv") {
      df <-
        tryCatch(
          read.csv(filename3, header = has_header, row.names =has_rownames, fileEncoding = encode,sep=",",check.names=FALSE,fill=TRUE, na.string = ""),
          warning = function(e) {
            read.csv(filename3, header = has_header, row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE,fill=TRUE, na.string = "")
          }
        )
    } else if (filetype == "txt") {
      df <-
        tryCatch(
          read.table(filename3, header = has_header, row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE, na.string = ""),
          warning = function(e) {
            read.table(filename3, header = has_header, row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE, na.string = "")
          }
        )
    } else if (filetype == "tsv") {
      df <-
        tryCatch(
          read.table(filename3, header = has_header, row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE, na.string = ""),
          warning = function(e) {
            read.table(filename3, header = has_header, row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE, na.string = "")
          }
        )
    } else {
      stop("[ERRO] Only support txt csv xls xlsx")
    }
    return(df)
    
  }
  clinical = read_data(file = filename3,has_header = T,has_rownames=1)
  
}else if (filetype %in% c("xls", "xlsx")) {
  
  read_data <- function(filename3, has_header) {
    if(filetype %in% c("xls", "xlsx")){
      df <- readxl::read_excel(filename3,col_names=has_header)
      
    } else {
      stop("[ERRO] Only support txt csv xls xlsx")}
  }
  
  
  clinical = read_data(file = filename3,has_header = T)
  clinical =as.data.frame(clinical)
  row.names(clinical)=clinical[,1]
  clinical = clinical[,-1,drop=F]
  
}


Cell_markers<- split(as.matrix(Cell_markers)[,1], Cell_markers[,2])
data_ssgsea<- gsva(as.matrix(expression_data),Cell_markers, method='ssgsea',kcdf='Gaussian',abs.ranking=TRUE)




#data_ssgsea<- t(scale(t(data_ssgsea)))
#normalization<-function(x){
#  return((x-min(x))/(max(x)-min(x)))}
#data_ssgsea_normaliztion <- normalization(data_ssgsea_filter)

  
#for (i in colnames(data_ssgsea)) {  
#  data_ssgsea[,i] <- (data_ssgsea[,i] -min(data_ssgsea[,i]))/(max(data_ssgsea[,i] )-min(data_ssgsea[,i] ))  
#}  

clinical=clinical[order(clinical[,1]),,drop=F]
data_ssgsea=data_ssgsea[,row.names(clinical)]
all(colnames(data_ssgsea)==row.names(clinical))

p1=myplot({pheatmap(data_ssgsea,
                    color = colorRampPalette(c("skyblue","white", "red"))(50),
                    annotation_col = clinical,
                    show_rownames =is_show_rownames,
                    show_colnames = is_show_colnames,
                    cluster_rows = is_cluster_rows,
                    cluster_cols = is_cluster_cols,
                    scale=is_scale,  
                    border_color ="gray",
                    fontsize = 8,
                    fontsize_row=8,
                    fontsize_col=8,
                    cellwidth = cellwidthSize,
                    cellheight = cellheightSize,
                    treeheight_col = 20,
                    treeheight_row = 25,
                    legend = is_legend,
                    display_numbers = F,
                    number_color = "black")
})
plotsave(p1,file="EnrichScore_pheatmap.svg",unit="cm",width=is_width,height=is_height,dpi=600)
plotsave(p1,file="EnrichScore_pheatmap.pdf",unit="cm",width=is_width,height=is_height,dpi=600)
write.csv(data_ssgsea,file="cell_EnrichScore.csv",row.names=T)


colnames(clinical) <- 'group'
data_ssgsea_boxplot=as.data.frame(cbind(clinical,t(data_ssgsea)))
data_ssgsea_boxplot=melt(data_ssgsea_boxplot,id="group")
colnames(data_ssgsea_boxplot) <- c("group","celltype","EnrichScore")

#pdf("boxplot_all_cell.pdf",width=8,height=5,onefile = FALSE) 
p2=ggboxplot(data_ssgsea_boxplot, x = "celltype", y = "EnrichScore", fill= 'group',color = 'group',
             palette = 'lancet',alpha=0.3,size = 0.1)+
  #theme_bw()+
  stat_compare_means(aes(group = group),
                    # method = "wilcox.test",
                     label = "p.signif",
                     symnum.args=list(cutpoints = c(0, 0.001, 0.01, 0.05, 1),
                                      symbols = c("***", "**", "*", "ns")))+
  theme(axis.text.x=element_text(angle=45, hjust=1,size=10),
        axis.title.x=element_text(size=16),
        legend.title = element_blank())

ggsave(plot=p2,filename="cell_enrichscore_boxplot.svg",device='svg',units="cm",width=25,height=13,dpi=600)
ggsave(plot=p2,filename="cell_enrichscore_boxplot.pdf",device='pdf',units="cm",width=25,height=13,dpi=600)

