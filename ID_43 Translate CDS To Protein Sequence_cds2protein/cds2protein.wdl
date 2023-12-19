version 1.0

task task_cds2protein {
  input {
    String appBinDir
    String inputFile
    String outputFile
    String codeTable
    String cluster_config
    String mount_paths
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/cds2protein_v1.0.py ~{inputFile} ~{outputFile} ~{codeTable}
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
  call task_cds2protein
}