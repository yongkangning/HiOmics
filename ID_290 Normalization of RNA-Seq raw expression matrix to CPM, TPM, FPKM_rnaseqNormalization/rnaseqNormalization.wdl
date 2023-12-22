version 1.0

task task_rnaseqNormalization {
  input {
    String readCountFile
    String appDir
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    
    ~{appDir}/datacheck_v1.0 -c true -d true -i ~{readCountFile} -o gene_count.tsv

    
    cat gene_count.tsv | ~{appDir}/csvtk_v1.0 -t cut -f 1,2 | ~{appDir}/csvtk_v1.0 -t rename -f 1 -n FEATURE_ID >  gene_length.tsv
    cat gene_count.tsv | ~{appDir}/csvtk_v1.0 -t cut -f 1,3- | ~{appDir}/csvtk_v1.0 -t rename -f 1 -n FEATURE_ID > reads_count.tsv

    
    rnanorm reads_count.tsv \
      --gene-lengths=gene_length.tsv \
      --fpkm-output=gene_count_fpkm.tsv \
      --cpm-output=gene_count_cpm.tsv \
      --tpm-output=gene_count_tpm.tsv

    
   >>>

  output {
    Array[File] outFiles = ["gene_count_fpkm.tsv", "gene_count_cpm.tsv", "gene_count_tpm.tsv"]
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:rnanorm-v1"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 900
  }
}
workflow henbio_wf {
  call task_rnaseqNormalization
}