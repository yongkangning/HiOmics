task task_danbaizhudaixiezhu {
  String appBinDir
  String RLibPath
  String inputFile2
  String inputFile3
  String inputFile6
  String in_colname
  String category
  String plot  
  String outcomeAnalyteOf_Interest
  String independentAnalyteOf_Interest
  String outputFileName
  String cluster_config
  String mount_paths
  
  command <<<
    set -o pipefail
    set -e
    cp ${inputFile2} ./metabData.csv
    cp ${inputFile3} ./geneData.csv
    cp ${inputFile6} ./pData.csv
    cp /henbio/henbio_web/public/demo_data/IntLIM/NCItestinput.csv ./
    Rscript ${appBinDir}/Integration_docker_RNAseq_metabolome_v2.1.R ${RLibPath} ${inputFile2} ${inputFile3} ${inputFile6} ${in_colname} ${category} ${plot} ${outcomeAnalyteOf_Interest} ${independentAnalyteOf_Interest} ${outputFileName}
    mkdir result
    mv ${outputFileName}_lib result/
	mv ${outputFileName}*.pdf result/
	cp ${outputFileName}*.csv result/
	mv ${outputFileName}*.html result/
    tar -czvf result.tar.gz result
  >>>

  output {
      File outFile = "result.tar.gz"
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
  call task_danbaizhudaixiezhu
  output{
      task_danbaizhudaixiezhu.outFile
  }
}
