


args = commandArgs(trailingOnly=TRUE)
argsCount = 11

if (length(args)!=argsCount) {
  stop("scatter_docker.R libPath inputFile x_lab y_lab is_alpha is_line is_method is_se line_R outputFileName outPutFileType")
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

is_line <- args[6]
if (is.na(is_line)) {
  is_line <- "yes"
}

is_method <- args[7]
if (is.na(is_method)) {
  is_method <- "lm"
}
is_se <- as.logical(args[8])
if (is.na(is_se)) {
  is_se <- "TRUE"
}
line_R <- args[9]
if (is.na(line_R)) {
  line_R <- "spearman"
}
outputFileName <- args[10]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}
outPutFileType <- args[11]
if (is.na(outPutFileType)) {
  outPutFileType <- "svg"
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
  
line1=c("yes")
line2=c("no")
if(is_line %in% line1){p1=p+geom_smooth(method=is_method,formula = y ~ x,se=is_se,color=c("#595959"))+ stat_cor(method = line_R)
ggsave(filename=paste(outputFileName,outPutFileType,sep="."),device='svg',plot=p1,units="cm",width=13,height=13,dpi=600)
}else if(is_line %in% line2){p
ggsave(filename=paste(outputFileName,outPutFileType,sep="."),device='svg',plot=p,units="cm",width=13,height=13,dpi=600)
  }
  
  
