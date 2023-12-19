

args = commandArgs(trailingOnly=TRUE)
argsCount = 19

if (length(args)!=argsCount) {
  stop("pheatmap_docker_v.1.2.R libPath inputFile1 inputFile2 inputdata inputFile3 color1 color2 is_cluster_cols is_cluster_rows is_show_colnames is_show_rownames 
  is_scale cellwidthSize cellheightSize col_angle is_main is_legend is_display_numbers outputFileName")
}
.libPaths(args[1])
inputFile1 <- args[2]
inputFile2 <- args[3]

inputdata <- args[4]
if (is.na(inputdata)) {
  inputdata <- "yes"
}

inputFile3 <- args[5]

color1 <- args[6]
if (is.na(color1)) {
  color1 <- "skyblue"
}
color2 <- args[7]
if (is.na(color2)) {
  color2 <- "red"
}


is_cluster_cols <- as.logical(args[8])
if (is.na(is_cluster_cols)) {
  is_cluster_cols <- "T"
}
is_cluster_rows <- as.logical(args[9])
if (is.na(is_cluster_rows)) {
  is_cluster_rows <- "T"
}

is_show_colnames <- as.logical(args[10])
if (is.na(is_show_colnames)) {
  is_show_colnames <- "T"
}

is_show_rownames <- as.logical(args[11])
if (is.na(is_show_rownames)) {
  is_show_rownames <- "T"
}
is_scale <- args[12]
if (is.na(is_scale)) {
  is_scale <- "row"
}
cellwidthSize <- as.numeric(args[13])
if (is.na(cellwidthSize)) {
  cellwidthSize <- 13
}
cellheightSize <- as.numeric(args[14])
if (is.na(cellheightSize)) {
  cellheightSize <- 13
}
col_angle <- as.numeric(args[15])
if (is.na(col_angle)) {
  col_angle <- 45
}
is_main  <- args[16]
if (is.na(is_main)) {
  is_main <- "heatmap"
}
is_legend <- as.logical(args[17])
if (is.na(is_legend)) {
  is_legend <- "F"
}
is_display_numbers <- as.logical(args[18])
if (is.na(is_display_numbers)) {
  is_display_numbers <- "F"
}
outputFileName <- args[19]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}

library(pheatmap)  
library(myplot)
data=read.table(inputFile1,header=T,sep="\t",row.names=1,check.names=F)     
group=read.table(inputFile2,header=T,sep="\t",row.names=1,check.names=F)    
Colnames <- colnames(data)
ann = data.frame(group=group[,1])
row.names(ann) = Colnames 
 

input_alldata <- c("no")
input_interest_genedata <- c("yes")


if(inputdata %in% input_interest_genedata){

interest_gene <- read.table(inputFile3)
interest_gene <- interest_gene$V1
data_interest_gene <- data[interest_gene,]

p=myplot({pheatmap(data_interest_gene,
         annotation=ann,
         cluster_cols = is_cluster_cols,
         cluster_rows = is_cluster_rows,
         color = colorRampPalette(c(color1,"white", color2))(50),
         show_colnames = is_show_colnames,
		 show_rownames = is_show_rownames,
         scale=is_scale,  
         border_color ="gray",
         fontsize = 8,
         fontsize_row=8,
         fontsize_col=8,
         cellwidth = cellwidthSize,
         cellheight = cellheightSize,
		 angle_col = col_angle,
         treeheight_col = 20,
         treeheight_row = 25,
		 main=is_main, 
		 legend = is_legend,
         display_numbers = is_display_numbers,
         number_color = "black")}
		 )
}else if(inputdata %in% input_alldata){
p=myplot({pheatmap(data,
         annotation=ann,
         cluster_cols = is_cluster_cols,
         cluster_rows = is_cluster_rows,
         color = colorRampPalette(c(color1,"white", color2))(50),
         show_colnames = is_show_colnames,
		 show_rownames = is_show_rownames,
         scale=is_scale,  
         border_color ="gray",
         fontsize = 8,
         fontsize_row=8,
         fontsize_col=8,
         cellwidth = cellwidthSize,
         cellheight = cellheightSize,
		 angle_col = col_angle,
         treeheight_col = 20,
         treeheight_row = 25,
		 main=is_main, 
		 legend = is_legend,
         display_numbers = is_display_numbers,
         number_color = "black")
		  })
		
	
		 }
plotsave(p,file=paste(outputFileName,"svg",sep="."),unit="cm",width=30,height=22,dpi=600)	 



