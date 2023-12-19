
args = commandArgs(trailingOnly=TRUE)
argsCount = 10

if (length(args)!=argsCount) {
  stop("tree_with_barplot_docker_v.1.0.R libPath inputFile is_prop dist_method hclust_method y_title plot_title picture1_width picture2_width outputFileName")
}
.libPaths(args[1])
 
inputFile <- args[2]

is_prop <- args[3]
if (is.na(is_prop)) {
  is_prop <- "yes"
}

dist_method <- args[4]
if (is.na(dist_method)) {
  dist_method <- "bray"
}

hclust_method <- args[5]
if (is.na(hclust_method)) {
  hclust_method <- "complete"
}

y_title <- args[6]
if (is.na(y_title)) {
  y_title <- "y"
}
plot_title <- args[7]
if (is.na(plot_title)) {
  plot_title <- "tree_with_barplot"
}
picture1_width <- as.numeric(args[8])
if (is.na(picture1_width)) {
  picture1_width <- "1"
}
picture2_width <- as.numeric(args[9])
if (is.na(picture2_width)) {
  picture2_width <- "4"
}

outputFileName <- args[10]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}

library(ggplot2)
library(reshape2)
library(colourpicker)
library(patchwork)
library(ggtree)



data1=read.table(inputFile,header=T,sep="\t",check.names=F,row.names = 1,quote = "")

Perccol <-  prop.table(as.matrix(data1),2)
id <- row.names(Perccol)
data_prop <- as.data.frame(cbind(id,Perccol),stringsAsFactors = F)

data_prop$id <- factor(data_prop$id,levels = unique(data_prop$id))
data_prop <- melt(data_prop,id.vars="id")


data2=read.table(inputFile,header=T,sep="\t",check.names=F,quote = "")
data2[,1] <- factor(data2[,1],levels = unique(data2[,1]))
data_noprop <- melt(data2,id.vars=colnames(data)[1])


col_map <- c("#FF6A6A", "#EEAD0E", "#00FFFF", "#87CEFA", "#FF6EB4", "#76EE00",
             "#757575", "#AB82FF", "#EEEE00", "#9AC0CD",
             "#6CA6CD", "#CD96CD", "#FF4040","#CD3333", "#6B8E23",   "#8B5A00", 
             "#836FFF",  "#CD6600", "#7FFFD4", "#6959CD", "#0000FF", "#E0EEEE", 
             "#838B83", "#8B4726", "#CD0000", "#00C5CD",   "#68228B","#EE00EE", 
             "#228B22","#8B7E66","#EEE9BF", "#0A0A0A","#F8F8FF", "#9400D3", 
             "#556B2F", "#EE7600", "#EEC900", "#CDAD00","#98F5FF", "#008B8B", 
             "#DEB887","#B0B0B0",  "#008B00", "#00EE00", "#27408B", "#473C8B",
             "#2E8B57", "#8B2252", "#F5DEB3", "#FFFF00",  "#7AC5CD", "#EEA9B8",
             "#4876FF",  "#B03060", "#B4CDCD", "#7A8B8B", "#CD1076", "#FFE1FF", 
             "#FF7F00", "#B8860B", "#2F4F4F", "#EEE8CD", "#FFE7BA", 
             "#FF8C00",  "#A3A3A3", "#424242", "#858585",  "#CD5555",
             "#EEEED1", "#191970", "#EE8262", "#9FB6CD", "#D02090", "#FFA54F",
             "#CD919E", "#DA70D6", "#FF4500", "#EEDC82", "#8B814C", "#8B8970",
             "#CDBE70", "#00008B")


yes_prop <- c("yes")
no_prop <- c("no")
if(is_prop %in% yes_prop){

p1= ggplot(data=data_prop,aes(x=variable ,y=as.numeric(value),fill=id))+
  geom_bar(stat="identity",position="stack", color="NA", 
           width=0.7,size=1,alpha=0.7)+
  # scale_y_continuous(labels = function(x) paste0(100*x),expand=c(0,0))+
  theme_bw()+ 
  labs(y=y_title,title=plot_title)+
  scale_y_continuous(expand = c(0,0))+
  theme(plot.title = element_text(size =15,hjust = 0.5),
        axis.title.x=element_text(size=10),
        #axis.title.y=element_text(size=10),
        axis.title.y = element_blank(),
        axis.text.x=element_text(angle=0,size = 10),
        axis.text.y=element_text(size =10),
		axis.ticks = element_line(size=0.2),
        panel.border = element_blank())+
  theme(legend.key.size = unit(10,"pt"))+
  theme(legend.text = element_text( size =8),legend.title = element_blank())+
  theme(panel.grid.major=element_blank(),
        panel.background = element_rect(fill = "transparent",colour = NA),
        plot.background = element_rect(fill = "transparent",colour = NA),
        panel.grid.minor = element_blank(),
        panel.border = element_blank())+
  scale_fill_manual(values=col_map)+
   theme(axis.line.x = element_line(colour="black",size = 0.2))+
  #guides(fill = guide_legend(override.aes = list(colour = "NA")))+
  coord_flip()
  
  }else if(is_prop %in% no_prop){
  
 p1= ggplot(data=data_noprop,aes_string(x=colnames(data_noprop)[2] ,y=colnames(data_noprop)[3],fill=colnames(data_noprop)[1]))+
  geom_bar(stat="identity",position="stack", color="NA", 
           width=0.7,size=1,alpha=0.7)+
  # scale_y_continuous(labels = function(x) paste0(100*x),expand=c(0,0))+
  theme_bw()+ 
  labs(y=y_title,title=plot_title)+
  scale_y_continuous(expand = c(0,0))+
  theme(plot.title = element_text(size =15,hjust = 0.5),
        axis.title.x=element_text(size=10),
        #axis.title.y=element_text(size=10),
        axis.title.y = element_blank(),
        axis.text.x=element_text(angle=0,size = 10),
        axis.text.y=element_text(size =10),
		axis.ticks = element_line(size=0.2),
        panel.border = element_blank())+
  theme(legend.key.size = unit(10,"pt"))+
  theme(legend.text = element_text( size =8),legend.title = element_blank())+
  theme(panel.grid.major=element_blank(),
        panel.background = element_rect(fill = "transparent",colour = NA),
        plot.background = element_rect(fill = "transparent",colour = NA),
        panel.grid.minor = element_blank(),
        panel.border = element_blank())+
  scale_fill_manual(values=col_map)+
   theme(axis.line.x = element_line(colour="black",size = 0.2))+
  #guides(fill = guide_legend(override.aes = list(colour = "NA")))+
  coord_flip()
  }

t_data <- t(data1)

data_dist <- vegan::vegdist(t_data, method = dist_method)

p2 <- ggtree(hclust(data_dist,method = hclust_method))


p <-p2+ p1+plot_layout(widths = c(picture1_width, picture2_width))

ggsave(plot=p,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=15,height=15,dpi=600)














