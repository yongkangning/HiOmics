task task_logistic {
  String appBinDir
  String RLibPath
  String P1
  String OR
  String alpha
  String power
  String outputFileName
  String cluster_config
  String mount_paths

  command <<<
   Rscript ${appBinDir}/logistic.R ${RLibPath} ${P1} ${OR} ${alpha} ${power} ${outputFileName}
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
  call task_logistic
  output{
  task_logistic.outFile
  }
}
