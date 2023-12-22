
args = commandArgs(trailingOnly=TRUE)
argsCount = 7

if (length(args)!=argsCount) {
  stop("inputFile1 inputFile2 need_group inputFile3 inputFile4 need_surv x_label")
}


inputFile1 <- args[1]
inputFile2 <- args[2]
need_group <- args[3]
if (is.na(need_group)) {
  need_group <- "yes"
}
inputFile3 <- args[4]
need_surv <- args[5]

if (is.na(need_surv)) {
  need_surv <- "yes"
}
inputFile4 <- args[6]

x_label <- args[7]
if (is.na(x_label)) {
  x_label <- "no"
}



library(ggplot2)
library(immunedeconv)
library(tidyverse)
library(dplyr)
library(reshape2)


#exprMatrix <- read.table(inputFile1,header=TRUE,row.names=1, as.is=TRUE)
filename1 = inputFile1#="TCGA-HNSC.tpm.txt"


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
  exprMatrix = read_data(file = filename1,has_header = T,has_rownames=1)
  
}else if (filetype %in% c("xls", "xlsx")) {
  
  read_data <- function(filename1, has_header) {
    if(filetype %in% c("xls", "xlsx")){
      df <- readxl::read_excel(filename1,col_names=has_header)
      
    } else {
      stop("[ERRO] xls xlsx")}
  }
  
  
  exprMatrix = read_data(file = filename1,has_header = T)
  exprMatrix =as.data.frame(exprMatrix)
  row.names(exprMatrix)=exprMatrix[,1]
  exprMatrix = exprMatrix[,-1]
  
  
}




#exprMatrix <- read.table(inputFile1,header=TRUE,row.names=1, as.is=TRUE)
filename2 = inputFile2#="ref_sig_by_DEG.txt"


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
      stop("[ERRO] txt csv")
    }
    return(df)
    
  }
  resdf = read_data(file = filename2,has_header = T,has_rownames=1)
  
}else if (filetype %in% c("xls", "xlsx")) {
  
  read_data <- function(filename2, has_header) {
    if(filetype %in% c("xls", "xlsx")){
      df <- readxl::read_excel(filename2,col_names=has_header)
      
    } else {
      stop("[ERRO] xls xlsx")}
  }
  
  
  resdf = read_data(file = filename2,has_header = T)
  resdf =as.data.frame(resdf)
  row.names(resdf)=resdf[,1]
  resdf = resdf[,-1,drop=F]
  
  
}


library(CIBERSORT)

#resdf = read.table("ref_sig_by_DEG.txt",header = T,row.names = 1,sep = "\t",check.names = F)
resdf = data.matrix(resdf)
exprMatrix <- data.matrix(exprMatrix)
res <- cibersort(sig_matrix = resdf, mixture_file = exprMatrix,perm = 1000, QN = F)
res1=cbind(sample=row.names(res),res)
write.csv(res1, file='CIBERSORT_result_expression.csv', col.names=T, row.names=F, quote=F)



my_theme <- function(){
  theme(panel.grid = element_blank(),       
        panel.border = element_blank(),     
        legend.position="right",            
        legend.text = element_text(size=8), 
        legend.title = element_text(size=8),
        axis.line = element_line(size=0.2),   
        #text = element_text(family="Times"),
        axis.text.y = element_text(size = 8,face='bold',color='black'),
        axis.text.x = element_text(size = 8,face='bold',color='black',angle=0,hjust=1),        
        axis.title = element_text(size=10,face="bold"), 
        plot.title = element_text(hjust=0.5,size=10))   
}  

