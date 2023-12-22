version 1.0

task task_picrust2FunctionalPrediction {
  input {
    String otuFastaFile
    String otuAbundanceFile
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    
    source activate picrust2
    cpu_cores=$(nproc)
    picrust2_pipeline.py -s ~{otuFastaFile} -i ~{otuAbundanceFile} -o picrust2_result -p ${cpu_cores}
    tar -zcf picrust2_result.tar.gz picrust2_result
   >>>

  output {
    File outFile = "picrust2_result.tar.gz"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:picrust2-2-5-1"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 36000
  }
}
workflow henbio_wf {
  call task_picrust2FunctionalPrediction
}