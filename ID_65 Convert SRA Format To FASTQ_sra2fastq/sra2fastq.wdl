version 1.0

task task_sra2fastq {
  input {
    String inputFile
    String thread
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    if test -d ~{inputFile}
    then
      echo "This a dir"
      find ~{inputFile} -type f | while read line;
      do
        parallel-fastq-dump -t ~{thread} -O ./ --split-3  --gzip -s ${line}
      done
    else
      echo "This is a file."
      parallel-fastq-dump -t ~{thread} -O ./ --split-3  --gzip -s ~{inputFile}
    fi
   
   >>>

  output {
    Array[File] outFiles = glob("*.gz")
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-toolkits-1-0"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 86400
  }
}
workflow henbio_wf {
  call task_sra2fastq
}