col_map <- c("#FF6A6A", "#EEAD0E", "#00FFFF", "#87CEFA", "#FF6EB4", "#76EE00",
             "#757575", "#AB82FF", "#7AC5CD", "#EEEE00", "#EEA9B8",
             "#6CA6CD", "#CD96CD", "#FF4040","#CD3333", "#6B8E23",   "#8B5A00", 
             "#836FFF",  "#CD6600", "#7FFFD4", "#6959CD", "#0000FF", "#E0EEEE", 
             "#838B83", "#8B4726", "#CD0000", "#00C5CD",   "#68228B","#EE00EE", 
             "#228B22","#8B7E66","#EEE9BF", "#0A0A0A","#F8F8FF", "#9400D3", 
             "#556B2F", "#EE7600", "#EEC900", "#CDAD00","#98F5FF", "#008B8B", 
             "#DEB887","#B0B0B0",  "#008B00", "#00EE00", "#27408B", "#473C8B",
             "#2E8B57", "#8B2252", "#F5DEB3", "#FFFF00", "#9AC0CD", 
             "#4876FF",  "#B03060", "#B4CDCD", "#7A8B8B", "#CD1076", "#FFE1FF", 
             "#FF7F00", "#B8860B", "#2F4F4F", "#EEE8CD", "#FFE7BA", 
             "#FF8C00",  "#A3A3A3", "#424242", "#858585",  "#CD5555",
             "#EEEED1", "#191970", "#EE8262", "#9FB6CD", "#D02090", "#FFA54F",
             "#CD919E", "#DA70D6", "#FF4500", "#EEDC82", "#8B814C", "#8B8970",
             "#CDBE70", "#00008B")


if(need_group %in% c('yes')){
  
  
  
  #exprMatrix <- read.table(inputFile1,header=TRUE,row.names=1, as.is=TRUE)
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
        stop("[ERRO] txt csv")
      }
      return(df)
      
    }
    group = read_data(file = filename3,has_header = T,has_rownames=1)
    
  }else if (filetype %in% c("xls", "xlsx")) {
    
    read_data <- function(filename3, has_header) {
      if(filetype %in% c("xls", "xlsx")){
        df <- readxl::read_excel(filename3,col_names=has_header)
        
      } else {
        stop("[ERRO] xls xlsx")}
    }
    
    
    group = read_data(file = filename3,has_header = T)
    group =as.data.frame(group)
    row.names(group)=group[,1]
    group = group[,-1,drop=F]
    
    
  }
  
  
  res3 <- as.data.frame(res[,1:(ncol(res)-3)]) %>% cbind(group=group[,1]) %>% rownames_to_column("sample") %>%gather(cell_type, fraction,-group, -sample)
  
  
  #svg(file=paste(outname,"svg",sep="."),width=is_width,height=is_height)	
  
  dd <- dist(res[,1:(ncol(res)-3)], method = "euclidean")
  hc <- hclust(dd, method = "ward.D2")
  library(ggdendro)
  #ggdendrogram(hc,theme_dendro = FALSE)+  theme_minimal()+
  #  theme(
  #    panel.grid = element_blank(),
  #    axis.title.x.bottom = element_blank(),
  #    axis.title.y.left = element_blank(),
  #    axis.text.y.left = element_blank(),
  #    axis.text.x.bottom = element_blank()
  #  )
  dend <- as.dendrogram(hc)
  dend_data <- dendro_data(dend, type = "rectangle")
  sample_sort=dend_data$labels$label 
  res3$sample = factor(res3$sample,levels = sample_sort)
# pdf(file="CIBERSORT_result.pdf", onefile=FALSE, width=10, height=8)  
  
  #res3 %>% ggplot(aes(x=sample,y=fraction))+
  #  geom_bar(aes(fill = cell_type),stat = "identity")+
  #  facet_grid(.~group,scales = "free_x",space = "free_x")+
  #  scale_y_continuous(expand = c(0,0))+
  #  scale_fill_brewer(palette = "Set3")+
  #  theme_bw()+
  #  theme(
  #    panel.grid = element_blank(),
  #    axis.text.x.bottom = element_blank(),
  #    axis.ticks.x.bottom = element_blank(),
  #    axis.text.y.left = element_text(size = 12,colour = "black"),
  #    axis.title = element_text(size = 14),
  #    strip.text.x = element_text(size = 14)
  #  )
  if(x_label %in% c('yes')){
    
    ggplot(res3,aes(x=sample, y=fraction, fill=cell_type)) +
                geom_bar(stat='identity') +
                #coord_flip()  +
                facet_grid(.~group,scales = "free_x",space = "free_x")+
                scale_fill_manual(values =col_map ) +
                theme_bw()+ theme(panel.border = element_blank(),
                                  panel.grid.major = element_blank(),
                                  panel.grid.minor = element_blank(),
                                  axis.line = element_line(colour = "black"))+
                scale_y_continuous(expand = c(0.01,0))+
                my_theme()+theme(legend.key.size = unit(10,"pt"))+
                theme(legend.text = element_text( size =8),
                      legend.title = element_blank())+
                theme(
                      axis.ticks.x.bottom = element_blank())
  
  }else if(x_label %in% c('no')){
    ggplot(res3,aes(x=sample, y=fraction, fill=cell_type)) +
            geom_bar(stat='identity') +
            #coord_flip()  +
            facet_grid(.~group,scales = "free_x",space = "free_x")+
            scale_fill_manual(values =col_map ) +
            theme_bw()+ theme(panel.border = element_blank(),panel.grid.major = element_blank(),
                              panel.grid.minor = element_blank(),axis.line = element_line(colour = "black"))+
            scale_y_continuous(expand = c(0.01,0))+
            my_theme()+theme(legend.key.size = unit(10,"pt"))+
            theme(legend.text = element_text( size =8),
                  legend.title = element_blank(),
                  axis.text.x = element_blank(),
                  axis.ticks.x.bottom = element_blank())
    
  }
