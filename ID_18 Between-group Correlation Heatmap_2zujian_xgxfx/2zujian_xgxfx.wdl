version 1.0

task task_2zujian_xgxfx {
  input {
    String inputFile
    String inputFile2
    String is_method
    String is_cluster_cols
    String is_cluster_rows
    String is_show_colnames 
    String is_show_rownames
    String is_scale
    String cellwidthSize
    String cellhightSize
    String dis_num
    String outputFileName

    String ossTargetDir

    String appBinDir
    String RLibPath
    String cromwellDir
  }

  command <<<
    set -eo pipefail
    # download input from oss
    ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp oss:/~{inputFile} ./inputFile1.txt
    # check input data
    ~{appBinDir}/datacheck_v1.0 -i inputFile1.txt -o inputFile2.txt -c true -d true -s 0
    # download input from oss
    ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp oss:/~{inputFile2} ./inputFile3.txt
    # check input data
    ~{appBinDir}/datacheck_v1.0 -i inputFile3.txt -o inputFile4.txt -c true -d true -s 0
    # genarate the result
    Rscript ~{appBinDir}/between_cor_analysis_docker.R ~{RLibPath} inputFile2.txt inputFile4.txt ~{is_method} ~{is_cluster_cols} ~{is_cluster_rows} ~{is_show_colnames} ~{is_show_rownames} ~{is_scale} ~{cellwidthSize} ~{cellhightSize} ~{dis_num} ~{outputFileName}
    # update result to oss
    task_id=`echo $PWD | sed -e s"#~{cromwellDir}/##" -e s"#/execution##"`
    ls ~{outputFileName}_cordata.txt ~{outputFileName}_pvalue.txt ~{outputFileName}.svg stdout stderr | xargs -P 3 -I {}  ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp -f {} oss:/~{ossTargetDir}/${task_id}/
  >>>

  output {
    File outFile1 = "${outputFileName}_cordata.txt"
    File outFile2 = "${outputFileName}_pvalue.txt"
    File outFile3 = "${outputFileName}.svg"
  }
 
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:rstudio-r-base-4.2.0-focal"
    timeout: 600
  }
}

workflow henbio_wf {
  call task_2zujian_xgxfx

  output {
    File outFile1 = task_2zujian_xgxfx.outFile1
    File outFile2 = task_2zujian_xgxfx.outFile2
    File outFile3 = task_2zujian_xgxfx.outFile3
  }
}