version 1.0

task task_Phred64to33 {
  input {
    String inputFile
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    seqtk seq -VQ64 ~{inputFile} | gzip > phred33_result.fq.gz
   
   >>>

  output {
    File outFiles = "phred33_result.fq.gz"
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
  call task_Phred64to33
}