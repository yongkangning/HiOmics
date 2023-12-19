version 1.0

task task_Circular_manhattan {
  input {
    String inputFile
    String is_density
    String is_threshold
    String number1
    String is_binsize
    String is_outward
    String is_circhr
    String circhr_high
    String is_cir_legend
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
    Rscript ~{appBinDir}/Circular_manhattan_docker_v.1.1.R ~{RLibPath} inputFile2.txt ~{is_density} ~{is_threshold} ~{number1} ~{is_binsize} ~{is_outward} ~{is_circhr} ~{circhr_high} ~{is_cir_legend} ~{outputFileName}
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
  call task_Circular_manhattan

  output {
    File outFile = task_Circular_manhattan.outFile
  }
}