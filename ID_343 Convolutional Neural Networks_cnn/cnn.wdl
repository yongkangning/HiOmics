version 1.0

task task_cnn {
  input {
    String appBinDir
    String img_width
    String img_height
    String batch_size
    String train_data_dir
    String optimizer
    String epochs
    String test_data_dir
    String predict_data_dir
    String cluster_config
    String mount_paths 	
  }

  command <<<
    python ~{appBinDir}/cnn.py ~{img_width} ~{img_height} ~{batch_size} ~{train_data_dir} ~{optimizer} ~{epochs} ~{test_data_dir} ~{predict_data_dir}
    >>>
  output {
    File outFile1 = 'cnn_model.keras'
	File outFile2 = 'predictions.txt'
	File outFile3 = 'bar_chart.png'
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-pyfordp-v1"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 7200
  }
}
workflow henbio_wf {
  call task_cnn
}