
args = commandArgs(trailingOnly=TRUE)
argsCount = 6

if (length(args)!=argsCount) {
  stop("app.R inputFile celltype1 celltype2 log2FC species is_ont pjmethod")
}

inputFile <- args[1]
celltype1 <- args[2]
if (is.na(celltype1)) {
  celltype1 <- 'Memory CD4 T'
}
celltype2 <- args[3]
if (is.na(celltype2)) {
  celltype2 <- 'Naive CD4 T'
}


species <- args[4]#org.Hs.eg.db（Human）、org.Ag.eg.db（Anopheles）、org.At.tair.db（Arabidopsis）、org.Bt.eg.db（Bovine）、org.Ce.eg.db（Worm）、org.Cf.eg.db（Canine）、
#org.Dm.eg.db（Fly）、org.Dr.eg.db（Zebrafish）、org.EcK12.eg.db（E coli strain K12）、org.EcSakai.eg.db（E coli strain Sakai）、org.Gg.eg.db（Chicken）、org.Mm.eg.db（Mouse）、org.Mmu.eg.db（Rhesus）、
#org.Pf.plasmo.db（Malaria）、org.Pt.eg.db（Chimp）、org.Rn.eg.db（Rat）、org.Sc.sgd.db（Yeast）、org.Ss.eg.db（Pig）、org.Xl.eg.db（Xenopus）、org.Mxanthus.db（Myxococcus xanthus）
if (is.na(species)) {
  species <- "org.Hs.eg.db"
}



is_ont <- args[5]
if (is.na(is_ont)) {
  is_ont <- 'BP'
}
pjmethod <- args[6]
if (is.na(pjmethod)) {
  pjmethod <- "BH"
}

library(ggplot2)  
library(tidyverse)

filename = inputFile#="Seuratproject.rds"

file_suffix <- strsplit(filename, "\\.")[[1]]
filetype <- file_suffix[length(file_suffix)]

