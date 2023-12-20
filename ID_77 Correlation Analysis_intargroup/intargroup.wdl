task task_intargroup {
  String appBinDir
  String RLibPath
  String inputFile
  String cor_method
  String is_pvalue
  String is_insig
  String visual_method
  String is_type
  String tl_pos
  String is_order
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  command <<<
    if [ "${is_pvalue}" == "yes" ]; then
      Rscript ${appBinDir}/correlation_docker_v.1.1.R ${RLibPath} ${inputFile} ${cor_method} ${is_pvalue} ${is_insig} ${visual_method} ${is_type} ${tl_pos} ${is_order} ${outputFileName}
    elif [ "${is_pvalue}" == "no" ]; then
      # file2 file3 占位，保持参数个数一致
      Rscript ${appBinDir}/correlation_docker_v.1.1.R ${RLibPath} ${inputFile} ${cor_method} ${is_pvalue} file3 ${visual_method} ${is_type} ${tl_pos} ${is_order} ${outputFileName}
    else
      echo "is_pvalue must be one of yes or no."
      exit 111
    fi
	 >>>

  output {
    File outFile = "${outputFileName}.svg"
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
  call task_intargroup
  output{
    task_intargroup.outFile
  }
}

