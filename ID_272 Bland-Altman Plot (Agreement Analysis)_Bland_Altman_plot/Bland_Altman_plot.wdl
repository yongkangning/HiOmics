version 1.0

task task_Bland_Altman_plot {
  input {
    String inputFile
    String point_col
    String is_type
    String fill_col
    String outputFileName1
    String outputFileName2

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
    ~{appBinDir}/datacheck_v1.0 -i inputFile1.txt -o inputFile2.txt -c false -d true -s 0
    # genarate the result
    Rscript ~{appBinDir}/Bland_Altman_plot.R ~{RLibPath} inputFile2.txt ~{point_col} ~{is_type} ~{fill_col} ~{outputFileName1} ~{outputFileName2}
    # update result to oss
    task_id=`echo $PWD | sed -e s"#~{cromwellDir}/##" -e s"#/execution##"`
    ls ~{outputFileName1}.svg ~{outputFileName2}.svg stdout stderr | xargs -P 3 -I {}  ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp -f {} oss:/~{ossTargetDir}/${task_id}/
  >>>

  output {
    File outFile1 = "${outputFileName1}.svg"
    File outFile2 = "${outputFileName2}.svg"
  }
 
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:rstudio-r-base-4.2.0-focal"
    timeout: 600
  }
}

workflow henbio_wf {
  call task_Bland_Altman_plot

  output {
    File outFile1 = task_Bland_Altman_plot.outFile1
    File outFile2 = task_Bland_Altman_plot.outFile2
  }
}