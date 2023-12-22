task task_cluster_VS_cluster_GO {
  String appBinDir
  String inputFile
  String celltype1
  String fileName1 ="GO_up_"+sub(celltype1,"\\s+", "_")
  String celltype2
  String fileName2 ="GO_down_"+sub(celltype2,"\\s+", "_")
  String species
  String is_ont
  String pjmethod
  String cluster_config
  String mount_paths

  
  command <<<
    Rscript ${appBinDir}/cluster_VS_cluster_GO.R ${inputFile} "${celltype1}" "${celltype2}" ${species} ${is_ont} ${pjmethod} 
    # mkdir result
    mv GO_up_*.pdf ${fileName1}.pdf
    mv GO_up_*.txt ${fileName1}.txt
    mv GO_down_*.pdf ${fileName2}.pdf
    mv GO_down_*.txt ${fileName2}.txt
     >>>

  output {
    File outFile1 = "${fileName1}.pdf"
    File outFile2 = "${fileName1}.txt"
    File outFile3 = "${fileName2}.pdf"
    File outFile4 = "${fileName2}.txt"
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
  call task_cluster_VS_cluster_GO
  output{
    task_cluster_VS_cluster_GO.outFile1
    task_cluster_VS_cluster_GO.outFile2
    task_cluster_VS_cluster_GO.outFile3
    task_cluster_VS_cluster_GO.outFile4
  }
}
