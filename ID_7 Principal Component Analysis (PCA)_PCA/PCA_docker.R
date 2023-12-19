 

args = commandArgs(trailingOnly=TRUE)
argsCount = 7

if (length(args)!=argsCount) {
  stop("PCA_docker.R libPath inputFile1 inputFile2 is_scale Title outputFile outPutFileType")
}
.libPaths(args[1])
 
inputFile1 <- args[2]
inputFile2 <- args[3]
is_scale <- as.logical(args[4])
if (is.na(is_scale)) {
  is_scale <- "TRUE"
}
Title <- args[5]
if (is.na(Title)) {
  Title <- "pca"
}
outputFile <- args[6]
outPutFileType <- args[7]
if (is.na(outPutFileType)) {
  outPutFileType <- "svg"
}

library(ggplot2)  
data=read.table(inputFile1,header=T,sep="\t",check.names=F,row.names=1)
group=read.table(inputFile2,header=T,sep="\t",check.names=F,row.names=1,quote = "")
data_pca=t(data[,row.names(group)])
group=group[,1]


data.pca=prcomp(data_pca, scale.=is_scale)
pcaPredict=predict(data.pca)
write.table(data.pca$rotation,file="species_eig.txt",quote=FALSE,sep="\t",row.names=T)
write.table(pcaPredict,file="sample_eig.txt",quote=FALSE,sep="\t",row.names=T)
PCA = data.frame(PC1=pcaPredict[,1], PC2=pcaPredict[,2])
summ <- summary(data.pca)
xlab <- paste0("PC1(",round(summ$importance[2,1]*100,2),"%)")
ylab <- paste0("PC2(",round(summ$importance[2,2]*100,2),"%)")
#fviz_pca_ind(data.pca,addEllipses = T)

p.pca <- ggplot(data = PCA,aes(x = PC1,y = PC2,color = group))+
  geom_point(aes(shape=group),size=2)+
  theme_bw()+
  labs(x = xlab,y = ylab,color = "group" ,title =Title
       )+
  #stat_ellipse(aes(fill = group),group = "norm",geom = "polygon",alpha = 0.2,color = NA)+
  guides(fill = "none")+
  theme(plot.title = element_text(hjust = 0.5,size = 15),
        axis.text = element_text(size = 8),axis.title = element_text(size = 10),
        legend.text = element_text(size = 8),legend.title = element_text(size = 10),
        plot.margin = unit(c(0.4,0.4,0.4,0.4),'cm'))+
  geom_vline(xintercept=0,linetype=4,color="gray")+
  geom_hline(yintercept=0,linetype=4,color="gray")+
  theme(panel.grid=element_blank())


outputFileName <- paste(outputFile,outPutFileType,sep = ".")
separator <- "\t"

  ggsave(filename=paste(outputFileName),device='svg',plot=p.pca,units="cm",width=13,height=13,dpi=600)
  


