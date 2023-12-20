version 1.0

task task_GNB {
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
    String NB_diy_TF
    String NB_var_smoothing
    String NB_priors
    String cluster_config
    String mount_paths 
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/clf_GNB.py ~{mode_choose} ~{Y_lb_TF} ~{input_model} ~{input_file1} ~{input_file2} ~{rate} ~{shuffle_TF} ~{cv_TF} ~{cv_times} ~{cv_scoring} ~{NB_diy_TF} ~{NB_var_smoothing} ~{NB_priors}
    >>>
  output {
    Array[File] outputFile = glob("*.zip")
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:python-3.9.12"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 1400
  }
}
workflow henbio_wf {
  call task_GNB
}