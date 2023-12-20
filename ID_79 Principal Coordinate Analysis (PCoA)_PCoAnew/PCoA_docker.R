
 

args = commandArgs(trailingOnly=TRUE)
argsCount = 7

if (length(args)!=argsCount) {
  stop("PCoA_docker.R libPath inputFile1 inputFile2 bray is_legend is_horiz outputFileName")
}
.libPaths(args[1])
inputFile1 <- args[2]
inputFile2 <- args[3]
bray <- args[4]

if (is.na(bray)) {
  bray <- "bray"
}
is_legend <- args[5]
if (is.na(is_legend)) {
  is_legend <- "topright"
}
is_horiz <- as.logical(args[6])
if (is.na(is_horiz)) {
  is_horiz <- "F"
}

outputFileName <- args[7]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}


library("ggplot2")
library("vegan")
library(ape)
#install.packages("scatterplot3d")
library(scatterplot3d)
library(myplot)
rt=read.table(inputFile1,header=T,sep="\t",check.names=F,row.names=1,quote = "")
group=read.table(inputFile2,header=T,sep="\t",check.names=F,row.names=1,quote = "")

rt <- t(rt[,row.names(group)])
#rt=decostand(rt, method = 'hellinger')

data_bray <-vegdist(rt, method="bray",diag=T, upper=F)

pcoa<-pcoa(data_bray,correction = "none") 
rowname_eig <- paste("PCO",row.names(pcoa$values),sep = "")
eigenvalues <- pcoa$values$Eigenvalues
eig <- round(pcoa$values$Relative_eig*100,2)
eig <- paste(eig,"%",sep="")
eig <- cbind.data.frame(rowname_eig,eigenvalues,eig)
write.table(eig, file=paste(outputFileName,"eig.txt",sep="_"),quote=FALSE,sep="\t",row.names=T)

pco1=round(pcoa$values$Relative_eig[1]*100,2)
pco2=round(pcoa$values$Relative_eig[2]*100,2)
pco3=round(pcoa$values$Relative_eig[3]*100,2)
xlab = paste0("PCoA1 (",pco1,"%)")
ylab = paste0("PCoA2 (",pco2,"%)")
zlab = paste0("PCoA3 (",pco3,"%)")
pcoa_points = as.data.frame(pcoa$vectors[,1:3])
write.table(pcoa_points,file=paste(outputFileName,"sites.txt",sep="_"),quote=FALSE,sep="\t",row.names=T)

group = group[,1]

pcoa_points =cbind.data.frame(pcoa_points ,group)
col = c("#EE799F", "#00BFFF", "#FFFFFF","#836FFF", "#8B3A3A",
        "#FF00FF", "#436EEE", "#7FFF00", "#00FFFF",
        "#CD9B9B","#858585",  "#20B2AA" , "#EE0000","#8B3A62",
        "#FFC0CB",  "#CDBE70" , "#FF7F50", "#009ACD","#ADD8E6", 
        "#00CD66", "#FF4500", "#EE7600",  "#7D26CD", "#698B69" ,
  "#C1CDC1", "#008B00","#FFFF00", "#141414","#FF1493",
  "#FFEBCD", "#B8860B", "#CDB5CD", "#8B8B00") 
cols=col[as.numeric(as.factor(group))]
#svg(file="All.Taxa.OTU_PCoA.svg")
p=myplot({scatterplot3d(pcoa_points[,1:3],xlab =xlab,
                ylab=ylab,zlab = zlab,angle=55,color = cols,
                grid=TRUE, box=F,pch = 16,cex.symbols=1 ,cex.axis=0.7 ,
                cex.lab=0.7 ,font.axis=3,font.lab=3,#highlight.3d=T,
                type="h",lty.grid=3,lty.axis=1)

legend(is_legend,legend=levels(factor(pcoa_points$group)),bty = 'n',horiz = is_horiz, cex = 0.7, 
       pch = 16,inset = 0.05,col=col)})
       
plotsave(p,file=paste(outputFileName,"svg",sep="."),unit="cm",width=17,height=17,dpi=600)

