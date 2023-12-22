task task_junshuchayi {
  String appBinDir
  String RLibPath
  String D
  String sig_level
  String power
  String outputFileName
  String cluster_config
  String mount_paths

  command <<<
   Rscript ${appBinDir}/junshuchayi.R ${RLibPath} ${D} ${sig_level} ${power} ${outputFileName}
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
  call task_junshuchayi
  output{
  task_junshuchayi.outFile
  }
}
