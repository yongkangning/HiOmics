task task_lsfse {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String inputFile3
  String is_use_taxa_num
  String is_use_feature_num
  String outputFileName
  String cluster_config
  String mount_paths  
 
  command <<<
    Rscript ${appBinDir}/lsfse.R ${RLibPath} ${inputFile1} ${inputFile2} ${inputFile3} ${is_use_taxa_num} ${is_use_feature_num} ${outputFileName}
	  >>>

  output {
    File outFile = "${outputFileName}.svg"
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
  call task_lsfse
  output{
    task_lsfse.outFile
  }
}
