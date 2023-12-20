

args = commandArgs(trailingOnly=TRUE)
argsCount = 3

if (length(args)!=argsCount) {
  stop("CheckGene_docker_v.1.0.R libPath inputFile outputFileName")
}

.libPaths(args[1])
inputFile <- args[2]
outputFileName <- args[3]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}
library(tidyverse)
CheckGene=function(querylist){
 
library(HGNChelper) 

  query<-querylist$V1 
  
 
data("hgnc.table", package="HGNChelper")
head(hgnc.table) 
res<-checkGeneSymbols(query, map=hgnc.table)

#write.table(res,file="result.xls",row.names = F,quote = T,sep="\t")
write.csv(res,file=paste(outputFileName,"csv",sep="."),row.names = F)
}


usage<-function(){
  cat('USAGE:\n\tCheckGene.R -querylist=<querylist>  \n',file=stderr())
  cat('PARAMETERS:\n',file=stderr())
  cat('\t-querylist\tthe query genes list ,input txt format.\n',file=stderr())
  
}  


parse.arg<-function(args){
  #set arguments to default values
  
  for (each.arg in args){
    if(grepl("^-querylist=",each.arg)){
      arg.split = unlist(strsplit(each.arg,split="="))
      if (!is.na(arg.split[2])){
        querylist = arg.split[2]
      }
    }
   
      } 
  return(list(querylist = querylist))
}

filename1 = inputFile


file_suffix <- strsplit(filename1, "\\.")[[1]]
filetype <- file_suffix[length(file_suffix)]

encode <-
  guess_encoding(filename1, n_max = 1000)[1, 1, drop = TRUE]
# print(encode)
if(is.na(encode)) {
  stop(paste("[ERRO]", filename1,"encoding_nonsupport"))
}
if(filetype %in% c("csv","txt")){
  
  read_data <- function(filename1, has_header) {
    
    if (filetype == "csv") {
      df <-
        tryCatch(
          read.csv(filename1, header = has_header, fileEncoding = encode,sep=",",check.names=FALSE),
          warning = function(e) {
            read.csv(filename1, header = has_header, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
          }
        )
    }else if(filetype == "txt") {
      df <-
        tryCatch(
          read.table(filename1, header = has_header, fileEncoding = encode,sep="\t",check.names=FALSE),
          warning = function(e) {
            read.table(filename1, header = has_header,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
          }
        )
    }  else {
      stop("[ERRO] txt csv")
    }
    return(df)
    
  }
}

x = read_data(file = filename1,has_header = F)

CheckGene(x)
#print("Program execution is completed")
