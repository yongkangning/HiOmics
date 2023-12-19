

args = commandArgs(trailingOnly=TRUE)
argsCount = 12

if (length(args)!=argsCount) {
  stop("beeswarm_docker_v.1.0.R libPath inputFile point_cex point_size is_priority x_title y_title plot_title is_flip plot_with is_width outputFileName")
}
.libPaths(args[1])
 
inputFile <- args[2]

point_cex <- as.numeric(args[3])
if (is.na(point_cex)) {
  point_cex <- "1.5"
}

point_size <- as.numeric(args[4])
if (is.na(point_size)) {
  point_size <- "1"
}

is_priority <- args[5]
if (is.na(is_priority)) {
  is_priority <- "ascending"
}
x_title <- args[6]
if (is.na(x_title)) {
  x_title <- "group"
}
y_title <- args[7]
if (is.na(y_title)) {
  y_title <- "value"
}
plot_title <- args[8]
if (is.na(plot_title)) {
  plot_title <- "beeswarm_plot"
}
is_flip <- args[9]
if (is.na(is_flip)) {
  is_flip <- "no"
}

plot_with <- args[10]
if (is.na(plot_with)) {
  plot_with <- "no"
}

is_width<- as.numeric(args[11])
if (is.na(is_width)) {
  is_width <- "0.3"
}
outputFileName <- args[12]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}


library(ggbeeswarm)

data <- read.table(inputFile,sep="\t", header=T)


p1 = ggplot(data,aes_string(x=colnames(data)[1],y=colnames(data)[2]))+
    #   geom_violin(width=0.3)+
       geom_beeswarm(aes(color=colnames(data)[1]),cex=point_cex,size=point_size,priority = is_priority)+
       theme_bw()+
  labs(title=plot_title,x=x_title,y=y_title) + 
  #scale_color_manual(values=c("black","red"),name="Censored",labels=c("Yes","No")) +
 # scale_x_discrete(labels=c("ER neg","ER pos"))+
  theme_classic()+
  theme(plot.title = element_text(size =15,hjust = 0.5),
        axis.title.x=element_text(size=10),
        axis.title.y=element_text(size=10),
        axis.text.x=element_text(angle=0,size = 10),
        axis.text.y=element_text(size =10),
        axis.ticks = element_line(size=0.1),
        panel.border = element_blank())+
  theme(legend.key.size = unit(10,"pt"),
        legend.title = element_text(size=10),
        legend.text = element_text(size =10))
 
 
 p2 = ggplot(data,aes_string(x=colnames(data)[1],y=colnames(data)[2]))+
      geom_boxplot(width=is_width)+
       geom_beeswarm(aes(color=colnames(data)[1]),cex=point_cex,size=point_size,priority = is_priority)+
       theme_bw()+
  labs(title=plot_title,x=x_title,y=y_title) + 
  #scale_color_manual(values=c("black","red"),name="Censored",labels=c("Yes","No")) +
 # scale_x_discrete(labels=c("ER neg","ER pos"))+
  theme_classic()+
  theme(plot.title = element_text(size =15,hjust = 0.5),
        axis.title.x=element_text(size=10),
        axis.title.y=element_text(size=10),
        axis.text.x=element_text(angle=0,size = 10),
        axis.text.y=element_text(size =10),
        axis.ticks = element_line(size=0.1),
        panel.border = element_blank())+
  theme(legend.key.size = unit(10,"pt"),
        legend.title = element_text(size=10),
        legend.text = element_text(size =10))
  
 
 p3 = ggplot(data,aes_string(x=colnames(data)[1],y=colnames(data)[2]))+
       geom_violin(width=is_width)+
       geom_beeswarm(aes(color=colnames(data)[1]),cex=point_cex,size=point_size,priority = is_priority)+
       theme_bw()+
  labs(title=plot_title,x=x_title,y=y_title) + 
  #scale_color_manual(values=c("black","red"),name="Censored",labels=c("Yes","No")) +
 # scale_x_discrete(labels=c("ER neg","ER pos"))+
  theme_classic()+
  theme(plot.title = element_text(size =15,hjust = 0.5),
        axis.title.x=element_text(size=10),
        axis.title.y=element_text(size=10),
        axis.text.x=element_text(angle=0,size = 10),
        axis.text.y=element_text(size =10),
        axis.ticks = element_line(size=0.1),
        panel.border = element_blank())+
  theme(legend.key.size = unit(10,"pt"),
        legend.title = element_text(size=10),
        legend.text = element_text(size =10))
  
    
  
  yes_flip <- c("yes")
  no_filp <- c("no")
  
  nobox <- c("no")
  by_box <- c("box")
  by_violin <- c("violin")

if(is_flip %in% yes_flip){
       
           if(plot_with %in% nobox){    
              p = p1 + coord_flip()
      
		 }else if(plot_with %in% by_box){
		  p = p2 + coord_flip()
		
		}else if(plot_with %in% by_violin){
          p = p3 + coord_flip()
	    }

ggsave(plot=p,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=15,height=15,dpi=600)
   
}else if(is_flip %in% no_filp){
         
           if(plot_with %in% nobox){    
           p = p1
      
		 }else if(plot_with %in% by_box){
		  p = p2 
		
		}else if(plot_with %in% by_violin){
          p = p3
	    }
ggsave(plot=p,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=15,height=15,dpi=600)
}

  
  