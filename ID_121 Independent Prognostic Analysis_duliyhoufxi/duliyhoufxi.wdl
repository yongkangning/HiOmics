task task_duliyhoufxi {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  
  command <<<
    Rscript ${appBinDir}/FerrLnc18.indep_docker_v.1.1.R ${RLibPath} ${inputFile1} ${inputFile2} ${outputFileName}
  >>>

  output {
    File outFile1 = "${outputFileName}_uniCox.txt"
	File outFile2 = "${outputFileName}_multiCox.txt"
	File outFile3 = "${outputFileName}_uniForest.svg"
	File outFile4 = "${outputFileName}_multiForest.svg"
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
  call task_duliyhoufxi
  output{
    task_duliyhoufxi.outFile1
	task_duliyhoufxi.outFile2
	task_duliyhoufxi.outFile3
	task_duliyhoufxi.outFile4
  }
}
