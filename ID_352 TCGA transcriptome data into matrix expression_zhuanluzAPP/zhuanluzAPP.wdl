task task_zhuanluzAPP {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String cluster_config
  String mount_paths
  
  
  
  command <<<
    set -e
    set -o pipefail
    unzip ${inputFile1}
    # `basename ${inputFile1} | sed 's/.zip//'`
    Rscript ${appBinDir}/zhuanluzAPP.R ${RLibPath} `basename ${inputFile1} | sed 's/.zip//'` ${inputFile2}
  >>>


  output {
    File outFile1 = "unstranded.txt"
    File outFile2 = "tpm_unstranded.txt"
    File outFile3 = "fpkm_unstranded.txt"
    #File outFile4 = "fpkm_uq_unstranded.txt"
    #File outFile2 = "clusters_markers.csv"
  }
 
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:rstudio-r-base-4.2.0-focal"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 2400
  }
}
workflow henbio_wf {
  call task_zhuanluzAPP
  output{
    task_zhuanluzAPP.outFile1
    task_zhuanluzAPP.outFile2
    task_zhuanluzAPP.outFile3
    #task_zhuanluzAPP.outFile4
  }
}
