version 1.0

task task_fastafastq2tab {
  input {
    String inputfileDir
    String type
    String cluster_config
    String mount_paths
}

  command <<<
    set -o pipefail
    set -e
    if [ "~{type}" == "fasta" ]; then
    seqkit fx2tab ~{inputfileDir} > result.tab.fa
    elif [ "~{type}" == "fastq" ]; then
    seqkit fx2tab ~{inputfileDir} > result.tab.fq
    else
    echo "type must be one of fasta or fastq."
    exit 111
    fi
    #mkdir result
    #tar -zcvf result.tar.gz result
    >>>


  output {
    File outFile1 = "result.tab.fa"
	File outFile2 = "result.tab.fq"
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
  call task_fastafastq2tab
}
