task task_fisher {
  String appBinDir
  String RLibPath
  String inputFile
  String outputFile
  String outPutFileType
  
  String cluster_config
  String mount_paths

  
  command <<<
    Rscript ${appBinDir}/fisher_test_docker.R ${RLibPath} ${inputFile} ${outputFile} ${ outPutFileType} 
	 >>>

  output {
    File outFile = "${outputFile}.${outPutFileType}"
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
  call task_fisher
  output{
    task_fisher.outFile
  }
}
