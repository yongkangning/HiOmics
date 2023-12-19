task task_PCA {
  String appBinDir
  String RLibPath
  String inputFile
  String inputFile2
  String is_scale
  String Title
  String outputFile
  String outPutFileType
  
  String cluster_config
  String mount_paths

  command <<<
    Rscript ${appBinDir}/PCA_docker.R ${RLibPath} ${inputFile} ${inputFile2} ${is_scale} ${Title} ${outputFile} ${outPutFileType}
  >>>

  output {
    File outFile = "${outputFile}.${outPutFileType}"
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
  call task_PCA
  output{
    task_PCA.outFile
  }
}