version 1.0

task task_SVC2 {
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
    String svc_diy_TF
    String svc_c
    String svc_kernel
    String svc_tol
    String svc_max_iter
    String svc_dfs
    String cluster_config
    String mount_paths
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/clf_SVC3.py ~{mode_choose} ~{Y_lb_TF} ~{input_model} ~{input_file1} ~{input_file2} ~{rate} ~{shuffle_TF} ~{cv_TF} ~{cv_times} ~{cv_scoring} ~{svc_diy_TF} ~{svc_c} ~{svc_kernel} ~{svc_tol} ~{svc_max_iter} ~{svc_dfs}
    >>>
  output {
    Array[File] outputFile = glob("*.zip")
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:python-3.9.12"
	cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 1800
  }
}
workflow henbio_wf {
  call task_SVC2
}