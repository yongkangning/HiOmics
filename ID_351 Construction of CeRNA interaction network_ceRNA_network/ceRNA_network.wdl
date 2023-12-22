version 1.0

task task_ceRNA_network {
  input {
    String gene_count_file
    String group_file
    String log2FC
    String p_value
    String ceRNA_db
    String RLibPath

    String cluster_config
    String mount_paths
  }
  command <<<
    set -oe pipefail
    
    Rscript ~{ceRNA_db}/bin/getBioTypeAndDiff.R ~{gene_count_file} ~{ceRNA_db}/db/genetype.txt ~{group_file} ./ ~{log2FC} ~{p_value} ~{RLibPath}
    tail -n+2 lncRNA_diff_expr.tsv |  cut -f1 | sort | uniq > lncRNA_diff.txt
    
    python3 ~{ceRNA_db}/bin/get_lncRAN_miRNA.py lncRNA_diff.txt ~{ceRNA_db}/db/mircode.txt lncRNA_miRNA.txt
    
    python3 ~{ceRNA_db}/bin/get_target_gene.py lncRNA_miRNA.txt ~{ceRNA_db}/db miRNA_targetGene.txt
    
    Rscript  ~{ceRNA_db}/bin/ceRNANetwork.R mRNA_diff_expr.tsv lncRNA_miRNA.txt miRNA_targetGene.txt ./ ~{RLibPath}
  >>>

  output {
    File mRNAFile = "mRNA.txt"
    File lncRNAFile = "lncRNA.txt"
    File miRNAFile = "miRNA.txt"
    File ceRNAtypeFile = "ceRNAtype.txt"
    File networkFile = "ceRNA_network.txt"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-r-base-4-2-0-v1"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: true
    timeout: 3600
  }
}
workflow henbio_wf {
  call task_ceRNA_network
}