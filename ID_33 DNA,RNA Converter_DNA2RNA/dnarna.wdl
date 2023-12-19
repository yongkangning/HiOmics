task task_dnarna {
  String appBinDir
  String inputFile
  String outputFile
  
  String cluster_config
  String mount_paths
  
  command <<<
    ${appBinDir}/DNA2RNA_v1.0 ${inputFile} ${outputFile} 
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
  call task_dnarna
  output{
    task_dnarna.outFile
  }
}
