task task_tumor_microenvironment {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String is_method
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/tumor_microenvironment_docker_v.1.0.R ${RLibPath} ${inputFile1} ${inputFile2} ${is_method} ${outputFileName} 
	 >>>

  output {
    File outFile = "${outputFileName}.svg"
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
  call task_tumor_microenvironment
  output{
    task_tumor_microenvironment.outFile
  }
}
