task task_lasso {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String family_model
  String is_alpha
  String outputFileName1
  String outputFileName2
  String outputFileName3
  
  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/lasso_docker_v.1.0.R ${RLibPath} ${inputFile1} ${inputFile2} ${family_model} ${is_alpha} ${outputFileName1} ${outputFileName2} ${outputFileName3}
	 >>>

  output {
    File outFile1 = "${outputFileName1}.svg"
	File outFile2 = "${outputFileName2}.svg"
	File outFile3 = "${outputFileName3}_coef_min.txt"
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
  call task_lasso
  output{
    task_lasso.outFile1
	task_lasso.outFile2
	task_lasso.outFile3
  }
}
