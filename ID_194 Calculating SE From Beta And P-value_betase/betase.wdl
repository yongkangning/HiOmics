task task_betase {
  String appBinDir
  String RLibPath
  String BETA 
  String p
  String outputFileName
  String cluster_config
  String mount_paths
  
  command <<<
   ulimit -s unlimited
    Rscript ${appBinDir}/betase.R ${RLibPath} ${BETA} ${p} ${outputFileName}
	 >>>

  output {
    File outFile = "${outputFileName}.csv"
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
  call task_betase
  output{
    task_betase.outFile
  }
}
