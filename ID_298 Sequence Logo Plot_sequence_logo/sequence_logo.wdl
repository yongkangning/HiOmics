task task_sequence_logo {
  String appBinDir
  String RLibPath
  String inputFile
  String is_col
  String is_method
  String outputFileName
  String cluster_config
  String mount_paths

  command <<<
   Rscript ${appBinDir}/sequence_logo.R ${RLibPath} ${inputFile} ${is_col} ${is_method} ${outputFileName}
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
  call task_sequence_logo
  output{
  task_sequence_logo.outFile
  }
}
