task task_MR {
  String appBinDir
  String inputFile1
  String inputFile2
  String inputFile3 
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/MR_docker_v.1.3.R ${inputFile1} ${inputFile2} ${inputFile3} ${outputFileName}
	 >>>

  output {
    File outFile1 = "${outputFileName}_harmonise_data.csv"
	File outFile2 = "${outputFileName}_mr_data.csv"
	File outFile3 = "${outputFileName}_scatter_plot.svg"
	File outFile4 = "${outputFileName}_forest.svg"
	File outFile5 = "${outputFileName}_funnel.svg"
  }
 
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-twosamplemr-v1"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: true
    timeout: 600
  }
}
workflow henbio_wf {
  call task_MR
  output{
    task_MR.outFile1
	task_MR.outFile2
	task_MR.outFile3
	task_MR.outFile4
	task_MR.outFile5
  }
}
