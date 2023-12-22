version 1.0

task task_extractSeqFromBed {
  input {
    String fastaFile
    String bedFile
    String appDir
    String cluster_config
    String mount_paths
  }

  command <<<

    set -o pipefail
    set -e
    
    ~{appDir}/seqkit subseq --bed ~{bedFile} ~{fastaFile} > result.fa

   >>>

  output {
    File outFile = "result.fa"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:debian-latest"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 3600
  }
}
workflow henbio_wf {
  call task_extractSeqFromBed
}