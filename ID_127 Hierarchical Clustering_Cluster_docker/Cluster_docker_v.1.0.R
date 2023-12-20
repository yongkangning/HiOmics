
 args = commandArgs(trailingOnly=TRUE)
argsCount = 7

if (length(args)!=argsCount) {
  stop("cluster_docker.R libPath inputFile dist_method cluster_method cluster_type showlabels outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]
dist_method <- args[3]
if (is.na(dist_method)) {
  dist_method <- "euclidean"
}
cluster_method <- args[4]
if (is.na(cluster_method)) {
  cluster_method <- "ward.D2"
}
cluster_type <- args[5]
if (is.na(cluster_type)) {
  cluster_type <- "rectangle"
}
showlabels <- args[6]
if (is.na(showlabels)) {
  showlabels <- "T"
}

outputFileName <- args[7]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}
  library("cluster")
  library("NbClust")
  library("ggplot2")
  library("RColorBrewer")
  library("tidyverse")
  library("factoextra")
  
#data = read.csv("Expression.csv",header=T,stringsAsFactors = FALSE,row.names=1,check.names = FALSE)
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
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
    
}
data = read_data(file = filename1,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename1, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename1,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  data = read_data(file = filename1,has_header = T)
  data =as.data.frame(data)
  row.names(data)=data[,1]
  data = data[,-1]
  
  }
  
set.seed(100) 
data=scale(data)
nb_clust <- NbClust(data,distance = "euclidean",
                    min.nc=2, max.nc=30, method = "kmeans"
                    )
#barplot(table(nb_clust$Best.nc[1,]),xlab="Number of Clusters",ylab="Number of Criteria")
max=which.max(table(nb_clust$Best.nc[1,]))
inmax = max[[1]]

#Hierarchy analysis
result <- dist(data, method = dist_method)
result_hc <- hclust(d = result, method = cluster_method)
#pdf("Cluster.Sample.relevance.pdf",width = 6,height = 6)
svg(filename =paste(outputFileName,"cluster.svg",sep="_"),width = 6,height = 6)
p3 <- fviz_dend(result_hc, k = inmax,type = cluster_type,show_labels = showlabels, cex = 0.5 )
base::print(p3)
dev.off()
