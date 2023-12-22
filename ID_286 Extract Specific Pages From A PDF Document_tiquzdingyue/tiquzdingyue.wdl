version 1.0

task task_tiquzdingyue {
  input {
    String inputfile
    String yuema
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    pdftk ~{inputfile} cat ~{yuema} output result.pdf
    #mkdir result
    #tar -czvf result.tar.gz result
   >>>

  output {
  File outFile = "result.pdf"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-pdftk-3-2-2"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 600
  }
}
workflow henbio_wf {
  call task_tiquzdingyue
}

