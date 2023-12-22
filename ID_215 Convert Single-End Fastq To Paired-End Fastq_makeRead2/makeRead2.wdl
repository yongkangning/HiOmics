version 1.0

task task_makeRead2 {
  input {
    String inputFile
    String appBinDir
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    if [[ "~{inputFile}" = *gz ]]
    then
      fastqFile=~{inputFile}
    else
      fastqFile=`basename ~{inputFile}`.gz
      
      # gzip ~{inputFile}
      gzip -c ~{inputFile}  > ${fastqFile}
    fi

    ~{appBinDir}/makeRead2 ${fastqFile} | gzip > sample_R2.fq.gz
    cp ${fastqFile} sample_R1.fq.gz
   
   
   >>>

  output {
    File outFile1 = "sample_R1.fq.gz"
    File outFile2 = "sample_R2.fq.gz"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:debian-latest"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 3600
  }
}
workflow henbio_wf {
  call task_makeRead2
}