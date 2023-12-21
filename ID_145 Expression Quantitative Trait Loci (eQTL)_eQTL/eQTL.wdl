task task_eQTL {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String inputFile3
  String usemodel
  String input_snpspos_genepos
  String inputFile4
  String inputFile5
  String pvOutputThreshold
  String tra_pvOutputThreshold
  String cis_pvOutputThreshold
  String outputFileName
  String cluster_config
  String mount_paths

 
  command <<<
   Rscript ${appBinDir}/eQTL_dockerxing.R ${RLibPath} ${inputFile1} ${inputFile2} ${inputFile3} ${usemodel} ${input_snpspos_genepos} ${inputFile4} ${inputFile5} ${pvOutputThreshold} ${tra_pvOutputThreshold} ${cis_pvOutputThreshold} ${outputFileName}

mkdir result
mv ${outputFileName}* result/
tar -czvf result.tar.gz result
	 >>>

  output {
    File outFile =  "result.tar.gz"
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
  call task_eQTL
  output{
    task_eQTL.outFile
  }
}