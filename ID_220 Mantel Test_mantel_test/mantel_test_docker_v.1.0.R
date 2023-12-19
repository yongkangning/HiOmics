#devtools::install_local("C:/Users/syg/Documents/R/win-library/4.0/ggcor_master.zip")
#devtools::install_github("Hy4m/linkET", force = TRUE)
#devtools::install_github("zlabx/ggcor")
#devtools::install_github("Github-Yilei/ggcor")



args = commandArgs(trailingOnly=TRUE)
argsCount = 7

if (length(args)!=argsCount) {
  stop("mantel_test.R libPath inputFile1 inputFile2 inputFile3 cor_method is_mark outputFileName")
}
.libPaths(args[1])
inputFile1 <- args[2]
inputFile2 <- args[3]
inputFile3 <- args[4]

cor_method <- args[5] 
if (is.na(cor_method)) {
  cor_method <- "pearson"
}
is_mark <- args[6]
if (is.na(is_mark)) {
  is_mark <- "no"
}

outputFileName <- args[7]
if (is.na(outputFileName)) {
  outputFileName <- "bubble_plot_facet"
}

library(tidyverse)
library(RColorBrewer)
library(linkET)
library(ggforce)
library(vegan)
library(dplyr)
library(ggtext)

#setwd("F:\\zuotu\\mantel_test")
#data("varechem", package = "vegan")
#varechem[1:5,1:10]
#
#data("varespec", package = "vegan")
#varespec[1:5,1:10]
#write.csv(varespec,file="varespec.csv",row.names = F)
filename1 = inputFile1

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
        read.csv(filename1, header = has_header, row.names =has_rownames,fileEncoding = encode,sep=",",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.csv(filename1, header = has_header,row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename1, header = has_header,row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.table(filename1, header = has_header, row.names =has_rownames,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  }  else {
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
    
}
varespec = read_data(file = filename1,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename1, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename1,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  varespec = read_data(file = filename1,has_header = T)
  varespec =as.data.frame(varespec)
  row.names(varespec)=varespec[,1]
  varespec = varespec[,-1]
  
  }

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
        read.csv(filename2, header = has_header, row.names =has_rownames,fileEncoding = encode,sep=",",check.names=FALSE),
        warning = function(e) {
          read.csv(filename2, header = has_header,row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename2, header = has_header,row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE),
        warning = function(e) {
          read.table(filename2, header = has_header, row.names =has_rownames,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
        }
      )
  }  else {
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
    
}
varechem = read_data(file = filename2,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename2, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename2,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  varechem = read_data(file = filename2,has_header = T)
  varechem =as.data.frame(varechem)
  row.names(varechem)=varechem[,1]
  varechem = varechem[,-1]
  
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
        read.csv(filename3, header = has_header, row.names =has_rownames,fileEncoding = encode,sep=",",check.names=FALSE),
        warning = function(e) {
          read.csv(filename3, header = has_header,row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename3, header = has_header,row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE),
        warning = function(e) {
          read.table(filename3, header = has_header, row.names =has_rownames,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
        }
      )
  }  else {
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
    
}
group = read_data(file = filename3,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename3, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename3,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  group = read_data(file = filename3,has_header = T)
  group =as.data.frame(group)
  row.names(group)=group[,1]
  group = group[,-1]
  
  }
#group <- read.table(inputFile,header = T,row.names = 1)
#head(group)
group =t(group)
colnames(group) ==colnames(varespec)
class=unique(group[1,])
#class[1]
#ncol(group)

species_list=list()
for(i in seq_along(class)){
 # species_class[1]  = which(class[1]==group[,])
  species_class=which(class[i]==group[,])
  species_list[[i]]=species_class
}

names(species_list) <- class


mantel <- mantel_test(varespec, varechem,
                      spec_select = species_list) %>% 
  mutate(rd = cut(r, breaks = c(-Inf, 0.2, 0.4, Inf),
                  labels = c("< 0.2", "0.2 - 0.4", ">= 0.4")),
         pd = cut(p, breaks = c(-Inf, 0.01, 0.05, Inf),
                 labels = c("< 0.01", "0.01 - 0.05", ">= 0.05")))
 #view(mantel)
#head(mantel)

cor <- correlate(varechem,method = cor_method)
#corr2 <- cor2 %>% as_md_tbl()
#head(corr2)
p1 = qcorrplot(cor, type = "upper", diag = FALSE,grid_col = "grey50") +  
  geom_square() +
  geom_couple(data = mantel,
              aes(colour = pd, size = rd),
              curvature = nice_curvature(-0.25), nudge_x=0.5)+
  #scale_fill_gradientn(values = seq(0,1,0.2),
  #                     colors = colormap) +
  #scale_colour_manual(values = c("#d85c01", "#29d300", "#A2A2A288","#610214", "#d05646", "#f5f4f4", "#569cc7", "#0b3b71")) +
  scale_fill_gradientn(colours = RColorBrewer::brewer.pal(11, "PiYG")) +
  scale_size_manual(values = c(0.5, 1.2, 2)) +
  scale_colour_manual(values = color_pal(3)) +
  guides(size = guide_legend(title = "Mantel's r",
                             override.aes = list(colour = "grey35"), 
                             order = 2),
         colour = guide_legend(title = "Mantel's p", 
                               override.aes = list(size = 3), 
                               order = 1),
         fill = guide_colorbar(title = paste(cor_method,"'s r",sep=""), order = 3))
		 
if(is_mark %in% c("yes")){
    p2 = p1 + geom_mark(#data = corr2,
                        size = 4,
                        only_mark = T,
                        sig_level = c(0.05, 0.01, 0.001),
                        sig_thres = 0.05,
                        colour = 'white')
}else if(is_mark %in% c("no")){p2=p1}		 

len=1.17*nrow(varechem)+10
ggsave(egg::set_panel_size(p2, width=unit(15, "cm"), height=unit(10, "cm")),
       file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=len,height=20,dpi=600)








