version 1.0

task task_extractSeqbyId {
  input {
    String inputFile
    String idFile
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    filename=$(basename ~{inputFile})
    suffix=${filename##*.}
    if [ "${suffix}" == "gz" ]
    then
      echo "This a gz file"
      zcat ~{inputFile} | seqkit grep -f ~{idFile} > result.fa
    else
      echo "This is a ungz file."
      cat ~{inputFile} | seqkit grep -f ~{idFile} > result.fa
    fi
    gzip result.fa
    
   >>>

  output {
    File outFile = "result.fa.gz"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-toolkits-1-0"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 7200
  }
}
workflow henbio_wf {
  call task_extractSeqbyId
}