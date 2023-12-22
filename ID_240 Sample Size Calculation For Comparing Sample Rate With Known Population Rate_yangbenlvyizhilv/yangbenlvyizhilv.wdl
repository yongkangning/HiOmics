task task_yangbenlvyizhilv {
  String appBinDir
  String RLibPath
  String H
  String sig_level
  String Power
  String outputFileName
  String cluster_config
  String mount_paths

  command <<<
   Rscript ${appBinDir}/yangbenlvyizhilv.R ${RLibPath} ${H} ${sig_level} ${Power} ${outputFileName}
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
  call task_yangbenlvyizhilv
  output{
  task_yangbenlvyizhilv.outFile
  }
}
