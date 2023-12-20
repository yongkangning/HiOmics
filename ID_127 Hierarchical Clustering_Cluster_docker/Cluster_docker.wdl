task task_Cluster_docker {
  String appBinDir
  String RLibPath
  String inputFile
  String dist_method
  String cluster_method
  String cluster_type
  String showlabels
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/Cluster_docker_v.1.0.R ${RLibPath} ${inputFile} ${dist_method} ${cluster_method} ${cluster_type} ${showlabels} ${outputFileName}   
	 >>>

  output {
    File outFile = "${outputFileName}_cluster.svg"
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
  call task_Cluster_docker
  output{
    task_Cluster_docker.outFile
  }
}
