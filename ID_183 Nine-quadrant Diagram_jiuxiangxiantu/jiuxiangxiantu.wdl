version 1.0

task task_jiuxiangxiantu {
  input {
    String inputFile1
    String inputFile2
    String ncol_log2FC_RNA
    String ncol_log2FC_Ribo
    String FC_RNA
    String FC_Ribo
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
    Rscript ~{appBinDir}/jiuxiangxiantu_docker.R ~{RLibPath} inputFile2.txt inputFile4.txt ~{ncol_log2FC_RNA} ~{ncol_log2FC_Ribo} ~{FC_RNA} ~{FC_Ribo} ~{x_title} ~{y_title} ~{outputFileName}
    # update result to oss
    task_id=`echo $PWD | sed -e s"#~{cromwellDir}/##" -e s"#/execution##"`
    ls ~{outputFileName}.svg ~{outputFileName}_common.csv stdout stderr | xargs -P 3 -I {}  ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp -f {} oss:/~{ossTargetDir}/${task_id}/
  >>>

  output {
    File outFile1 = "${outputFileName}.svg"
    File outFile2 = "${outputFileName}_common.csv"
  }
 
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:rstudio-r-base-4.2.0-focal"
    timeout: 600
  }
}

workflow henbio_wf {
  call task_jiuxiangxiantu

  output {
    File outFile1 = task_jiuxiangxiantu.outFile1
    File outFile2 = task_jiuxiangxiantu.outFile2
  }
}