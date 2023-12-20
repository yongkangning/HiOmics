task task_CheckGene {
  String appBinDir
  String RLibPath
  String inputFile
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/CheckGene_docker_v.1.0.R ${RLibPath} ${inputFile} ${outputFileName}
	 >>>

  output {
    File outFile = "${outputFileName}.csv"
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
  call task_CheckGene
  output{
    task_CheckGene.outFile
  }
}
