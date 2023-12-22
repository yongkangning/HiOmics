task task_PCANMDS {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String outputFileName1
  String outputFileName3
  String outputFileName4
  
  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/PCANMDS.R ${RLibPath} ${inputFile1} ${inputFile2} ${outputFileName1} ${outputFileName3} ${outputFileName4}
	 >>>

  output {
    File outFile1 = "${outputFileName1}.svg"
	File outFile3 = "${outputFileName3}.svg"
	File outFile4 = "${outputFileName4}.svg"
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
  call task_PCANMDS
  output{
    task_PCANMDS.outFile1
	task_PCANMDS.outFile3
	task_PCANMDS.outFile4
  }
}
