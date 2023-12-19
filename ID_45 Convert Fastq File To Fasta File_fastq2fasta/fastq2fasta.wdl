version 1.0

task task_fastq2fasta {
  input {
    String appBinDir
    String inputFile
    String outputFile
    String cluster_config
    String mount_paths
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/fastq2fasta_v1.0.py ~{inputFile} ~{outputFile}
  >>>

  output {
    File outFile = outputFile
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:python-3.9.12"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 600
  }
}
workflow henbio_wf {
  call task_fastq2fasta
}