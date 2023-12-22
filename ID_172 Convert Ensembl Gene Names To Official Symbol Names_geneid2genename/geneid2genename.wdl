version 1.0

task task_geneid2genename {
  input {
    String inputFile1
    String inputFile2
    String outputFile
    String appDir
    String RLibPath
    String cluster_config
    String mount_paths
  }

command <<<
    set -o pipefail
    set -e
    /henbio/henbio_web/public/apps/tools/datacheck_v1.0 -i ~{inputFile1} -o geneCount_all_checked.txt -c true -d true -r true
    /henbio/henbio_web/public/apps/tools/datacheck_v1.0 -i ~{inputFile2} -o gTranscriptIDVersion2GeneName_checked.txt -c true -d true -r true
    Rscript ~{appDir}/geneid2genename.R ~{RLibPath} $(pwd)/geneCount_all_checked.txt $(pwd)/gTranscriptIDVersion2GeneName_checked.txt GeneCountMatrix.txt
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
  call task_geneid2genename
}