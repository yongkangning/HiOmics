task task_LYBbutong {
  String appBinDir
  String RLibPath
  String H
  String N1
  String power
  String sig_level
  String outputFileName
  String cluster_config
  String mount_paths

  command <<<
   Rscript ${appBinDir}/LYBbutong.R ${RLibPath} ${H} ${N1} ${power} ${sig_level} ${outputFileName}
	 >>>

  output {
    File outFile = "${outputFileName}.csv"
    File outFile2 = "${outputFileName}.pdf"
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
  call task_LYBbutong
  output{
  task_LYBbutong.outFile
  }
}
