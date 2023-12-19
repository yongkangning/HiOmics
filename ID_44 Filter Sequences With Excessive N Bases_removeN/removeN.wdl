version 1.0

task task_removeN {
  input {
    String appBinDir
    String inputFile
    String fileFormat
    String n_percentage
    String cluster_config
    String mount_paths
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/removeN_v1.0.py ~{inputFile} ~{fileFormat} ~{n_percentage}
  >>>

  output {
    File outFile = "clean_" + basename(inputFile)
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
  call task_removeN
}