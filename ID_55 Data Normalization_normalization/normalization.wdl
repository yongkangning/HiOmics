version 1.0

task task_normalization {
  input {
    String appBinDir
    String input_file
    String judge_name01
    String mode_choose
    String mode_range
    String cluster_config
    String mount_paths
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/normalization.py ~{input_file} ~{judge_name01} ~{mode_choose} ~{mode_range}
    >>>
  output {
    Array[File] outFile = glob("output.*")
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
  call task_normalization
}