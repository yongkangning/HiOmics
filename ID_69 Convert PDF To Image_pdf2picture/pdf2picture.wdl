version 1.0

task task_pdf2picture {
  input {
    String inputFile
    String outputType
    String dpi
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    if test -d ~{inputFile}
    then
      echo "This a dir"
      find ~{inputFile} -type f -name "*.pdf" | while read line;
      do
        convert -density ~{dpi} -quality 100 ${line} $(basename ${line} .pdf).~{outputType}
      done
    else
      echo "This is a file."
      convert -density ~{dpi} -quality 100 ~{inputFile} $(basename ~{inputFile} .pdf).~{outputType}
    fi
    # 打包压缩
    tar -zcvf result.tar.gz *.~{outputType}

   >>>

  output {
    File outFiles = "result.tar.gz" # png jpg tif
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:zavolab-imagemagick-6-9-10"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 7200
  }
}
workflow henbio_wf {
  call task_pdf2picture
}