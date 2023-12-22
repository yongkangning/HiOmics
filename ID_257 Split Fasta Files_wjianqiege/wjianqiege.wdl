version 1.0

task task_wjianqiege {
  input {
    String inputfile
    String type
    String p
    String s
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    if [ "~{type}" == "type1" ]; then
    seqkit split ~{inputfile} -i -O result.spilt
    elif [ "~{type}" == "type2" ]; then
    seqkit split ~{inputfile} -p ~{p} -O result.spilt
    elif [ "~{type}" == "type3" ]; then
    seqkit split ~{inputfile} -s ~{s} -O result.spilt
    else
    echo "type must be one of type1 type2 type3."
    exit 111
    fi
    #mkdir ~{inputfile}.spilt
    #tar -czvf result.tar.gz ~{inputfile}.spilt
   >>>

  output {
  Array[File] outFile = glob("result.spilt/*.fa")
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-samtools-1-15"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 600
  }
}
workflow henbio_wf {
  call task_wjianqiege
}

