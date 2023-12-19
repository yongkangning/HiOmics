#install.packages("ggpubr")






args = commandArgs(trailingOnly=TRUE)
argsCount = 10

if (length(args)!=argsCount) {
  stop("ggballoonplot_docker.R libPath inputFile x_lab y_lab color_group size_balloon x_title y_title plot_title outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]
x_lab <- as.numeric(args[3])
if (is.na(x_lab)) {
  x_lab <- "1"
}
y_lab <- as.numeric(args[4])
if (is.na(y_lab)) {
  y_lab <- "2"
}

color_group <- as.numeric(args[5])
if (is.na(color_group)) {
  color_group <- "3"
}

size_balloon <- as.numeric(args[6])
if (is.na(size_balloon)) {
  size_balloon <- "4"
}
x_title <- args[7] 
if (is.na(x_title)) {
  x_title <- "bubble plot"
}
y_title <- args[8] 
if (is.na(y_title)) {
  y_title <- "bubble plot"
}
plot_title <- args[9] 
if (is.na(plot_title)) {
  plot_title <- "balloon"
}
outputFileName <- args[10]
if (is.na(outputFileName)) {
  outputFileName <- "balloon"
}

library(ggpubr)                 
data=read.table(inputFile,header=T,sep="\t",check.names=F)   


	p= ggplot(data, aes_string(x=colnames(data)[x_lab],
                    y=colnames(data)[y_lab],
					color = colnames(data)[color_group],
                    size = colnames(data)[size_balloon]
                    ))+
					geom_point(alpha=0.8)+
              scale_color_hue(direction = -1)+
			  labs(x=x_title,y=y_title,title=plot_title)+
  theme(plot.title = element_text(size =15,hjust = 0.5),
        axis.title.x=element_text(size=10),
        axis.title.y=element_text(size=10),
        axis.text.x=element_text(angle=45,vjust =1.2,hjust =1.2,size = 8),
        axis.text.y=element_text(size =8),
        axis.ticks = element_line(size=0.2)
        )+
  theme(legend.key.size = unit(10,"pt"))+
    
  theme(legend.text = element_text( size =8),legend.title = element_text(size = 8))+
  theme(panel.grid.major=element_line(colour="gray80",size=0.1),
      panel.background = element_rect(fill = "transparent",colour = "black"),
      plot.background = element_rect(fill = "transparent",colour = NA),
       panel.grid.minor = element_line(colour = "gray")
        #panel.border = element_blank()
        )+
 # scale_fill_manual(values=col_map)+
  theme(axis.line = element_line(colour="black",size = 0.2))

ggsave(plot=p,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=20,height=13,dpi=600)
