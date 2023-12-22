
args = commandArgs(trailingOnly=TRUE)
argsCount = 6

if (length(args)!=argsCount) {
  stop("PCANMDS.R libPath inputFile1 inputFile2 outputFileName1 outputFileName3 outputFileName4")
}

.libPaths(args[1])
inputFile1 <- args[2]

inputFile2 <- args[3]

outputFileName1 <- args[4]
if (is.na(outputFileName1)) {
  outputFileName1 <- "result"
}
outputFileName3 <- args[5]
if (is.na(outputFileName3)) {
  outputFileName3 <- "result1"
}
outputFileName4 <- args[6]
if (is.na(outputFileName4)) {
  outputFileName4 <- "result1"
}




library("DESeq2")

#setwd("C:\\Users\\Administrator\\Desktop\\")
#countdata <- read.table("1.txt",header = T,row.names = 1,sep = "\t")
countdata=read.table(inputFile1,header = T,row.names = 1,sep = "\t")
#head(countdata, 10)



#coldata <- read.csv("2.txt",header = T,sep = "\t")
coldata=read.csv(inputFile2,header = T,sep = "\t")

colnames(coldata)[2] <- c("Group")
#coldata <- read.csv("sample.csv",header = T)

dds <- DESeqDataSetFromMatrix(countData = countdata,colData = coldata,design = ~ Group)
#re=results(dds, contrast=c("Group","WT_BDL","WT_sham"))

#help(contrast)

#dim(dds)
#assay(dds)
#assayNames(dds)
#colSums(assay(dds))
#rowRanges(dds)
#colData(dds)
#DESeq


nrow(dds)
dds <- dds[rowSums(counts(dds)) > 1,]
nrow(dds)
colSums(assay(dds))



#barplot(colSums(assay(dds)),las=3,col=rep(rainbow(4),each=2))
rld <- rlog(dds, blind = FALSE)
#head(assay(rld), 3)

#vsd <- vst(dds, blind = FALSE)
#head(assay(vsd), 3)



sampleDists <- dist(t(assay(rld)))

#sampleDists
#install.packages("pheatmap")
library("pheatmap")
library("RColorBrewer")
library("myplot")

library("ggplot2")
## ----distheatmap, fig.width = 6.1, fig.height = 4.5----------------------


sampleDistMatrix <- as.matrix( sampleDists )
rownames(sampleDistMatrix) <- paste(  coldata[,1], sep = " - " )
colnames(sampleDistMatrix) <-  paste(  coldata[,1], sep = " - " )
p1=myplot({pheatmap(sampleDistMatrix,clustering_distance_rows = sampleDists,show_rownames = T,show_colnames = T,
         clustering_distance_cols = sampleDists)})
plotsave(p1,file=paste(outputFileName1,"svg",sep="."),unit="cm",width=15,height=15,dpi=600)


#install.packages("PoiClaClu")
#library("PoiClaClu")
#poisd <- PoissonDistance(t(counts(dds)))
#samplePoisDistMatrix <- as.matrix( poisd$dd )
#rownames(samplePoisDistMatrix) <- paste( rld$Sample,sep=" - " )

#colnames(samplePoisDistMatrix) <- paste( rld$Sample, sep = " - " )
#p2=myplot({pheatmap(samplePoisDistMatrix,clustering_distance_rows = poisd$dd,
        # clustering_distance_cols = poisd$dd)})

#ggsave(plot=p2,file=paste(outputFileName2,"svg",sep="."),device='svg',units="cm",width=18,height=18,dpi=600)



p3=plotPCA(rld, intgroup = c("Group"))
ggsave(plot=p3,file=paste(outputFileName3,"svg",sep="."),device='svg',units="cm",width=18,height=18,dpi=600)

#plotsave(p3,file=paste(outputFileName3,"svg",sep="."),unit="cm",width=15,height=15,dpi=600)


## ------------------------------------------------------------------------
#pcaData <- plotPCA(rld, intgroup = c( "Group"), returnData = TRUE)


#pcaData
#percentVar <- round(100 * attr(pcaData, "percentVar"))


#library(ggplot2)
#p3=ggplot(pcaData, aes(x = PC1, y = PC2, color = name, shape = Group)) +
  #geom_point(size =3) +  xlab(paste0("PC1: ", percentVar[1], "% variance")) +
 # ylab(paste0("PC2: ", percentVar[2], "% variance")) +  coord_fixed()


library(dplyr)
mds <- as.data.frame(colData(rld))  %>%   cbind(cmdscale(sampleDistMatrix))
p4=ggplot(mds, aes(x = `1`, y = `2`, color = sizeFactor, shape = Group)) +  
  geom_point(size = 3) + coord_fixed()




#mdsPois <- as.data.frame(colData(dds)) %>% cbind(cmdscale(samplePoisDistMatrix))
#ggplot(mdsPois, aes(x = `1`, y = `2`, color = Group, shape = Group)) +
  #geom_point(size = 3) + coord_fixed()
ggsave(plot=p4,file=paste(outputFileName4,"svg",sep="."),device='svg',units="cm",width=18,height=18,dpi=600)

#plotsave(p4,file=paste("outputFileName4","svg",sep="."),unit="cm",width=15,height=15,dpi=600)
