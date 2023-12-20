
args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("tonglujiyinbiaodatiqu.R libPath inputFile1 inputFile2 outputFileName")
}
.libPaths(args[1])
inputFile1 <- args[2]
inputFile2 <- args[3]

outputFileName <- args[4]
if (is.na(outputFileName)) {
  outputFileName <- "expresssion_select"
}

data_expression=read.table(inputFile1,sep="\t",check.names=F,header=T,row.names=1)
#head(data_expression)
data_gene=read.table(inputFile2,sep="\t",check.names=F)
#head(data_gene)
data_expression_gene=toupper(data_expression[,1])
data_expression = data_expression[,-1]
data_expression_gene_toupper=cbind(gene_name=data_expression_gene,data_expression)

data_gene=data_gene$V1
data_gene=toupper(data_gene)

data_expression_select=subset(data_expression_gene_toupper,data_expression_gene_toupper[,1] %in% data_gene)
data_expression_select=cbind(gene_id=row.names(data_expression_select),data_expression_select)
#head(data_expression_select)
write.table(data_expression_select,file = paste(outputFileName,"txt",sep="."),sep = "\t",row.names = F,quote=F)

