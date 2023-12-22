


args = commandArgs(trailingOnly=TRUE)
argsCount = 2

if (length(args)!=argsCount) {
  stop("app.R libPath inputFile")
}

.libPaths(args[1])
inputFile <- args[2] 


library(ggplot2)  
library(Seurat)


pbmc <- readRDS(inputFile)

Idents(pbmc) = "celltype"
#ref_marker=FindAllMarkers(pbmc,logfc.threshold = 0.25,min.pct = 0.1,only.pos = T,test.use = "wilcox")
#ref_marker=ref_marker%>%filter(p_val_adj < 0.01)
#ref_marker$d=ref_marker$pct.1 - ref_marker$pct.2
#ref_marker %>% ggplot(aes(x=d,fill = cluster))+geom_density()+facet_grid(cluster~.)+geom_vline(xintercept = 0.1)

#ref_marker=ref_marker%>%filter(d > 0.1)
#ref_marker=ref_marker%>%arrange(cluster,desc(avg_log2FC))
#ref_marker=as.data.frame(ref_marker)

#used_gene=sort(unique(ref_marker$gene))
sig_matrix=AverageExpression(pbmc, slot = 'data' ,verbose = FALSE)
sig_matrix =sig_matrix$RNA

write.csv(sig_matrix,file = "scRNA_signature_matrix.csv",quote = FALSE)

