
args = commandArgs(trailingOnly=TRUE)
argsCount = 8

if (length(args)!=argsCount) {
  stop("pie_docker_v.1.0.R libPath inputFile lab_pos lab_font legend_pos plot_title plot_title_size outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]


lab_pos <- args[3]
if (is.na(lab_pos)) {
  lab_pos <- "in"
}
lab_font <- as.numeric(args[4])
if (is.na(lab_font)) {
  lab_font <- "4"
}
legend_pos <- args[5] 
if (is.na(legend_pos)) {
  legend_pos <- "right"
}
plot_title <- args[6] 
if (is.na(plot_title)) {
  plot_title <- "pie"
}
plot_title_size <- as.numeric(args[7])
if (is.na(plot_title_size)) {
  plot_title_size <- "15"
}
outputFileName <- args[8]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}


library(ggplot2)
library(ggpubr)

data=read.table(inputFile,header=T,sep="\t",quote = "")

data <- mutate(data,perc = data[,2]/sum(data[,2])*100)

labs <- paste0(round(data[,3],2),"%")
p<-ggpie(data,x="perc",
         label=labs,
         fill=colnames(data)[1],
         color="white",
         lab.font= c(lab_font,"black"),
         lab.pos=lab_pos)+#lab.pos=c("out","in")
theme(legend.position = legend_pos,
      legend.text = element_text(size=8))+
labs(title=plot_title)  +
  theme(#axis.text.x = element_text(size = 8,angle = 45, hjust = 1),
        #axis.text.y = element_text(size = 8),
        plot.title = element_text(size =plot_title_size,hjust = 0.5),
        #axis.title.x = element_text(size=12),
        #axis.title.y = element_text(size=12)
        )
		
ggsave(plot=p,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=15,height=15,dpi=600)