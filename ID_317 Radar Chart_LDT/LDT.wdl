task task_LDT {
  String appBinDir
  String RLibPath
  String inputFile
  String cluster_config
  String mount_paths
 
  command <<<
    Rscript ${appBinDir}/LDT.R ${RLibPath} ${inputFile}
	  >>>

  output {
    File outFile = "LDT.pdf"
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
  call task_LDT
  output{
    task_LDT.outFile
  }
}
