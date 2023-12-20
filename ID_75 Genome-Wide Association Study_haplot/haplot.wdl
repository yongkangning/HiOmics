task task_haplot {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String outputFileName
  
  String cluster_config
  String mount_paths
 
  
  command <<<
    Rscript ${appBinDir}/haplot.R ${RLibPath} ${inputFile1} ${inputFile2} ${outputFileName}   
	 >>>

  output {
    File outFile = "${outputFileName}.csv"
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
  call task_haplot
  output{
    task_haplot.outFile
  }
}
