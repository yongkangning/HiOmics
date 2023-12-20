
args = commandArgs(trailingOnly=TRUE)
argsCount = 13

if (length(args)!=argsCount) {
  stop("cnetplot_docker_v.1.1.R libPath is_Model_Species inputFile1 inputFile2 inputFile3 is_logFC species pjmethod is_ont is_node_label is_plot is_showCategory outputFileName")
}
.libPaths(args[1])
 
 is_Model_Species <- args[2]
 if (is.na(is_Model_Species)) {
  is_Model_Species <- "yes"
}
 
inputFile1 <- args[3]
inputFile2 <- args[4]
inputFile3 <- args[5]


is_logFC <- args[6]
if (is.na(is_logFC)) {
  is_logFC <- "no"
}

species <- args[7]
if (is.na(species)) {
  species <- "org.Hs.eg.db"
}

pjmethod <- args[8]
if (is.na(pjmethod)) {
  pjmethod <- "BH"
}

is_ont <- args[9]
if (is.na(is_ont)) {
  is_ont <- "all"
}
is_node_label <- args[10] 
if (is.na(is_node_label)) {
  is_node_label <- "all"
}

is_plot <- args[11]
if (is.na(is_plot)) {
  is_plot <- "netplot"
}

is_showCategory <- as.numeric(args[12]) 
if (is.na(is_showCategory)) {
  is_showCategory <- "5"
}

outputFileName <- args[13]
if (is.na(outputFileName)) {
  outputFileName <- "netplot"
}


library("clusterProfiler")
library(org.Hs.eg.db)
library("enrichplot")
library("ggplot2")
library(stringr)


yes_Model_Species <- c("yes")
no_Model_Species <- c("no")
yes_logFC <- c("yes")
no_logFC <- c("no")


