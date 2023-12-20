
args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("MR_docker_v.1.3.R inputFile1 inputFile2 inputFile3 outputFileName")
}

inputFile1 <- args[1]
                     
					 
                     
					 
inputFile2 <- args[2]
inputFile3 <- args[3]

outputFileName <- args[4]##
if (is.na(outputFileName)) {
  outputFileName <- "result"
}


library(TwoSampleMR)
library(myplot)
#PC_file <- system.file("extdata", "inflammatory3.txt", package="TwoSampleMR")

PC_exp_dat <- read_exposure_data(filename = inputFile1,clump =F,
                                 sep= "\t",
                                 snp_col = "SNP",# rs ID
                                 beta_col = "beta",
                                 se_col = "se",
                                 effect_allele_col ="effect_allele",
                                 #other_allele_col = "other_allele",
                                 #eaf_col = "effect_allele_freq",
                                 #pval_col = "pval"
								 )
#PC_exp_dat <- clump_data(PC_exp_dat)#clump_data()������ȥ��������ƽ��
PC_outcome_dat <- read_outcome_data(
    filename = inputFile2, 
  snps = PC_exp_dat$SNP,       
  sep = "\t",    
  snp_col = "SNP",    
  beta_col = "beta",    
  se_col = "se",    
  effect_allele_col = "effect_allele",
 # other_allele_col = "other_allele",
 # pval_col = "pval",    
)

dat_PC <- harmonise_data(exposure_dat = PC_exp_dat,
                        PC_outcome_dat)
write.csv(dat_PC,file=paste(outputFileName,"harmonise_data.csv",sep="_"),row.names = F)



#method <- fromJSON(file = inputFile3)
#method <- as.matrix(method)
#method=subset(method,method[,1]==TRUE)
#method <- as.vector(row.names(method))
method <- inputFile3
method=strsplit(inputFile3,",")[[1]]
method <- as.vector(method)
res_PC <- mr(dat_PC,method_list=method)
write.csv(res_PC,file=paste(outputFileName,"mr_data.csv",sep="_"),row.names = F)



  svg(file=paste(outputFileName,"scatter_plot.svg",sep="_"),width=12,height=8)
#p1 <- myplot({mr_scatter_plot(res_PC, dat_PC)})
mr_scatter_plot(res_PC, dat_PC)
#plotsave(p1,file=paste(outputFileName1,"svg",sep="."),unit="cm",width=15,height=15,dpi=600)
dev.off()


res_single <- mr_singlesnp(dat_PC)
  svg(file=paste(outputFileName,"forest.svg",sep="_"),width=12,height=8)
#p2 <- myplot({mr_forest_plot(res_single)})
mr_forest_plot(res_single)
#plotsave(p2,file=paste(outputFileName2,"svg",sep="."),unit="cm",width=15,height=15,dpi=600)
dev.off()


res_single <- mr_singlesnp(dat_PC)

  svg(file=paste(outputFileName,"funnel.svg",sep="_"),width=12,height=8)
#p3 <- myplot({mr_funnel_plot(res_single)})
mr_funnel_plot(res_single)
#plotsave(p3,file=paste(outputFileName3,"svg",sep="."),unit="cm",width=15,height=15,dpi=600)

dev.off()
