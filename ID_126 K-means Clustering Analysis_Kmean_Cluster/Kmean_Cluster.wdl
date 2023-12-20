task task_Kmean_Cluster {
  String appBinDir
  String RLibPath
  String inputFile
  String dist_method
  String cluster_method
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/kmean_Cluster.R ${RLibPath} ${inputFile} ${dist_method} ${cluster_method} ${outputFileName}   
	 >>>

  output {
    File outFile1 = "${outputFileName}_number_cluster.svg"
	File outFile2 = "${outputFileName}_optimum_cluster.svg"
	File outFile3 = "${outputFileName}_Cluster_PCA.svg"
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
  call task_Kmean_Cluster
  output{
    task_Kmean_Cluster.outFile1
	task_Kmean_Cluster.outFile2
	task_Kmean_Cluster.outFile3
  }
}