if(is_Model_Species %in% yes_Model_Species){


data_gene=read.table(inputFile1,sep="\t",check.names=F,header=T)
genes=as.vector(data_gene[,1])
#entrezIDs <- mget(genes, org.Hs.egSYMBOL2EG, ifnotfound=NA)
#entrezIDs <- as.character(entrezIDs)
#out=cbind(gene,entrezID=entrezIDs)



if(is_logFC %in% yes_logFC){
geneid=bitr(genes,fromType = "SYMBOL",
            toType = "ENTREZID",
            OrgDb = species,drop = F)

id =cbind(geneid,logFC=gene$logFC)
#id=na.omit(id)
#write.table(id,file="id.txt",sep="\t",quote=F,row.names=F)


#rt=read.table("id.txt",sep="\t",header=T,check.names=F)
gene_id=id[is.na(id[,"ENTREZID"])==F,]
gene=gene_id$ENTREZID

go_enrich <- enrichGO(gene = gene,
               OrgDb = species, 
			   pAdjustMethod = pjmethod,
               pvalueCutoff = 0.05, 
               qvalueCutoff = 0.05,
               ont = is_ont,
               readable = T)
#write.table(go_enrich,file="GO_enrichment.csv",sep=",",quote=F,row.names = F)
write.table(go_enrich,file=paste(outputFileName,"GO_enrichment.csv",sep="_"),sep=",",row.names=F,quote=F)

geneList <- gene_id$logFC
names(geneList) <- gene_id$ENTREZID

circular_netplot <- c("circular")
netplot <- c("netplot")

if(is_plot %in% circular_netplot){
p=cnetplot(go_enrich, 
         foldChange = geneList, 
         #foldChange = NULL, 
         circular = TRUE,
         node_label = is_node_label,
         showCategory = is_showCategory, 
         colorEdge = TRUE)

ggsave(plot=p,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=30,height=20,dpi=600)
}else if(is_plot %in% netplot){

svg(filename = paste(outputFileName,"svg",sep="."),height = 7,width = 10)
cnetplot(go_enrich, 
         foldChange = geneList, 
         #foldChange = NULL, 
         #circular = TRUE,
         node_label = is_node_label,
         showCategory = is_showCategory, 
         colorEdge = TRUE)
#ggsave(plot=p,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=30,height=20,dpi=600)
dev.off()
}



}else if(is_logFC %in% no_logFC){
geneid=bitr(genes,fromType = "SYMBOL",
            toType = "ENTREZID",
            OrgDb = species,drop = F)
			
gene_id=geneid[is.na(geneid[,"ENTREZID"])==F,]
gene=gene_id$ENTREZID

go_enrich <- enrichGO(gene = gene,
               OrgDb = species, 
			   pAdjustMethod = pjmethod,
               pvalueCutoff =0.05, 
               qvalueCutoff = 0.05,
               ont=is_ont,
               readable =T)
#write.table(go_enrich,file="GO_enrichment.csv",sep=",",quote=F,row.names = F)
write.table(go_enrich,file=paste(outputFileName,"GO_enrichment.csv",sep="_"),sep=",",row.names=F,quote=F)

circular_netplot <- c("circular")
netplot <- c("netplot")

if(is_plot %in% circular_netplot){
p=cnetplot(go_enrich, 
         #foldChange = geneList, 
         circular = TRUE,
         node_label = is_node_label,
         showCategory = is_showCategory, 
         colorEdge = TRUE)

ggsave(plot=p,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=30,height=20,dpi=600)
}else if(is_plot %in% netplot){

p=cnetplot(go_enrich, 
         #foldChange = geneList, 
           #circular = TRUE,
         node_label = is_node_label,
         showCategory = is_showCategory, 
         colorEdge = TRUE)
ggsave(plot=p,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=30,height=20,dpi=600)

}
}


}else if(is_Model_Species %in% no_Model_Species){

data_gene <- read.table(inputFile1,sep="\t",check.names=F,header=T)
gene_GO <- read.table(inputFile2,sep="\t",check.names=F,header=T)
GO_Discription <- read.delim(inputFile3,header=TRUE,sep='\t')

term2gene = data.frame(gene_GO[,2],gene_GO[,1])
term2name = data.frame(GO_Discription[,1],GO_Discription[,2])
gene = as.vector(data_gene[,1])


if(is_logFC %in% yes_logFC){
go_enrich = enricher(gene,
                     pvalueCutoff = 0.05,
					 qvalueCutoff = 0.05,
					 pAdjustMethod = pjmethod,
					 TERM2GENE = term2gene,
					 TERM2NAME = term2name)
#go_enrich = as.data.frame(go_enrich)

#write.table(go_enrich,file="GO_enrichment.csv",sep=",",quote=F,row.names = F)
write.table(go_enrich,file=paste(outputFileName,"GO_enrichment.csv",sep="_"),sep=",",row.names=F,quote=F)

circular_netplot <- c("circular")
netplot <- c("netplot")


if(is_plot %in% circular_netplot){
p=cnetplot(go_enrich, 
         #foldChange = geneList, 
         #foldChange = NULL, 
         circular = TRUE,
         node_label = is_node_label,
         showCategory = is_showCategory, 
         colorEdge = TRUE)

ggsave(plot=p,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=30,height=20,dpi=600)
}else if(is_plot %in% netplot){

p=cnetplot(go_enrich, 
         #foldChange = geneList, 
         #foldChange = NULL, 
         #circular = TRUE,
         node_label = is_node_label,
         showCategory = is_showCategory, 
         colorEdge = TRUE)
ggsave(plot=p,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=30,height=20,dpi=600)
}


}else if(is_logFC %in% no_logFC){

go_enrich = enricher(gene,
                     pvalueCutoff = 0.05,
					 qvalueCutoff = 0.05,
					 pAdjustMethod = pjmethod,
					 TERM2GENE = term2gene,
					 TERM2NAME = term2name)
#go_enrich = as.data.frame(go_enrich)

#write.table(go_enrich,file="GO_enrichment.csv",sep=",",quote=F,row.names = F)
write.table(go_enrich,file=paste(outputFileName,"GO_enrichment.csv",sep="_"),sep=",",row.names=F,quote=F)

circular_netplot <- c("circular")
netplot <- c("netplot")

if(is_plot %in% circular_netplot){
p=cnetplot(go_enrich, 
         #foldChange = geneList, 
         #foldChange = NULL, 
         circular = TRUE,
         node_label = is_node_label,
         showCategory = is_showCategory, 
         colorEdge = TRUE)

ggsave(plot=p,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=30,height=20,dpi=600)
}else if(is_plot %in% netplot){

p=cnetplot(go_enrich, 
         #foldChange = geneList, 
         #foldChange = NULL, 
         #circular = TRUE,
         node_label = is_node_label,
         showCategory = is_showCategory, 
         colorEdge = TRUE)
ggsave(plot=p,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=30,height=20,dpi=600)
}

}

}


