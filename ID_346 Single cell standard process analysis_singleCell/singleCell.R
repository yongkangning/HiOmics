

args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("singleCell.R inputFile gene_counts MT_percent resolution")
}

inputFile <- args[1]
gene_counts <- as.numeric(args[2])
if (is.na(gene_counts)) {
  gene_counts <- 2500
}

MT_percent <- as.numeric(args[3])
if (is.na(MT_percent)) {
  MT_percent <- 5
}

resolution <- as.numeric(args[4])
if (is.na(resolution)) {
  resolution <- 0.5
}


library(patchwork)
library(Seurat)
library(ggplot2)
library(cowplot)
library(Matrix)
library(dplyr)
library(tidyr)
library(plotly)
library(stringr)



inputFile <- inputFile
#inputFile1 <- unzip(zipfile = inputFile)
 
# sub("\\.zip$", "", inputFile)
#folders=list.files( sub("\\.zip$", "", inputFile))         
folders=list.files( inputFile)
if(length(folders)==1){



#inputFile <- file.path(inputFile)
#setwd(inputFile)
#list.files(paste0(inputFile,'/'))


#pbmc.data <- Read10X(data.dir = paste0(sub("\\.zip$", "", inputFile),'/',folders))
pbmc.data <- Read10X(data.dir = paste0( inputFile,'/',folders))

pbmc <- CreateSeuratObject(counts = pbmc.data,min.cells = 3,min.features = 200)


if(length(which(PercentageFeatureSet(pbmc,pattern = "^MT-") > 0))>0 ){
  
pbmc[['percent.MT']] <- PercentageFeatureSet(pbmc,pattern = "^MT-")


VlnPlot(pbmc,group.by = "orig.ident",features = c("nFeature_RNA","nCount_RNA","percent.MT"),ncol=3)
ggsave(filename="Vlnplot_filter_before.pdf")


plot1 <- FeatureScatter(pbmc,group.by = "orig.ident",feature1 = "nCount_RNA",feature2 = "percent.MT")
plot2 <- FeatureScatter(pbmc,group.by = "orig.ident",feature1 = "nCount_RNA",feature2 = "nFeature_RNA")
plot1+plot2
ggsave(filename="FeatureScatter.pdf",width = 8)

pbmc <- subset(pbmc, subset = nFeature_RNA > 200 & nFeature_RNA < gene_counts & percent.MT < MT_percent)
dim(pbmc)



VlnPlot(pbmc,group.by = "orig.ident",features = c("nFeature_RNA","nCount_RNA","percent.MT"),ncol=3)
ggsave(filename="Vlnplot_filter_after.pdf")
#plot1 <- FeatureScatter(pbmc, feature1 ="nCount_RNA", feature2 = "percent.MT")+ NoLegend()
#plot2 <- FeatureScatter(pbmc, feature1 ="nCount_RNA", feature2 = "nFeature_RNA")+ NoLegend()
#plot1 + plot2

}else{
  
  pbmc[['percent.MT']] <- PercentageFeatureSet(pbmc,pattern = "^mt-")
  
  
  
  VlnPlot(pbmc,group.by = "orig.ident",features = c("nFeature_RNA","nCount_RNA","percent.MT"),ncol=3)
  ggsave(filename="Vlnplot_filter_before.pdf")
  
  plot1 <- FeatureScatter(pbmc,group.by = "orig.ident",feature1 = "nCount_RNA",feature2 = "percent.MT")
  plot2 <- FeatureScatter(pbmc,group.by = "orig.ident",feature1 = "nCount_RNA",feature2 = "nFeature_RNA")
  plot1+plot2
  ggsave(filename="FeatureScatter.pdf",width = 8)
  
  pbmc <- subset(pbmc, subset = nFeature_RNA > 200 & nFeature_RNA < gene_counts & percent.MT < MT_percent)
  dim(pbmc)
  
  
  
  VlnPlot(pbmc,group.by = "orig.ident",features = c("nFeature_RNA","nCount_RNA","percent.MT"),ncol=3)
  ggsave(filename="Vlnplot_filter_after.pdf")
  #plot1 <- FeatureScatter(pbmc, feature1 ="nCount_RNA", feature2 = "percent.MT")+ NoLegend()
  #plot2 <- FeatureScatter(pbmc, feature1 ="nCount_RNA", feature2 = "nFeature_RNA")+ NoLegend()
  #plot1 + plot2
  
  
}

pbmc <- NormalizeData(pbmc, normalization.method = "LogNormalize", scale.factor = 10000)


#s.genes <- cc.genes$s.genes
#g2m.genes <- cc.genes$g2m.genes
#pbmc <- CellCycleScoring(pbmc, s.features = s.genes, g2m.features = g2m.genes, set.ident = TRUE)


pbmc <- FindVariableFeatures(pbmc, selection.method = "vst", nfeatures = 2000)


#top10 <- head(VariableFeatures(pbmc), 10)



#plot1 <- VariableFeaturePlot(pbmc)+guides(color="none")

#plot2 <- LabelPoints(plot = plot1,points = top10,repel = TRUE,xnudge = 0,ynudge = 0)

#plot1+plot2

all.genes <- rownames(pbmc)
all.genes

pbmc <- ScaleData(pbmc,vars.to.regress = c('percent.MT'#,"S.Score","G2M.Score"
                                           ))


#shuqu_T_filter1 <- SCTransform(shuqu_T_filter1,vars.to.regress = c('percent.MT',"S.Score","G2M.Score"),verbose=F)



pbmc <- RunPCA(pbmc,features = VariableFeatures(object = pbmc))

#print(pbmc[['pca']],dims = 1:5,nfeatures = 5)


#VizDimLoadings(pbmc,dims = 1:2,reduction = "pca")

#DimPlot(pbmc,reduction = "pca" )

#DimHeatmap(pbmc,dims = 1,cells = 500,balanced = TRUE,)

#DimHeatmap(pbmc, dims = 1:15, cells = 500, balanced = TRUE)








#pbmc <- JackStraw(pbmc,num.replicate = 100)
#pbmc <- ScoreJackStraw(pbmc,dims = 1:20)

#JackStrawPlot(pbmc,dims = 1:15)

ElbowPlot(pbmc)
ggsave(filename="ElbowPlot.pdf")


pbmc <- FindNeighbors(pbmc,dims = 1:20)
pbmc <- FindClusters(pbmc,resolution = resolution)


#library(clustree)
#for (res in c(0.01, 0.05, 0.1, 0.2, 0.3, 0.5,0.8,1)) {
#  pbmc=FindClusters(pbmc, #graph.name = "CCA_snn", 
#                               resolution =res, algorithm = 1)}

#pbmc=FindClusters(pbmc, #graph.name = "SCT_snn", 
#                            resolution = seq(from=0.1,to=1,by=0.1), algorithm = 1)


#apply(pbmc@meta.data[,grep("RNA_snn",colnames(pbmc@meta.data))],2,table)
#p2_tree=clustree(pbmc@meta.data, prefix = "RNA_snn_res.")


pbmc <- RunUMAP(pbmc,dims = 1:20,label=T)
#pbmc@reductions
#pbmc@reductions$umap
#pbmc@reductions$umap@cell.embeddings
#head(pbmc@reductions$umap@cell.embeddings)

DimPlot(pbmc, reduction = "umap",#group.by = "RNA_snn_res.0.5",
        label = T) 
ggsave(filename="cluster.pdf")


#write.csv(x = pbmc@reductions$umap@cell.embeddings,file = "umap.csv",quote = FALSE)



#p1 <- DimPlot(pbmc,reduction = "umap")


#pbmc <- RunTSNE(pbmc,dims = 1:15)
#head(pbmc@reductions$tsne@cell.embeddings)

#write.csv(x = pbmc@reductions$tsne@cell.embeddings,file = "tsne.csv",quote = FALSE)
#p2 <- DimPlot(pbmc,reduction = "tsne")

#p1+guides(color="none")+p2

#p3 <- DimPlot(pbmc,reduction = "pca")
#(p1+guides(color="none"))+(p2+guides(color="none"))+p3


saveRDS(pbmc,file = "Seuratproject.rds")


# find all markers of cluster 2
#cluster2.markers <- FindMarkers(pbmc, ident.1 = 2, min.pct = 0.25)


# find markers for every cluster compared to all remaining cells, report only the positive ones
pbmc.markers <- FindAllMarkers(pbmc, only.pos = TRUE, min.pct = 0.1, logfc.threshold = 0.25)
write.csv(pbmc.markers,file = "clusters_markers.csv",quote = FALSE)



}else{
  
  
  
  #inputFile <- file.path(inputFile)
  #setwd(inputFile)
  #list.files(paste0(inputFile,'/'))
  
 
  
  
  pbmc = lapply(paste0( inputFile,'/',folders),function(folder){ 
    CreateSeuratObject(counts = Read10X(folder), 
                       project = folder, min.cells = 3,
                       min.features = 200)})
  pbmc <- merge(pbmc[[1]], 
                   y = c(pbmc[c(2:length(pbmc))]),add.cell.ids = folders,
                   project = "project") 
  
  
  df_zhushi<-as.data.frame(pbmc$orig.ident)
  df_zhushi$V2<-"a"
  colnames(df_zhushi) <- c('sample','V2') 
  extract_string <- function(x) {
    split_val <- strsplit(x, "/")[[1]]
    extracted_val <- split_val[length(split_val)]
    return(extracted_val)
  }
  df_zhushi$V2 <- sapply(df_zhushi$sample, extract_string)
  
  pbmc$orig.ident<-df_zhushi$V2
  Idents(pbmc) <- 'orig.ident'
  

  if(length(which(PercentageFeatureSet(pbmc,pattern = "^MT-") > 0))>0 ){
    
    pbmc[['percent.MT']] <- PercentageFeatureSet(pbmc,pattern = "^MT-")
    
    
    VlnPlot(pbmc,features = c("nFeature_RNA","nCount_RNA"),ncol=2)
    ggsave(filename="Vlnplot_filter_before.pdf")
    
    plot1 <- FeatureScatter(pbmc,feature1 = "nCount_RNA",feature2 = "percent.MT")
    plot2 <- FeatureScatter(pbmc,feature1 = "nCount_RNA",feature2 = "nFeature_RNA")
    plot1+plot2
    ggsave(filename="FeatureScatter.pdf",width = 8)
    
    
    pbmc <- subset(pbmc, subset = nFeature_RNA > 200 & nFeature_RNA < gene_counts & percent.MT < MT_percent)
    dim(pbmc)
    
    
    
    VlnPlot(pbmc,features = c("nFeature_RNA","nCount_RNA","percent.MT"),ncol=3)
    
    ggsave(filename="Vlnplot_filter_after.pdf")
    
    #plot1 <- FeatureScatter(pbmc, feature1 ="nCount_RNA", feature2 = "percent.MT")+ NoLegend()
   # plot2 <- FeatureScatter(pbmc, feature1 ="nCount_RNA", feature2 = "nFeature_RNA")+ NoLegend()
   # plot1 + plot2
    
    
  }else{
    
    pbmc[['percent.MT']] <- PercentageFeatureSet(pbmc,pattern = "^mt-")
    
    
    VlnPlot(pbmc,features = c("nFeature_RNA","nCount_RNA","percent.MT"),ncol=3)
    ggsave(filename="Vlnplot_filter_before.pdf")
    
    
    plot1 <- FeatureScatter(pbmc,feature1 = "nCount_RNA",feature2 = "percent.MT")
    plot2 <- FeatureScatter(pbmc,feature1 = "nCount_RNA",feature2 = "nFeature_RNA")
    plot1+plot2
    ggsave(filename="FeatureScatter.pdf",width = 8)
    
    
    pbmc <- subset(pbmc, subset = nFeature_RNA > 200 & nFeature_RNA < gene_counts & percent.MT < MT_percent)
    dim(pbmc)
    
    
    
    VlnPlot(pbmc,features = c("nFeature_RNA","nCount_RNA","percent.MT"),ncol=3)
    ggsave(filename="Vlnplot_filter_after.pdf")
    
  #  plot1 <- FeatureScatter(pbmc, feature1 ="nCount_RNA", feature2 = "percent.MT")+ NoLegend()
  #  plot2 <- FeatureScatter(pbmc, feature1 ="nCount_RNA", feature2 = "nFeature_RNA")+ NoLegend()
   # plot1 + plot2
    
  }
  
  
  pbmc <- NormalizeData(pbmc, normalization.method = "LogNormalize", scale.factor = 10000)
  pbmc
  
  
 # s.genes <- cc.genes$s.genes
 # g2m.genes <- cc.genes$g2m.genes
 # pbmc <- CellCycleScoring(pbmc, s.features = s.genes, g2m.features = g2m.genes, set.ident = TRUE)
  
  
  pbmc <- FindVariableFeatures(pbmc, selection.method = "vst", nfeatures = 2000)
  
  
  #top10 <- head(VariableFeatures(pbmc), 10)
  
  
  
  #plot1 <- VariableFeaturePlot(pbmc)+guides(color="none")
  
  #plot2 <- LabelPoints(plot = plot1,points = top10,repel = TRUE,xnudge = 0,ynudge = 0)
  
  #plot1+plot2
  
  all.genes <- rownames(pbmc)
  all.genes
  
  pbmc <- ScaleData(pbmc,vars.to.regress = c('percent.MT'#,"S.Score","G2M.Score"
                                             ))
  
  
  #shuqu_T_filter1 <- SCTransform(shuqu_T_filter1,vars.to.regress = c('percent.MT',"S.Score","G2M.Score"),verbose=F)
  
  
 
  pbmc <- RunPCA(pbmc,features = VariableFeatures(object = pbmc))
  
  #print(pbmc[['pca']],dims = 1:5,nfeatures = 5)
  
  
  #VizDimLoadings(pbmc,dims = 1:2,reduction = "pca")
  
  #DimPlot(pbmc,reduction = "pca" )
  
  #DimHeatmap(pbmc,dims = 1,cells = 500,balanced = TRUE,)
 
  #DimHeatmap(pbmc, dims = 1:15, cells = 500, balanced = TRUE)
  
  
  
 ================
  
  #pbmc <- JackStraw(pbmc,num.replicate = 100)
  #pbmc <- ScoreJackStraw(pbmc,dims = 1:20)
 
 # JackStrawPlot(pbmc,dims = 1:15)
  ElbowPlot(pbmc)
  ggsave(filename="ElbowPlot.pdf")
  

 
  #DefaultAssay(shuqu_T_PCA) <- "RNA"   #  DefaultAssay(shuqu_T_PCA) <- "integrated"
  
  library(harmony)
  pbmc<- RunHarmony(pbmc,group.by.vars= 'orig.ident', max.iter.harmony = 20)
  
  pbmc<- RunUMAP(pbmc,  dims = 1:20,# min.dist = 0.2,n.neighbors = 15L,
                 reduction = "harmony")

  
  
  pbmc <- FindNeighbors(pbmc,dims = 1:20)
  pbmc <- FindClusters(pbmc,resolution = 0.6)
  
  
  #library(clustree)
  #for (res in c(0.01, 0.05, 0.1, 0.2, 0.3, 0.5,0.8,1)) {
  #  pbmc=FindClusters(pbmc, #graph.name = "CCA_snn", 
  #                               resolution =res, algorithm = 1)}
  
  #pbmc=FindClusters(pbmc, #graph.name = "SCT_snn", 
  #                            resolution = seq(from=0.1,to=1,by=0.1), algorithm = 1)
  
  
  #apply(pbmc@meta.data[,grep("RNA_snn",colnames(pbmc@meta.data))],2,table)
  #p2_tree=clustree(pbmc@meta.data, prefix = "RNA_snn_res.")

  
  DimPlot(pbmc, reduction = "umap",#group.by = "RNA_snn_res.0.5",
          label = T) 

  ggsave(filename="cluster.pdf")
  
  saveRDS(pbmc,file = "Seuratproject.rds")
  
  
  # find all markers of cluster 2
  #cluster2.markers <- FindMarkers(pbmc, ident.1 = 2, min.pct = 0.25)
  
  
  # find markers for every cluster compared to all remaining cells, report only the positive ones
  pbmc.markers <- FindAllMarkers(pbmc, only.pos = TRUE, min.pct = 0.1, logfc.threshold = 0.25)
  write.csv(pbmc.markers,file = "clusters_markers.csv",quote = FALSE)
  
  
}










