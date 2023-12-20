
args = commandArgs(trailingOnly=TRUE)
argsCount = 15

if (length(args)!=argsCount) {
  stop("GO_barplot_docker_v.1.0.R libPath is_Model_Species inputFile1 inputFile2 inputFile3 species pjmethod is_ont is_title p_color is_showCategory is_label_format color_low color_high outputFileName")
}
.libPaths(args[1])
 
 is_Model_Species <- args[2]
 if (is.na(is_Model_Species)) {
  is_Model_Species <- "yes"
}
 
inputFile1 <- args[3]
inputFile2 <- args[4]
inputFile3 <- args[5]

species <- args[6]
if (is.na(species)) {
  species <- "org.Hs.eg.db"
}

pjmethod <- args[7]
if (is.na(pjmethod)) {
  pjmethod <- "BH"
}

is_ont <- args[8]
if (is.na(is_ont)) {
  is_ont <- "all"
}

is_title <- args[9]
if (is.na(is_title)) {
  is_title <- "GO_term"
}
p_color <- args[10]
if (is.na(p_color)) {
  p_color <- "p.adjust"
}

is_showCategory <- as.numeric(args[11]) 
if (is.na(is_showCategory)) {
  is_showCategory <- "5"
}
is_label_format <- as.numeric(args[12]) 
if (is.na(is_label_format)) {
  is_label_format <- "30"
}
color_low <- args[13]
if (is.na(color_low)) {
  color_low <- "red"
}

color_high <- args[14]
if (is.na(color_high)) {
  color_high <- "blue"
}

outputFileName <- args[15]
if (is.na(outputFileName)) {
  outputFileName <- "dotplot"
}


library("clusterProfiler")
library(org.Hs.eg.db)
library("enrichplot")
library("ggplot2")

yes_Model_Species <- c("yes")
no_Model_Species <- c("no")


if(is_Model_Species %in% yes_Model_Species){


data_gene=read.table(inputFile1,sep="\t",check.names=F,header=T)
genes=as.vector(data_gene[,1])

geneid=bitr(genes,fromType = "SYMBOL",
            toType = "ENTREZID",
            OrgDb = species,drop = F)

gene_id=geneid[is.na(geneid[,"ENTREZID"])==F,]
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

GO1 <- c("BP","CC","MF")
GO2 <- c("all")
if(is_ont %in% GO2){
p=dotplot(go_enrich,
        title=is_title,
        font.size=10,
		color=p_color,#'pvalue', 'p.adjust' or 'qvalue'
        showCategory=is_showCategory,
        label_format = is_label_format,
        split='ONTOLOGY')+
         facet_grid(ONTOLOGY~.,scale="free")+
          theme(axis.text.y=element_text(angle=0, vjust=0, hjust=0))+
		# labs(y="Description)+
  scale_color_continuous(low=color_low, high=color_high)


}else if(is_ont %in% GO1){
p=dotplot(go_enrich,
        title=is_title,
        font.size=10,
		color=p_color,#'pvalue', 'p.adjust' or 'qvalue'
        showCategory=is_showCategory,
        label_format = is_label_format,
        )+ theme(axis.text.y=element_text(angle=0, vjust=0, hjust=0))+
		# labs(y="Description)+
  scale_color_continuous(low=color_low, high=color_high)

}
ggsave(plot=p,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=35,height=20,dpi=600)



}else if(is_Model_Species %in% no_Model_Species){

data_gene <- read.table(inputFile1,sep="\t",check.names=F,header=T)
gene_GO <- read.table(inputFile2,sep="\t",check.names=F,header=T)
GO_Discription <- read.delim(inputFile3,header=TRUE,sep='\t')

term2gene = data.frame(gene_GO[,2],gene_GO[,1])
term2name = data.frame(GO_Discription[,1],GO_Discription[,2])
gene = as.vector(data_gene[,1])

go_enrich = enricher(gene,
                     pvalueCutoff = 0.05,
					 qvalueCutoff = 0.05,
					 pAdjustMethod = pjmethod,
					 TERM2GENE = term2gene,
					 TERM2NAME = term2name)

#write.table(go_enrich,file="GO_enrichment.csv",sep=",",quote=F,row.names = F)
write.table(go_enrich,file=paste(outputFileName,"GO_enrichment.csv",sep="_"),sep=",",row.names=F,quote=F)

p=dotplot(go_enrich,
        title=is_title,
        font.size=10,
		color=p_color,#'pvalue', 'p.adjust' or 'qvalue'
        showCategory=is_showCategory,
        label_format = is_label_format,
        )+ theme(axis.text.y=element_text(angle=0, vjust=0, hjust=0))+
		# labs(y="Description)+
  scale_color_continuous(low=color_low, high=color_high)
ggsave(plot=p,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=35,height=20,dpi=600)
}



