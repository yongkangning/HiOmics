

args = commandArgs(trailingOnly=TRUE)
argsCount = 10

if (length(args)!=argsCount) {
  stop("WGCNA_docker.R libPath inputFile1 inputFile2 which_type min_modulesize is_TOMcutoff outputFileName1 outputFileName2 outputFileName3")
}
.libPaths(args[1])
inputFile1 <- args[2]
inputFile2 <- args[3]

which_type <- args[4]
if (is.na(which_type)) {
  which_type <- "unsigned"
}
min_modulesize <- as.numeric(args[5])
if (is.na(min_modulesize)) {
  min_modulesize <- 30
}
is_TOMcutoff  <- as.numeric(args[6])
if (is.na(is_TOMcutoff)) {
  is_TOMcutoff <- 0.05
}
interest_Trait <- as.numeric(args[7])
if (is.na(interest_Trait)) {
  interest_Trait <- 1
}
outputFileName1 <- args[8]
if (is.na(outputFileName1)) {
  outputFileName1 <- "result"
}
outputFileName2 <- args[9]
if (is.na(outputFileName2)) {
  outputFileName2 <- "Cytoscape"
}
outputFileName3 <- args[10]
if (is.na(outputFileName3)) {
  outputFileName3 <- "hubgene"
}
library(WGCNA)
library(reshape2)
library(stringr)
library(tidyverse)

options(stringsAsFactors = FALSE)

enableWGCNAThreads()


set.seed=1
type = which_type#"unsigned"

corType = "pearson"
corFnc = ifelse(corType=="pearson", cor, bicor)

maxPOutliers = ifelse(corType=="pearson",1,0.05)

robustY = ifelse(corType=="pearson",T,F)



#dataExpr <- read.table("exp_matrix.txt",row.names=1, header=T,sep="\t")
filename1 = inputFile1#='input1.txt'

file_suffix <- strsplit(filename1, "\\.")[[1]]
filetype <- file_suffix[length(file_suffix)]

encode <-
  guess_encoding(filename1, n_max = 1000)[1, 1, drop = TRUE]
