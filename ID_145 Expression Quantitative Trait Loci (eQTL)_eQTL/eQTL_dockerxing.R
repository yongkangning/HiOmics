

args = commandArgs(trailingOnly=TRUE)
argsCount = 12

if (length(args)!=argsCount) {
  stop("eQTL_dockerxing.R libPath inputFile1 inputFile2 inputFile3 usemodel input_snpspos_genepos inputFile4 inputFile5 pvOutputThreshold tra_pvOutputThreshold cis_pvOutputThreshold outputFileName")
}
.libPaths(args[1])
 
inputFile1 <- args[2]
inputFile2 <- args[3]
inputFile3 <- args[4]
usemodel <- args[5]
if (is.na(usemodel)) {
  usemodel <- "modelLINEAR"
}

input_snpspos_genepos <- args[6]
if (is.na(input_snpspos_genepos)) {
  input_snpspos_genepos <- "no"
}

inputFile4 <- args[7]
inputFile5 <- args[8]

pvOutputThreshold <- as.numeric(args[9])
if (is.na(pvOutputThreshold)) {
  pvOutputThreshold <- "0.01"
}
tra_pvOutputThreshold <- as.numeric(args[10])
if (is.na(tra_pvOutputThreshold)) {
  tra_pvOutputThreshold <- "0.01"
}
cis_pvOutputThreshold <- as.numeric(args[11])
if (is.na(cis_pvOutputThreshold)) {
  cis_pvOutputThreshold <- "0.02"
}

outputFileName <- args[12]
if (is.na(outputFileName)) {
  outputFileName <- "reult"
}

library(myplot)
library("MatrixEQTL")


SNP_file_name1=inputFile1

snps1 = SlicedData$new() 
snps1$fileDelimiter = "\t"       
snps1$fileOmitCharacters = "NA" 
snps1$fileSkipRows = 1        
snps1$fileSkipColumns = 1     
snps1$fileSliceSize = 2000      
snps1$LoadFile( SNP_file_name1 ) 


expression_file_name1=inputFile2

gene1 = SlicedData$new()
gene1$fileDelimiter = "\t" 
gene1$fileOmitCharacters = "NA"
gene1$fileSkipRows = 1
gene1$fileSkipColumns = 1
gene1$fileSliceSize = 2000
gene1$LoadFile(expression_file_name1)



covariates_file_name1=inputFile3
cvrt = SlicedData$new()
cvrt$fileDelimiter = "\t"
cvrt$fileOmitCharacters = "NA"
cvrt$fileSkipRows = 1
cvrt$fileSkipColumns = 1
cvrt$fileSliceSize = 2000
cvrt$LoadFile( covariates_file_name1 )




