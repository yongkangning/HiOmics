version 1.0

task task_xiantongxlie {
  input {
    String inputfile1
    String inputfile2
    String type
    String resultFlie = "common_" + basename(inputfile1)
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    seqkit common ~{inputfile1} ~{inputfile2} ~{type} ~{resultFlie}
    #mkdir result
    #tar -czvf result.tar.gz result
   >>>

  output {
  File outFile = resultFlie
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
  call task_xiantongxlie
}
