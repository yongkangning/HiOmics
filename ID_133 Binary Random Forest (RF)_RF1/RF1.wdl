version 1.0

task task_RF1 {
  input {
    String appBinDir
    String mode_choose
    String Y_lb_TF
    String input_model
    String input_file1
    String input_file2
    String rate
    String shuffle_TF
    String cv_TF
    String cv_times
    String cv_scoring
    String RF_diy_TF
    String RF_criterion
    String RF_max_depth
    String RF_min_samples_split
    String RF_class_weight
    String RF_n_estimators
    String cluster_config
    String mount_paths
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/RF1.py ~{mode_choose} ~{Y_lb_TF} ~{input_model} ~{input_file1} ~{input_file2} ~{rate} ~{shuffle_TF} ~{cv_TF} ~{cv_times} ~{cv_scoring} ~{RF_diy_TF} ~{RF_criterion} ~{RF_max_depth} ~{RF_min_samples_split} ~{RF_class_weight} ~{RF_n_estimators}
    >>>
  output {
    Array[File] outputFile = glob("*.zip")
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:python-3.9.12"
	cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 900
  }
}
workflow henbio_wf {
  call task_RF1
}