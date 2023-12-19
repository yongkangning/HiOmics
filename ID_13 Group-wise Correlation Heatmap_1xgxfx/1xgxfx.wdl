version 1.0

task task_1xgxfx {
  input {
    String inputFile
    String is_method
    String is_cluster_cols
    String is_cluster_rows
    String is_show_colnames 
    String is_show_rownames
    String is_scale
    String cellwidthSize
    String cellhightSize
    String dis_num
    String outputFile1
    String outputFile2
    String outputFile3
    String outPutFileType1
    String outPutFileType2

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
    # genarate the result
    Rscript ~{appBinDir}/intargroup_cor_analysis_docker.R ~{RLibPath} inputFile2.txt ~{is_method} ~{is_cluster_cols} ~{is_cluster_rows} ~{is_show_colnames} ~{is_show_rownames} ~{is_scale} ~{cellwidthSize} ~{cellhightSize} ~{dis_num} ~{outputFile1} ~{outputFile2} ~{outputFile3} ~{outPutFileType1} ~{outPutFileType2}
    # update result to oss
    task_id=`echo $PWD | sed -e s"#~{cromwellDir}/##" -e s"#/execution##"`
    ls ~{outputFile1}.~{outPutFileType1} ~{outputFile2}.~{outPutFileType1} ~{outputFile3}.~{outPutFileType2} stdout stderr | xargs -P 3 -I {}  ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp -f {} oss:/~{ossTargetDir}/${task_id}/
  >>>

  output {
    File outFile1 = "${outputFile1}.${outPutFileType1}"
    File outFile2 = "${outputFile2}.${outPutFileType1}"
    File outFile3 = "${outputFile3}.${outPutFileType2}"
  }
 
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:rstudio-r-base-4.2.0-focal"
    timeout: 600
  }
}

workflow henbio_wf {
  call task_1xgxfx

  output {
    File outFile1 = task_1xgxfx.outFile1
    File outFile2 = task_1xgxfx.outFile2
    File outFile3 = task_1xgxfx.outFile3
  }
}