task task_between_cor_analysis {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String inputFile3
  String cor_method
  String in_pstar
  String x_title
  String y_title
  String plot_title
  String legend_title
  String outputFileName
  
  String cluster_config
  String mount_paths
 
  
  command <<<
    Rscript ${appBinDir}/Correlation_between_cor_analysis_inputpstar_docker_v.1.0.R ${RLibPath} ${inputFile1} ${inputFile2} ${inputFile3} ${cor_method} ${in_pstar} ${x_title} ${y_title} ${plot_title} ${legend_title} ${outputFileName} 
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
  call task_between_cor_analysis
  output{
    task_between_cor_analysis.outFile
  }
}
