task task_pvalue_adjust {
  String appBinDir
  String RLibPath
  String inputFile
  String method
  String outputFileName
  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/code.R ${RLibPath} ${inputFile} ${method} ${outputFileName} 
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
  call task_pvalue_adjust
  output{
    task_pvalue_adjust.outFile
  }
}