if(filetype %in% 'rds'){
  
  library(Seurat) 
  pbmc <- readRDS(inputFile)
  Idents(pbmc) = "celltype"
  markers <- FindMarkers(pbmc, only.pos = F,ident.1 = celltype1,
                         ident.2 = celltype2,  min.pct = 0.1)
  
  write.csv(markers,file = "cluster_markers.csv",quote = FALSE)
  
}else{
  
  #markers <- read.table(inputFile2,head = T,sep = '\t')
  filename = inputFile#="celltype.txt"
  
  
  file_suffix <- strsplit(filename, "\\.")[[1]]
  filetype <- file_suffix[length(file_suffix)]
  
  encode <-
    guess_encoding(filename, n_max = 1000)[1, 1, drop = TRUE]
  # print(encode)
  if(is.na(encode)) {
    stop(paste("[ERRO]", filename,"encoding_nonsupport"))
  }
  if(filetype %in% c("csv","txt")){
    
    read_data <- function(filename, has_header) {
      
      if (filetype == "csv") {
        df <-
          tryCatch(
            read.csv(filename, header = has_header, fileEncoding = encode,sep=",",check.names=FALSE),
            warning = function(e) {
              read.csv(filename, header = has_header,fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
            }
          )
      } else if (filetype == "txt") {
        df <-
          tryCatch(
            read.table(filename, header = has_header, fileEncoding = encode,sep="\t",check.names=FALSE),
            warning = function(e) {
              read.table(filename, header = has_header, fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
            }
          )
      }  else {
        stop("[ERRO] txt csv")
      }
      return(df)
      
    }
    markers = read_data(file = filename,has_header = T)
    
  }else if (filetype %in% c("xls", "xlsx")) {
    
    read_data <- function(filename, has_header) {
      if(filetype %in% c("xls", "xlsx")){
        df <- readxl::read_excel(filename,col_names=has_header)
        
      } else {
        stop("[ERRO] xls xlsx")}
    }
    
    
    markers = read_data(file = filename,has_header = T)
    markers =as.data.frame(markers)
    
    
  }
  
}


library(clusterProfiler)
library(org.Hs.eg.db)
library(org.Mm.eg.db)

Organism <-c("hsa","aga","ath","bta","cel","cfa","dme","dre","ecok","ecs","gga","mmu","pfa","ptr","rno","sce","ssc","xla","mcc","mxa")
Organism_in= 
  if(species %in% c("org.Hs.eg.db")){Organism %in% c("hsa")
  }else if(species %in% c("org.Ag.eg.db")){Organism %in% c("aga")
  }else if(species %in% c("rg.At.tair.db")){Organism %in% c("ath")
  }else if(species %in% c("org.Bt.eg.db")){Organism %in% c("bta")
  }else if(species %in% c("org.Ce.eg.db")){Organism %in% c("cel")
  }else if(species %in% c("org.Cf.eg.db")){Organism %in% c("cfa")
  }else if(species %in% c("org.Dm.eg.db")){Organism %in% c("dme")
  }else if(species %in% c("org.Dr.eg.db")){Organism %in% c("dre")
  }else if(species %in% c("org.EcK12.eg.db")){Organism %in% c("ecok")
  }else if(species %in% c("org.EcSakai.eg.db")){Organism %in% c("ecs")
  }else if(species %in% c("org.Gg.eg.db")){Organism %in% c("gga")
  }else if(species %in% c("org.Mm.eg.db")){Organism %in% c("mmu")
  }else if(species %in% c("org.Pf.plasmo.db")){Organism %in% c("pfa")
  }else if(species %in% c("org.Pt.eg.db")){Organism %in% c("ptr")
  }else if(species %in% c("org.Rn.eg.db")){Organism %in% c("rno")
  }else if(species %in% c("org.Sc.sgd.db")){Organism %in% c("sce")
  }else if(species %in% c("org.Ss.eg.db")){Organism %in% c("ssc")
  }else if(species %in% c("org.Xl.eg.db")){Organism %in% c("xla")
  }else if(species %in% c("org.Mmu.eg.db")){Organism %in% c("mcc")
  }else if(species %in% c("org.Mxanthus.db")){Organism %in% c("mxa")
  }
is_Organism <- Organism[Organism_in==T]

markers$gene <- rownames(markers)



gene_up=rownames(markers[markers$avg_log2FC > 0,])
gene_down=rownames(markers[markers$avg_log2FC < 0,])

gene_up <- bitr(gene_up, 
                fromType = "SYMBOL",
                toType = "ENTREZID",
                OrgDb = species,drop = F)   
gene_down <- bitr(gene_down, 
                  fromType = "SYMBOL",
                  toType = "ENTREZID",
                  OrgDb = species,drop = F)  


go_up <- enrichGO(gene = gene_up$ENTREZID,
                      OrgDb = species, 
                      pAdjustMethod = pjmethod,
                      pvalueCutoff = 0.05, 
                      qvalueCutoff = 0.05,
                      ont = is_ont,
                      readable = T)

go_down <- enrichGO(gene = gene_down$ENTREZID,
                  OrgDb = species, 
                  pAdjustMethod = pjmethod,
                  pvalueCutoff = 0.05, 
                  qvalueCutoff = 0.05,
                  ont = is_ont,
                  readable = T)




GO1 <- c("BP","CC","MF")
GO2 <- c("all")
if(is_ont %in% GO2){
  
  grDevices::cairo_pdf(file = paste0("GO_up_",celltype1,".pdf"),
                       family = "serif", width = 10+length(unique(markers$cluster)), height = 6)
  dotplot(go_up,label_format =85)+ theme(axis.text.x = element_text(angle = 45,  vjust = 0.5, hjust = 0.5,size = 12),
                                      axis.text.y = element_text(size = 12))+ facet_grid(ONTOLOGY~.,scale="free")  
  
}else if(is_ont %in% GO1){
  
  grDevices::cairo_pdf(file = paste0("GO_up_",celltype1,".pdf"),
                       family = "serif", width = 10+length(unique(markers$cluster)), height = 6)
  dotplot(go_up,label_format =85)+ theme(axis.text.x = element_text(angle = 45,  vjust = 0.5, hjust = 0.5,size = 12),
                                      axis.text.y = element_text(size = 12))
}
dev.off()

if(is_ont %in% GO2){

  grDevices::cairo_pdf(file = paste0("GO_down_",celltype2,".pdf"),
                       family = "serif", width = 10+length(unique(markers$cluster)), height = 6)
  dotplot(go_down,label_format =85)+ theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust = 0.5,size = 12),
                                         axis.text.y = element_text(size = 12))+ facet_grid(ONTOLOGY~.,scale="free")
  
}else if(is_ont %in% GO1){
  
  grDevices::cairo_pdf(file = paste0("GO_down_",celltype2,".pdf"),
                       family = "serif", width = 10+length(unique(markers$cluster)), height = 6)
  dotplot(go_down,label_format =85)+ theme(axis.text.x = element_text(size = 12),
                                         axis.text.y = element_text(size = 12))

}
dev.off()

go_up=DOSE::setReadable(go_up, OrgDb=species,keyType='ENTREZID')
write.table(go_up@result,file=paste0("GO_up_",celltype1,".txt"),sep="\t",quote=F,row.names = F)

go_down=DOSE::setReadable(go_down, OrgDb=species,keyType='ENTREZID')
write.table(go_down@result,file=paste0("GO_down_",celltype2,".txt"),sep="\t",quote=F,row.names = F)


