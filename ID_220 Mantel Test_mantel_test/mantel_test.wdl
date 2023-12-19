version 1.0

task task_mantel_test {
  input {
    String inputFile1
    String inputFile2
    String inputFile3
    String cor_method
    String is_mark
    String outputFileName

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
    ~{appBinDir}/datacheck_v1.0 -i inputFile1.csv -o inputFile2.txt -c true -d true -s 0
    # download input from oss
    ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp oss:/~{inputFile2} ./inputFile1.csv
    # check input data
    ~{appBinDir}/datacheck_v1.0 -i inputFile1.csv -o inputFile3.txt -c true -d true -s 0
    # download input from oss
    ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp oss:/~{inputFile3} ./inputFile1.txt
    # check input data
    ~{appBinDir}/datacheck_v1.0 -i inputFile1.txt -o inputFile4.txt -c true -d true -s 0
    # genarate the result
    Rscript ~{appBinDir}/mantel_test_docker_v.1.0.R ~{RLibPath} inputFile2.txt inputFile3.txt inputFile4.txt ~{cor_method} ~{is_mark} ~{outputFileName}
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
  call task_mantel_test

  output {
    File outFile = task_mantel_test.outFile
  }
}