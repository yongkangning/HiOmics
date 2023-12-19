task task_sequenceLength {
  String appBinDir
  String inputFile
  String outputFile
  
  String cluster_config
  String mount_paths

  command <<<
    ${appBinDir}/sequenceLength ${inputFile} ${outputFile} 
  >>>

   output {
    File outFile = "${outputFile}"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:rstudio-r-base-4.2.0-focal"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 600
  }
}
workflow henbio_wf {
  call task_sequenceLength
  output{
    task_sequenceLength.outFile
  }
}
