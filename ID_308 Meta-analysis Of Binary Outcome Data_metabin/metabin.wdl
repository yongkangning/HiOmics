task task_metabin {
  String appBinDir
  String RLibPath
  String inputFile
  String is_sm
  String cluster_config
  String mount_paths

  command <<<
   Rscript ${appBinDir}/metabin.R ${RLibPath} ${inputFile} ${is_sm}
	 >>>

  output {
    File outFile1 = "Forest.svg"
	    File outFile2 = "Funnel.svg"
		    File outFile3 = "Egger.svg"
			    File outFile4 = "Sensitivity.svg"
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
  call task_metabin
  output{
  task_metabin.outFile1
    task_metabin.outFile2
	  task_metabin.outFile3
	    task_metabin.outFile4
  }
}
