task task_singleCell {
  String appBinDir
  String inputFile
  String gene_counts
  String MT_percent
  String resolution
  String cluster_config
  String mount_paths
  
  
  command <<<
    set -e
    set -o pipefail
    unzip ${inputFile}
    # `basename ${inputFile} | sed 's/.zip//'`
    Rscript ${appBinDir}/singleCell.R `basename ${inputFile} | sed 's/.zip//'` ${gene_counts} ${MT_percent} ${resolution}
    mkdir result
    mv ./*.pdf result/
    mv ./*.csv result/
    mv ./*.rds result/
    tar -czvf result.tar.gz result
  >>>


  output {
    File outFile = "result.tar.gz"
    #File outFile1 = "Seuratproject.rds"
    #File outFile2 = "clusters_markers.csv"
  }
 
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:singlecell-1-6-v2"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 7200
  }
}
workflow henbio_wf {
  call task_singleCell
  output{
    task_singleCell.outFile
    #task_singleCell.outFile1
	#task_singleCell.outFile2
  }
}