# print(encode)
if(is.na(encode)) {
  stop(paste("[ERRO]", filename1,"encoding_nonsupport"))
}
if(filetype %in% c("csv","txt")){
  
  read_data <- function(filename1, has_header,has_rownames) {
    
    if (filetype == "csv") {
      df <-
        tryCatch(
          read.csv(filename1, header = has_header, row.names =has_rownames,fileEncoding = encode,sep=",",check.names=FALSE),
          warning = function(e) {
            read.csv(filename1, header = has_header,row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
          }
        )
    } else if (filetype == "txt") {
      df <-
        tryCatch(
          read.table(filename1, header = has_header,row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE),
          warning = function(e) {
            read.table(filename1, header = has_header, row.names =has_rownames,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
          }
        )
    }  else {
      stop("[ERRO] Only support txt csv xls xlsx")
    }
    return(df)
    
  }
  dataExpr = read_data(file = filename1,has_header = T,has_rownames=1)
  
}else if (filetype %in% c("xls", "xlsx")) {
  
  read_data <- function(filename1, has_header) {
    if(filetype %in% c("xls", "xlsx")){
      df <- readxl::read_excel(filename1,col_names=has_header)
      
    } else {
      stop("[ERRO] Only support txt csv xls xlsx")}
  }
  
  
  dataExpr = read_data(file = filename1,has_header = T)
  dataExpr =as.data.frame(dataExpr)
  row.names(dataExpr)=dataExpr[,1]
  dataExpr = dataExpr[,-1]
  
}

dataExpr <- as.data.frame(t(dataExpr))


gsg = goodSamplesGenes(dataExpr)

if (!gsg$allOK){
  # Optionally, print the gene and sample names that were removed:
  if (sum(!gsg$goodGenes)>0) 
    printFlush(paste("Removing genes:", 
                     paste(names(dataExpr)[!gsg$goodGenes], collapse = ",")));
  if (sum(!gsg$goodSamples)>0) 
    printFlush(paste("Removing samples:", 
                     paste(rownames(dataExpr)[!gsg$goodSamples], collapse = ",")));
  # Remove the offending genes and samples from the data:
  dataExpr = dataExpr[gsg$goodSamples, gsg$goodGenes]
}

nGenes = ncol(dataExpr)
nSamples = nrow(dataExpr)





#sampleTree = hclust(dist(dataExpr), method = "average")
#plot(sampleTree, main = "Sample clustering to detect outliers", sub="", xlab="")

powers = c(1:10,seq(from=11,to=30,by=2))
sft = pickSoftThreshold(dataExpr, powerVector=powers, 
                        networkType=type, verbose=5)



pdf(file = paste(outputFileName1,"ThresholdPower.pdf",sep="_"), width =8, height =8)
par(mfrow = c(1,2))
cex1 = 0.85


plot(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
     xlab="Soft Threshold (power)",
     ylab="Scale Free Topology Model Fit,signed R^2",type="n",
     main = paste("Scale independence"))
text(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
     labels=powers,cex=cex1,col="red")

abline(h=0.85,col="red")




plot(sft$fitIndices[,1], sft$fitIndices[,5],
     xlab="Soft Threshold (power)",ylab="Mean Connectivity", type="n",
     main = paste("Mean connectivity"))
text(sft$fitIndices[,1], sft$fitIndices[,5], labels=powers, 
     cex=cex1, col="red")

abline(h=100,col="red")

power = sft$powerEstimate
dev.off()


#if (is.na(power)){
#  power = ifelse(nSamples<20, ifelse(type == "unsigned", 9, 18),
#                 ifelse(nSamples<30, ifelse(type == "unsigned", 8, 16),
#                        ifelse(nSamples<40, ifelse(type == "unsigned", 7, 14),
#                               ifelse(type == "unsigned", 6, 12))       
#                 )
#  )
#}


net = blockwiseModules(dataExpr, power = power, maxBlockSize = nGenes,
                       TOMType = 'unsigned', minModuleSize = min_modulesize,
                       reassignThreshold = 0, mergeCutHeight = 0.25,
                       pamRespectsDendro = FALSE,
                       saveTOMs=TRUE, corType = corType, 
                       maxPOutliers=maxPOutliers, loadTOMs=TRUE,
                       saveTOMFileBase = "diff.tom",
                       verbose = 3)

table(net$colors)


#moduleColors = net$colors
moduleColors <- labels2colors(net$colors)

pdf(file = paste(outputFileName1,"ModuleView.pdf",sep="_"), width =6, height =6)

plotDendroAndColors(net$dendrograms[[1]], moduleColors[net$blockGenes[[1]]],
                    "Module colors",
                    dendroLabels = FALSE, hang = 0.03,
                    addGuide = TRUE, guideHang = 0.05)




MEs = net$MEs


MEs_col = MEs

colnames(MEs_col) = paste0("ME", labels2colors(
  str_replace_all(colnames(MEs),"ME","")))
MEs_col = orderMEs(MEs_col)

#MEs_colpheno = orderMEs(cbind(MEs_col, design$good))
plotEigengeneNetworks(MEs_col, "Eigengene adjacency heatmap",
                      marDendro = c(3,3,2,4),
                      marHeatmap = c(3,4,2,2), plotDendrograms = T, 
                      xLabelsAngle = 90)					  
dev.off()








####design
#design <- read.csv("design.csv")
#colnames(design)=c("Bad","Good","mean","very_bad")
filename2 = inputFile2#='input2.txt'
file_suffix <- strsplit(filename2, "\\.")[[1]]
filetype <- file_suffix[length(file_suffix)]

encode <-
  guess_encoding(filename2, n_max = 1000)[1, 1, drop = TRUE]
# print(encode)
if(is.na(encode)) {
  stop(paste("[ERRO]", filename2,"encoding_nonsupport"))
}
if(filetype %in% c("csv","txt")){
  
  read_data <- function(filename2, has_header,has_rownames) {
    
    if (filetype == "csv") {
      df <-
        tryCatch(
          read.csv(filename2, header = has_header, row.names =has_rownames,fileEncoding = encode,sep=",",check.names=FALSE),
          warning = function(e) {
            read.csv(filename2, header = has_header,row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
          }
        )
    } else if (filetype == "txt") {
      df <-
        tryCatch(
          read.table(filename2, header = has_header,row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE),
          warning = function(e) {
            read.table(filename2, header = has_header, row.names =has_rownames,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
          }
        )
    }  else {
      stop("[ERRO] txt csv")
    }
    return(df)
    
  }
  design = read_data(file = filename2,has_header = T,has_rownames=1)
  
}else if (filetype %in% c("xls", "xlsx")) {
  
  read_data <- function(filename2, has_header) {
    if(filetype %in% c("xls", "xlsx")){
      df <- readxl::read_excel(filename2,col_names=has_header)
      
    } else {
      stop("[ERRO] xls xlsx")}
  }
  
  
  design = read_data(file = filename2,has_header = T)
  design =as.data.frame(design)
  row.names(design)=design[,1]
  design = design[,-1]
  
}



sizeGrWindow(10,6)
# Will display correlations and their p-values


#if(trait != "") {
#  design <- read.table(file=trait, sep='\t', header=T, row.names=1,
#                          check.names=FALSE, comment='',quote="")
#  sampleName = rownames(dataExpr)
#  design = design[match(sampleName, rownames(design)), ]
#}

if (corType=="pearson") {
  modTraitCor = cor(MEs_col, design, use = "p")
  modTraitP = corPvalueStudent(modTraitCor, nSamples)
} else {
  modTraitCorP = bicorAndPvalue(MEs_col, design, robustY=robustY)
  modTraitCor = modTraitCorP$bicor
  modTraitP   = modTraitCorP$p
}

## Warning in bicor(x, y, use = use, ...): bicor: zero MAD in variable 'y'.
## Pearson correlation was used for individual columns with zero (or missing)
## MAD.


textMatrix = paste(signif(modTraitCor, 2), "\n(", signif(modTraitP, 1), ")", sep = "")
dim(textMatrix) = dim(modTraitCor)

pdf(file = paste(outputFileName1,"ModuleTrait.pdf",sep="_"))

# Display the correlation values within a heatmap plot

par(mar = c(6, 9, 3, 3));
labeledHeatmap(Matrix = modTraitCor, xLabels = colnames(design), 
               yLabels = colnames(MEs_col), 
               cex.lab = 0.5, 
               ySymbols = colnames(MEs_col), colorLabels = FALSE, 
               colors = blueWhiteRed(50), 
               textMatrix = textMatrix, setStdMargins = FALSE, 
               cex.text = 0.5, 
               main = paste("Module-trait relationships"))

dev.off()





TOM = TOMsimilarityFromExpr(dataExpr, power = power)


# load(net$TOMFiles[1], verbose=T)
 #TOM <- as.matrix(TOM)
dissTOM = 1-TOM
# Transform dissTOM with a power to make moderately strong 
# connections more visible in the heatmap
plotTOM = dissTOM^7
# Set diagonal to NA for a nicer plot
diag(plotTOM) = NA
# Call the plot function
library("gplots") 

pdf(file = paste(outputFileName1,"_Network_heatmap.pdf",sep="_"), width =10, height =8)
mycol = colorpanel(250,'red','orange','lemonchiffon') 
TOMplot(plotTOM, net$dendrograms, moduleColors,#col= mycol,
        main = "Network heatmap plot, all genes")
dev.off()


#geneid_allnet <- names(dataExpr)
MEs = moduleEigengenes(dataExpr, moduleColors)$eigengenes
modNames <- substring(names(MEs),3) 
TOMcutoff <- is_TOMcutoff 




for (mod in 1:nrow(table(moduleColors)))
{
  modules = names(table(moduleColors))[mod]
  # Select module probes
  probes = names(dataExpr)
  inModule = (moduleColors == modules)
  modProbes = probes[inModule]
  modGenes = modProbes
  # Select the corresponding Topological Overlap
  modTOM = TOM[inModule, inModule]
  
  dimnames(modTOM) = list(modProbes, modProbes)
  # Export the network into edge and node list files Cytoscape can read
  cyt = exportNetworkToCytoscape(modTOM,
                                 edgeFile = paste(outputFileName2,"-edges-", modules , ".txt", sep=""),
                                 nodeFile = paste(outputFileName2,"-nodes-", modules, ".txt", sep=""),
                                 weighted = TRUE,
                                 threshold = TOMcutoff,
                                 nodeNames = modProbes,
                                 altNodeNames = modGenes,
                                 nodeAttr = moduleColors[inModule])
}

#write.csv(cyt, file = "cytoscape.csv")



design <- rownames_to_column(design)
weight = as.data.frame(design[interest_Trait+1]);
#names(weight) = "weight";

modNames = substring(names(MEs), 3)

geneModuleMembership = as.data.frame(cor(dataExpr, MEs, use = "p"));
MMPvalue = as.data.frame(corPvalueStudent(as.matrix(geneModuleMembership), nSamples));
names(geneModuleMembership) = paste("MM", modNames, sep="");
names(MMPvalue) = paste("p.MM", modNames, sep="");

geneTraitSignificance = as.data.frame(cor(dataExpr, weight, use = "p"));
GSPvalue = as.data.frame(corPvalueStudent(as.matrix(geneTraitSignificance), nSamples));
names(geneTraitSignificance) = paste("GS.", names(weight), sep="");
names(GSPvalue) = paste("p.GS.", names(weight), sep="");



#selectModule <- modNames  
#pdf("gene-Module-trait-significance.pdf",width=7, height=1.5*ncol(MEs))
#par(mfrow=c(ceiling(length(selectModule)/2),2)) 
#for(module in selectModule){
#  column <- match(module,selectModule)
#  print(module)
#  moduleGenes <- moduleColors==module
#  verboseScatterplot(abs(geneModuleMembership[moduleGenes, column]),
#                     abs(geneTraitSignificance[moduleGenes, 1]),
#                     xlab = paste("Module Membership in", module, "module"),
#                     ylab = "Gene significance for trait",
#                     main = paste("Module membership vs. gene significance\n"),
#                     cex.main = 1.2, cex.lab = 1.2, cex.axis = 1.2, col = module)
#}
#dev.off()


#module = "brown"
#column = match(module, modNames);
#moduleGenes = moduleColors==module;
#
#green_module<-as.data.frame(dimnames(data.frame(dataExpr))[[2]][moduleGenes])
#names(green_module)="genename"
#MM<-abs(geneModuleMembership[moduleGenes,column])
#GS<-abs(geneTraitSignificance[moduleGenes, 1])
#c<-as.data.frame(cbind(MM,GS)) 
#rownames(c)=green_module$genename
#green_hub <-abs(c$MM)>0.8&abs(c$GS)>0.2 
#write.csv(green_hub, "hubgene_MMGS_green.csv")
#
#sizeGrWindow(7, 7);
#par(mfrow = c(1,1));
#verboseScatterplot(abs(geneModuleMembership[moduleGenes, column]),
#                   abs(geneTraitSignificance[moduleGenes, 1]),
#                   xlab = paste("Module Membership in", module, "module"),
#                   ylab = "Gene significance for body weight",
#                   main = paste("Module membership vs. gene significance\n"),
#                   cex.main = 1.2, cex.lab = 1.2, cex.axis = 1.2, col = module)
#				   


#names(dataExpr)
#names(dataExpr)[moduleColors=="brown"]
##annot = read.csv(file = "GeneAnnotation.csv");
##dim(annot)
##names(annot)
#probes = names(dataExpr) 
###probes2annot = match(probes, annot$substanceBXH);
##sum(is.na(probes2annot)) 

geneInfo0 = data.frame(#geneSymbol = probes,                       
                       #moduleColor = moduleColors,
                       geneTraitSignificance,
                       GSPvalue);

modOrder = order(-abs(cor(MEs, weight, use = "p")));

for (mod in 1:ncol(geneModuleMembership))
{
  oldNames = names(geneInfo0)
  geneInfo0 = data.frame(geneInfo0, geneModuleMembership[, modOrder[mod]],
                         MMPvalue[, modOrder[mod]]);
  names(geneInfo0) = c(oldNames, paste("MM.", modNames[modOrder[mod]], sep=""),
                       paste("p.MM.", modNames[modOrder[mod]], sep=""))
}
#geneOrder = order( -abs(geneInfo0[,1]));  
#geneInfo = geneInfo0[geneOrder, ]

write.csv(geneInfo0, file = paste(outputFileName3,".csv", sep=""))

#merge_modules = mergeCloseModules(dataExpr, moduleColors, cutHeight = 0.1, verbose = 3)
#mergedColors = merge_modules$colors
#connectivity=abs(cor(dataExpr,use="p"))^power
#Alldegrees=intramodularConnectivity(connectivity, mergedColors) 
#datKME=signedKME(dataExpr, MEs, outputColumnName="KME_MM.")
#GS=cor(dataExpr,design,use="p") 
#combin_data=cbind(Alldegrees,datKME,GS)
#write.csv(combin_data,"combine_hub.csv")
