version 1.0

task task_KNNN {
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
    String KNN_diy_TF
    String KNN_n_neighbors
    String KNN_algorithm
    String KNN_metric
    String KNN_leaf_size
    String cluster_config
    String mount_paths 
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/clf_KNNN.py ~{mode_choose} ~{Y_lb_TF} ~{input_model} ~{input_file1} ~{input_file2} ~{rate} ~{shuffle_TF} ~{cv_TF} ~{cv_times} ~{cv_scoring} ~{KNN_diy_TF} ~{KNN_n_neighbors} ~{KNN_algorithm} ~{KNN_metric} ~{KNN_leaf_size}
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
  call task_KNNN
}