version 1.0

task task_paixi {
  input {
    String inputfile
    String type
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    if [ "~{type}" == "type1" ]; then
    seqkit sort --quiet ~{inputfile} > result
    elif [ "~{type}" == "type2" ]; then
    seqkit sort --quiet --ignore-case ~{inputfile} > result
    elif [ "~{type}" == "type3" ]; then
    seqkit sort --by-seq ~{inputfile} > result
    elif [ "~{type}" == "type4" ]; then
    seqkit sort --by-seq --ignore-case ~{inputfile}  > result
    elif [ "~{type}" == "type5" ]; then
    seqkit sort --by-length ~{inputfile}  > result
    elif [ "~{type}" == "type6" ]; then
    seqkit sort --reverse ~{inputfile}  > result
    elif [ "~{type}" == "type7" ]; then
    seqkit sort --by-name ~{inputfile}  > result
    else
    echo "type must be one of type1 type2 type3 type4 type5 type6 type7."
    exit 111
    fi
    #mkdir result
    #tar -czvf result.tar.gz result
   >>>

  output {
  File outFile1 = "result"
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
  call task_paixi
}

