task task_TMB {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String fs_size
  String oncoplot_top
  String is_clinicalFeatures
  String draw_titv
  String outputFileName1
  String outputFileName2
  String outputFileName3
  String outputFileName4
  
  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/tmb_analysis_docker_v.1.0.r ${RLibPath} ${inputFile1} ${inputFile2} ${fs_size} ${oncoplot_top} ${is_clinicalFeatures} ${draw_titv} ${outputFileName1} ${outputFileName2} ${outputFileName3} ${outputFileName4} 
	 >>>

  output {
    File outFile1 = "${outputFileName1}.svg"
	File outFile2 = "${outputFileName2}.svg"
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
  call task_TMB
  output{
    task_TMB.outFile1
	task_TMB.outFile2
	task_TMB.outFile3
	task_TMB.outFile4
  }
}
