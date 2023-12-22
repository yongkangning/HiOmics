task task_sankey {
  String appBinDir
  String RLibPath
  String inputFile
  String stratum_width
  String is_alpha
  String text_size
  String x_size
  String plot_title
  String outputFileName
  String cluster_config
  String mount_paths

  command <<<
   Rscript ${appBinDir}/sankey_docker_v.1.1.R ${RLibPath} ${inputFile} ${stratum_width} ${is_alpha} ${text_size} ${x_size} ${plot_title} ${outputFileName}
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
  call task_sankey
  output{
  task_sankey.outFile
  }
}
