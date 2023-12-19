version 1.0

task task_missingfill {
  input {
    String appBinDir
    String input_file
    String output_file
    String judge_name01
    String misssing 
    String misssing_diy
    String judge_delete
    String missing_diy_proportions
    String judge_fill
    String file_shape
    String cluster_config
    String mount_paths
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/missingfill.py ~{input_file} ~{output_file} ~{judge_name01} ~{misssing} ~{misssing_diy} ~{judge_delete} ~{missing_diy_proportions} ~{judge_fill} ~{file_shape}
    >>>
  output {
    File outFile = output_file
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
  call task_missingfill
}