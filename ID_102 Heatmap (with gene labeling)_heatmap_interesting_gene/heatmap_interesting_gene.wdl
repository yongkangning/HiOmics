version 1.0

task task_heatmap_interesting_gene {
  input {
    String inputFile1
    String annotation
    String inputFile2
    String inputdata
    String inputFile3
    String legend_title
    String is_height
    String is_withd
    String outputFileName

    String ossTargetDir

    String appBinDir
    String RLibPath
    String cromwellDir
  }

  command <<<
    set -eo pipefail
    # download input from oss
    ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp oss:/~{inputFile1} ./inputFile1.txt
    # check input data
    ~{appBinDir}/datacheck_v1.0 -i inputFile1.txt -o inputFile2.txt -c true -d true -s 0
    # download input from oss
    ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp oss:/~{inputFile2} ./inputFile3.txt
    # check input data
    ~{appBinDir}/datacheck_v1.0 -i inputFile3.txt -o inputFile4.txt -c true -d true -s 0
    # download input from oss
    ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp oss:/~{inputFile3} ./inputFile5.txt
    # check input data
    ~{appBinDir}/datacheck_v1.0 -i inputFile5.txt -o inputFile6.txt -c true -d true -s 0
    # genarate the result
    Rscript ~{appBinDir}/cliHeatmap_docker_v.1.9.R ~{RLibPath} inputFile2.txt ~{annotation} inputFile4.txt ~{inputdata} inputFile6.txt ~{legend_title} ~{is_height} ~{is_withd} ~{outputFileName}
    # update result to oss
    task_id=`echo $PWD | sed -e s"#~{cromwellDir}/##" -e s"#/execution##"`
    ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp -f ~{outputFileName}.svg oss:/~{ossTargetDir}/${task_id}/
    # update log to oss
    ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp -f stdout oss:/~{ossTargetDir}/${task_id}/
    ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp -f stderr oss:/~{ossTargetDir}/${task_id}/
  >>>

  output {
    File outFile = "~{outputFileName}.svg"
  }
 
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:rstudio-r-base-4.2.0-focal"
    timeout: 600
  }
}

workflow henbio_wf {
  call task_heatmap_interesting_gene

  output {
    File outFile = task_heatmap_interesting_gene.outFile
  }
}