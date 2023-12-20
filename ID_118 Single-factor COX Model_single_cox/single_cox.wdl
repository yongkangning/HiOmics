task task_single_cox {
  String appBinDir
  String RLibPath
  String inputFile
  String P_fileter
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  
  command <<<
    Rscript ${appBinDir}/FerrLnc14.uniCox_docker_v.1.0.R ${RLibPath} ${inputFile} ${P_fileter} ${outputFileName}
  >>>

  output {
    File outFile1 = "${outputFileName}_uniCox.txt"
	File outFile2 = "${outputFileName}_uniSigExp.txt"
	File outFile3 = "${outputFileName}_forest.svg"
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
  call task_single_cox
  output{
    task_single_cox.outFile1
	task_single_cox.outFile2
	task_single_cox.outFile3
  }
}
