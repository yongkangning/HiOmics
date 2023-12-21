

args = commandArgs(trailingOnly=TRUE)
argsCount = 7

if (length(args)!=argsCount) {
  stop("eQTL_dockerdanbaizhu_v1.1.R libPath inputFile1 inputFile2 inputFile3 usemodel pvOutputThreshold outputFileName")
}
.libPaths(args[1])
 
inputFile1 <- args[2]
inputFile2 <- args[3]
inputFile3 <- args[4]
usemodel <- args[5]
if (is.na(usemodel)) {
  usemodel <- "modelLINEAR"
}

pvOutputThreshold <- as.numeric(args[6])
if (is.na(pvOutputThreshold)) {
  pvOutputThreshold <- "0.01"
}

outputFileName <- args[7]
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


#pvOutputThreshold = 1e-2 
#errorCovariance = numeric() 

 
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
  
   me_data <- me$all$eqtls
  colnames(me_data)[2] <- "protin"  
write.table(me_data,file = paste(outputFileName,"protin.txt",sep="_"),sep = "\t",quote=F,row.names = F)  
   
 
#show(me$all$eqtls)  


p=myplot({plot(me)})
plotsave(p,file=paste(outputFileName,"svg",sep="."),unit="cm",dpi=600)
















