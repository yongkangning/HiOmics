version 1.0

task task_XGB {
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
    String XGB_diy_TF
    String XGB_colsample_bytree
    String XGB_max_depth
    String XGB_min_child_weight
    String XGB_min_child_samples
    String XGB_n_estimators
    String XGB_num_leaves
    String XGB_objective
    String XGB_learning_rate
    String XGB_subsample
    String cluster_config
    String mount_paths
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/clf_XGB.py ~{mode_choose} ~{Y_lb_TF} ~{input_model} ~{input_file1} ~{input_file2} ~{rate} ~{shuffle_TF} ~{cv_TF} ~{cv_times} ~{cv_scoring} ~{XGB_diy_TF} ~{XGB_colsample_bytree} ~{XGB_max_depth} ~{XGB_min_child_weight} ~{XGB_min_child_samples} ~{XGB_n_estimators} ~{XGB_num_leaves} ~{XGB_objective} ~{XGB_learning_rate} ~{XGB_subsample}
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
  call task_XGB
}