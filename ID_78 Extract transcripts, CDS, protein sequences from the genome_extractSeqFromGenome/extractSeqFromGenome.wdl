version 1.0

task task_extractSeqFromGenome {
  input {
    String geneFile
    String gffFile
    String seqType # transcripts cds protein all
    String cluster_config
    String mount_paths
  }

  command <<<

    set -o pipefail
    set -e

    source activate cufflinks
    if [ "~{seqType}" == "transcripts" ]; then
      gffread ~{gffFile} -g ~{geneFile} -w transcripts.fa
    elif [ "~{seqType}" == "cds" ]; then
      gffread ~{gffFile} -g ~{geneFile} -x cds.fa
    elif [ "~{seqType}" == "protein" ]; then
      gffread ~{gffFile} -g ~{geneFile} -y protein.fa
    elif [ "~{seqType}" == "all" ]; then
      gffread ~{gffFile} -g ~{geneFile} -w transcripts.fa
      gffread ~{gffFile} -g ~{geneFile} -x cds.fa
      gffread ~{gffFile} -g ~{geneFile} -y protein.fa
    else
      echo "seqType must be one of transcripts cds protein all."
      exit 111
    fi
    tar -zcvf result.fa.tar.gz *.fa

   >>>

  output {
    File outFile = "result.fa.tar.gz"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-transform-tools-v2-0"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 600
  }
}
workflow henbio_wf {
  call task_extractSeqFromGenome
}