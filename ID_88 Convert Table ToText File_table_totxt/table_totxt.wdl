version 1.0

task task_table_totxt {
  input {
    String appBinDir
    String inpath
    String file_sep
    String cluster_config
    String mount_paths
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/table_totxt.py ~{inpath} ~{file_sep} 
    >>>
  output {
    Array[File] outputFile = glob("outputFile/*.txt")
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
  call task_table_totxt
}