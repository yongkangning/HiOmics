version 1.0

task task_tongjiGC {
  input {
    String inputfile1
    String inputfile2
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
   bedtools nuc -fi ~{inputfile1} -bed ~{inputfile2} | cut -f 1-3,5 > hg19_5m_gc.bed
   >>>

  output {
    File outFile = "hg19_5m_gc.bed"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-samtools-1-15"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 600
  }
}
workflow henbio_wf {
  call task_tongjiGC
}

