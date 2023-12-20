version 1.0

task task_checkPhred {
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
      fastqFile=`echo ~{inputFile} | sed s'/.gz//'` 
      fastqFile=`basename ${fastqFile}`
      
      # gunzip ~{inputFile}
      gunzip -c ~{inputFile}  > ${fastqFile}
    else
      fastqFile=~{inputFile}
    fi

    ~{appBinDir}/checkPhred.sh ${fastqFile} > result.txt
   
   >>>

  output {
    File outFiles = "result.txt"
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
  call task_checkPhred
}