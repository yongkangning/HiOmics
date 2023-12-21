version 1.0

task task_salmon2matrix {
  input {
    String quantFile
    String tx2geneFile
    String appDir
    String RLibPath
    String cluster_config
    String mount_paths
  }

  command <<<

    set -o pipefail
    set -e
    
    Rscript ~{appDir}/salmon2matrix_v1.R ~{RLibPath} $(pwd) ~{quantFile} ~{tx2geneFile}

   >>>

  output {
    File outFile = "GeneCountMatrix.txt"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-r-base-4-2-0-v1"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 7200
  }
}
workflow henbio_wf {
  call task_salmon2matrix
}