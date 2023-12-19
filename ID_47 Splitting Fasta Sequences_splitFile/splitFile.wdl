version 1.0

task task_splitFile {
  input {
    String appBinDir
    String inputFile
    String dataFormat
    String batchSize
    String cluster_config
    String mount_paths
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/splitFile_v1.0.py ~{inputFile} ~{dataFormat} ~{batchSize}
  >>>

  output {
    Array[File] outFile = glob("part*")
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
  call task_splitFile
}