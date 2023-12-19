
args = commandArgs(trailingOnly=TRUE)
argsCount = 12

if (length(args)!=argsCount) {
  stop("Single_character_rectangular_manhattan_docker_v.1.1.R libPath inputFile1 inputFile2 inputFile3 Highlight is_threshold suggestive_line annotate_Pval point_cex axis_cex is_main outputFileName")
}
.libPaths(args[1])
 
inputFile1 <- args[2]
inputFile2 <- args[3]
inputFile3 <- args[4]

Highlight <- args[5]
if (is.na(Highlight)) {
  Highlight <- "yes"
}

is_threshold <- args[6]
if (is.na(is_threshold)) {
  is_threshold <- "yes"
}

suggestive_line <- as.numeric(args[7])
if (is.na(suggestive_line)) {
  suggestive_line <- "0.00001"
}


annotate_Pval <- as.numeric(args[8])
if (is.na(annotate_Pval)) {
  annotate_Pval <- "0.0001"
}

point_cex  <- as.numeric(args[9])
if (is.na(point_cex)) {
  point_cex <- "0.7"
}

axis_cex <- as.numeric(args[10])
if (is.na(axis_cex)) {
  axis_cex <- "0.8"
}

is_main <- args[11]
if (is.na(is_main)) {
  is_main <- "Manhattan_plot"
}

outputFileName <- args[12]
if (is.na(outputFileName)) {
  outputFileName <- "Manhattan_plot"
}

library(qqman)    
library(myplot)
data_gwas <- read.table(inputFile1, header = T )

col_map <- c("#FF6A6A", "#EEAD0E", "#00FFFF", "#87CEFA", "#FF6EB4", "#76EE00",
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
			 

yes_highlight <- c("yes")
no_highlight <- c("no")
own_highlight <- c("ownhighlight")

yes_threshold <- c("yes")
no_threshold <- c("no")



if (Highlight %in% yes_highlight){
             
			 if(is_threshold %in% yes_threshold)
			      
			      {
				  
			 chrlabs_data <- read.table(file=inputFile3,header = T,sep = "\t",row.names=1)
             chrlabs_data <- as.matrix(chrlabs_data)
             chrlabs_data <- as.vector(chrlabs_data) 				  

   p =({myplot( manhattan(data_gwas,col = col_map,
          suggestiveline = -log10(suggestive_line),
          genomewideline = FALSE,
          highlight = snpsOfInterest,
          annotatePval = annotate_Pval,
          annotateTop = F,
		  chrlabs = chrlabs_data,
		  cex=point_cex, 
		  cex.axis = axis_cex,
		  main =is_main 
		  ))
		  })
		  
	

         
	}else if(is_threshold %in% no_threshold){

			 chrlabs_data <- read.table(file=inputFile3,header = T,sep = "\t",row.names=1)
             chrlabs_data <- as.matrix(chrlabs_data)
             chrlabs_data <- as.vector(chrlabs_data) 
			 
	p =	({myplot( manhattan(data_gwas,col = col_map,
          suggestiveline = FALSE,
          genomewideline = FALSE,
          highlight = snpsOfInterest,
          annotatePval = annotate_Pval,
          annotateTop = F,
		  chrlabs = chrlabs_data,
		  cex=point_cex, 
		  cex.axis = axis_cex,
		  main =is_main 
		  ))
		  })
	}
		  
		  
		  
		  
}else if(Highlight %in% no_highlight){
       
	      
		  if(is_threshold %in% yes_threshold){
		     
			 chrlabs_data <- read.table(file=inputFile3,header = T,sep = "\t",row.names=1)
             chrlabs_data <- as.matrix(chrlabs_data)
             chrlabs_data <- as.vector(chrlabs_data) 
			 
   p = ({myplot(  manhattan(data_gwas,col = col_map,
          suggestiveline = -log10(suggestive_line),
          genomewideline = FALSE,
          #highlight = snpsOfInterest,
          annotatePval = annotate_Pval,
          annotateTop = F,
		  chrlabs = chrlabs_data,¡£
		  cex=point_cex, 
		  cex.axis = axis_cex,
		  main =is_main 
		  ))
		  })
	 
	 
       
	}else if(is_threshold %in% no_threshold){

			 chrlabs_data <- read.table(file=inputFile3,header = T,sep = "\t",row.names=1)
             chrlabs_data <- as.matrix(chrlabs_data)
             chrlabs_data <- as.vector(chrlabs_data) 
			 
	p = ({myplot( manhattan(data_gwas,col = col_map,
          suggestiveline = FALSE,
          genomewideline = FALSE,
         # highlight = snpsOfInterest,
          annotatePval = annotate_Pval,
          annotateTop = F,
		  chrlabs = chrlabs_data,
		  cex=point_cex, 
		  cex.axis = axis_cex,
		  main =is_main 
		  ))
        })
	}
	
	
  
}else if(Highlight %in% own_highlight){
             
			 
		  if(is_threshold %in% yes_threshold){
		     
			 
			 own_highlight_data <- read.table(file=inputFile2,header = F,sep = "\t")#
             own_highlight_data <- as.matrix(own_highlight_data)
             own_highlight_data <- as.vector(own_highlight_data)
			 
			 chrlabs_data <- read.table(file=inputFile3,header = T,sep = "\t",row.names=1)
             chrlabs_data <- as.matrix(chrlabs_data)
             chrlabs_data <- as.vector(chrlabs_data) 
			 
   p =({myplot(  manhattan(data_gwas,col = col_map,
          suggestiveline = -log10(suggestive_line),
          genomewideline = FALSE,
          highlight = own_highlight_data,
          annotatePval = annotate_Pval,
          annotateTop = F,
		  chrlabs = chrlabs_data,
		  cex=point_cex, 
		  cex.axis = axis_cex,
		  main =is_main 
		  ))
		  })
		  
	
	 }else if(is_threshold %in% no_threshold){
	 
			 own_highlight_data <- read.table(file=inputFile2,header = F,sep = "\t")#
             own_highlight_data <- as.matrix(own_highlight_data)
             own_highlight_data <- as.vector(own_highlight_data)	
			 
			 chrlabs_data <- read.table(file=inputFile3,header = T,sep = "\t",row.names=1)
             chrlabs_data <- as.matrix(chrlabs_data)
             chrlabs_data <- as.vector(chrlabs_data) 
			 
	p =({myplot(	manhattan(data_gwas,col = col_map,
          suggestiveline = FALSE,
          genomewideline = FALSE,
          highlight = own_highlight_data,
          annotatePval = annotate_Pval,
          annotateTop = F,
		  chrlabs = chrlabs_data,
		  cex=point_cex, 
		  cex.axis = axis_cex,
		  main =is_main 
		  ))
         })
		  }
 }

  plotsave(p,file=paste(outputFileName,"svg",sep="."),unit="cm",width=16,height=13,dpi=600)  
	

	   


