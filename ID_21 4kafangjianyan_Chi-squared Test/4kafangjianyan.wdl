task task_4kafangjianyan {
  String appBinDir
  String RLibPath
  String inputFile
  String outputFileName
  
  String cluster_config
  String mount_paths

  command <<<
    Rscript ${appBinDir}/chisq_test_docker.R ${RLibPath} ${inputFile} ${outputFileName}
  >>>

  output {
    File outFile1 = "${outputFileName}_chisq$stdres.txt"
   	File outFile2 = "${outputFileName}_chisq$residuals.txt"
    File outFile3 = "${outputFileName}_chisq$expected.txt"
  	File outFile4 = "${outputFileName}_chisq.test_result.txt"
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
  call task_4kafangjianyan
  output{
    task_4kafangjianyan.outFile1
	  task_4kafangjianyan.outFile2
	  task_4kafangjianyan.outFile3
    task_4kafangjianyan.outFile4
  }
}