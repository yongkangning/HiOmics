version 1.0

task task_scatter {
  input {
    String inputFile
    String x_lab
    String y_lab
    String is_alpha
    String is_line
    String is_method
    String is_se 
    String line_R
    String outputFileName
    String outPutFileType

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
    Rscript ~{appBinDir}/scatter_docker.R ~{RLibPath} inputFile2.txt ~{x_lab} ~{y_lab} ~{is_alpha} ~{is_line} ~{is_method} ~{is_se} ~{line_R} ~{outputFileName} ~{outPutFileType}
    # update result to oss
    task_id=`echo $PWD | sed -e s"#~{cromwellDir}/##" -e s"#/execution##"`
    ls ~{outputFileName}.~{outPutFileType} stdout stderr | xargs -P 3 -I {}  ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp -f {} oss:/~{ossTargetDir}/${task_id}/
  >>>

  output {
    File outFile = "${outputFileName}.${outPutFileType}"
  }
 
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:rstudio-r-base-4.2.0-focal"
    timeout: 600
  }
}

workflow henbio_wf {
  call task_scatter

  output {
    File outFile1 = task_scatter.outFile
  }
}