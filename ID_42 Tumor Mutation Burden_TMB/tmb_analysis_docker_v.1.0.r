args = commandArgs(trailingOnly=TRUE)
argsCount = 11

if (length(args)!=argsCount) {
  stop("tmb_analysis_docker_v.1.0.r libPath inputFile1 inputFile2 fs_size oncoplot_top is_clinicalFeatures draw_titv outputFileName1 outputFileName2 outputFileName3 outputFileName4")
}
.libPaths(args[1])
 
inputFile1 <- args[2]
inputFile2 <- args[3]

fs_size <- as.numeric(args[4])
if (is.na(fs_size)) {
  fs_size <- "0.8"
}
oncoplot_top <- as.numeric(args[5])
if (is.na(oncoplot_top)) {
  oncoplot_top <- "10"
}
is_clinicalFeatures <- args[6]
if (is.na(is_clinicalFeatures)) {
  is_clinicalFeatures <- "yes"
}
draw_titv <- as.logical(args[7])
if (is.na(draw_titv)) {
  draw_titv <- "T"
}
outputFileName1 <- args[8]
if (is.na(outputFileName1)) {
  outputFileName1 <- "plotmafSummary"
}

outputFileName2 <- args[9]
if (is.na(outputFileName2)) {
  outputFileName2 <- "oncoplot"
}

outputFileName3 <- args[10]
if (is.na(outputFileName3)) {
  outputFileName3 <- "Mutation_Burden_log"
}

outputFileName4 <- args[11]
if (is.na(outputFileName4)) {
  outputFileName4 <- "Mutation_Burden_boxplot"
}

  library('maftools')
  library("data.table")
  library("utils")
  library("dplyr")
  library("DT")
  library("ggpubr")
  library("ggsignif")
  library("gplots")
  library("ggplot2")
  library(myplot)
  phenotype_file <- read.table(inputFile1,header = T,sep = '\t',quote = '',stringsAsFactors=FALSE)
  colnames(phenotype_file)[1]="Tumor_Sample_Barcode"
  #laml.maf=maf_file
  #annovarToMaf("TCGA-LUAD.allsample.txt",  Center = NULL,  refBuild = "hg19" )
  laml = read.maf(maf =inputFile2,clinicalData = phenotype_file)

 p1= myplot({plotmafSummary(maf = laml,
                 rmOutlier = TRUE,
                 addStat = 'median', 
                 dashboard = TRUE,
                 titvRaw = FALSE,
				 fs=fs_size,
				 titleSize = 0.9)})
plotsave(p1,file=paste(outputFileName1,"svg",sep="."),unit="cm",width=15,height=15,dpi=600)
 

clinicalFeatures_yes<-c("yes")
clinicalFeatures_no<-c("no")
if(is_clinicalFeatures %in% clinicalFeatures_yes){
p2_2= myplot({ oncoplot(maf = laml, top = oncoplot_top, 
           clinicalFeatures=colnames(phenotype_file)[2],
           sortByAnnotation=F,
           fontSize = 0.8,titleFontSize = 1.5,
           legendFontSize = 1.2,
           removeNonMutated = T,
           borderCol=NULL,showTumorSampleBarcodes = F ,
		   draw_titv = draw_titv)})
	plotsave(p2_2,file=paste(outputFileName2,"svg",sep="."),unit="cm",width=15,height=15,dpi=600)
}else if(is_clinicalFeatures %in% clinicalFeatures_no){
   p2_1= myplot({oncoplot(maf = laml, top = oncoplot_top, 
          # clinicalFeatures=colnames(phenotype_file)[2],
           sortByAnnotation=F,
           fontSize = 0.8,titleFontSize = 1.5,
           legendFontSize = 1.2,
           removeNonMutated = T,
           borderCol=NULL,showTumorSampleBarcodes = F ,
		   draw_titv = draw_titv)})
  plotsave(p2_1,file=paste(outputFileName2,"svg",sep="."),unit="cm",width=15,height=15,dpi=600)}



 p3=myplot({ x = tmb(maf = laml)})
plotsave(p3,file=paste(outputFileName3,"svg",sep="."),unit="cm",width=15,height=15,dpi=600)


  tmb=as.data.frame(x)
  write.csv(tmb,"TMB.csv")
  tmb=read.csv("TMB.csv",header=T,row.names = 1,stringsAsFactors = FALSE)
  s=which(tmb$Tumor_Sample_Barcode%in%phenotype_file$Tumor_Sample_Barcode)
  tmb=tmb[s,]
  row.names(phenotype_file)=phenotype_file$Tumor_Sample_Barcode
  phenotype_file=phenotype_file[tmb$Tumor_Sample_Barcode,]
  all(tmb$Tumor_Sample_Barcode==phenotype_file$Tumor_Sample_Barcode)
  tmb$group=phenotype_file$group
  tmb=tmb[!is.infinite(tmb$total_perMB_log),]
 write.csv(tmb,"TMB.csv",row.names = F)
  
  library(ggpubr)
library(ggsignif)
library(ggplot2)

p4=ggboxplot(tmb, x = "group", y = "total_perMB_log", fill = "group",color = "black",
         add = "jitter", add.params = list(color = "black",size=0.01))+
    scale_fill_manual(values = c("#156077", "#f46f20"))+
    stat_compare_means(label = "p.format",label.y = max(tmb$total_perMB_log))+xlab("")+
    theme(axis.text.x=element_text(colour="black",angle = 0,vjust = 0.5),axis.text.y=element_text(colour="black"),panel.grid.major = element_blank(),panel.grid.minor = element_blank()) 
 
 ggsave(plot=p4,filename=paste(outputFileName4,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)

 
 
 