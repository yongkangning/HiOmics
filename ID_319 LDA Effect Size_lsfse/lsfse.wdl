version 1.0

task task_lsfse {
  input {
    String inputFile1
    String inputFile2
    String inputFile3
    String is_use_taxa_num
    String is_use_feature_num
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
    ~{appBinDir}/datacheck_v1.0 -i inputFile1.csv -o inputFile2.csv -c true -d true -s 1
    # download input from oss
    ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp oss:/~{inputFile2} ./inputFile3.csv
    # check input data
    ~{appBinDir}/datacheck_v1.0 -i inputFile3.csv -o inputFile4.csv -c true -d true -s 1
    # download input from oss
    ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp oss:/~{inputFile3} ./inputFile5.csv
    # check input data
    ~{appBinDir}/datacheck_v1.0 -i inputFile5.csv -o inputFile6.csv -c true -d true -s 1
    # genarate the result
    Rscript ~{appBinDir}/lsfse.R ~{RLibPath} inputFile2.csv inputFile4.csv inputFile6.csv ~{is_use_taxa_num} ~{is_use_feature_num} ~{outputFileName}
    # update result to oss
    task_id=`echo $PWD | sed -e s"#~{cromwellDir}/##" -e s"#/execution##"`
    ls ~{outputFileName}.svg stdout stderr | xargs -P 3 -I {}  ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp -f {} oss:/~{ossTargetDir}/${task_id}/
  >>>

  output {
    File outFile = "${outputFileName}.svg"
  }
 
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:rstudio-r-base-4.2.0-focal"
    timeout: 600
  }
}

workflow henbio_wf {
  call task_lsfse

  output {
    File outFile = task_lsfse.outFile
  }
}