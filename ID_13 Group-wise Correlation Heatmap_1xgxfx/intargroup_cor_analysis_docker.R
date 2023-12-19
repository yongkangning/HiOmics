# Collect command line arguments and give default values if not provided
args = commandArgs(trailingOnly=TRUE)
argsCount = 16
# If the number of arguments is not consistent, stop the program with an error message
if (length(args)!=argsCount) {
  stop("zuneixgxfx.R libPath inputFile is_method is_cluster_cols is_cluster_rows is_show_colnames is_show_rownames is_scale cellwidthSize cellhightSize dis_num outputFile1 outputFile2 outputFile3 outPutFileType1 outPutFileType2")
}
.libPaths(args[1])
inputFile <- args[2]# Data file
is_method <- args[3]# Correlation matrix, significance test can choose pearson coefficient, spearman coefficient, kendall coefficient
if (is.na(is_method)) {
  is_method <- "pearson"
}
is_cluster_cols <- as.logical(args[4])# Whether to show column clustering
if (is.na(is_cluster_cols)) {
  is_cluster_cols <- "T"
}
is_cluster_rows <- as.logical(args[5])# Whether to show row clustering
if (is.na(is_cluster_rows)) {
  is_cluster_rows <- "T"
}

is_show_colnames <- as.logical(args[6])# Whether to show column names
if (is.na(is_show_colnames)) {
  is_show_colnames <- "T"
}

is_show_rownames <- as.logical(args[7])# Whether to show row names
if (is.na(is_show_rownames)) {
  is_show_rownames <- "T"
}
is_scale <- args[8]# Data normalization direction, can be "row", "column", or "none"
if (is.na(is_scale)) {
  is_scale <- "row"
}
cellwidthSize <- as.numeric(args[9])# Block width
if (is.na(cellwidthSize)) {
  cellwidthSize <- 13
}
cellhightSize <- as.numeric(args[10])# Block height
if (is.na(cellhightSize)) {
  cellhightSize <- 13
}

dis_num <- as.logical(args[11])# Whether to display numbers in the blocks
if (is.na(dis_num)) {
  dis_num <- "T"
}

outputFile1 <- args[12]# Output file name can be customized
outputFile2 <- args[13]
outputFile3 <- args[14]
outPutFileType1 <- args[15]
if (is.na(outPutFileType1)) {
  outPutFileType1 <- "txt"
}
outPutFileType2 <- args[16]
if (is.na(outPutFileType2)) {
  outPutFileType2 <- "svg"
}


library(pheatmap) 
library(myplot)
library(ggcorrplot)
data=read.table(inputFile,header=T,sep="\t",row.names=1,check.names=F)
cordata=cor(data,y=NULL,use="everything",method = is_method)# Correlation matrix, significance test can choose pearson coefficient, spearman coefficient, kendall coefficient
p.mat=cor_pmat(cordata)# Return data matrix pvalue

outputFileName1 <- paste(outputFile1,outPutFileType1,sep = ".")
separator <- "\t"
outputFileName2 <- paste(outputFile2,outPutFileType1,sep = ".")
separator <- "\t"
outputFileName3 <- paste(outputFile3,outPutFileType2,sep = ".")
separator <- "\t"

write.table(cordata,file=paste(outputFileName1),quote=FALSE,sep="\t",row.names=T)# Output correlation values
write.table(p.mat,file=paste(outputFileName2),quote=FALSE,sep="\t",row.names=T)# Output pvalues

p=myplot({pheatmap(cordata,
         #annotation=ann,
         cluster_cols = is_cluster_cols,
         cluster_rows = is_cluster_rows,
         color = colorRampPalette(c("skyblue","white", "red"))(50),
         show_colnames = is_show_colnames,
		 show_rownames = is_show_rownames,
         scale=is_scale,  # Data normalization by row or column
         border_color ="gray",
         fontsize = 8,# Font size in the heatmap
         fontsize_row=8,
         fontsize_col=8,
         cellwidth = cellwidthSize,
         cellhight = cellhightSize,
         treeheight_col = 20,
         treeheight_row = 25,
		 legend = T,# Whether to show legend
         display_numbers = dis_num,# Whether to display numbers on the blocks
         number_color = "black")}# Number color
		 )


plotsave(p,file=paste(outputFileName3),unit="cm",width=15,height=15,dpi=600)