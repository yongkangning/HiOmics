version 1.0

task task_GBR {
  input {
    String appBinDir
    String choose
    String Y_lb
    String file
    String filet
    String model
    String rate
    String cvtime
    String shuffle
    String Zscore
    String cluster_config
    String mount_paths
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/main.py -choose ~{choose} -l ~{Y_lb} -fi ~{file} -model ~{model} -ra ~{rate} -cvtime ~{cvtime} -sf ~{shuffle} -Z ~{Zscore} -fit ~{filet}
  >>>
  output {
    File outFile2 = 'Linear.pkl'
    File outFile3 = 'load_model_report.txt'
    File outFile4 = 'ModelPredictData.txt'
    File outFile5 = 'GBR.svg'
    File outFile6 = 'GBR.svg'
    File outFile7 = 'report.txt'
    File outFile8 = 'report.txt'
    File outFile9 = 'Test_set.svg'
    File outFile10 = 'Training_set.svg'
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
  call task_GBR
}