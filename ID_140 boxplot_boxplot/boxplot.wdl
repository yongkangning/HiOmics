version 1.0

task task_boxplot {
  input {
    String inputFile1
    String groupfile
    String inputFile2
    String is_method
    String p_sig
    String x_title
    String y_title
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
    # genarate the result
    Rscript ~{appBinDir}/boxplot_docker_v.1.2.R ~{RLibPath} inputFile2.txt ~{groupfile} inputFile4.txt ~{is_method} ~{p_sig} ~{x_title} ~{y_title} ~{outputFileName}
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
  call task_boxplot

  output {
    File outFile = task_boxplot.outFile
  }
}