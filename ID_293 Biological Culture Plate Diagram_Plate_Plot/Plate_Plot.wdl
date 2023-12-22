task task_Plate_Plot {
  String appBinDir
  String RLibPath
  String inputFile
  String is_title
  String colour
  String is_size
  String is_type
  String cluster_config
  String mount_paths

  command <<<
    set -o pipefail
    set -e
    cp ${appBinDir}/datacheck_v1.0 /usr/local/bin/
    datacheck_v1.0 -i ${inputFile} -o inputFile.txt -c true -d true -s 0
   Rscript ${appBinDir}/Plate_Plot.R ${RLibPath} inputFile.txt ${is_title} ${colour} ${is_size} ${is_type}
	 >>>

  output {
    File outFile = "result.svg"
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
  call task_Plate_Plot
  output{
  task_Plate_Plot.outFile
  }
}
