version 1.0

task task_pdfjiemi {
  input {
    String inputfile
    String foopass
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    pdftk ~{inputfile} input_pw ~{foopass} output unsecured.pdf
    #mkdir result
    #tar -czvf result.tar.gz result
   >>>

  output {
  File outFile = "unsecured.pdf"
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
  call task_pdfjiemi
}

