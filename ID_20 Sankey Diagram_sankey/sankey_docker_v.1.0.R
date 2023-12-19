
args = commandArgs(trailingOnly=TRUE)
argsCount = 8

if (length(args)!=argsCount) {
  stop("sankey_docker_v.1.0.R libPath inputFile stratum_width is_alpha text_size x_size plot_title outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]

stratum_width <- as.numeric(args[3])
if (is.na(stratum_width)) {
  stratum_width <- "0.3"
}

is_alpha <- as.numeric(args[4])
if (is.na(is_alpha)) {
  is_alpha <- "0.5"}
text_size <- as.numeric(args[5])
if (is.na(text_size)) {
  text_size <- "2"
}
x_size <- as.numeric(args[6])
if (is.na(x_size)) {
  x_size <- "8"
}
plot_title <- args[7]
if (is.na(plot_title)) {
  plot_title <- "sankey"
}
outputFileName <- args[8]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}
library(ggalluvial)
library(ggplot2)

    
data=read.table(inputFile, header = T, sep="\t", check.names=F)     
corLodes=to_lodes_form(data, axes = 1:ncol(data))



col_map <- c("#FF6A6A", "#EEAD0E", "#00FFFF", "#87CEFA", "#FF6EB4", "#76EE00",
             "#757575", "#AB82FF", "#7AC5CD", "#EEEE00", "#9AC0CD", "#EEA9B8",
             "#6CA6CD", "#CD96CD", "#FF4040","#CD3333", "#6B8E23",   "#8B5A00", 
             "#836FFF",  "#CD6600", "#7FFFD4", "#6959CD", "#0000FF", "#E0EEEE", 
             "#838B83", "#8B4726", "#CD0000", "#00C5CD",   "#68228B","#EE00EE", 
             "#228B22","#8B7E66","#EEE9BF", "#0A0A0A","#F8F8FF", "#9400D3", 
             "#556B2F", "#EE7600", "#EEC900", "#CDAD00","#98F5FF", "#008B8B", 
             "#DEB887","#B0B0B0",  "#008B00", "#00EE00", "#27408B", "#473C8B",
             "#2E8B57", "#8B2252", "#F5DEB3", "#FFFF00", 
             "#4876FF",  "#B03060", "#B4CDCD", "#7A8B8B", "#CD1076", "#FFE1FF", 
             "#FF7F00", "#B8860B", "#2F4F4F", "#EEE8CD", "#FFE7BA", 
             "#FF8C00",  "#A3A3A3", "#424242", "#858585",  "#CD5555",
             "#EEEED1", "#191970", "#EE8262", "#9FB6CD", "#D02090", "#FFA54F",
             "#CD919E", "#DA70D6", "#FF4500", "#EEDC82", "#8B814C", "#8B8970",
             "#CDBE70", "#00008B")
p=ggplot(corLodes, aes(x = x, stratum = stratum, alluvium = alluvium,fill = stratum, label = stratum)) +
  scale_x_discrete(expand = c(0, 0)) +  
  
  geom_flow(width = stratum_width,aes.flow = "forward") + 
  geom_stratum(alpha =is_alpha,width = stratum_width) +
  scale_fill_manual(values = col_map) +
  
  geom_text(stat = "stratum", size = text_size,color="black") +
        theme_bw() + 
   theme(plot.title = element_text(size =15,hjust = 0.5),
		 axis.line = element_blank(),
         axis.ticks = element_blank(),
         axis.text.y = element_blank(),
         axis.text.x=element_text(size =x_size)) +
         theme(panel.grid =element_blank()) + 
         theme(panel.border = element_blank()) +
		 xlab("") + ylab("") + 
         ggtitle(plot_title) + guides(fill ="none")    
		 
ggsave(plot=p,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)
