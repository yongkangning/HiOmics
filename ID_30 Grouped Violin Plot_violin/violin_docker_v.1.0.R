
args = commandArgs(trailingOnly=TRUE)
argsCount = 13

if (length(args)!=argsCount) {
  stop("violin_docker_v.1.0.R libPath inputFile is_alpha Palette x_title y_title plot_title is_legend is_method p_sig is_facet is_nrow outputFileName")
}
.libPaths(args[1])
 
inputFile <- args[2]

is_alpha <- as.numeric(args[3])
if (is.na(is_alpha)) {
  is_alpha <- "0.2"
}

Palette <- args[4]
                        
if (is.na(Palette)) {
  Palette <- "npg"
}

x_title <- args[5]
if (is.na(x_title)) {
  x_title <- "x"
}
y_title <- args[6]
if (is.na(y_title)) {
  y_title <- "y"
}
plot_title <- args[7]
if (is.na(plot_title)) {
  plot_title <- "violinplot"
}

is_legend <- args[8] 
if (is.na(is_legend)) {
  is_legend <- "top"
}

is_method <- args[9]
if (is.na(is_method)) {
  is_method <- "t.test"
}
p_sig <- args[10]
if (is.na(p_sig)) {
  p_sig <- "signif"
}

is_facet <- args[11]
if (is.na(is_facet)) {
  is_facet <- "no"
}

is_nrow <- as.numeric(args[12])
if (is.na(is_nrow)) {
  is_nrow <- "1"
}

outputFileName <- args[13]
if (is.na(outputFileName)) {
  outputFileName <- "vioplot"
}

library(reshape2)
library(ggpubr)         
rt=read.table(inputFile,header=T,sep="\t",check.names=F,row.names=1)

data=melt(rt,id.vars=colnames(rt)[1])


group=levels(factor(data[,1]))
data[,1]=factor(data[,1], levels=group)
comp=combn(group,2)
my_comparisons=list()
for(i in 1:ncol(comp)){my_comparisons[[i]]<-comp[,i]}

p0 = ggviolin(data, x=colnames(data)[1], y=colnames(data)[3],
              color=colnames(data)[1],
             fill = colnames(data)[1],
			 alpha=is_alpha,
		     #legend.title=x,
              palette = Palette,
                                           
			add = "boxplot", add.params = list(fill="white"))+
#stat_compare_means(comparisons = my_comparisons,method = is_method,label = "p.signif")+
        labs(x=x_title,y=y_title,title=plot_title)+
		theme(panel.background=element_rect(fill="white",color="black"),
       # panel.grid=element_line(color="grey50",linetype=3)
        )+
		 theme(plot.title = element_text(size =15,hjust = 0.5),
                      axis.title.x=element_text(size=10),
                      axis.title.y=element_text(size=10),
                      axis.text.x=element_text(angle=45,size = 8,vjust =1.2,hjust =1.1),
                      axis.text.y=element_text(size =8),
					  axis.ticks = element_line(size=0.2),
                      panel.border = element_blank())+
              theme(legend.key.size = unit(10,"pt"),
			        legend.title = element_text(size=8,vjust = 0.9),
			        legend.text = element_text(size =8,vjust = 0.8),
					legend.position = is_legend)
								
		
										
is_method1=c("no")
is_method2=c("t.test")
is_method3=c("wilcox.test")
is_method4=c("anova")
is_method5=c("kruskal.test")

pval=c("pvalue")
sig=c("signif")

facet=c("yes")
no_facet=c("no")

if(is_facet %in% facet){p1= p0 + facet_wrap(~variable,nrow =is_nrow)
if(is_method %in% is_method1){
ggsave(plot=p1,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)
}else if(is_method %in% is_method2){if(p_sig %in% pval){p2_1=p1+stat_compare_means(comparisons = my_comparisons,method = "t.test")
                                                         ggsave(plot=p2_1,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=25,height=13,dpi=600)
                              }else if(p_sig %in% sig){p2_2=p1+stat_compare_means(comparisons = my_comparisons,method = "t.test",label = "p.signif")
                                                         ggsave(plot=p2_2,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=25,height=18,dpi=600)}
}else if(is_method %in% is_method3){if(p_sig %in% pval){p3_1=p1+stat_compare_means(comparisons = my_comparisons,method = "wilcox.test")
                                                         ggsave(plot=p3_1,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=25,height=18,dpi=600)
                              }else if(p_sig %in% sig){p3_2=p1+stat_compare_means(comparisons = my_comparisons,method = "wilcox.test",label = "p.signif")
                                                         ggsave(plot=p3_2,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=25,height=18,dpi=600)}
}else if(is_method %in% is_method4){if(p_sig %in% pval){p4_1=p1+stat_compare_means(method = "anova")
                                                         ggsave(plot=p4_1,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=25,height=18,dpi=600)
                              }else if(p_sig %in% sig){p4_2=p1+stat_compare_means(method ="anova",label = "p.signif")
                                                         ggsave(plot=p4_2,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=25,height=18,dpi=600)}
}else if(is_method %in% is_method5){if(p_sig %in% pval){p5_1=p1+stat_compare_means(method = "kruskal.test")
                                                         ggsave(plot=p5_1,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=25,height=18,dpi=600)
                              }else if(p_sig %in% sig){p5_2=p1+stat_compare_means(method ="kruskal.test",label = "p.signif")
                                                         ggsave(plot=p5_2,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=25,height=18,dpi=600)}
}

}else if(is_facet %in% no_facet){
if(is_method %in% is_method1){
ggsave(plot=p0,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)
}else if(is_method %in% is_method2){if(p_sig %in% pval){p2_1=p0+stat_compare_means(comparisons = my_comparisons,method = "t.test")
                                                         ggsave(plot=p2_1,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)
                              }else if(p_sig %in% sig){p2_2=p0+stat_compare_means(comparisons = my_comparisons,method = "t.test",label = "p.signif")
                                                         ggsave(plot=p2_2,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)}
}else if(is_method %in% is_method3){if(p_sig %in% pval){p3_1=p0+stat_compare_means(comparisons = my_comparisons,method = "wilcox.test")
                                                         ggsave(plot=p3_1,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)
                              }else if(p_sig %in% sig){p3_2=p0+stat_compare_means(comparisons = my_comparisons,method = "wilcox.test",label = "p.signif")
                                                         ggsave(plot=p3_2,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)}
}else if(is_method %in% is_method4){if(p_sig %in% pval){p4_1=p0+stat_compare_means(method = "anova")
                                                         ggsave(plot=p4_1,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)
                              }else if(p_sig %in% sig){p4_2=p0+stat_compare_means(method ="anova",label = "p.signif")
                                                         ggsave(plot=p4_2,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)}
}else if(is_method %in% is_method5){if(p_sig %in% pval){p5_1=p0+stat_compare_means(method = "kruskal.test")
                                                         ggsave(plot=p5_1,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)
                              }else if(p_sig %in% sig){p5_2=p0+stat_compare_means(method ="kruskal.test",label = "p.signif")
                                                         ggsave(plot=p5_2,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=13,height=13,dpi=600)}
}
}


