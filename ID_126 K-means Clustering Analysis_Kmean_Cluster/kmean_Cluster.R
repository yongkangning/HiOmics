

 args = commandArgs(trailingOnly=TRUE)
argsCount = 5

if (length(args)!=argsCount) {
  stop("cluster_docker.R libPath inputFile dist_method cluster_method outputFileName")
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

outputFileName <- args[5]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}

library("cluster")
  library("factoextra")
  library("NbClust")
  library("ggplot2")
  library("RColorBrewer")
  library("tidyverse")
 # RNAseq.data = read.csv("Expression.csv",header=T,stringsAsFactors = FALSE,row.names=1,check.names = FALSE)
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
nb_clust <- NbClust(data,distance = dist_method,
                    min.nc=2, max.nc=30, method = cluster_method
                    )
					
svg(filename =paste(outputFileName,"number_cluster.svg",sep="_"),width = 6,height = 6)					
barplot(table(nb_clust$Best.nc[1,]),xlab="Number of Clusters",ylab="Number of Criteria")
dev.off()

max=which.max(table(nb_clust$Best.nc[1,]))
inmax = max[[1]]

#pdf("K-Cluster.pdf",width = 6,height = 6)
svg(filename =paste(outputFileName,"optimum_cluster.svg",sep="_"),width = 6,height = 6)
p1 <- fviz_nbclust(data, kmeans, method = "wss") + geom_vline(xintercept =inmax , linetype = 2)
print(p1)
dev.off()
#Clustering using k-mean
##nstart the number of repeated iterations of kmeans, Here, for computer hardware adaptation, the lower 25 is selected as the number of iterations.
km_fit = kmeans(data, inmax, nstart = 25) 
#cluester.Group <- base::data.frame(Cluster.Group=km_fit$cluster) 
#write.csv(cluester.Group,"cluester.Group.csv")
##km_fit
##PCA
#pdf("Cluster.PCA.pdf",width = 6,height = 6)
svg(filename =paste(outputFileName,"Cluster_PCA.svg",sep="_"),width = 6,height = 6)
p2 <- fviz_cluster(km_fit, data, palette = c("#f39b7f", "#00a087", "#3c5488", "#4dbbd5", "#e64b35", "#E64B35FF", "#4DBBD5FF", "#00A087FF","#F39B7FFF","#91D1C2FF", "#8491B4FF","#ffffff","#f0f0f0","#787878","#3c3c3c","#ffa500","#3cb371","#6a5acd", "#ff0000", "#0000ff", "#3cb371", "#ee82ee", "#6a5acd", "#ff6347", "#466347", "#46d947"),  geom = "point" ,ellipse.type = "convex", star.plot = TRUE, repel = TRUE, ggtheme = theme_grey() )
print(p2)
dev.off()


