version 1.0

task task_area_chart {
  input {
    String inputFile
    String is_alpha
    String x_title
    String y_title
    String plot_title
    String legend_title
    String outputFileName

    String ossTargetDir

    String appBinDir
    String RLibPath
    String cromwellDir
  }

  command <<<
    set -eo pipefail
    # download input from oss
    ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp oss:/~{inputFile} ./inputFile1.xls
    # check input data
    # ~{appBinDir}/datacheck_v1.0 -i inputFile1.xls -o inputFile2.xls -c true -d true -s 0
    # genarate the result
    Rscript ~{appBinDir}/area_chart.R ~{RLibPath} inputFile1.xls ~{is_alpha} ~{x_title} ~{y_title} ~{plot_title} ~{legend_title} ~{outputFileName}
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
  call task_area_chart

  output {
    File outFile = task_area_chart.outFile
  }
}