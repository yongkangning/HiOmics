

args = commandArgs(trailingOnly=TRUE)
argsCount = 7

if (length(args)!=argsCount) {
  stop("circos_docker.R libPath inputFile1 inputFile2 i_top is_big_gap Title outputFileName")
}
.libPaths(args[1])
inputFile1 <- args[2]
inputFile2 <- args[3]

i_top <- as.numeric(args[4])
if (is.na(i_top)) {
  i_top <- "10"
}

is_big_gap <- as.numeric(args[5])
if (is.na(is_big_gap)) {
  is_big_gap <- "15"
}
Title <- args[6]
if (is.na(Title)) {
  Title <- "circos"
}
outputFileName <- args[7]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}

library(dplyr)
library(reshape2)
library(circlize)
library(myplot)

data=read.table(inputFile1,header=T,sep="\t",row.names=1,check.names=F,quote = "")     
group=read.table(inputFile2,header=T,sep="\t",row.names=1,check.names=F)  

level_rowsum=rowSums(data[,row.names(group)])

data <- cbind(data,level_rowsum)
data <- data[order(data$level_rowsum,decreasing = T),]
#sort(data$level1_rowsum,decreasing = T)

for(i in 1:nrow(data)){if( i>=i_top ){
  data_top <- data[1:i_top,]
}
} 


data_top<- data_top[,row.names(group)]
#df = data.frame(from = rep(rownames(data_top10), times = ncol(data_top10)),
#                to = rep(colnames(data_top10), each = nrow(data_top10)),
#                value = as.vector(data_top10),
#               stringsAsFactors = FALSE)
id=row.names(data_top)
data_top_id=cbind(id,data_top)
data_top_id_melt<-melt(data_top_id,id.vars ="id" )

p=myplot({circos.par(start.degree = 270)
chordDiagram(data_top_id_melt,grid.border = 'black',
             preAllocateTracks = 1,
             big.gap = is_big_gap,
             transparency=0,#directional=1,diffHeight = -mm_h(5),
             # order=c(colnames(data_top10),row.names(data_top10)),
             annotationTrack = c( "grid"),
             annotationTrackHeight = c(0.03))


circos.track(track.index = 1, panel.fun = function(x, y) {xlim = get.cell.meta.data("xlim")
   ylim =c(0,10)
sector.name = get.cell.meta.data("sector.index")
  circos.text(CELL_META$xcenter,ylim[1] + cm_h(1),sector.name,
              facing = "clockwise", niceFacing = TRUE, adj = c(0,0.5),cex = 0.7)
    }, bg.border = NA) 
#circos.track(track.index = 1, panel.fun = function(x, y) {
#  circos.text(CELL_META$xcenter, CELL_META$ylim[1], CELL_META$sector.index, 
#              facing = "clockwise", niceFacing = TRUE, adj = c(0, 0.5),cex = 0.7)
#}, bg.border = NA) 
title(Title)
circos.clear()})

plotsave(p,file=paste(outputFileName,"svg",sep="."),unit="cm",width=15,height=15,dpi=600)




















