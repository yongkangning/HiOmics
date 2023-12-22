version 1.0

task task_pdfjiami {
  input {
    String inputfile
    String type
    String mm
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    if [ "~{type}" == "128wei" ]; then
    pdftk ~{inputfile} output result.pdf user_pw ~{mm}
    elif [ "~{type}" == "40wei" ]; then
    pdftk ~{inputfile} output result.pdf encrypt_40bit ~{mm}
    else
    echo "type must be one of 128wei or 40wei."
    exit 111
    fi
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
    autoReleaseJob: true
    timeout: 600
  }
}
workflow henbio_wf {
  call task_pdfjiami
}

