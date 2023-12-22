task task_unicellular {
  String appBinDir
  String inputFile1
  String inputFile2
  String need_group
  String inputFile3
  String need_surv
  String inputFile4
  String x_label
  String cluster_config
  String mount_paths
 
  command <<<
    Rscript ${appBinDir}/unicellular.R ${inputFile1} ${inputFile2} ${need_group} ${inputFile3} ${need_surv} ${inputFile4} ${x_label}
    mkdir result
		mv $ *.pdf result/
		mv $ *.csv result/
    tar -czvf result.tar.gz result
    >>>


  output {
	  File outFile = "result.tar.gz"
      #File outFile1 = "CIBERSORT_result_expression.csv"
	  #File outFile2= "celltype_ratio.pdf"
  }
 
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:r-immunedeconv-v2"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 720000
  }
}
workflow henbio_wf {
  call task_unicellular
  output{
    task_unicellular.outFile
	#task_unicellular.outFile2
  }
}
