task task_shanjitu {
  String appBinDir
  String RLibPath
  String inputFile1
  String x_title
  String y_title
  String is_name
  String outputFileName
  String cluster_config
  String mount_paths
 
  command <<<
    set -o pipefail
    set -e
    cp ${appBinDir}/datacheck_v1.0 /usr/local/bin/
    datacheck_v1.0 -i ${inputFile1} -o inputFile1.txt -c true -d true -s 0
    Rscript ${appBinDir}/shanjitu.R ${RLibPath} inputFile1.txt ${x_title} ${y_title} ${is_name} ${outputFileName}
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
  call task_shanjitu
  output{
    task_shanjitu.outFile
  }
}
