version 1.0

task task_survival {
  input {
    String inputFile
    String is_conf
    String is_conf_style
    String con_alpha
    String is_pval 
    String is_legend
    String is_xlab
    String is_ylab
    String is_title
    String is_risk_table
    String risk_table_height
    String median_line
    String is_palette
    String is_censor
    String is_ncensor
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
    # genarate the result
    Rscript ~{appBinDir}/survival_docker_v.1.0.R ~{RLibPath} inputFile2.txt ~{is_conf} ~{is_conf_style} ~{con_alpha} ~{is_pval} ~{is_legend} ~{is_xlab} ~{is_ylab} ~{is_title} ~{is_risk_table} ~{risk_table_height} ~{median_line} ~{is_palette} ~{is_censor} ~{is_ncensor} ~{outputFileName}
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
  call task_survival

  output {
    File outFile = task_survival.outFile
  }
}