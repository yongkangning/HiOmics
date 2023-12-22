task task_duozudanyinsu {
  String appBinDir
  String RLibPath
  String F
  String K
  String power
  String sig_level
  String outputFileName
  String cluster_config
  String mount_paths

  command <<<
   Rscript ${appBinDir}/duozudanyinsu.R ${RLibPath} ${F} ${K} ${power} ${sig_level} ${outputFileName}
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
  call task_duozudanyinsu
  output{
  task_duozudanyinsu.outFile
  }
}
