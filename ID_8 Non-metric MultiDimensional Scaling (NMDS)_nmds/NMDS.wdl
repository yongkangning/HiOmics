task task_NMDS {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String bray
  String is_alpha
  String outputFile
  String outPutFileType
  
  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/NMDS_docker.R ${RLibPath} ${inputFile1} ${inputFile2} ${bray} ${is_alpha} ${outputFile} ${outPutFileType}
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
  call task_NMDS
  output{
    task_NMDS.outFile
  }
}
