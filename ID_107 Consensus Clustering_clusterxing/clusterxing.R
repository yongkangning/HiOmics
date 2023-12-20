


args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("clusterxing.R libPath inputFile clusterNum outputFileName")
}
.libPaths(args[1])

inputFile <- args[2]

clusterNum <- as.numeric(args[3])
if (is.na(clusterNum)) {
  clusterNum <- "2"
}
outputFileName <- args[4]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}




#if (!requireNamespace("BiocManager", quietly = TRUE))
#    install.packages("BiocManager")
#BiocManager::install("ConsensusClusterPlus")

#if (!requireNamespace("BiocManager", quietly = TRUE))
#    install.packages("BiocManager")
#BiocManager::install("limma")


#???ð?
#install.packages("limma")
#install.packages("ConsensusClusterPlus")
library(limma)
library(ConsensusClusterPlus)
#workDir="C:\\Users\\Administrator\\Desktop\\OS\\22cluster"     
#setwd(workDir)

#setwd("C:/Users/Administrator/Desktop/cluster")


rt=read.table(inputFile, header=T, sep="\t", check.names=F, row.names=1)
data=rt[,(3:ncol(rt))]
data=t(data)


maxK=9
results=ConsensusClusterPlus(data,
              maxK=maxK,
              reps=50,
              pItem=0.8,
              pFeature=1,
            #  title="workDir",
              clusterAlg="km",
              distance="euclidean",
              seed=123456,
              plot="png")


#clusterNum=2         
cluster=results[[clusterNum]][["consensusClass"]]
#write.table(cluster, file="cluster.txt", sep="\t", quote=F, col.names=F)

write.table(cluster,file=paste(outputFileName,"cluster.txt",sep="_"),sep="\t",col.names=F,row.names=T,quote=F)
