task task_betasezscore {
  String appBinDir
  String RLibPath
  String BETA
  String SE
  String outputFileName
  String cluster_config
  String mount_paths
  
  command <<<
   ulimit -s unlimited
    Rscript ${appBinDir}/betasezscore.R ${RLibPath} ${BETA} ${SE} ${outputFileName}
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
  call task_betasezscore
  output{
    task_betasezscore.outFile
  }
}