yes_snpspos_genepos <- c("yes") 
no_snpspos_genepos <- c("no") 



  if(input_snpspos_genepos %in% yes_snpspos_genepos){
  
  snps_location_file_name = inputFile4
  gene_location_file_name = inputFile5
  snpspos = read.table(snps_location_file_name, header = TRUE, stringsAsFactors = FALSE);
  genepos = read.table(gene_location_file_name, header = TRUE, stringsAsFactors = FALSE);
  
output_file_name_tra = "trans-eqtl" 
output_file_name_cis = "cis-eqtl"

  if(usemodel %in% c("modelLINEAR")){
  useModel = modelLINEAR
me = Matrix_eQTL_main(
  snps = snps1, 
  gene = gene1, 
  cvrt = cvrt,
  output_file_name     = output_file_name_tra,
  pvOutputThreshold     = tra_pvOutputThreshold,
  useModel = useModel, 
  #errorCovariance = errorCovariance, 
  verbose = TRUE, 
  output_file_name.cis = output_file_name_cis,
  pvOutputThreshold.cis = cis_pvOutputThreshold,
  snpspos = snpspos, 
  genepos = genepos,
  cisDist = 1e6,
  pvalue.hist = "qqplot",
  min.pv.by.genesnp = FALSE,
  noFDRsaveMemory = FALSE)
  
  }else if(usemodel %in% c("modelANOVA")){  
  useModel = modelANOVA
me = Matrix_eQTL_main(
  snps = snps1, 
  gene = gene1, 
  cvrt = cvrt,
  output_file_name     = output_file_name_tra,
  pvOutputThreshold     = tra_pvOutputThreshold,
  useModel = useModel, 
  #errorCovariance = errorCovariance, 
  verbose = TRUE, 
  output_file_name.cis = output_file_name_cis,
  pvOutputThreshold.cis = cis_pvOutputThreshold,
  snpspos = snpspos, 
  genepos = genepos,
  cisDist = 1e6,
  pvalue.hist = "qqplot",
  min.pv.by.genesnp = FALSE,
  noFDRsaveMemory = FALSE)
  
  }else if(usemodel %in% c("modelLINEAR_CROSS")){  
  useModel = modelLINEAR_CROSS
me = Matrix_eQTL_main(
  snps = snps1, 
  gene = gene1, 
  cvrt = cvrt,
  output_file_name     = output_file_name_tra,
  pvOutputThreshold     = tra_pvOutputThreshold,
  useModel = useModel, 
  #errorCovariance = errorCovariance, 
  verbose = TRUE, 
  output_file_name.cis = output_file_name_cis,
  pvOutputThreshold.cis = cis_pvOutputThreshold,
  snpspos = snpspos, 
  genepos = genepos,
  cisDist = 1e6,
  pvalue.hist = "qqplot",
  min.pv.by.genesnp = FALSE,
  noFDRsaveMemory = FALSE)
  }
  
  write.table(me$trans$eqtls,file = paste(outputFileName,"trans_eqtl.txt",sep="_"),sep = "\t",quote=F,row.names = F)
  write.table(me$cis$eqtls,file = paste(outputFileName,"cis_eqtl_.txt",sep="_"),sep = "\t",quote=F,row.names = F)
  
  
 }else if(input_snpspos_genepos %in% no_snpspos_genepos){
 
 if(usemodel %in% c("modelLINEAR")){
   useModel = modelLINEAR
output_file_name = "cis"
me = Matrix_eQTL_engine(  
  snps = snps1,  
  gene = gene1,  
  cvrt = cvrt,   
  output_file_name = output_file_name,  
  pvOutputThreshold = pvOutputThreshold,  
  useModel = useModel,  
  #errorCovariance = errorCovariance, 
  verbose = TRUE,
  pvalue.hist = TRUE,
  min.pv.by.genesnp = FALSE,
  noFDRsaveMemory = FALSE)
  
  }else if(usemodel %in% c("modelANOVA")){  
     useModel = modelANOVA
output_file_name = "cis"
me = Matrix_eQTL_engine(  
  snps = snps1,  
  gene = gene1,  
  cvrt = cvrt,   
  output_file_name = output_file_name,  
  pvOutputThreshold = pvOutputThreshold,  
  useModel = useModel,  
  #errorCovariance = errorCovariance, 
  verbose = TRUE,
  pvalue.hist = TRUE,
  min.pv.by.genesnp = FALSE,
  noFDRsaveMemory = FALSE)
  
  }else if(usemodel %in% c("modelLINEAR_CROSS")){  
     useModel = modelLINEAR_CROSS
output_file_name = "cis"
me = Matrix_eQTL_engine(  
  snps = snps1,  
  gene = gene1,  
  cvrt = cvrt,   
  output_file_name = output_file_name,  
  pvOutputThreshold = pvOutputThreshold,  
  useModel = useModel,  
  #errorCovariance = errorCovariance, 
  verbose = TRUE,
  pvalue.hist = TRUE,
  min.pv.by.genesnp = FALSE,
  noFDRsaveMemory = FALSE)
 }  
  
write.table(me$all$eqtls,file = paste(outputFileName,"eqtl.txt",sep="_"),sep = "\t",quote=F,row.names = F)  
  
 }
  
 
#show(me$all$eqtls)  


p=myplot({plot(me)})
plotsave(p,file=paste(outputFileName,"svg",sep="."),unit="cm",dpi=600)
















