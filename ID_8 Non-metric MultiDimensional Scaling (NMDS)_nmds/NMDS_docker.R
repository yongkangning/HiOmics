

args = commandArgs(trailingOnly=TRUE)
argsCount = 7

if (length(args)!=argsCount) {
  stop("NMDS_docker.R libPath inputFile1 inputFile2 bray is_alpha outputFile outPutFileType")
}
.libPaths(args[1])
inputFile1 <- args[2]
inputFile2 <- args[3]
bray <- args[4]
#bty <- args[4]
if (is.na(bray)) {
  bray <- "bray"
}
is_alpha <- as.numeric(args[5])
if (is.na(is_alpha)) {
  is_alpha <- "0.8"
}
outputFile <- args[6]
if (is.na(outputFile)) {
  outputFile <- "result"
}
outPutFileType <- args[7]
if (is.na(outPutFileType)) {
  outPutFileType <- "svg"
}

library("ggplot2")
library("vegan")
library(plyr)

data=read.table(inputFile1,header=T,sep="\t",check.names=F,row.names=1)
group=read.table(inputFile2,header=T,sep="\t",check.names=F,row.names=1,quote = "")
data_pca=t(data[,row.names(group)])
Type=group[,1]

nmds=metaMDS(data_pca,distance = 'bray',k=4)

nmds.stress <- nmds$stress 
nmds.point <- nmds$points 
nmds.species <- nmds$species 
write.table(nmds.point, 'nmds.point.txt',quote=FALSE,sep="\t",row.names=T)
nmds_point <- nmds.point[,1:2]
colnames(nmds_point)[1:2] <- c('NMDS1', 'NMDS2')
group <- group[match(rownames(data_pca),rownames(group)),] 
nmds_point <- cbind.data.frame(nmds_point,Type)

#find_hull <- function(nmds_point) nmds_point[chull(nmds_point$NMDS1,nmds_point$NMDS2),]
#hulls <- ddply(nmds_point, "Type", find_hull)

p<-ggplot()+theme_bw()+
theme(panel.grid=element_blank())+
geom_point(data = nmds_point , aes(NMDS1,NMDS2,shape= Type, color = Type),size=2,alpha=is_alpha)+
geom_text(data=nmds_point,aes(label=rownames(nmds_point),x=NMDS1,y=NMDS2),size=3,hjust=1.5, vjust=0.5)+
theme(legend.key=element_rect(colour="white",fill="white",size=3,linetype="dashed"))+
theme(legend.title=element_blank())+#
#geom_polygon(data=hulls,aes(x=NMDS1,y=NMDS2,fill=Type,alpha=0.8),show.legend=FALSE,alpha = 0.3)+
 annotate("text",x=max(nmds_point$NMDS1),y=max(nmds_point$NMDS2),hjust=0.8,vjust=-1,label=paste("Stress:",round(nmds$stress,3),sep = ""),size=3)+#labs( title = paste('Stress:', round(nmds$stress, 3)),size=3)+
geom_vline(xintercept=0,linetype=4,color="gray")+
  geom_hline(yintercept=0,linetype=4,color="gray")+ 
  labs(title = ""
  )+
theme(plot.title = element_text(hjust = 0.5,size = 15))
#stat_ellipse(data=nmds_point,aes(x=NMDS1,y=NMDS2,fill = Type),
# type = "norm",geom = "polygon",alpha = 0.2,color = NA) 

outputFileName <- paste(outputFile,outPutFileType,sep = ".")
separator <- "\t"

ggsave(filename=paste(outputFileName),device='svg',plot=p,units="cm",width=13,height=13,dpi=600)





