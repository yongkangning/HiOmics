version 1.0

task task_extractSeqName {
  input {
    String fastaFile
    String appDir
    String cluster_config
    String mount_paths
  }

  command <<<

    set -o pipefail
    set -e
    
    ~{appDir}/seqkit seq -n ~{fastaFile} > seqNames.txt

   >>>

  output {
    File outFile = "seqNames.txt"
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
  call task_extractSeqName
}