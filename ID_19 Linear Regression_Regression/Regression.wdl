task task_Regression {
  String appBinDir
  String RLibPath
  String inputFile
  String point_s
  String x_title
  String y_title
  String plot_title
  String is_method
  String is_se
  String outputFileName
  
  String cluster_config
  String mount_paths
  

   command <<<
    Rscript ${appBinDir}/Linear_Regression-docker.R ${RLibPath} ${inputFile} ${point_s} ${x_title} ${y_title} ${plot_title} ${is_method} ${is_se} ${outputFileName} 
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
  call task_Regression
  output{
    task_Regression.outFile
  }
}
