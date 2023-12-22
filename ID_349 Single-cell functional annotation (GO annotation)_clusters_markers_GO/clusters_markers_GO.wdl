task task_clusters_markers_GO {
  String appBinDir
  String RLibPath
  String inputFile
  String species
  String log2FC
  String is_ont
  String pjmethod
  String cluster_config
  String mount_paths

  
  command <<<
    Rscript ${appBinDir}/clusters_markers_GO.R ${RLibPath} ${inputFile} ${species} ${log2FC} ${is_ont} ${pjmethod}
	 >>>

  output {
    File outFile1 = "cluster_markers.csv"
	File outFile2 = "cluster_GO.pdf"
	File outFile3 = "cluster_markers_GO.csv"
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
  call task_clusters_markers_GO
  output{
    task_clusters_markers_GO.outFile1
	task_clusters_markers_GO.outFile2
	task_clusters_markers_GO.outFile3
  }
}
