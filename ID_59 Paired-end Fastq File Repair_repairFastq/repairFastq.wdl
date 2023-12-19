version 1.0

task task_repairFastq {
  input {
    String fastqRead1
    String fastqRead2
    String outFile1 = basename(fastqRead1)
    String outFile2 = basename(fastqRead2)
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    repair.sh in1=~{fastqRead1} in2=~{fastqRead2} out1=fixed_~{outFile1} out2=fixed_~{outFile2} outs=singletons.fq.gz repair
   >>>

  output {
    File fixed_outFile1 = "fixed_~{outFile1}"
    File fixed_outFile2 = "fixed_~{outFile2}"
    File singletonsFile = "singletons.fq.gz"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-bbmap-v38-18"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 3600
  }
}
workflow henbio_wf {
  call task_repairFastq
}