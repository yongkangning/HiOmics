version 1.0

task task_mergePairend {
  input {
    String read1File
    String read2File
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    seqtk mergepe ~{read1File} ~{read2File} | gzip > result.fq.gz
   >>>

  output {
    File outFile = "result.fq.gz"
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
  call task_mergePairend
}