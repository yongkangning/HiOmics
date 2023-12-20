task task_Cox {
  String appBinDir
  String RLibPath
  String inputFile
  String is_fontsize
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/Cox_docker_v.1.0.R ${RLibPath} ${inputFile} ${is_fontsize} ${outputFileName}
	 >>>

  output {
    File outFile1 = "${outputFileName}_multiCox.txt"
	File outFile2 = "${outputFileName}.svg"
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
  call task_Cox
  output{
    task_Cox.outFile1
	task_Cox.outFile2
  }
}
