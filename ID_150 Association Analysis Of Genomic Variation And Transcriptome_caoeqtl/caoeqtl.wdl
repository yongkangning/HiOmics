task task_caoeqtl {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String inputFile3
  String usemodel
  String pvOutputThreshold
  String outputFileName
  String cluster_config
  String mount_paths

 
  command <<<
   Rscript ${appBinDir}/eQTL_docker_v1.1.R ${RLibPath} ${inputFile1} ${inputFile2} ${inputFile3} ${usemodel} ${pvOutputThreshold} ${outputFileName}

mkdir result
mv ${outputFileName}* result/
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
    timeout: 600
  }
}
workflow henbio_wf {
  call task_caoeqtl
  output{
    task_caoeqtl.outFile
  }
}