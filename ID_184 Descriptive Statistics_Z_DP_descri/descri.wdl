version 1.0

task task_descri {
  input {
    String appBinDir
    String input_file
    String cluster_config
    String mount_paths
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/descri.py ~{input_file}
    >>>
  output {
    Array[File] outputFile = glob("*.txt")
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:python-3.9.12"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: true
    timeout: 1200
  }
}
workflow henbio_wf {
  call task_descri
}