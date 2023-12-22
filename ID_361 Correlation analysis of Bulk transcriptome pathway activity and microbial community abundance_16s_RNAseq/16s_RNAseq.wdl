task task_16s_RNAseq {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String species
  String need_interest_Bacteria
  String inputFile3
  String corr_method
  String p_adjust
  String in_pvlaue

  String cluster_config
  String mount_paths
  
  command <<<
    Rscript ${appBinDir}/16s_RNAseq_docker_V1.0.R ${RLibPath} ${inputFile1} ${inputFile2} ${species} ${need_interest_Bacteria} ${inputFile3} ${corr_method} ${p_adjust} ${in_pvlaue}

    mkdir result
    mv pathway_activities.csv result/
    mv Pathway_correlation.csv result/
    mv Pathway_correlation_heatmap.pdf result/
    mv Pathway_activity_heatmap.pdf result/
    tar -czvf result.tar.gz result
     >>>

  output {
    File outFile = "result.tar.gz"
  }

 
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:rstudio-r-base-4.2.0-focal"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: true
    timeout: 7200
  }
}
workflow henbio_wf {
  call task_16s_RNAseq
  output{
    task_16s_RNAseq.outFile
  }
}
