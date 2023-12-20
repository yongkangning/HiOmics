
args = commandArgs(trailingOnly=TRUE)
argsCount = 6

if (length(args)!=argsCount) {
  stop("venn_docker_v.1.0.R libPaths inputFile percentage alpha textsize outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]

percentage <- args[3]
if (is.na(percentage)) {
  percentage <- "F"
}

alpha <- as.numeric(args[4])
if (is.na(alpha)) {
  alpha <- 0.5
}
textsize <- as.numeric(args[5])
if (is.na(textsize)) {
  textsize <- 3.5
}
outputFileName <- args[6]
if (is.na(outputFileName)) {
  outputFileName <- "venn"
}

library(ggvenn)
library(dplyr)
library(tidyr)


data <- read.delim(inputFile, stringsAsFactors = F, check.names = F,na.strings = "")
data <- gather(data, groups, value, colnames(data))
data <- na.omit(data)

split_tibble <- function(tibble, column = 'col') {
  tibble %>% split(., .[,column]) %>% lapply(., function(x) x[,setdiff(names(x),column)])
}
x <- split_tibble(data, 'groups')
#data_spilt=split(df_plot, df_plot[,"groups"])
#data=lapply(data_spilt, function(x) x[,setdiff(names(x),"groups")])

#mycolor <- c("blue", "yellow", "steelblue", "red", 'salmon', "green")
mycolor <- c("#FF69B4", "#63B8FF", "#828282", "#CAFF70", "#CD6600", "#FFD700", "#458B74")
p = venn_plot = ggvenn(x, 
  show_percentage = percentage,
  fill_color = mycolor[1:length(x)],
  #fill_color = c("#0073C2FF", "#EFC000FF", "#868686FF", "#CD534CFF"),
  stroke_size = 0.1, 
  stroke_linetype=1,
  stroke_alpha=0.2,
  stroke_color="white",
  set_name_size = 3.5,
  fill_alpha = alpha,
  text_size = textsize
)

ggsave(plot=p,file=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=10,height=10,dpi=600)
