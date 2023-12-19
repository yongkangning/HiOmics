task task_seqFilterByLength {
  String appBinDir
  String inputFile
  String outputFile
  String minLen
  String maxLen
  
  String cluster_config
  String mount_paths

  
  command <<<
    ${appBinDir}/seqFilterByLength_v1.0 ${inputFile} ${outputFile} ${minLen} ${maxLen}
  >>>

  output {
    File outFile = "${outputFile}"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:debian-latest"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 600
  }
}
workflow henbio_wf {
  call task_seqFilterByLength
  output{
    task_seqFilterByLength.outFile
  }
}
