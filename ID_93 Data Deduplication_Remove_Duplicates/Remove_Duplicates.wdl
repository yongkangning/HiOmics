task task_Remove_Duplicates {
  String appBinDir
  String RLibPath
  String inputFile
  String r_clunm
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/remove_duplicates_docker_v.1.2.R ${RLibPath} ${inputFile} ${r_clunm} ${outputFileName}   
	 >>>

  output {
    File outFile = "${outputFileName}.txt"
  }


 
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:rstudio-r-base-4.2.0-focal"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: true
    timeout: 600
  }
}
workflow henbio_wf {
  call task_Remove_Duplicates
  output{
    task_Remove_Duplicates.outFile
  }
}
