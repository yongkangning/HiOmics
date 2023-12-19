

args = commandArgs(trailingOnly=TRUE)
argsCount = 17

if (length(args)!=argsCount) {
  stop("ggballoonplot_docker.R libPath inputFile is_conf is_conf_style con_alpha is_pval is_legend 
  is_xlab is_ylab is_title is_risk_table risk_table_height median_line is_palette 
  is_censor is_ncensor outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]

is_conf <- as.logical(args[3])
if (is.na(is_conf)) {
  is_conf <- "T"
}

is_conf_style <- args[4] 
if (is.na(is_conf_style)) {
  is_conf_style <- "ribbon"
}

con_alpha <- as.numeric(args[5])
if (is.na(con_alpha)) {
  con_alpha <- "0.2"
}

is_pval <- as.logical(args[6])
if (is.na(is_pval)) {
  is_pval <- "T"
}

is_legend <- args[7] 
if (is.na(is_legend)) {
  is_legend <- "top"
}

is_xlab <- args[8]
if (is.na(is_xlab)) {
  is_xlab <- "time"
}

 is_ylab <- args[9]
if (is.na(is_ylab)) {
  is_ylab <- "survival_probability"
}

is_title <- args[10] 
if (is.na(is_title)) {
  is_title <- "survival"
}
is_risk_table <- as.logical(args[11])
if (is.na(is_risk_table)) {
  is_risk_table <- "T"
}

risk_table_height <- as.numeric(args[12])
if (is.na(risk_table_height)) {
  risk_table_height <- "0.25"
}

median_line <- args[13] 
if (is.na(median_line)) {
  median_line <- "hv"
}

is_palette <- args[14] 
if (is.na(is_palette)) {
  is_palette <- "hue"
}
is_censor <- as.logical(args[15])
if (is.na(is_censor)) {
  is_censor <- "T"
}
is_ncensor<- as.logical(args[16])
if (is.na(is_ncensor)) {
  is_ncensor <- "T"
}

outputFileName <- args[17]
if (is.na(outputFileName)) {
  outputFileName <- "survival"
}
library(myplot)
library(ggplot2)
library(survival)
library(survminer)

rt=read.table(inputFile, header=T, sep="\t", check.names=F)
groupname=colnames(rt)[3]
names(rt)<-c("time","status","group")

diff=survdiff(Surv(time, status) ~group,data = rt)
pValue=1-pchisq(diff$chisq,df=1)
if(pValue<0.001){
  pValue="pvalue<0.001"
}else{
  pValue=paste0("pvalue=",sprintf("%.03f",pValue))
}
fit=survfit(Surv(time, status) ~ group, data = rt)
  svg(file=paste(outputFileName,"svg",sep="."),width=12,height=8)
 ggsurvplot(fit, data=rt,
                       conf.int=is_conf, 
                       conf.int.style=is_conf_style, 
                       conf.int.alpha=con_alpha, ；
                       pval=is_pval, 
                       pval.method=F,
                       pval.size=4,
                       pval.coord=c(0,0),
                       legend.labs=levels(factor(rt[,"group"])),
                       legend.title=groupname,
                       legend=is_legend,
                       xlab=is_xlab,
                       ylab=is_ylab,
                       title=is_title,
                       #break.time.by = 1,
                       surv.scale="default",
                       risk.table=is_risk_table, 
					   #risk.table.title="",
                       #table.font.x=12,
                      # tables.y.text.col=T ,
                       fontsize =4,
                       #surv.plot.height=0.2,
                       risk.table.height=risk_table_height,
                       surv.median.line = median_line,
                       palette = is_palette , 
                       linetype = 1, 
                       ggtheme=theme_survminer() ,
                       censor=is_censor,
                       cumevents =F ,
                       cumcensor=F, 
                       #font.title=15,
                     #  font.x=8,
                     #  font.y =12, 
                      # font.tickslab=8  
                       font.legend=8, 
                       ncensor.plot = is_ncensor
               )
			 
dev.off()

 
 