task task_jiajihua {
  String appBinDir
  String inputFile1
  String inputFile2
  String labrow
  String cluster_config
  String mount_paths

  command <<<
    Rscript ${appBinDir}/jiajihua_docker_v.1.1.R ${inputFile1} ${inputFile2} ${labrow}  
	
	mkdir result
	cp *.xls result/
	cp *.pdf result/

	tar -czvf result.tar.gz result
	 >>>

  output {
    File outFile = "result.tar.gz"
  }

 
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:methylation-analysis-v1"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 600
  }
}
workflow henbio_wf {
  call task_jiajihua
  output{
    task_jiajihua.outFile
  }
}