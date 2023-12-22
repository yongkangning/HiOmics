



args = commandArgs(trailingOnly=TRUE)
argsCount = 10

if (length(args)!=argsCount) {
  stop("Integration_docker_v2.0.R libPath inputFile2 inputFile3 inputFile6 in_colname category plot outcomeAnalyteOf_Interest independentAnalyteOf_Interest outputFileName")
}

.libPaths(args[1])
inputFile2 <- args[2]
inputFile3 <- args[3]
inputFile6 <- args[4]

in_colname <- args[5]
if (is.na(in_colname)) {
  in_colname <- "PBO_vs_Leukemia"
}
category <- args[6]
if (is.na(category)) {
  category <- "discrete_variable"
}

plot <- args[7]##
if (is.na(plot)) {
  plot <- "yes"
}
outcomeAnalyteOf_Interest <- args[8]
if (is.na(outcomeAnalyteOf_Interest)) {
  outcomeAnalyteOf_Interest <- "5-oxoproline"
}
independentAnalyteOf_Interest <- args[9]
if (is.na(independentAnalyteOf_Interest)) {
  independentAnalyteOf_Interest <- "ZRSR2"
}


outputFileName <- args[10]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}

library(IntLIM)
library(htmltools)
library(tidyverse)
#csvfile <- file.path(inputFile6)
#setwd(csvfile)
getwd()


#input1=read.csv(inputFile1, header = T,row.names=1, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)

#input2=read.csv(inputFile2, header = T,row.names=1, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)

#input3=read.csv(inputFile3, header = T, row.names=1,fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)

#input4=read.csv(inputFile4, header = T, row.names=1,fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)

#input5=read.csv(inputFile5, header = T, row.names=1,fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)

#input6=read.csv(inputFile6, header = T, row.names=1,fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)

