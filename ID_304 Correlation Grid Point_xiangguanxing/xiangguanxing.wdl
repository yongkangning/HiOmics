task task_xiangguanxing {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String is_method
  String outputFileName
  String cluster_config
  String mount_paths
 
    command <<<
    set -o pipefail
    set -e
    cp ${appBinDir}/datacheck_v1.0 /usr/local/bin/
    datacheck_v1.0 -i ${inputFile1} -o inputFile1.csv -c true -d true -s 1
    datacheck_v1.0 -i ${inputFile2} -o inputFile2.csv -c true -d true -s 1

    Rscript ${appBinDir}/xiangguanxing.R ${RLibPath} inputFile1.csv inputFile2.csv ${is_method} ${outputFileName}
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
  call task_xiangguanxing
  output{
    task_xiangguanxing.outFile
  }
}
