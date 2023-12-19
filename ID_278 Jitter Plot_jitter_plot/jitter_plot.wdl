version 1.0

task task_jitter_plot {
  input {
    String inputFile
    String jitter_width
    String point_size
    String errorbar_size
    String x_title
    String y_title
    String is_title
    String outputFileName

    String ossTargetDir

    String appBinDir
    String RLibPath
    String cromwellDir
  }

  command <<<
    set -eo pipefail
    # download input from oss
    ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp oss:/~{inputFile} ./inputFile1.csv
    # check input data
    ~{appBinDir}/datacheck_v1.0 -i inputFile1.csv -o inputFile2.csv -c true -d true -s 1
    # genarate the result
    Rscript ~{appBinDir}/jitter_plot.R ~{RLibPath} inputFile2.csv ~{jitter_width} ~{point_size} ~{errorbar_size} ~{x_title} ~{y_title} ~{is_title} ~{outputFileName}
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
  call task_jitter_plot

  output {
    File outFile = task_jitter_plot.outFile
  }
}