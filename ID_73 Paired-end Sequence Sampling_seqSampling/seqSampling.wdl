version 1.0

task task_seqSampling {
  input {
    String read1File
    String read2File
    String samplingValue
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    seed=$(date +%s%N)
    seqtk sample -s${seed}  ~{read1File} ~{samplingValue} | gzip > result.R1.fq.gz
    seqtk sample -s${seed}  ~{read2File} ~{samplingValue} | gzip > result.R2.fq.gz
    
   >>>

  output {
    File outFile1 = "result.R1.fq.gz"
    File outFile2 = "result.R2.fq.gz"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-toolkits-1-0"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 7200
  }
}
workflow henbio_wf {
  call task_seqSampling
}