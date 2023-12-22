version 1.0

task task_perceptron {
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
    String perceptron_diy_TF
    String perceptron_penalty
    String perceptron_eta0
    String perceptron_fit_intercept
    String perceptron_tol
    String perceptron_alpha
    String perceptron_max_iter
    String cluster_config
    String mount_paths
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/clf_perceptron.py ~{mode_choose} ~{Y_lb_TF} ~{input_model} ~{input_file1} ~{input_file2} ~{rate} ~{shuffle_TF} ~{cv_TF} ~{cv_times} ~{cv_scoring} ~{perceptron_diy_TF} ~{perceptron_penalty} ~{perceptron_eta0} ~{perceptron_fit_intercept} ~{perceptron_tol} ~{perceptron_alpha} ~{perceptron_max_iter}
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
  call task_perceptron
}