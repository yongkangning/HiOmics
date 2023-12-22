version 1.0

task task_bbdukWithoutHost {
  input {
    String fastqRead1
    String fastqRead2
    String referenceGenome
    String outFile1 = basename(fastqRead1)
    String outFile2 = basename(fastqRead2)
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    bbduk.sh -Xmx112640m ref=~{referenceGenome} in1=~{fastqRead1} in2=~{fastqRead2} out1=unmap_~{outFile1} out2=unmap_~{outFile2}
   >>>

  output {
    File clean_outFile1 = "unmap_~{outFile1}"
    File clean_outFile2 = "unmap_~{outFile2}"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-bbmap-v38-18"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 14400
  }
}
workflow henbio_wf {
  call task_bbdukWithoutHost
}