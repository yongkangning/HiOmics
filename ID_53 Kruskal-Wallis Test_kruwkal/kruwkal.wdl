task task_kruwkal {
  String appBinDir
  String RLibPath
  String inputFile
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/kruwkal_docker.R ${RLibPath} ${inputFile} ${outputFileName} 
	 >>>

  output {
    File outFile = "${outputFileName}.txt"
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
  call task_kruwkal
  output{
    task_kruwkal.outFile
  }
}
