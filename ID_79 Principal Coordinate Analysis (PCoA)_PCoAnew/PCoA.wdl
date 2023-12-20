task task_PCoA {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String bray
  String is_legend
  String is_horiz
  String outputFileName
  
  String cluster_config
  String mount_paths

  command <<<
    Rscript ${appBinDir}/PCoA_docker.R ${RLibPath} ${inputFile1} ${inputFile2} ${bray} ${is_legend} ${is_horiz} ${outputFileName}
  >>>

  output {
    File outFile1 = "${outputFileName}_eig.txt"
    File outFile2 = "${outputFileName}_sites.txt"
    File outFile3 = "${outputFileName}.svg"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:rstudio-r-base-4.2.0-focal"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: true
    timeout: 600
  }
}
workflow henbio_wf {
  call task_PCoA
  output{
    task_PCoA.outFile1
    task_PCoA.outFile2
    task_PCoA.outFile3
  }
}
