version 1.0

task task_renameSeqId {
  input {
    String inputFile
    String addString
    String position
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    if [ "~{position}" == "begin" -a "${suffix}" != "gz" ]; then
      cat ~{inputFile} | seqkit replace -p "^" -r "~{addString}" > result.fa
    elif [ "~{position}" == "begin" -a "${suffix}" == "gz" ]; then
      zcat ~{inputFile} | seqkit replace -p "^" -r "~{addString}" > result.fa
    elif [ "~{position}" == "end" -a "${suffix}" != "gz" ]; then
      cat ~{inputFile} | seqkit replace -p "$" -r "~{addString}" > result.fa
    elif [ "~{position}" == "end" -a "${suffix}" == "gz" ]; then
      zcat ~{inputFile} | seqkit replace -p "$" -r "~{addString}" > result.fa
    fi
   
   >>>

  output {
    File outFile = "result.fa"
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
  call task_renameSeqId
}