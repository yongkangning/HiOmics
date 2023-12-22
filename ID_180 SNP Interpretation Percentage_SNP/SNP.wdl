task task_SNP {
  String appBinDir
  String RLibPath
  String inputFile
  String name_beta
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/SNP.R ${RLibPath} ${inputFile} ${name_beta} ${outputFileName}
    >>>

  output {
    File outFile = "${outputFileName}.txt"
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
  call task_SNP
  output{
    task_SNP.outFile
  }
}
