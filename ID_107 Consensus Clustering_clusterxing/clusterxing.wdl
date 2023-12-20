task task_clusterxing {
  String appBinDir
  String RLibPath
  String inputFile
  String clusterNum
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/clusterxing.R ${RLibPath} ${inputFile} ${clusterNum} ${outputFileName}
	 >>>

  output {
    File outFile = "${outputFileName}_cluster.txt"
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
  call task_clusterxing
  output{
    task_clusterxing.outFile
  }
}
