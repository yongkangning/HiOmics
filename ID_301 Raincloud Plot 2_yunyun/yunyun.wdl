version 1.0

task task_yunyun {
  input {
    String inputFile1
    String is_range_scale
    String is_alpha
    String outputFile

    String ossTargetDir

    String appBinDir
    String RLibPath
    String cromwellDir
  }

  command <<<
    set -eo pipefail
    # download input from oss
    ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp oss:/~{inputFile1} ./inputFile1.csv
    # check input data
    #~{appBinDir}/datacheck_v1.0 -i inputFile1.csv -o inputFile2.csv -c false -d false -s 0
    # genarate the result
    Rscript ~{appBinDir}/yunyun.R ~{RLibPath} inputFile1.csv ~{is_range_scale} ~{is_alpha} ~{outputFile}
    # update result to oss
    task_id=`echo $PWD | sed -e s"#~{cromwellDir}/##" -e s"#/execution##"`
    ls ~{outputFile}.svg stdout stderr | xargs -P 3 -I {}  ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp -f {} oss:/~{ossTargetDir}/${task_id}/
  >>>

  output {
    File outFile = "${outputFile}.svg"
  }
 
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:rstudio-r-base-4.2.0-focal"
    timeout: 600
  }
}

workflow henbio_wf {
  call task_yunyun

  output {
    File outFile = task_yunyun.outFile
  }
}