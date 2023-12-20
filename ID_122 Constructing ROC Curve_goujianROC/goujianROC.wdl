task task_goujianROC {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String inputFile3
  String predict_Time
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  
  command <<<
    Rscript ${appBinDir}/FerrLnc21.ROC_docker_v.1.0.R ${RLibPath} ${inputFile1} ${inputFile2} ${inputFile3} ${predict_Time} ${outputFileName}
  >>>

  output {
    File outFile1 = "${outputFileName}_ROC.svg"
	File outFile2 = "${outputFileName}_clinicalROC.svg"
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
  call task_goujianROC
  output{
    task_goujianROC.outFile1
	task_goujianROC.outFile2
  }
}
