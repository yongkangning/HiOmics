task task_gene_arrow_maps {
  String appBinDir
  String RLibPath
  String inputFile
  String y_title
  String plot_title
  String outputFileName
  String cluster_config
  String mount_paths

  command <<<
    set -o pipefail
    set -e
    cp ${appBinDir}/datacheck_v1.0 /usr/local/bin/
    datacheck_v1.0 -i ${inputFile} -o inputFile.txt -c true -d true -s 0
   Rscript ${appBinDir}/gene_arrow_maps.R ${RLibPath} inputFile.txt ${y_title} ${plot_title} ${outputFileName}
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
  call task_gene_arrow_maps
  output{
  task_gene_arrow_maps.outFile
  }
}
