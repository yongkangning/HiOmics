version 1.0

task task_differential_gene_barplot {
  input {
    String inputFile
    String up_col
    String down_col
    String up_title
    String down_title
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
    ~{appBinDir}/datacheck_v1.0 -i inputFile1.csv -o inputFile2.csv -c false -d true -s 0
    # genarate the result
    Rscript ~{appBinDir}/differential_gene_barplot.R ~{RLibPath} inputFile2.csv ~{up_col} ~{down_col} ~{up_title} ~{down_title} ~{outputFileName}
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
  call task_differential_gene_barplot

  output {
    File outFile = task_differential_gene_barplot.outFile
  }
}