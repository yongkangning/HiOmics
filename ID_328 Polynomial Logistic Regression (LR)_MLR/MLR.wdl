version 1.0

task task_MLR {
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
    String LR_diy_TF
    String LR_penalty
    String LR_multi_class
    String LR_C
    String LR_fi
    String LR_tol
    String LR_max_iter
    String LR_solver
    String cluster_config
    String mount_paths
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/clf_MLR.py ~{mode_choose} ~{Y_lb_TF} ~{input_model} ~{input_file1} ~{input_file2} ~{rate} ~{shuffle_TF} ~{cv_TF} ~{cv_times} ~{cv_scoring} ~{LR_diy_TF} ~{LR_penalty} ~{LR_multi_class} ~{LR_C} ~{LR_fi} ~{LR_tol} ~{LR_max_iter} ~{LR_solver}
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
  call task_MLR
}