ggsave(filename ="celltype_ratio.pdf", onefile=FALSE, width=10, height=6)
  
  
  library(ggpubr)
  library(RColorBrewer)
  library(scales)
  library(GGally)
  
  
  # pval=res3 %>% group_by(cell_type )%>%wilcox.test(fraction~fraction)%>%adjust_pvalue(p.col='p',method='bonferroni')%>%
  #   add_significance(p.col='p.adj')%>%add_xy_position(x='name',dodge=0.8)
  #plot.df=res2[,c("type2","celltype","ratio")]
  res3 %>% ggplot(aes(cell_type,fraction,fill=group))+
    #  geom_stripped_cols(odd = "#d9d9d9")+
    #geom_violin(scale = "width",color=NA,alpha=0.7)+
    geom_boxplot(width=0.6,outlier.shape = NA,position=position_dodge(0.8))+
    stat_compare_means(method = "wilcox.test",aes(label = ..p.signif..),label.y = c(0.95),hide.ns = F)+
    scale_y_continuous("Relative Percent",limits = c(0,1),expand = c(0.01,0))+
    # scale_fill_manual(values = c("normal"="#59b892","tumor"="#f367b2"))+
    theme_classic()+
    theme(
      legend.title = element_blank(),
      axis.ticks.length = unit(.15, "cm"),
      axis.text.x.bottom = element_text(size = 10,color = "black",angle = 45,hjust = 1),
      axis.text.y.left = element_text(size = 8,color = "black"),
      axis.title.x.bottom = element_blank(),
      axis.title.y.left = element_text(size = 12)
    )
  ggsave("celltype_ratio_between_groups.pdf",width = 15,height = 10,units = "cm")  
  

}else if(need_group %in% c('no')){
  
  res3 <- as.data.frame(res[,1:(ncol(res)-3)]) %>% rownames_to_column("sample") %>%gather(cell_type, fraction,-sample)
  

  
 # svg(file=paste(outname,"svg",sep="."),width=is_width,height=is_height)	
  
  dd <- dist(res[,1:(ncol(res)-3)], method = "euclidean")
  hc <- hclust(dd, method = "ward.D2")
  library(ggdendro)
  #ggdendrogram(hc,theme_dendro = FALSE)+  theme_minimal()+
  #  theme(
  #    panel.grid = element_blank(),
  #    axis.title.x.bottom = element_blank(),
  #    axis.title.y.left = element_blank(),
  #    axis.text.y.left = element_blank(),
  #    axis.text.x.bottom = element_blank()
  #  )
  dend <- as.dendrogram(hc)
  dend_data <- dendro_data(dend, type = "rectangle")
  sample_sort=dend_data$labels$label 
  res3$sample = factor(res3$sample,levels = sample_sort)
  
#  res3 %>% ggplot(aes(x=sample,y=fraction))+
#    geom_bar(aes(fill = cell_type),stat = "identity")+
#    facet_grid(.~group,scales = "free_x",space = "free_x")+
#    scale_y_continuous(expand = c(0,0))+
#    scale_fill_brewer(palette = "Set3")+
#    theme_bw()+
#    theme(
#      panel.grid = element_blank(),
#      axis.text.x.bottom = element_blank(),
#      axis.ticks.x.bottom = element_blank(),
#      axis.text.y.left = element_text(size = 12,colour = "black"),
#      axis.title = element_text(size = 14),
#      strip.text.x = element_text(size = 14)
#    )
  if(x_label %in% c('yes')){
    
    ggplot(res3,aes(x=sample, y=fraction, fill=cell_type)) +
                   geom_bar(stat='identity') +
                   #coord_flip()  +
                  # facet_grid(.~group,scales = "free_x",space = "free_x")+
                   scale_fill_manual(values =col_map ) +
                   theme_bw()+ theme(panel.border = element_blank(),
                                     panel.grid.major = element_blank(),
                                     panel.grid.minor = element_blank(),
                                     axis.line = element_line(colour = "black"))+
                   scale_y_continuous(expand = c(0.01,0))+
                   my_theme()+theme(legend.key.size = unit(10,"pt"))+
                   theme(legend.text = element_text( size =8),
                         legend.title = element_blank())+
                   theme(axis.ticks.x.bottom = element_blank())
  
  }else if(x_label %in% c('no')){
    ggplot(res3,aes(x=sample, y=fraction, fill=cell_type)) +
            geom_bar(stat='identity') +
            #coord_flip()  +
            scale_fill_manual(values =col_map ) +
            theme_bw()+ theme(panel.border = element_blank(),panel.grid.major = element_blank(),
                              panel.grid.minor = element_blank(),axis.line = element_line(colour = "black"))+
            scale_y_continuous(expand = c(0.01,0))+
            my_theme()+theme(legend.key.size = unit(10,"pt"))+#ͼ????С
            theme(legend.text = element_text( size =8),
                  legend.title = element_blank(),
                  axis.text.x = element_blank(),
                  axis.ticks.x.bottom = element_blank())
    
  }
  ggsave(filename ="celltype_ratio.pdf", onefile=FALSE, width=15, height=8)
  
  

  res3 %>% ggplot(aes(cell_type,fraction,fill=cell_type))+
    #  geom_stripped_cols(odd = "#d9d9d9")+
    #geom_violin(scale = "width",color=NA,alpha=0.7)+
    geom_boxplot(width=0.6,outlier.shape = NA,position=position_dodge(0.8))+ylim(0,1)+
   # stat_compare_means(method = "wilcox.test",aes(label = ..p.signif..),label.y = c(0.95),hide.ns = F)+
    scale_y_continuous("Relative Percent",limits = c(0,1),expand = c(0.01,0))+
    # scale_fill_manual(values = c("normal"="#59b892","tumor"="#f367b2"))+
    theme_classic()+
    theme(
      legend.title = element_blank(),
      axis.ticks.length = unit(.15, "cm"),
      axis.text.x.bottom = element_text(size = 10,color = "black",angle = 45,hjust = 1),
      axis.text.y.left = element_text(size = 8,color = "black"),
      axis.title.x.bottom = element_blank(),
      axis.title.y.left = element_text(size = 12)
    )
  ggsave("celltype_ratio_between_groups.pdf",width = 15,height = 10,units = "cm")  
  
}



