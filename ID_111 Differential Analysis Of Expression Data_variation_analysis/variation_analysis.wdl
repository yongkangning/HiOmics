task task_variation_analysis {
  String appBinDir
  String RLibPath
  String inputFile
  String num_tumor
  String num_normal
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  
  command <<<
    Rscript ${appBinDir}/variation_analysis_docker_v1.2.R ${RLibPath} ${inputFile} ${num_tumor} ${num_normal} ${outputFileName}
  >>>

  output {
    File outFile = "${outputFileName}_edgerOut.xls"
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
  call task_variation_analysis
  output{
    task_variation_analysis.outFile
  }
}
