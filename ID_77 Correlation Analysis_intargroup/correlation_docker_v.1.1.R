args = commandArgs(trailingOnly=TRUE)
argsCount = 10

if (length(args)!=argsCount) {
  stop("correlation_docker_v.1.1.R libPath inputFile cor_method is_pvalue is_insig visual_method is_type tl_pos is_order outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]

cor_method <- args[3]
if (is.na(cor_method)) {
  cor_method <- "pearson"
}

is_pvalue <- args[4]
if (is.na(is_pvalue)) {
  is_pvalue <- "no"
}

is_insig <- args[5]
if (is.na(is_insig)) {
  is_insig <- "p-value"
}
visual_method <- args[6]
if (is.na(visual_method)) {
  visual_method <- "circle"
}

is_type <- args[7]
if (is.na(is_type)) {
  is_type <- "lower"
}
tl_pos <- args[8]
if (is.na(tl_pos)) {
  tl_pos <- "lt"
}
is_order <- args[9]
if (is.na(is_order)) {
  is_order <- "original"
}


outputFileName <- args[10]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}


library(myplot)
library(ggcorrplot)
library(corrplot)
library(tidyverse)

#data=t(read.table(inputFile,header=T,sep="\t",row.names=1,check.names=F))
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
data = read_data(file = filename1,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename1, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename1,col_names=has_header)
	
  } else {
  stop("[ERRO] xls xlsx")}
  }

  
  data = read_data(file = filename1,has_header = T)
  data =as.data.frame(data)
  row.names(data)=data[,1]
  data = data[,-1]
 
  }
cordata=cor(data,y=NULL,use="everything",method = cor_method)
p.mat=cor_pmat(data)


yes_pvalue <- c("yes")
no_pvalue <- c("no")


  if(is_pvalue %in% no_pvalue){
p=myplot({corrplot(cordata,method =visual_method,# method = c("circle", "square", "ellipse", "number", "shade", "color", "pie"), 
          
         type=is_type,#type=c("full", "lower", "upper"), 
         
		  bg="white",
         #add=T,
       #  p.mat = p.mat,
        # insig = is_insig,
        # sig.level =  c(0.001, 0.01, 0.05),
		 #tl.srt=0,
		 pch.cex = 1,
		 col =  cm.colors(100),
		 tl.col = "black",
		 tl.pos = tl_pos,
		 order=is_order,
         # title = is_title,
		 addCoef.col = )
		 })
		 
		 }else if(is_pvalue %in% yes_pvalue){
		 p=myplot({corrplot(cordata,method =visual_method,# method = c("circle", "square", "ellipse", "number", "shade", "color", "pie"), 
         
         type=is_type,#type=c("full", "lower", "upper"), 
         
		  bg="white",
         #add=T,
		 pch.cex = 1,
		 col =  cm.colors(100),
         p.mat = p.mat,
          insig = is_insig,
         sig.level = c(0.001, 0.01, 0.05),
		# tl.srt=0,
		 tl.col = "black",
		 tl.pos = tl_pos,
		 order=is_order,
         # title = is_title,
		 addCoef.col = )
		 })
		 }
		 
plotsave(p,file=paste(outputFileName,"svg",sep="."),unit="cm",width=17,height=15,dpi=600)
  
  
  