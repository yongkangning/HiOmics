task task_heatmap_interesting_gene {
  String appBinDir
  String RLibPath
  String inputFile1
  String annotation
  String inputFile2
  String inputdata
  String inputFile3
  String legend_title
  String is_height
  String is_withd
  String outputFileName
  
  String cluster_config
  String mount_paths
  
  command <<<  
    set -o pipefail
    set -e
    cp ${appBinDir}/datacheck_v1.0 /usr/local/bin/
    datacheck_v1.0 -i ${inputFile1} -o inputFile1.txt -c true -d true -s 0
    datacheck_v1.0 -i ${inputFile2} -o inputFile2.txt -c true -d true -s 0
    datacheck_v1.0 -i ${inputFile3} -o inputFile3.txt -c true -d true -s 0
    Rscript ${appBinDir}/cliHeatmap_docker_v.1.9.R ${RLibPath} inputFile1.txt ${annotation} inputFile2.txt ${inputdata} inputFile3.txt ${legend_title} ${is_height} ${is_withd} ${outputFileName}
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
  call task_heatmap_interesting_gene
  output{
    task_heatmap_interesting_gene.outFile
  }
}
 