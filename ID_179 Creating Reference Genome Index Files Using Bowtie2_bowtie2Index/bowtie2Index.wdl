version 1.0

task task_bowtie2Index {
  input {
    String referenceGenome
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    
    if [[ "~{referenceGenome}" = *gz ]]
    then
      gunzip ~{referenceGenome}
      refFile=`echo ~{referenceGenome} | sed s'/.gz//'`
      echo "refFile:${refFile}"
    else
      refFile=~{referenceGenome}
      echo "refFile:${refFile}"
    fi

    mkdir bowtie2_index
    bowtie2-build ${refFile} bowtie2_index/bowtie2_index
    tar -czf bowtie2_index.tar.gz bowtie2_index
   >>>

  output {
    File outFile = "bowtie2_index.tar.gz"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:bowtie2-2-2-5"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 14400
  }
}
workflow henbio_wf {
  call task_bowtie2Index
}