version 1.0

task task_duidie {
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
    String Stacking_diy_TF
    String cv_timess
    String cv_scoringgcv_scoringg
    String cluster_config
    String mount_paths
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/duidie.py ~{mode_choose} ~{Y_lb_TF} ~{input_model} ~{input_file1} ~{input_file2} ~{rate} ~{shuffle_TF} ~{cv_TF} ~{cv_times} ~{cv_scoring} ~{Stacking_diy_TF} ~{cv_timess} ~{cv_scoringgcv_scoringg}
    >>>
  output {
    Array[File] outputFile = glob("*.zip")
    Array[File] outFile = glob("output.*")
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:python-3.9.12"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 2000
  }
}
workflow henbio_wf {
  call task_duidie
}