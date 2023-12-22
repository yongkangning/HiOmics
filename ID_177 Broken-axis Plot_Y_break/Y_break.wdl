task task_Y_break {
  String appBinDir
  String RLibPath
  String inputFile
  String xdata
  String ydata
  String is_group
  String y_min
  String y_max
  String x_title
  String y_title
  String plot_title
  String outputFileName
  String cluster_config
  String mount_paths
  
  command <<<  
    set -o pipefail
    set -e
    Rscript ${appBinDir}/Y_break.R ${RLibPath} ${inputFile} ${xdata} ${ydata} ${is_group} ${y_min} ${y_max} ${x_title} ${y_title} ${plot_title} ${outputFileName} 
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
  call task_Y_break
  output{
    task_Y_break.outFile
  }
}
