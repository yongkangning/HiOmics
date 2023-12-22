task task_scRNA_signature {
  String appBinDir
  String RLibPath
  String inputFile
  String cluster_config
  String mount_paths
 
  command <<<
    Rscript ${appBinDir}/scRNA_signature.R ${RLibPath} ${inputFile}
    #mkdir result
    #tar -czvf result.tar.gz result
    >>>


  output {
      #File outFile = "result.tar.gz"
	  File outFile = "scRNA_signature_matrix.csv"
  }
 
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:singlecell-1-6-v2"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 3600
  }
}
workflow henbio_wf {
  call task_scRNA_signature
  output{
    task_scRNA_signature.outFile
  }
}
