task task_veen {
  String appBinDir
  String RLibPath
  String inputFile
  String percentage
  String alpha
  String textsize
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/venn_docker_v.1.0.R ${RLibPath} ${inputFile} ${percentage} ${alpha} ${textsize} ${outputFileName}
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
  call task_veen
  output{
    task_veen.outFile
  }
}
