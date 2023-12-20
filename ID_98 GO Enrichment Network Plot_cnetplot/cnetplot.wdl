task task_cnetplot {
  String appBinDir
  String RLibPath
  String is_Model_Species
  String inputFile1
  String inputFile2
  String inputFile3
  String is_logFC
  String species
  String pjmethod
  String is_ont
  String is_node_label
  String is_plot
  String is_showCategory
  String outputFileName
  
  String cluster_config
  String mount_paths
 
  command <<<
    if [ "${is_Model_Species}" == "no" ]; then
      Rscript ${appBinDir}/cnetplot_docker_v.1.1.R ${RLibPath} ${is_Model_Species} ${inputFile1} ${inputFile2} ${inputFile3} ${is_logFC} file2 ${pjmethod} file3 ${is_node_label} ${is_plot} ${is_showCategory} ${outputFileName}
    elif [ "${is_Model_Species}" == "yes" ]; then
      
      Rscript ${appBinDir}/cnetplot_docker_v.1.1.R ${RLibPath} ${is_Model_Species} ${inputFile1} file2 file3 ${is_logFC} ${species} ${pjmethod} ${is_ont} ${is_node_label} ${is_plot} ${is_showCategory} ${outputFileName}
    else
      echo "is_Model_Species must be one of yes or no."
      exit 111
    fi
	 >>>

  output {
    File outFile1 = "${outputFileName}.svg"
	File outFile2 = "${outputFileName}_GO_enrichment.csv"
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
  call task_cnetplot
  output{
    task_cnetplot.outFile1
	task_cnetplot.outFile2
  }
}
