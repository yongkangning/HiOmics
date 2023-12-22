
args = commandArgs(trailingOnly=TRUE)
argsCount = 6

if (length(args)!=argsCount) {
  stop("app.R libPath inputFile species log2FC is_ont pjmethod")
}

.libPaths(args[1])
inputFile <- args[2]
species <- args[3]
#org.Dm.eg.db（Fly）、org.Dr.eg.db（Zebrafish）、org.EcK12.eg.db（E coli strain K12）、org.EcSakai.eg.db（E coli strain Sakai）、org.Gg.eg.db（Chicken）、org.Mm.eg.db（Mouse）、org.Mmu.eg.db（Rhesus）、
#org.Pf.plasmo.db（Malaria）、org.Pt.eg.db（Chimp）、org.Rn.eg.db（Rat）、org.Sc.sgd.db（Yeast）、org.Ss.eg.db（Pig）、org.Xl.eg.db（Xenopus）、org.Mxanthus.db（Myxococcus xanthus）
if (is.na(species)) {
  species <- "org.Hs.eg.db"
}

log2FC <- as.numeric(args[4])
if (is.na(log2FC)) {
  log2FC <- 0.25
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
  markers <- FindAllMarkers(pbmc, only.pos = TRUE, min.pct = 0.1, logfc.threshold = log2FC)
  
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
#library(org.Ss.eg.db)

# Organism <-c("hsa","aga","ath","bta","cel","cfa","dme","dre","ecok","ecs","gga","mmu","pfa","ptr","rno","sce","ssc","xla","mcc","mxa")
# Organism_in= 
  # if(species %in% c("org.Hs.eg.db")){Organism %in% c("hsa")
  # }else if(species %in% c("org.Ag.eg.db")){Organism %in% c("aga")
  # }else if(species %in% c("rg.At.tair.db")){Organism %in% c("ath")
  # }else if(species %in% c("org.Bt.eg.db")){Organism %in% c("bta")
  # }else if(species %in% c("org.Ce.eg.db")){Organism %in% c("cel")
  # }else if(species %in% c("org.Cf.eg.db")){Organism %in% c("cfa")
  # }else if(species %in% c("org.Dm.eg.db")){Organism %in% c("dme")
  # }else if(species %in% c("org.Dr.eg.db")){Organism %in% c("dre")
  # }else if(species %in% c("org.EcK12.eg.db")){Organism %in% c("ecok")
  # }else if(species %in% c("org.EcSakai.eg.db")){Organism %in% c("ecs")
  # }else if(species %in% c("org.Gg.eg.db")){Organism %in% c("gga")
  # }else if(species %in% c("org.Mm.eg.db")){Organism %in% c("mmu")
  # }else if(species %in% c("org.Pf.plasmo.db")){Organism %in% c("pfa"
  # }else if(species %in% c("org.Pt.eg.db")){Organism %in% c("ptr")
  # }else if(species %in% c("org.Rn.eg.db")){Organism %in% c("rno")
  # }else if(species %in% c("org.Sc.sgd.db")){Organism %in% c("sce")
  # }else if(species %in% c("org.Ss.eg.db")){Organism %in% c("ssc")
  # }else if(species %in% c("org.Xl.eg.db")){Organism %in% c("xla")
  # }else if(species %in% c("org.Mmu.eg.db")){Organism %in% c("mcc")
  # }else if(species %in% c("org.Mxanthus.db")){Organism %in% c("mxa")
  # }
# is_Organism <- Organism[Organism_in==T]

ids=bitr(markers$gene,'SYMBOL','ENTREZID',species) 
markers=merge(markers,ids,by.x='gene',by.y='SYMBOL')

gcSample=split(markers$ENTREZID, markers$cluster) 


## GO 
xx <- compareCluster(gcSample,
                     fun = "enrichGO",
                     OrgDb = species,
                     ont = is_ont,
                     pAdjustMethod = pjmethod,
                     pvalueCutoff = 0.01,
                     qvalueCutoff = 0.2
)


GO1 <- c("BP","CC","MF")
GO2 <- c("all")
if(is_ont %in% GO2){

grDevices::cairo_pdf(file = "cluster_GO.pdf",
                      width = 2+length(unique(markers$cluster)), height = 12)
dotplot(xx,label_format =85)+ theme(axis.text.x = element_text(angle = 45,  vjust = 0.5, hjust = 0.5,size = 12),
                                    axis.text.y = element_text(size = 12))+ facet_grid(ONTOLOGY~.,scale="free")

}else if(is_ont %in% GO1){
  
  grDevices::cairo_pdf(file = "cluster_GO.pdf",
                       family = "serif",width = 2+length(unique(markers$cluster)), height = 12)
  dotplot(xx,label_format =85)+ theme(axis.text.x = element_text(angle = 45,  vjust = 0.5, hjust = 0.5,size = 12),
                                      axis.text.y = element_text(size = 12))
 
}
dev.off()
xx=DOSE::setReadable(xx, OrgDb=species,keyType='ENTREZID')
write.csv(xx@compareClusterResult,'cluster_markers_GO.csv')

