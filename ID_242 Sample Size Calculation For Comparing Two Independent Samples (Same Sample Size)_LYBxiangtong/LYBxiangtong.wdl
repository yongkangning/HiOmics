task task_LYBxiangtong {
  String appBinDir
  String RLibPath
  String H
  String power
  String sig_level
  String outputFileName
  String cluster_config
  String mount_paths

  command <<<
   Rscript ${appBinDir}/LYBxiangtong.R ${RLibPath} ${H} ${power} ${sig_level} ${outputFileName}
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
  call task_LYBxiangtong
  output{
  task_LYBxiangtong.outFile
    task_LYBxiangtong.outFile2
  }
}
