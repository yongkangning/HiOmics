task task_HZTXT {
  String appBinDir
  String RLibPath
  String inputFile1
  String is_col
  String outputFileName
  String cluster_config
  String mount_paths  
 
  command <<<
    Rscript ${appBinDir}/HZTXT.R ${RLibPath} ${inputFile1} ${is_col} ${outputFileName}
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
  call task_HZTXT
  output{
    task_HZTXT.outFile
  }
}
