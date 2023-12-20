task task_mult_cox {
  String appBinDir
  String RLibPath
  String inputFile
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/FerrLnc15.model_docker.R ${RLibPath} ${inputFile} ${outputFileName}
  >>>

  output {
    File outFile1 = "${outputFileName}_multiCox.txt"
	File outFile2 = "${outputFileName}_risk.txt"
  }


  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:rstudio-r-base-4.2.0-focal"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 10800
  }
}
workflow henbio_wf {
  call task_mult_cox
  output{
    task_mult_cox.outFile1
	task_mult_cox.outFile2
  }
}
