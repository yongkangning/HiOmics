task task_liexianbiao {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  
  command <<<
    Rscript ${appBinDir}/FerrLnc22.Nomo_docker_v1.0.R ${RLibPath} ${inputFile1} ${inputFile2} ${outputFileName}
  >>>

  output {
    File outFile = "${outputFileName}_res.cox.pdf"
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
  call task_liexianbiao
  output{
    task_liexianbiao.outFile
  }
}
