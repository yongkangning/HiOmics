version 1.0

task task_samples_mean {
  input {
    String appBinDir
    String input_data
    String mode_choose
    String mode_choose_up
    String mode_choose_down
    String mode_choose_conbine
    String cluster_config
    String mount_paths
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/samples_mean.py ~{input_data} ~{mode_choose} ~{mode_choose_up} ~{mode_choose_down} ~{mode_choose_conbine}
    >>>
  output {
    Array[File] outputFile = glob("*.zip")
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:python-3.9.12"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: true
    timeout: 900
  }
}
workflow henbio_wf {
  call task_samples_mean
}