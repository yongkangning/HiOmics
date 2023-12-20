

args = commandArgs(trailingOnly=TRUE)
argsCount = 7

if (length(args)!=argsCount) {
  stop("gongbiaodawangluotu_docker.R libPath inputFile is_method is_cor is_pvalue is_label outputFileName")
}

 .libPaths(args[1])
inputFile <- args[2]

is_method <- args[3]
if (is.na(is_method)) {
  is_method <- "spearman"
}
is_cor <- as.numeric(args[4])
if (is.na(is_cor)) {
  is_cor <- "0.6"
}
is_pvalue <- as.numeric(args[5])
if (is.na(is_pvalue)) {
  is_pvalue <- "0.001"
}
is_label <- args[6]
if (is.na(is_label)) {
  is_label <- "no"
}

outputFileName <- args[7]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}


library(igraph)
library(WGCNA)
library(impute)
library(tidyverse)
library(myplot)


#otu <- read.csv("input.csv")
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
    stop("[ERRO] txt csv")
  }
  return(df)
    
}
otu = read_data(file = filename1,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename1, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename1,col_names=has_header)
	
  } else {
  stop("[ERRO] xls xlsx")}
  }

  
  otu = read_data(file = filename1,has_header = T)
  otu =as.data.frame(otu)
  row.names(otu)=otu[,1]
  otu = otu[,-1]
 
  }


CorrDF <- function(cormat, pmat) {
  ut <- upper.tri(cormat) 
  data.frame(
    from = rownames(cormat)[col(cormat)[ut]],
    to = rownames(cormat)[row(cormat)[ut]],
    cor = (cormat)[ut],
    p = pmat[ut]
  )
}


#rownames(otu) = otu[,1]


#otu = otu[,-1]


occor <- corAndPvalue(t(otu), use='pairwise', method=is_method) 
cor_df <- CorrDF(occor$cor , occor$p) 
cor_df <- cor_df[which(abs(cor_df$cor) >= is_cor),] 
cor_df <- cor_df[which(cor_df$p < is_pvalue),] 



igraph <- graph_from_data_frame(cor_df, directed=F) 
#length(V(igraph)) 
#> [1] 852
#length(E(igraph)) 



V(igraph)$size <- degree(igraph)*0.8 

cols <- c('#00A6FB', '#0582CA', '#fff0f3', '#006494', '#c9e4ca', '#31572c', '#90a955', '#ecf39e', '#a4133c', '#c9184a', '#ff4d6d')
V(igraph)$color <- sample(cols, length(V(igraph)), replace = T) 
E(igraph)$color[E(igraph)$cor >= 0.6] <- "darkgray" 
E(igraph)$color[E(igraph)$cor <= -0.6] <- "red" 
E(igraph)$width <- abs(E(igraph)$cor)*0.5 



coords <- layout_with_fr(igraph, niter=9999,grid="nogrid") 
#pdf("Figure.pdf", height = 10, width = 10) 
yes_label <- c("yes")
no_label <- c("no")
if(is_label %in% yes_label){

p=myplot({plot(igraph, layout=coords, vertex.label = V(igraph)$name , vertex.label.dist=0.4,vertex.frame.color="black")})
}else if(is_label %in% no_label){

p=myplot({plot(igraph, layout=coords, vertex.label = NA, vertex.label.dist=0.4,vertex.frame.color="black")}) 
}

#dev.off()

plotsave(p,file=paste(outputFileName,"svg",sep="."),unit="cm",width=15,height=15,dpi=600)