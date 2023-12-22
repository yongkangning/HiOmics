task task_jitter_plot {
  String appBinDir
  String RLibPath
  String inputFile
  String jitter_width
  String point_size
  String errorbar_size
  String x_title
  String y_title
  String is_title
  String outputFileName
  String cluster_config
  String mount_paths

  command <<<
   Rscript ${appBinDir}/jitter_plot.R ${RLibPath} ${inputFile} ${jitter_width} ${point_size} ${errorbar_size} ${x_title} ${y_title} ${is_title} ${outputFileName}
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
  call task_jitter_plot
  output{
  task_jitter_plot.outFile
  }
}
