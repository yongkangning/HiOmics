
args = commandArgs(trailingOnly=TRUE)
argsCount = 3

if (length(args)!=argsCount) {
  stop("MR_sensitivity_analysis_docker_v.1.0.R inputFile1 inputFile2 outputFileName")
}

inputFile1 <- args[1]
                     
					 
                     
					 
inputFile2 <- args[2]

outputFileName <- args[3]#
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
#PC_exp_dat <- clump_data(PC_exp_dat)
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


heterogeneity_test <- mr_heterogeneity(dat_PC)
write.csv(heterogeneity_test,file=paste(outputFileName,"mr_heterogeneity_test.csv",sep="_"),row.names = F)

pleiotropy_test <- mr_pleiotropy_test(dat_PC)
write.csv(pleiotropy_test,file=paste(outputFileName,"mr_pleiotropy_test.csv",sep="_"),row.names = F)

res_loo <- mr_leaveoneout(dat_PC)
write.csv(res_loo,file=paste(outputFileName,"mr_leaveoneout_test.csv",sep="_"),row.names = F)

svg(file=paste(outputFileName,"Leaveoneout_analysis.svg",sep="_"),width=12,height=8)
mr_leaveoneout_plot(res_loo)
#p3[[1]]
dev.off()