filename2 = inputFile2
 
  file_suffix <- strsplit(filename2, "\\.")[[1]]
  filetype <- file_suffix[length(file_suffix)]
  
  encode <-
    guess_encoding(filename2, n_max = 1000)[1, 1, drop = TRUE]
  # print(encode)
  if(is.na(encode)) {
    stop(paste("[ERRO]", filename2,"encoding_nonsupport"))
  }
  if(filetype %in% c("csv","txt")){
  
read_data <- function(filename2, has_header,has_rownames) {
 
    if (filetype == "csv") {
    df <-
      tryCatch(
        read.csv(filename2, header = has_header, row.names =has_rownames, fileEncoding = encode,sep=",",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.csv(filename2, header = has_header, row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename2, header = has_header, row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.table(filename2, header = has_header, row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  }  else {
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
    
}
input2 = read_data(file = filename2,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename2, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename2,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  input2 = read_data(file = filename2,has_header = T)
  input2 =as.data.frame(input2)
  
  }

filename3 = inputFile3
 
  file_suffix <- strsplit(filename3, "\\.")[[1]]
  filetype <- file_suffix[length(file_suffix)]
  
  encode <-
    guess_encoding(filename3, n_max = 1000)[1, 1, drop = TRUE]
  # print(encode)
  if(is.na(encode)) {
    stop(paste("[ERRO]", filename3,"encoding_nonsupport"))
  }
  if(filetype %in% c("csv","txt")){
  
read_data <- function(filename3, has_header,has_rownames) {
 
    if (filetype == "csv") {
    df <-
      tryCatch(
        read.csv(filename3, header = has_header, row.names =has_rownames, fileEncoding = encode,sep=",",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.csv(filename3, header = has_header, row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename3, header = has_header, row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.table(filename3, header = has_header, row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  }  else {
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
    
}
input3 = read_data(file = filename3,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename3, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename3,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  input3 = read_data(file = filename3,has_header = T)
  input3 =as.data.frame(input3)
  
  }

filename6 = inputFile6
 
  file_suffix <- strsplit(filename6, "\\.")[[1]]
  filetype <- file_suffix[length(file_suffix)]
  
  encode <-
    guess_encoding(filename6, n_max = 1000)[1, 1, drop = TRUE]
  # print(encode)
  if(is.na(encode)) {
    stop(paste("[ERRO]", filename6,"encoding_nonsupport"))
  }
  if(filetype %in% c("csv","txt")){
  
read_data <- function(filename6, has_header) {
 
    if (filetype == "csv") {
    df <-
      tryCatch(
        read.csv(filename6, header = has_header,fileEncoding = encode,sep=",",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.csv(filename6, header = has_header, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename6, header = has_header, fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.table(filename6, header = has_header,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  }  else {
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
    
}
input6 = read_data(file = filename6,has_header = T)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename6, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename6,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  input6 = read_data(file = filename6,has_header = T)
  input6 =as.data.frame(input6)
  
  }

#csvfile <- file.path(input6)

#input="input2.csv"

is_numeric <- c("numeric")#
is_discrete_variable <- c("discrete_variable")




if(category %in% is_discrete_variable){
list_name <- in_colname
list_class <- list("factor")
names(list_class) <- list_name 

inputData <- IntLIM::ReadData(inputFile = "/henbio/henbio_web/public/demo_data/RNAm6ayuRNA/IntLIM_input1.csv",analyteType1id ='id',analyteType2id ='id', class.feat = list_class)



inputDatafilt <- IntLIM::FilterData(inputData,analyteType1perc =0.10, analyteType2perc  = 0.1,analyteMiss = 0.80)
IntLIM::ShowStats(inputDatafilt)


save_html(IntLIM::PlotDistributions(inputDatafilt, palette = c('red', 'blue')), 
          file=paste(outputFileName,"Distributions.html",sep="_"), background = "white",libdir = paste(outputFileName,"lib",sep="_"))

save_html(IntLIM::PlotPCA(inputData = inputDatafilt,stype = in_colname), 
          file=paste(outputFileName,"PCA.html",sep="_"), background = "white",libdir = paste(outputFileName,"lib",sep="_"))


myres <- IntLIM::RunIntLim(inputData = inputDatafilt,
                                stype =in_colname,
								continuous = F,
								outcome = 1,
                                independent.var.type = 2,
                                save.covar.pvals = TRUE)
								

if(plot %in% c("yes")){				
save_html(IntLIM::PlotPair(inputData = inputDatafilt,
                 inputResults = myres,
                 outcome = 1,
                 independentVariable = 2,
                 outcomeAnalyteOfInterest = outcomeAnalyteOf_Interest ,
                 independentAnalyteOfInterest = independentAnalyteOf_Interest),	
				 file=paste(outputFileName,"Analyte_Of_Interest.html",sep="_"), background = "white",libdir = paste(outputFileName,"lib",sep="_")
)				 
}else if(plot %in% c("no")){	
print("1")
} 			   
					   
}else if(category %in% is_numeric){

list_name <- in_colname
list_class <- list("numeric")
names(list_class) <- list_name 

inputData <- IntLIM::ReadData(inputFile = "/henbio/henbio_web/public/demo_data/RNAm6ayuRNA/IntLIM_input1.csv",analyteType1id ='id',analyteType2id ='id',
                   class.feat = list_class)



inputDatafilt <- IntLIM::FilterData(inputData,analyteType1perc =0.10, analyteType2perc  = 0.1,analyteMiss = 0.80)
IntLIM::ShowStats(inputDatafilt)


save_html(IntLIM::PlotDistributions(inputDatafilt, palette = c('red', 'blue')), 
          file=paste(outputFileName,"Distributions.html",sep="_"), background = "white",libdir = paste(outputFileName,"lib",sep="_"))

save_html(IntLIM::PlotPCA(inputData = inputDatafilt,stype = in_colname), 
          file=paste(outputFileName,"PCA.html",sep="_"), background = "white",libdir = paste(outputFileName,"lib",sep="_"))

#
myres <- IntLIM::RunIntLim(inputData = inputDatafilt,
                               stype =in_colname, 
							   continuous = T,
							   outcome = 1,
                               independent.var.type = 2,
                               save.covar.pvals = TRUE)
#
if(plot %in% c("yes")){
pdf(paste(outputFileName,"Analyte_Of_Interest.pdf",sep="_"),height=6, width=6)

IntLIM::PlotPair(inputData = inputDatafilt,
                 inputResults = myres,
                 outcome = 1,
                 independentVariable = 2,
                 outcomeAnalyteOfInterest = outcomeAnalyteOf_Interest ,
                 independentAnalyteOfInterest = independentAnalyteOf_Interest)
dev.off()			 

}else if(plot %in% c("no")){	
print("1")
}
}
#
pdf(paste(outputFileName,"DistPvalues.pdf",sep="_"),height=6, width=6)
IntLIM::DistPvalues(IntLimResults = myres, adjusted = FALSE)
#hist(myres@interaction.pvalues, breaks = 100, 
#     main = "Histogram of Interaction P-values",xlab="pvalues")
dev.off()

pdf(paste(outputFileName,"pvalCoefVolcano.pdf",sep="_"),height=6, width=6)
IntLIM::pvalCoefVolcano(inputResults = myres, inputData = inputDatafilt,
                        pvalcutoff = 0.05)						
dev.off()						


myres1 <- IntLIM::ProcessResults(inputResults = myres, 
                                 inputData = inputDatafilt,
                                 #coeffPercentile = 0.8,
								 pvalcutoff = 0.05)


write.csv(myres1,file=paste(outputFileName,"corResults.csv",sep="_"),row.names = F)

