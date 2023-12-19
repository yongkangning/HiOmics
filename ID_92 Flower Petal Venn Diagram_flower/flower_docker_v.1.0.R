args = commandArgs(trailingOnly=TRUE)
argsCount = 8

if (length(args)!=argsCount) {
  stop("flower_docker_v.1.0.R libPath inputFile group_cex core_name is_start r_size cir_color outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]
                    

group_cex <- as.numeric(args[3])
if (is.na(group_cex)) {
  group_cex <- "1"
}

core_name <- args[4]
if (is.na(core_name)) {
  core_name <- "core"
}
is_start <- as.numeric(args[5])
if (is.na(is_start)) {
  is_start <- "0"
}
r_size <- as.numeric(args[6])
if (is.na(r_size)) {
  r_size <- "0.8"
}
cir_color <- args[7]
if (is.na(cir_color)) {
  cir_color <- "white"
}
outputFileName <- args[8]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}

library(myplot)
library(plotrix)

flower_data=read.delim(inputFile, stringsAsFactors = F, check.names = F)

sample_id <- colnames(flower_data)
otu_id <- unique(flower_data[,1])
otu_id <- otu_id[otu_id != '']
core_otu_id <- otu_id
otu_num <- length(otu_id)

for (i in 2:ncol(flower_data)) {
  otu_id <- unique(flower_data[,i])
  otu_id <- otu_id[otu_id != '']
  core_otu_id <- intersect(core_otu_id, otu_id)
  otu_num <- c(otu_num, length(otu_id))
}
core_num <- length(core_otu_id)


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

flower_plot <- function(sample, otu_num, core_otu, start, a, b, r, ellipse_col, circle_col) {
  par( bty = 'n', ann = F, xaxt = 'n', yaxt = 'n', mar = c(1,1,1,1))
  plot(c(0,10),c(0,10),type='n')
  n   <- length(sample)
  deg <- 360 / n
  res <- lapply(1:n, function(t){
        draw.ellipse(x = 5 + 2*cos((start + deg * (t - 1)) * pi / 180), 
                 y = 5 + 2*sin((start + deg * (t - 1)) * pi / 180), 
                 col = ellipse_col[t],
                 border = ellipse_col[t],
                 a = a, b = b, angle = deg * (t - 1))
    text(x = 5 + 2.5 * cos((start + deg * (t - 1)) * pi / 180),
         y = 5 + 2.5 * sin((start + deg * (t - 1)) * pi / 180),
         otu_num[t],cex=1)
    
        if (deg * (t - 1) < 180 && deg * (t - 1) > 0 ) {
      text(x = 5 + 3.6 * cos((start + deg * (t - 1)) * pi / 180),
           y = 5 + 3.6 * sin((start + deg * (t - 1)) * pi / 180),
           sample[t],
           srt = deg * (t - 1) - start,
           adj = 1,
           cex = group_cex
      )
    } else {
      text(x = 5 + 3.6 * cos((start + deg * (t - 1)) * pi / 180),
           y = 5 + 3.6 * sin((start + deg * (t - 1)) * pi / 180),
           sample[t],
           srt = deg * (t - 1) + start,
           adj = 0,
           cex = group_cex
             )
    }            
  })
  draw.circle(x = 5, y = 5, r = r, col = circle_col, border = NA)
  text(x = 5, y = 5, paste(core_name,":", core_otu))
}



p = myplot({flower_plot(sample = sample_id, otu_num = otu_num, core_otu = core_num, 
            start = is_start, a = 0.5, b = 1.5, r = r_size, ellipse_col = color, circle_col = cir_color)})


 plotsave(p,file=paste(outputFileName,"svg",sep="."),unit="cm",width=16,height=13,dpi=600)  
	








