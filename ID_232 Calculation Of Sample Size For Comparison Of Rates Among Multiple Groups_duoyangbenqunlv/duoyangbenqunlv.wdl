task task_duoyangbenqunlv {
  String appBinDir
  String RLibPath
  String is_w
  String nrow_df
  String ncol_df
  String sig_level
  String Power
  String outputFileName
  String cluster_config
  String mount_paths

  command <<<
   Rscript ${appBinDir}/pwr.chisq.test.R ${RLibPath} ${is_w} ${nrow_df} ${ncol_df} ${sig_level} ${Power} ${outputFileName}
	 >>>

  output {
    File outFile = "${outputFileName}.csv"
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
  call task_duoyangbenqunlv
  output{
  task_duoyangbenqunlv.outFile
  }
}
