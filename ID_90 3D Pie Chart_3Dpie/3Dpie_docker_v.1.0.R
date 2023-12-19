

args = commandArgs(trailingOnly=TRUE)
argsCount = 8

if (length(args)!=argsCount) {
  stop("3Dpie_docker_v.1.0.R libPath inputFile is_legend is_explode is_height is_radius label_ces outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]


is_legend <- args[3]
if (is.na(is_legend)) {
  is_legend <- "yes"
}
is_explode <- as.numeric(args[4])
if (is.na(is_explode)) {
  is_explode <- "0.05"
}

is_height <- as.numeric(args[5])
if (is.na(is_height)) {
  is_height <- "0.05"
}
is_radius <- as.numeric(args[6])
if (is.na(is_height)) {
  is_height <- "0.5"
}
label_ces <- as.numeric(args[7])
if (is.na(label_ces)) {
  label_ces <- "1.5"
}
outputFileName <- args[8]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}


library(plotrix)
library(dplyr)
library(myplot)

data=read.table(inputFile,header=T,sep="\t",quote = "")

data <- mutate(data,perc = data[,2]/sum(data[,2])*100)
data <- data[order(data$perc,decreasing = T),]

pielabels <- data[,1]
percent <- paste0(round(data[,3],2),"%")

labs1 <- paste(pielabels,percent,sep="\n")
labs2 <- paste0(pielabels,"(",percent,")")

color=c("#FF6A6A", "#EEAD0E", "#00FFFF", "#87CEFA", "#FF6EB4", "#76EE00",
             "#757575", "#AB82FF", "#7AC5CD", "#EEEE00", "#EEA9B8",
             "#6CA6CD", "#CD96CD", "#FF4040","#CD3333", "#6B8E23",   "#8B5A00", 
             "#836FFF",  "#CD6600", "#7FFFD4", "#6959CD", "#0000FF", "#E0EEEE", 
             "#838B83", "#8B4726", "#CD0000", "#00C5CD",   "#68228B","#EE00EE", 
             "#228B22","#8B7E66","#EEE9BF", "#0A0A0A","#F8F8FF", "#9400D3", 
             "#556B2F", "#EE7600", "#EEC900", "#CDAD00","#98F5FF", "#008B8B", 
             "#DEB887","#B0B0B0",  "#008B00", "#00EE00", "#27408B", "#473C8B",
             "#2E8B57", "#8B2252", "#F5DEB3", "#FFFF00", "#9AC0CD", 
             "#4876FF",  "#B03060", "#B4CDCD", "#7A8B8B", "#CD1076", "#FFE1FF", 
             "#FF7F00", "#B8860B", "#2F4F4F", "#EEE8CD", "#FFE7BA", 
             "#FF8C00",  "#A3A3A3", "#424242", "#858585",  "#CD5555",
             "#EEEED1", "#191970", "#EE8262", "#9FB6CD", "#D02090", "#FFA54F",
             "#CD919E", "#DA70D6", "#FF4500", "#EEDC82", "#8B814C", "#8B8970",
             "#CDBE70", "#00008B")

no_legend <- c("no")
yes_legend <- c("yes")

if(is_legend %in% no_legend){
   p = myplot({pie3D(data[,3],
      col = color, 
      explode = is_explode,
      height = is_height, 
      radius = is_radius, 
      labels = labs1, 
      #border="white",
      labelcex = label_ces,
     # main = is_main
	  )
	  })
}else if(is_legend %in% yes_legend){
	  
   p = myplot({pie3D(data[,3],
      col = color, 
      explode = is_explode,
      height = is_height, 
      radius = is_radius, 
      #labels = labs2, 
      #border="white",
      #labelcex = label_ces,
     # main = is_main
	  )
	  
legend(legend=labs2,c("right"),bty = "n",fill=color,inset = c(0,0),cex = label_ces)
      })
}

  plotsave(p,file=paste(outputFileName,"svg",sep="."),unit="cm",width=16,height=13,dpi=600)  
	



