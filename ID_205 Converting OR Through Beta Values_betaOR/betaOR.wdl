task task_betaOR {
  String appBinDir
  String RLibPath
  String BETA
  String outputFileName
  String cluster_config
  String mount_paths
  
  command <<<
   ulimit -s unlimited
    Rscript ${appBinDir}/betaOR.R ${RLibPath} ${BETA} ${outputFileName}
	 >>>

  output {
    File outFile = "${outputFileName}.csv"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-r-base-4-2-0-v1"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 600
  }
}
workflow henbio_wf {
  call task_betaOR
  output{
    task_betaOR.outFile
  }
}
