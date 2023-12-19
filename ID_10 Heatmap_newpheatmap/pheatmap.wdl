task task_pheatmap {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String inputdata
  String inputFile3
  String color1
  String color2
  String is_cluster_cols
  String is_cluster_rows
  String is_show_colnames
  String is_show_rownames 
  String is_scale
  String cellwidthSize
  String cellheightSize
  String col_angle
  String is_main
  String is_legend
  String is_display_numbers
  String outputFileName
  String cluster_config
  String mount_paths


  command <<<
    set -o pipefail
    set -e
    cp ${appBinDir}/datacheck_v1.0 /usr/local/bin/
    datacheck_v1.0 -i ${inputFile1} -o inputFile1.txt -c true -d true -s 0
    datacheck_v1.0 -i ${inputFile2} -o inputFile2.txt -c true -d true -s 0
    datacheck_v1.0 -i ${inputFile3} -o inputFile3.txt -s 0
    Rscript ${appBinDir}/pheatmap_docker_v.1.2.R ${RLibPath} inputFile1.txt inputFile2.txt ${inputdata} inputFile3.txt ${color1} ${color2} ${is_cluster_cols} ${is_cluster_rows} ${is_show_colnames} ${is_show_rownames} ${is_scale} ${cellwidthSize} ${cellheightSize} ${col_angle} ${is_main} ${is_legend} ${is_display_numbers} ${outputFileName} 
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
  call task_pheatmap
  output{
    task_pheatmap.outFile
  }
}