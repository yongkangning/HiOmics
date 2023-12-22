version 1.0

task task_bam2bed {
  input {
    String bamFile
    String cluster_config
    String mount_paths
  }

  command <<<

    set -o pipefail
    set -e
    
    bedtools bamtobed -i ~{bamFile} > result.bed

   >>>

  output {
    File outFile = "result.bed"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-samtools-1-15"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 3600
  }
}
workflow henbio_wf {
  call task_bam2bed
}