
args = commandArgs(trailingOnly=TRUE)
.libPaths(args[5])
library(tidyverse)

mRNA_diff <- read_tsv(args[1])
lncRNA_miRNA <- read_tsv(args[2])
miRNA_targetGene <- read_tsv(args[3])
output_dir <- args[4]

# mRNA_diff <- read_tsv("C:/Users/Administrator/Desktop/CeRNA/res/mRNA_diff_expr.tsv")
# lncRNA_miRNA <- read_tsv("C:/Users/Administrator/Desktop/CeRNA/res/lncRNA_miRNA.txt")
# miRNA_targetGene <- read_tsv("C:/Users/Administrator/Desktop/CeRNA/res/miRNA_targetGene.txt")
# output_dir <- "C:/Users/Administrator/Desktop/CeRNA/res"

mRNA_distinct <-  mRNA_diff %>% select(gene_name) %>% distinct()
miRNA_mRNA_intersect <- miRNA_targetGene %>% semi_join(mRNA_distinct, by = c("Gene" = "gene_name")) %>% select(miRNA, Gene)
mRNA_distinct_intersect <- miRNA_mRNA_intersect %>% select(Gene) %>% distinct()
miRNA_distinct <- miRNA_mRNA_intersect %>% select(miRNA) %>% distinct()
lncRNA_distinct <- lncRNA_miRNA %>% semi_join(miRNA_distinct, by = "miRNA") %>% select(lncRNA) %>% distinct()

# lncRNA.txt
write_tsv(lncRNA_distinct, str_c(output_dir, "lncRNA.txt", sep = "/"), col_names = FALSE)
# miRNA.txt
write_tsv(miRNA_distinct, str_c(output_dir, "miRNA.txt", sep = "/"), col_names = FALSE)
# mRNA.txt
write_tsv(mRNA_distinct_intersect, str_c(output_dir, "mRNA.txt", sep = "/"), col_names = FALSE)
# ceRNAtype.txt
lncRNA_temp <- lncRNA_distinct %>%dplyr::rename(gene_name = lncRNA) %>% mutate(type = "lncRNA")
miRNA_temp <- miRNA_distinct %>% dplyr::rename(gene_name = miRNA) %>% mutate(type = "miRNA")
mRNA_temp <- mRNA_distinct_intersect %>% dplyr::rename(gene_name = Gene) %>% mutate(type = "mRNA")
ceRNAtype <- lncRNA_temp %>% union_all(miRNA_temp) %>% union_all(mRNA_temp)
write_tsv(ceRNAtype, str_c(output_dir, "ceRNAtype.txt", sep = "/"), col_names = FALSE)
 
# ceRNA_network.txt
lncRNA_miRNA_node <- lncRNA_miRNA %>%  semi_join(miRNA_distinct, by = "miRNA") %>% dplyr::rename(Node1 = lncRNA, Node2 = miRNA) %>% 
  mutate(Line = "lncRNA")

mRNA_miRNA_node <- miRNA_targetGene %>%  semi_join(mRNA_distinct_intersect, by = "Gene") %>% 
  semi_join(miRNA_distinct, by = "miRNA") %>% select(Gene, miRNA) %>% dplyr::rename(Node1 = Gene, Node2 = miRNA) %>% 
  mutate(Line = "mRNA")
write_tsv(lncRNA_miRNA_node %>% union_all(mRNA_miRNA_node), str_c(output_dir, "ceRNA_network.txt", sep = "/"))
