

args = commandArgs(trailingOnly=TRUE)
argsCount = 7

if (length(args)!=argsCount) {
  stop("zuneixgxfx.R libPath inputFile x_lab y_lab is_alpha mar_type outputFileName")
}
.libPaths(args[1])

library(ggplot2)
library(ggpubr)
library(ggExtra)
    
inputFile <- args[2]
data=read.table(inputFile,sep="\t",header=T,check.names=F,row.names=1)


x_lab <- as.numeric(args[3])
if (is.na(x_lab)) {
  x_lab <- "1"
}
y_lab <- as.numeric(args[4])
if (is.na(y_lab)) {
  y_lab <- "2"
}
is_alpha <- as.numeric(args[5])
if (is.na(is_alpha)) {
  is_alpha <- "0.5"
}

mar_type <- args[6]
if (is.na(mar_type)) {
  mar_type <- "densigram"
}
outputFileName <- args[7]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}



p=ggplot(data,aes_string(x=colnames(data)[x_lab], y=colnames(data)[y_lab])) + 
  xlab(colnames(data)[x_lab])+ylab(colnames(data)[y_lab])+
  theme_bw()+
  geom_point(color="#4F94CD",alpha=is_alpha,size=0.8)+  
  theme(panel.grid=element_blank())+
  theme(plot.title = element_text(size =15,hjust = 0.5),
        axis.title.x=element_text(size=10),
        axis.title.y=element_text(size=10),
        axis.text.x=element_text(angle=0,size = 8),
        axis.text.y=element_text(size =8),
        axis.ticks = element_line(size=0.1),
        panel.border = element_blank())+
  theme(axis.line = element_line(colour="black"))
  
p1=ggMarginal(p, type = mar_type, xparams = list(fill = c("#79CDCD" )),yparams = list(fill = "#FF6A6A"))

ggsave(filename=paste(outputFileName,"svg",sep="."),device='svg',plot=p1,units="cm",width=13,height=13,dpi=600)
  