if(need_surv %in% c('yes')){
  filename4 = inputFile4
  
  
  file_suffix <- strsplit(filename4, "\\.")[[1]]
  filetype <- file_suffix[length(file_suffix)]
  
  encode <-
    guess_encoding(filename4, n_max = 1000)[1, 1, drop = TRUE]
  # print(encode)
  if(is.na(encode)) {
    stop(paste("[ERRO]", filename4,"encoding_nonsupport"))
  }
  if(filetype %in% c("csv","txt")){
    
    read_data <- function(filename4, has_header,has_rownames) {
      
      if (filetype == "csv") {
        df <-
          tryCatch(
            read.csv(filename4, header = has_header, row.names =has_rownames,fileEncoding = encode,sep=",",check.names=FALSE),
            warning = function(e) {
              read.csv(filename4, header = has_header,row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE)
            }
          )
      } else if (filetype == "txt") {
        df <-
          tryCatch(
            read.table(filename4, header = has_header,row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE),
            warning = function(e) {
              read.table(filename4, header = has_header, row.names =has_rownames,fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE)
            }
          )
      }  else {
        stop("[ERRO] txt csv")
      }
      return(df)
      
    }
    clinic = read_data(file = filename4,has_header = T,has_rownames=1)
    
  }else if (filetype %in% c("xls", "xlsx")) {
    
    read_data <- function(filename4, has_header) {
      if(filetype %in% c("xls", "xlsx")){
        df <- readxl::read_excel(filename4,col_names=has_header)
        
      } else {
        stop("[ERRO] xls xlsx")}
    }
    
    
    clinic = read_data(file = filename4,has_header = T)
    clinic =as.data.frame(clinic)
    row.names(clinic)=clinic[,1]
    clinic = clinic[,-1,drop=F]
    
    
  }
#clinic=read.csv("clini.csv",header = T)
clinic$sample = rownames(clinic)

res = res[,1:(ncol(res)-3)]
res=as.data.frame(res)
res$sample = rownames(res)
clinic=clinic%>%inner_join(res,by = "sample")


library("survival")
library("survminer")

celltype_v=c()
surv_p=c()
HR_v=c()
cox_p=c()

celltype_used = colnames(res[,1:(ncol(res)-1)])
for (celltypei in celltype_used) {
  
  tmpindex = which(colnames(clinic) %in% celltypei)
  colnames(clinic)[tmpindex]="risk"
  clinic$risk = ifelse(clinic$risk > median(clinic$risk),"high","low")
  clinic$risk = as.factor(clinic$risk)
  Fit <- survfit(Surv(futime, fustat) ~ risk, data = clinic)


gg=ggsurvplot(Fit,data=clinic,pval = TRUE,
            #title = "Survival curves", 
            #subtitle = "Based on Kaplan-Meier estimates",
            legend.title = celltypei,
            risk.table = TRUE,        
            palette = "lancet",
            #palette=c("red","blue"),
            risk.table.height = 0.25, 
           # legend.labs=c("Low risk","High risk"),
           # pval.method=T,
           # conf.int = TRUE,          
           # surv.median.line = "hv", 
          # add.all = TRUE, 
           size = 0.5,                 
           # font.x = c(14, "bold.italic", "darkred"),
           # font.y = c(14, "bold.italic", "darkred"),
            ggtheme = theme_classic2()      
            
            )
pdf(file=paste0("survival_analysis_",celltypei,".pdf"), onefile=FALSE, width=6.5, height=5.5)
#svg(filename = gg )
print(gg)
dev.off()
 #ggsave(filename=paste0("",celltypei,".pdf"),width = 12,height = 12,units = "cm")
  tmppvalue=as.numeric(surv_pvalue(Fit)["pval"])
  
  cox.mod=coxph(Surv(futime,fustat) ~ risk, data = clinic)
  tmpHR <- round(exp(coef(cox.mod)), 4)
  tmpcoxp=summary(cox.mod)$coefficients[, 5]
  
  celltype_v=append(celltype_v,celltypei)
  surv_p=append(surv_p,tmppvalue)
  HR_v=append(HR_v,tmpHR)
  cox_p=append(cox_p,tmpcoxp)
  
  colnames(clinic)[tmpindex]=celltypei
}

#survp.df=data.frame(celltype=celltype_v,surv_pvalue=surv_p,HR=HR_v,cox_pvalue=cox_p)
#

#final.df=survp.df%>%filter(surv_pvalue < 0.1)

#for (celltypei in final.df$celltype) {
#  tmpindex = which(colnames(cli.info) %in% celltypei)
#  colnames(cli.info)[tmpindex]="usedcelltype"
#  Fit <- survfit(Surv(os.month, status) ~ usedcelltype, data = cli.info)
#  ggsurvplot(Fit,data=cli.info,pval = TRUE,legend.title = celltypei,pval.method=T,palette=c("red","blue"))
#  ggsave(paste0("",celltypei,".pdf"),width = 12,height = 12,units = "cm")
#  colnames(cli.info)[tmpindex]=celltypei
#}

}else if(need_surv %in% c('no')){
  print(1)
}










