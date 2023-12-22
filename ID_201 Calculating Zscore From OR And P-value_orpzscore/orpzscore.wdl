task task_orpzscore {
  String appBinDir
  String RLibPath
  String OR
  String P
  String outputFileName
  String cluster_config
  String mount_paths
  
  command <<<
   ulimit -s unlimited
    Rscript ${appBinDir}/orpzscore.R ${RLibPath} ${OR} ${P} ${outputFileName}
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
  call task_orpzscore
  output{
    task_orpzscore.outFile
  }
}
