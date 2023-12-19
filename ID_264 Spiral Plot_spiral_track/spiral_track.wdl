version 1.0

task task_spiral_track {
  input {
    String inputFile
	String spiral_start
	String fill_col
	String track_height
	String is_date
	
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
    Rscript ~{appBinDir}/spiral_track.R ~{RLibPath} inputFile2.txt ~{spiral_start} ~{fill_col} ~{track_height} ~{is_date}
    # update result to oss
    task_id=`echo $PWD | sed -e s"#~{cromwellDir}/##" -e s"#/execution##"`
    ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp -f result.svg oss:/~{ossTargetDir}/${task_id}/
    # update log to oss
    ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp -f stdout oss:/~{ossTargetDir}/${task_id}/
    ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp -f stderr oss:/~{ossTargetDir}/${task_id}/
  >>>

  output {
    File outFile = "result.svg"
  }
 
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:rstudio-r-base-4.2.0-focal"
    timeout: 600
  }
}

workflow henbio_wf {
  call task_spiral_track

  output {
    File outFile = task_spiral_track.outFile
  }
}