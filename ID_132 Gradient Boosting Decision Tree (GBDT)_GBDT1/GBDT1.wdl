version 1.0

task task_GBDT1 {
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
    String GBDT_diy_TF
    String GBDT_loss
    String GBDT_learning_rate
    String GBDT_subsample
    String GBDT_n_estimators
    String GBDT_criterion
    String GBDT_max_depth
    String GBDT_min_samples_leaf
    String GBDT_min_samples_split
    String GBDT_max_features
    String cluster_config
    String mount_paths 
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/clf_GBDT1.py ~{mode_choose} ~{Y_lb_TF} ~{input_model} ~{input_file1} ~{input_file2} ~{rate} ~{shuffle_TF} ~{cv_TF} ~{cv_times} ~{cv_scoring} ~{GBDT_diy_TF} ~{GBDT_loss} ~{GBDT_learning_rate} ~{GBDT_subsample} ~{GBDT_n_estimators} ~{GBDT_criterion}~{GBDT_max_depth} ~{GBDT_min_samples_leaf}~{GBDT_min_samples_split} ~{GBDT_max_features}
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
  call task_GBDT1
}