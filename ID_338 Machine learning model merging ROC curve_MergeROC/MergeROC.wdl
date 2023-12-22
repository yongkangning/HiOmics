version 1.0

task task_MergeROC {
  input {
    String appBinDir
    String input_file1
	String model_folder_path
    String cluster_config
    String mount_paths
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/MergeROC.py ~{input_file1} ~{model_folder_path}
    >>>
  output {
    Array[File] outputFile = glob("*.svg")
    File outFile1 = '*.svg'
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:python-3.9.12"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 1200
  }
}
workflow henbio_wf {
  call task_MergeROC
}