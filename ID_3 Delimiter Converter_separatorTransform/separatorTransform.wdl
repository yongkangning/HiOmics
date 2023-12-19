task task_separatorTransform {
  String appBinDir
  String inputFile
  String outputFile
  String oldSeparator
  String newSeparator
  
  String cluster_config
  String mount_paths

  command <<<
  
    ${appBinDir}/separatorTransform_v1.0 ${inputFile} ${outputFile} ${oldSeparator} ${newSeparator}
	
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
  call task_separatorTransform
  output{
    task_separatorTransform.outFile
  }
}