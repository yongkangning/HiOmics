
 

args = commandArgs(trailingOnly=TRUE)
argsCount = 9

if (length(args)!=argsCount) {
  stop("Linear_Regression-docker.R libPath inputFile  point_s x_title y_title plot_title is_method is_se outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]

point_s <- as.numeric(args[3])
if (is.na(point_s)) {
  point_s <- 13
}
x_title <- args[4]
if (is.na(x_title)) {
  x_title <- "x"
}
y_title <- args[5]
if (is.na(y_title)) {
  y_title <- "y"
}
plot_title <- args[6]
if (is.na(plot_title)) {
  plot_title <- "Linear_Regression_Plot"
}

is_method <- args[7]
if (is.na(is_method)) {
  is_method <- "lm"
}
is_se <- as.logical(args[8])
if (is.na(is_se)) {
  is_se <- "TRUE"
}

outputFileName <- args[9]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}

library(ggpmisc)   
library(ggplot2)  
library(mgcv)
library(MASS)
data=read.table(inputFile,header=T,sep="\t",check.names=F)

p=ggplot(data,aes(x=x,y=y)) +
  geom_point(color=c("#4F94CD"),shape=point_s,size=2,alpha=0.8) +
  labs(x=x_title , y=y_title,title=plot_title)+
  geom_smooth(method = is_method,formula = y~x,se=is_se,color=c("#228B22"))+
 
 
  stat_poly_eq(
  aes(label = paste(..eq.label.., ..rr.label.., sep = '~~~~~~')),
  formula = y ~ x,  parse = TRUE,
  size = 3, 
  label.x = 0.05,
  label.y = 0.95)+
  theme_bw()+ theme(panel.border = element_blank(),
                    panel.grid=element_blank())+
  theme(axis.line = element_line(colour="black"))+
 theme(plot.title=element_text(face="bold.italic",color="black",size=10, hjust=0.5,vjust=0.5,angle=360,lineheight=113))

  ggsave(filename=paste(outputFileName,"svg",sep="."),device='svg',plot=p,units="cm",width=13,height=13,dpi=600)
  










