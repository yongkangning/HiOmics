task task_SampleN {
  String appBinDir
  String RLibPath
  String R
  String sig_level
  String power
  String outputFileName
  String cluster_config
  String mount_paths

  command <<<
   Rscript ${appBinDir}/SampleN.R ${RLibPath} ${R} ${sig_level} ${power} ${outputFileName}
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
  call task_SampleN
  output{
  task_SampleN.outFile
  }
}
