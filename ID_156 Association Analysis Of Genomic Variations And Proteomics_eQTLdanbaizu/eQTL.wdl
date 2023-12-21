task task_eQTL {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String inputFile3
  String usemodel
  String pvOutputThreshold
  String outputFileName
  
  String cluster_config
  String mount_paths
 
  command <<<
   Rscript ${appBinDir}/eQTL_dockerdanbaizhu_v1.1.R ${RLibPath} ${inputFile1} ${inputFile2} ${inputFile3} ${usemodel} ${pvOutputThreshold} ${outputFileName}
	 >>>

  output {
    File outFile1 = "${outputFileName}.svg"
	File outFile2 = "${outputFileName}_protin.txt"
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
  call task_eQTL
  output{
    task_eQTL.outFile1
	task_eQTL.outFile2
  }
}

