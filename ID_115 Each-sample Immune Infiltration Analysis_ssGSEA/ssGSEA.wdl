task task_ssGSEA {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String inputFile3
  String facet_ncol
  String pvlaue_size
  String facet_size
  String outputFileName1
  String outputFileName2
  String outputFileName3
  
  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/ssGSEA_docker_v.1.0.R ${RLibPath} ${inputFile1} ${inputFile2} ${inputFile3} ${facet_ncol} ${pvlaue_size} ${facet_size} ${outputFileName1} ${outputFileName2} ${outputFileName3} 
	 >>>

  output {
    File outFile1 = "${outputFileName1}.svg"
	File outFile2 = "${outputFileName2}.svg"
	File outFile3 = "${outputFileName3}.svg"
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
  call task_ssGSEA
  output{
    task_ssGSEA.outFile1
	task_ssGSEA.outFile2
	task_ssGSEA.outFile3
  }
}
