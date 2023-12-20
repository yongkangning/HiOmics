version 1.0

task task_ANN2 {
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
    String ANN_diy_TF
    String ANN_activation
    String ANN_solver
    String ANN_alpha
    String ANN_max_iter
    String ANN_hidden_layer_sizes
    String ANN_learning_rate
    String ANN_learning_rate_init
    String cluster_config
    String mount_paths 
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/clf_ANN2.py ~{mode_choose} ~{Y_lb_TF} ~{input_model} ~{input_file1} ~{input_file2} ~{rate} ~{shuffle_TF} ~{cv_TF} ~{cv_times} ~{cv_scoring} ~{ANN_diy_TF} ~{ANN_activation} ~{ANN_solver} ~{ANN_alpha} ~{ANN_max_iter} ~{ANN_hidden_layer_sizes} ~{ANN_learning_rate} ~{ANN_learning_rate_init}
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
  call task_ANN2
}