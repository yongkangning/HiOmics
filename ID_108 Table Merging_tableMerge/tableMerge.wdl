version 1.0

task task_tableMerge {
  input {
    String inputFile
    String separatorType
    String joinType
    String nullValue
    String cluster_config
    String mount_paths
  }

  command <<<

    set -o pipefail
    set -e
    
    if [ "~{nullValue}" == " " ]; then
      /henbio/henbio_web/public/apps/tools/csvtk_v1.0 ~{separatorType} join ~{joinType}  ~{inputFile} > result.txt
    else
      /henbio/henbio_web/public/apps/tools/csvtk_v1.0 ~{separatorType} join ~{joinType} --na ~{nullValue} ~{inputFile} > result.txt
    fi

   >>>

  output {
    File outFile = "result.txt"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-transform-tools-v2-0"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 7200
  }
}
workflow henbio_wf {
  call task_tableMerge
}