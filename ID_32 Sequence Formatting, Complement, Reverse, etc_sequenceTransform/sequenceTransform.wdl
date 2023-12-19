task task_sequenceTransform {
  String appBinDir
  String inputFile
  String outputFile
  String transType
  String seqLength
  
  String cluster_config
  String mount_paths

  command <<<
    ${appBinDir}/sequenceTransform_v1.0 ${inputFile} ${outputFile} ${ transType} ${seqLength}
  >>>

  output {
    File outFile = "${outputFile}"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:debian-latest"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 600
  }
}
workflow henbio_wf {
  call task_sequenceTransform
  output{
    task_sequenceTransform.outFile
  }
}
