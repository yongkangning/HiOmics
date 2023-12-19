
args = commandArgs(trailingOnly=TRUE)
argsCount = 9

if (length(args)!=argsCount) {
  stop("circos_heatmap.R libPath inputFile1 is_scale is_group inputFile2 track_height rownames_cex is_cluster outputFileName")
}

.libPaths(args[1])
inputFile1 <- args[2]
is_scale <- args[3]
if (is.na(is_scale)) {
  is_scale <- "yes"
}

is_group <- args[4]
if (is.na(is_group)) {
  is_group <- "yes"
}
inputFile2 <- args[5]

track_height <- as.numeric(args[6])
if (is.na(track_height)) {
  track_height <- "0.28"
}
rownames_cex <- as.numeric(args[7])
if (is.na(rownames_cex)) {
  rownames_cex <- "0.7"
}
is_cluster <- as.logical(args[8])
if (is.na(is_cluster)) {
  is_cluster <- "T"
}

outputFileName <- args[9]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}

library('ComplexHeatmap')
library('circlize')
library("RColorBrewer")
library(tidyverse)
#install.packages("dendextend")
#install.packages("dendsort")
library(dendextend)
library(dendsort)
library(gridBase)
library(myplot)



#data<-read.table(file='input.txt',header=TRUE,row.names= 1)
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
  row.names(data)=data[,1]
  data = data[,-1]
  
  }

#data=log2(data[,1:6]+1) 
#head(data) 

if(is_scale %in% c("yes")){


data <- as.matrix(data)
cir_data<-t(scale(t(data)))
#head(cir_data) 
}else if(is_scale %in% c("no")){
cir_data=data
}



mycol= colorRamp2(c(range(cir_data)[1], 0, range(cir_data)[2]),c("#0da9ce","white","#e74a32"))
     
if(is_group %in% c("yes")){
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

  
  group = read_data(file = filename2,has_header = T)
  group =as.data.frame(group)
  row.names(group)=group[,1]
  group = group[,-1]
  
  }



#split_group = data.frame(pathway=c(rep("pathway1",3),rep("pathway2",20),rep("pathway3",7)))
#row.names(split_group) = rownames(cir_data)

split_group <- as.matrix(group)

nn=length(unique(split_group))

p=myplot({
circos.par(gap.after=c(rep(2,nn-1),30)) 
#min(table(split_group))
circos.heatmap(cir_data,col=mycol,
               dend.side="inside",
               rownames.side="outside",
               track.height = track_height, 
               rownames.col="black",
               bg.border="black", 
               split = split_group,
               show.sector.labels = T,
               rownames.cex=rownames_cex,
               rownames.font=1,
               cluster=is_cluster,
               dend.track.height=0.18,
               dend.callback=function(dend,m,si) {
                 color_branches(dend,k=min(table(split_group)),col=1:10)
               }
)

lg=Legend(title="Legend",col_fun=mycol,direction = c("vertical"))
#grid.draw(lg)
#circos.track(track.index=get.current.track.index(),panel.fun=function(x,y){
#  if(CELL_META$sector.numeric.index==length(unique(split_group))){# the last sector
#    cn=colnames(cir_data)
#    n=length(cn)
#    circos.text(rep(CELL_META$cell.xlim[2],n)+convert_x(1,"mm"),
#                (1:n)+5,
#                cn,cex=0.8,adj=c(0,1),facing="inside")
#  }
#},bg.border=NA)
circle_size= unit(0.9,"npc")
h= dev.size()
lgd_list= packLegend(lg ,max_height = unit(2*h,"inch"))
draw(lgd_list, x = circle_size,y= unit(0.5, "npc"), just ="left")
circos.clear()
 })

      }else if(is_group %in% c("no")){
	  
p=myplot({
circos.par(gap.after=c(30)) 

circos.heatmap(cir_data,col=mycol,
               dend.side="inside",
               rownames.side="outside",
               track.height = track_height, 
               rownames.col="black",
               bg.border="black", 
               rownames.cex=rownames_cex,
               rownames.font=1,
               cluster=is_cluster,
               dend.track.height=0.18,
               dend.callback=function(dend,m,si) {
                 color_branches(dend,k=nrow(cir_data),col=1:10)
               }
)

lg=Legend(title="Legend",col_fun=mycol,direction = c("vertical"))
#grid.draw(lg)
#circos.track(track.index=get.current.track.index(),panel.fun=function(x,y){
#  if(CELL_META$sector.numeric.index==length(unique(split_group))){# the last sector
#    cn=colnames(cir_data)
#    n=length(cn)
#    circos.text(rep(CELL_META$cell.xlim[2],n)+convert_x(1,"mm"),
#                (1:n)+5,
#                cn,cex=0.8,adj=c(0,1),facing="inside")
#  }
#},bg.border=NA)
circle_size= unit(0.9,"npc")
h= dev.size()
lgd_list= packLegend(lg ,max_height = unit(2*h,"inch"))
draw(lgd_list, x = circle_size,y= unit(0.5, "npc"), just ="left")
circos.clear()
	})  
	  
	  }
plotsave(p,file=paste(outputFileName,"svg",sep="."),unit="cm",width = 20,height=15,dpi=600)


