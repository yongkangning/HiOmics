


args = commandArgs(trailingOnly=TRUE)
argsCount = 12

if (length(args)!=argsCount) {
  stop("Single_chromosome_manhattan_docker_v.1.1.R libPath inputFile1 inputFile2 num_SHR is_threshold suggestive_line annotate_Pval point_cex axis_cex is_xlab is_main outputFileName")
}
.libPaths(args[1])
 
inputFile1 <- args[2]
inputFile2 <- args[3]

num_SHR <- as.numeric(args[4])
if (is.na(num_SHR)) {
  num_SHR <- "3"
}

is_threshold <- args[5]
if (is.na(is_threshold)) {
  is_threshold <- "yes"
}

suggestive_line <- as.numeric(args[6])
if (is.na(suggestive_line)) {
  suggestive_line <- "0.00001"
}

annotate_Pval <- as.numeric(args[7])
if (is.na(annotate_Pval)) {
  annotate_Pval <- "0.0001"
}

point_cex  <- as.numeric(args[8])
if (is.na(point_cex)) {
  point_cex <- "0.7"
}

axis_cex <- as.numeric(args[9])
if (is.na(point_cex)) {
  point_cex <- "0.8"
}
is_xlab <- args[10]
if (is.na(is_xlab)) {
  is_xlab <- "X"
}

is_main <- args[11]
if (is.na(is_main)) {
  is_main <- "Manhattan_plot"
}

outputFileName <- args[12]
if (is.na(outputFileName)) {
  outputFileName <- "manhattan"
}

library(qqman)
library(myplot)        

data_gwas <- read.table(inputFile1, header = T )


yes_threshold <- c("yes")
no_threshold <- c("no")



if(is_threshold %in% yes_threshold){

            
			
     p=myplot({     manhattan(subset(data_gwas, CHR == num_SHR),
                    highlight = inputFile2, 
                    suggestiveline = -log10(suggestive_line),
                    genomewideline = FALSE,
                    # xlim = c(200,500), 
                    annotatePval = annotate_Pval,
                    annotateTop =F,
		            cex.axis = axis_cex,
		            cex = point_cex,
		            xlab=paste("Chromosome",is_xlab,"position"),
                    main =is_main,
					col = "skyblue")
		})
	
		 

}else if(is_threshold %in% no_threshold){

        p=myplot({  manhattan(subset(gwasResults, CHR == num_SHR),
                    highlight = inputFile2, 
                    suggestiveline = FALSE,
                    genomewideline = FALSE,
                    # xlim = c(200,500), 
                    main =is_main,
		            annotatePval = annotate_Pval,
                    annotateTop =F,
		            cex.axis = axis_cex,
		            cex = point_cex,
		            xlab=paste("Chromosome",is_xlab,"position"),
                    col = "skyblue")
 })

}


 plotsave(p,file=paste(outputFileName,"svg",sep="."),unit="cm",width=15,height=15,dpi=600)   
	



	   


