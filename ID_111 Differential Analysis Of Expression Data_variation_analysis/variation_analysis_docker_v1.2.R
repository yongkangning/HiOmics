
args = commandArgs(trailingOnly=TRUE)
argsCount = 5

if (length(args)!=argsCount) {
  stop("variation_analysis_docker_v1.2.R libPaths inputFile num_tumor num_normal outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]


num_tumor <- as.numeric(args[3])
if (is.na(num_tumor)) {
  num_tumor <- 3
}
num_normal <- as.numeric(args[4])
if (is.na(num_normal)) {
  num_normal <- 3
}
outputFileName <- args[5]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}

library(tidyverse)
filename = inputFile
read_data <- function(filename, has_header,has_rownames) {
  
  file_suffix <- strsplit(filename, "\\.")[[1]]
  filetype <- file_suffix[length(file_suffix)]
  
  encode <-
    guess_encoding(filename, n_max = 1000)[1, 1, drop = TRUE]
  # print(encode)
  if(is.na(encode)) {
    stop(paste("[ERRO]", filename,""))
  }
  
  if (filetype == "csv") {
    df <-
      tryCatch(
        read.csv(filename, header = has_header, row.names =has_rownames,fileEncoding = encode),
        warning = function(e) {
          read.csv(filename, header = has_header,row.names =has_rownames, fileEncoding = "UTF-8-BOM")
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename, header = has_header,row.names =has_rownames, fileEncoding = encode),
        warning = function(e) {
          read.table(filename, header = has_header, row.names =has_rownames,fileEncoding = "UTF-8-BOM")
        }
      )
  } else if (filetype %in% c("xls", "xlsx")) {
    df <- readxl::read_excel(filename)
  } else {
    stop("[ERRO] ")
  }
  return(df)
}

rt = read_data(file = filename,has_header = T,has_rownames=1)
library("edgeR")
library('gplots')

#rt<-read.csv(inputFile,sep=",",row.names=1) 
rt=as.matrix(rt)
#rownames(rt)=rt[,1]
exp=rt[,1:ncol(rt)]

dimnames=list(rownames(exp),colnames(exp))
data=matrix(as.numeric(as.matrix(exp)),nrow=nrow(exp),dimnames=dimnames)
data=avereps(data)




group=c(rep("tumor",num_tumor),rep("normal",num_normal))                          
design <- model.matrix(~group)
y <- DGEList(counts=data,group=group)
y <- calcNormFactors(y)
y <- estimateCommonDisp(y)
y <- estimateTagwiseDisp(y)
et <- exactTest(y,pair = c("normal","tumor"))
topTags(et)
ordered_tags <- topTags(et, n=100000)




allDiff=ordered_tags$table
allDiff=allDiff[is.na(allDiff$FDR)==FALSE,]
diff=allDiff
diff=cbind(gene_id=row.names(diff),diff)
newData=y$pseudo.counts




write.table(diff,file=paste(outputFileName,"edgerOut.xls",sep="_"),sep="\t",quote=F,row.names = F)
#diffSig = diff[(diff$FDR < 0.05 & (diff$logFC>1 | diff$logFC<(-1))),]
#write.table(diffSig, file=paste(outputFileName,"diffSig.xls",sep="_"),sep="\t",quote=F,row.names = F)
#diffUp = diff[(diff$FDR < 0.05 & (diff$logFC>1)),]
#write.table(diffUp, file=paste(outputFileName,"up.xls",sep="_"),sep="\t",quote=F,row.names = F)
#diffDown = diff[(diff$FDR < 0.05 & (diff$logFC<(-1))),]
#write.table(diffDown, file=paste(outputFileName,"down.xls",sep="_"),sep="\t",quote=F,row.names = F)
