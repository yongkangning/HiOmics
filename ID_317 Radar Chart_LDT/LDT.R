
args = commandArgs(trailingOnly=TRUE)
argsCount = 2

if (length(args)!=argsCount) {
  stop("LDT.R libPath inputFile")
}
.libPaths(args[1])
inputFile <- args[2]#





library(tidyverse)




library(ggradar)
library(dplyr)
library(scales)
library(tibble)
library(ggplot2)

#mtcars_radar <- read.csv(file.choose(),row.names = 1,header = T)
#mtcars_radar
filename = inputFile
 
  file_suffix <- strsplit(filename, "\\.")[[1]]
  filetype <- file_suffix[length(file_suffix)]
  
  encode <-
    guess_encoding(filename, n_max = 1000)[1, 1, drop = TRUE]
  # print(encode)
  if(is.na(encode)) {
    stop(paste("[ERRO]", filename,"encoding_nonsupport"))
  }
  if(filetype %in% c("csv","txt")){
  
read_data <- function(filename, has_header,has_rownames) {
 
    if (filetype == "csv") {
    df <-
      tryCatch(
        read.csv(filename, header = has_header, row.names =has_rownames, fileEncoding = encode,sep=",",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.csv(filename, header = has_header, row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename, header = has_header, row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.table(filename, header = has_header, row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  }  else {
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
    
}
mtcars_radar = read_data(file = filename,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  mtcars_radar = read_data(file = filename,has_header = T)
  mtcars_radar =as.data.frame(mtcars_radar)
  
  }


ggradar(mtcars_radar)


pdf(file = 'LDT.pdf', height = 8, width = 12)
ggradar(mtcars_radar)
dev.off()
#pdf("p.pdf", height = 8, width = 12)

#library(eoffice)


#dev.off()



#ggsave(plot = mtcars_radar,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=20,height=15,dpi=600)