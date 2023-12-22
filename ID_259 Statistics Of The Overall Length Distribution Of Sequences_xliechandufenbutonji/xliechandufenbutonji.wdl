version 1.0

task task_xliechandufenbutonji {
  input {
    String inputfile
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    seqkit stat ~{inputfile} -o result.txt
    #mkdir result
    #tar -czvf result.tar.gz result
   >>>

  output {
  File outFile = "result.txt"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-samtools-1-15"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 600
  }
}
workflow henbio_wf {
  call task_xliechandufenbutonji
}

