
args = commandArgs(trailingOnly=TRUE)
argsCount = 11

if (length(args)!=argsCount) {
  stop("Circular_manhattan_docker_v.1.1.R libPath inputFile is_density is_threshold number1 is_binsize is_outward is_circhr circhr_high is_cir_legend outputFileName")
}
.libPaths(args[1])
 
inputFile <- args[2]

is_density <- args[3]
if (is.na(is_density)) {
  is_density <- "yes"
}
is_threshold <- args[4]
if (is.na(is_threshold)) {
  is_threshold <- "yes"
}
number1 <- as.numeric(args[5])
if (is.na(number1)) {
  number1 <- "0.01"
}

is_binsize <- as.numeric(args[6])
if (is.na(is_binsize)) {
  is_binsize <- "1000000"
}
is_outward <- as.logical(args[7])
if(is.na(is_outward)) {
   is_outward <- "T"
}
is_circhr <- as.logical(args[8])
if(is.na(is_circhr)) {
   is_circhr <- "T"
}
circhr_high <- as.numeric(args[9])
if (is.na(circhr_high)) {
  circhr_high <- "1.5"
}
is_cir_legend <- as.logical(args[10])
if(is.na(is_cir_legend)) {
   is_cir_legend <- "T"
}

outputFileName <- args[11]
if (is.na(outputFileName)) {
  outputFileName <- "Manhattan"
}


library(CMplot)
library(myplot)
data <- data.table::fread(inputFile, header = T )

yes_density <- c("yes")
no_density <- c("no")
yes_threshold <- c("yes")
no_threshold <- c("no")

if(is_density %in% yes_density){
          if(is_threshold %in% yes_threshold){
   p = myplot({ CMplot(data,plot.type = "c", cex = 0.3,
       # cex.axis=1,
       threshold = c(number1)/nrow(data),
       threshold.col=c('red','green'),
       amplify = T, 
	   dpi = 600,	
       chr.den.col=c("darkgreen", "yellow", "red"),
       bin.size=is_binsize,
	   outward=is_outward, 
	   signal.cex = c(0.7,0.7),
	   signal.pch = c(19,19), 
	   signal.col = c("red",'green'), 
       cir.chr=is_circhr,
       cir.chr.h = circhr_high,
       cir.legend = is_cir_legend,
       cir.band = 0.5,
       
	   file.output = F,
	   file="pdf"	
	   )
	   })
   plotsave(p,file=paste(outputFileName,"svg",sep="."),unit="cm",width=22,height=22,dpi=600)
   
	      	   
	}else if(is_threshold %in% no_threshold){
   p = myplot({ CMplot(data,plot.type = "c", cex = 0.3,
       # cex.axis=1,
       #threshold = c(0.01,0.05)/nrow(data),
       threshold.col=c('red','green'),
       amplify = T, 
	   dpi = 600,	
       chr.den.col=c("darkgreen", "yellow", "red"),
       bin.size=is_binsize,
	   outward=is_outward, 
	   signal.cex = c(0.7,0.7), 
	   signal.pch = c(19,19), 
	   signal.col = c("red",'green'), 
       cir.chr=is_circhr,
       cir.chr.h = circhr_high,
       cir.legend = is_cir_legend,
       cir.band = 0.5,
      
	   file.output = F,
	   file="pdf"	
	   )
	   })
   plotsave(p,file=paste(outputFileName,"svg",sep="."),unit="cm",width=22,height=22,dpi=600)   
	   
	   
	   }
	   
}else if(is_density %in% no_density){
            if(is_threshold %in% yes_threshold){
                
   p =myplot({  CMplot(data,plot.type = "c", cex = 0.3,
       # cex.axis=1,
       threshold = c(number1)/nrow(data),
       threshold.col=c('red','green'),
       amplify = T, 
	   dpi = 600,	
       #chr.den.col=c("darkgreen", "yellow", "red"),
      # bin.size=is_binsize,
	   outward=is_outward, 
	   signal.cex = c(0.7,0.7), 
	   signal.pch = c(19,19), 
	   signal.col = c("red",'green'), 
       cir.chr=is_circhr,
       cir.chr.h = circhr_high,
       cir.legend = is_cir_legend,
       cir.band = 0.5,
       #LOG10 = T,
	  # memo = outputFileName,
	   file.output = F,
	   file="pdf"	
	   )
	   })
   plotsave(p,file=paste(outputFileName,"svg",sep="."),unit="cm",width=22,height=22,dpi=600)  

	   
	 }else if(is_threshold %in% no_threshold){
   p = myplot({ CMplot(data,plot.type = "c", cex = 0.3,
       # cex.axis=1,
       #threshold = c(0.01,0.05)/nrow(data),
       threshold.col=c('red','green'),
       amplify = T, 
	   dpi = 600,	
       #chr.den.col=c("darkgreen", "yellow", "red"),
       #bin.size=is_binsize,
	   outward=is_outward, 
	   signal.cex = c(0.7,0.7), 
	   signal.pch = c(19,19), 
	   signal.col = c("red",'green'), 
       cir.chr=is_circhr,
       cir.chr.h = circhr_high,
       cir.legend = is_cir_legend,
       cir.band = 0.5,
       #LOG10 = T,
	  # memo = outputFileName,
	   file.output = F,
	   file="pdf"	   
	   )
	   })
   plotsave(p,file=paste(outputFileName,"svg",sep="."),unit="cm",width=22,height=22,dpi=600)   
	   
	   }
}
	   
	   
	   
	   
	   
	   
	  