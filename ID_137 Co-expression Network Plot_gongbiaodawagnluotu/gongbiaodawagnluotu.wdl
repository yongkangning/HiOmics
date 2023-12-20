task task_gongbiaodawagnluotu {
  String appBinDir
  String RLibPath
  String inputFile
  String is_method
  String is_cor
  String is_pvalue
  String is_label
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  command <<<  
    Rscript ${appBinDir}/gongbiaodawagnluotu_docker.R ${RLibPath} ${inputFile} ${is_method} ${is_cor} ${is_pvalue} ${is_label} ${outputFileName}   
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
  call task_gongbiaodawagnluotu
  output{
    task_gongbiaodawagnluotu.outFile
  }
}
