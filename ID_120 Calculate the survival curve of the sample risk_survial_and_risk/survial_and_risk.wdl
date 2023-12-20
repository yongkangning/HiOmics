task task_survial_and_risk {
  String appBinDir
  String RLibPath
  String inputFile
  String is_width
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  
  command <<<
    Rscript ${appBinDir}/FerrLnc16.survival_docker_v.1.0.R ${RLibPath} ${inputFile} ${is_width} ${outputFileName}
  >>>

  output {
    File outFile = "${outputFileName}_survival.svg"
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
  call task_survial_and_risk
  output{
    task_survial_and_risk.outFile
  }
}
