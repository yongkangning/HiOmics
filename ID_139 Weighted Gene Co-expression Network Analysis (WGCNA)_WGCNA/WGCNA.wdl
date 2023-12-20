task task_WGCNA {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String which_type
  String min_modulesize
  String is_TOMcutoff
  String interest_Trait
  String outputFileName1
  String outputFileName2
  String outputFileName3

  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/WGCNA_V1.2.R ${RLibPath} ${inputFile1} ${inputFile2} ${which_type} ${min_modulesize} ${is_TOMcutoff} ${interest_Trait} ${outputFileName1} ${outputFileName2} ${outputFileName3}
	
	mkdir result
	mv ${outputFileName1}* result/
	mv ${outputFileName2}* result/
	mv ${outputFileName3}* result/
	tar -czvf result.tar.gz result
	 >>>

  output {
    File outFile = "result.tar.gz"
  }

 
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:rstudio-r-base-4.2.0-focal"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
      timeout: 18000
  }
}
workflow henbio_wf {
  call task_WGCNA
  output{
    task_WGCNA.outFile
  }
}
