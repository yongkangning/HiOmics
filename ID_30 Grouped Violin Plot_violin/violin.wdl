version 1.0

task task_violin {
  input {
    String inputFile
    String is_alpha
    String Palette
    String x_title
    String y_title
    String plot_title
    String is_legend
    String is_method
    String p_sig
    String is_facet
    String is_nrow
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
    Rscript ~{appBinDir}/violin_docker_v.1.0.R ~{RLibPath} inputFile2.txt ~{is_alpha} ~{Palette} ~{x_title} ~{y_title} ~{plot_title} ~{is_legend} ~{is_method} ~{p_sig} ~{is_facet} ~{is_nrow} ~{outputFileName}
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
  call task_violin

  output {
    File outFile = task_violin.outFile
  }
}