task task_GO_barplot {
  String appBinDir
  String RLibPath
  String is_Model_Species
  String inputFile1
  String inputFile2
  String inputFile3
  String species
  String pjmethod
  String is_ont
  String is_title
  String p_color
  String is_showCategory
  String is_label_format
  String color_low
  String color_high
  String outputFileName
  
  String cluster_config
  String mount_paths
 
 
  command <<<
    if [ "${is_Model_Species}" == "no" ]; then
      Rscript ${appBinDir}/GO_barplot_docker_v.1.0.R ${RLibPath} ${is_Model_Species} ${inputFile1} ${inputFile2} ${inputFile3} file2 ${pjmethod} file3 ${is_title} ${p_color} ${is_showCategory} ${is_label_format} ${color_low} ${color_high} ${outputFileName}
    elif [ "${is_Model_Species}" == "yes" ]; then
      
      Rscript ${appBinDir}/GO_barplot_docker_v.1.0.R ${RLibPath} ${is_Model_Species} ${inputFile1} file2 file3 ${species} ${pjmethod} ${is_ont} ${is_title} ${p_color} ${is_showCategory} ${is_label_format} ${color_low} ${color_high} ${outputFileName}
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
  call task_GO_barplot
  output{
    task_GO_barplot.outFile1
	task_GO_barplot.outFile2
  }
}
